# Neovide built from a nightly commit. Released Neovide (0.16.2) can't parse the
# API info of Neovim nightly (neovide#3528), so this tracks nightly alongside
# neovim-nightly-overlay. Nightly moved rust-skia from 0.93 to 0.153, which
# needs a newer skia checkout and externals than nixpkgs carries.
#
# To bump: set `rev` + `hash`, check the skia-bindings version in the new
# Cargo.lock, look up its `package.metadata.skia` tag, regenerate
# skia-externals.json from that tag's DEPS, then fix `cargoHash`.
{
  lib,
  neovide,
  fetchFromGitHub,
  fetchgit,
  linkFarm,
  runCommand,
  rustPlatform,
}:

neovide.overrideAttrs (finalAttrs: prev: {
  version = "0.16.2-nightly-3f0fcc0";

  src = fetchFromGitHub {
    owner = "neovide";
    repo = "neovide";
    rev = "3f0fcc0d18a088e6c8cef16cb3c47db3439cfca5";
    hash = "sha256-aDUs0IOOCjKfs7S59MBZ4PJjwwb8woXimSKLR1Kmf3Q=";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    name = "neovide-${finalAttrs.version}";
    hash = "sha256-wYuJxxNPl7pUY/lkVMUoKceBJFDHgGrusYKoUTmoRIM=";
  };

  env = prev.env // {
    SKIA_SOURCE_DIR =
      let
        repo = fetchFromGitHub {
          owner = "rust-skia";
          repo = "skia";
          # skia-bindings 0.153.3 -> package.metadata.skia
          tag = "m153-0.101.2";
          hash = "sha256-xKCkvQoTAMlLvKdVzzSxTST6kER4kRUIDjvTRZ9z72o=";
        };
        externals = linkFarm "skia-externals" (
          lib.mapAttrsToList (name: value: {
            inherit name;
            path = fetchgit value;
          }) (lib.importJSON ./skia-externals.json)
        );
      in
      runCommand "source" { } ''
        cp -R ${repo} $out
        chmod -R +w $out
        ln -s ${externals} $out/third_party/externals
      '';
  };

  # Custom Icon Composer icon, precompiled with actool (see icons/Neovide/README.md)
  # since the sandboxed build has no Xcode.
  postInstall = prev.postInstall + ''
    res=$out/Applications/Neovide.app/Contents/Resources
    cp ${../../icons/Neovide/compiled/Assets.car} $res/Assets.car
    cp ${../../icons/Neovide/compiled/AppIcon.icns} $res/AppIcon.icns
    substituteInPlace $out/Applications/Neovide.app/Contents/Info.plist \
      --replace-fail '<string>Neovide.icns</string>' \
        '<string>AppIcon</string><key>CFBundleIconName</key><string>AppIcon</string>'
  '';

  # The test suite spawns nvim; skip it rather than pin a matching one.
  doCheck = false;
})
