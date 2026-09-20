# Neovide app icon (macOS 26+ Icon Composer)

`AppIcon.icon` is an Icon Composer bundle built from the upstream Neovide logo
(`source-neovide.svg`), split into two layers:

- `Assets/gear.svg` — the dark cog ring (`path434` + `path849`)
- `Assets/mark.svg` — the blue/green Neovim N (`Left---green`, `Right---blue`, `Cross---blue`, `Shadow`)

Artwork is scaled to 88% of a 1024x1024 canvas and centred. Both groups are
opaque (translucency off) so the mark stays saturated in the default appearance.

Open it with Icon Composer (in Xcode.app/Contents/Applications) to tweak.

## Rebuild + install

```sh
cd ~/dotfiles/icons/Neovide
mkdir -p build
xcrun actool AppIcon.icon --compile build --app-icon AppIcon \
  --output-partial-info-plist build/p.plist \
  --platform macosx --minimum-deployment-target 26.0 --errors --warnings

cp build/Assets.car build/AppIcon.icns /Applications/Neovide.app/Contents/Resources/
/usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" /Applications/Neovide.app/Contents/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleIconName AppIcon" /Applications/Neovide.app/Contents/Info.plist

# bundle edits break the Developer ID signature; re-sign ad-hoc
codesign --force --sign - --preserve-metadata=entitlements,requirements,flags /Applications/Neovide.app
xattr -dr com.apple.quarantine /Applications/Neovide.app

/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f /Applications/Neovide.app
killall Dock
```

Note: a Neovide upgrade replaces the bundle and reverts this. Re-run the block above.

`--app-icon` must match the bundle's basename, i.e. the directory has to be
called `AppIcon.icon`, or actool silently compiles nothing.

## Why there's also a dock-icon.png

`src/window/mod.rs` in Neovide calls `with_window_icon(Some(icon))` under
`#[cfg(target_family = "unix")]` — which macOS matches — and winit's macOS
backend implements that as `NSApp.setApplicationIconImage:`. So once the window
finishes opening, the running app overwrites the bundle icon with the embedded
`assets/neovide.ico`. `load_icon` always returns an icon (it falls back to the
embedded one), so there is no way to tell it to leave the bundle icon alone.

Workaround: `~/.config/neovide/config.toml` sets `icon` to `dock-icon.png`,
which is the bundle icon rendered out via `NSWorkspace.icon(forFile:)`.

Caveat: that PNG is a static bake of whatever icon appearance was active when
it was rendered (Clear/dark, matching `AppleIconAppearanceTheme`). Finder,
Spotlight, Launchpad and the pre-launch Dock tile all use the real tintable
icon and follow the system live; only the Dock tile of the *running* app is
frozen. Re-render after changing icon style:

```sh
# see shot3.swift in the session scratchpad, or:
swiftc -O shot3.swift -o shot3 && ./shot3 /Applications/Neovide.app \
  ~/dotfiles/icons/Neovide/dock-icon.png 1024
```
