#!/bin/sh
# Build blink.cmp's Rust fuzzy matcher from source and fix its Mach-O layout.
#
# macOS 26's dyld rejects images whose __LINKEDIT chunks aren't 8-byte aligned
# ("mis-aligned LINKEDIT string pool"). Both Apple ld and lld emit blink's
# string pool at 4 mod 8, so the upstream prebuilt binaries and plain `cargo
# build` output both fail to dlopen. align_linkedit.py pads them straight.
set -eu

dir="${1:?usage: build-blink-fuzzy.sh <blink.cmp dir>}"
cd "$dir"

cargo build --release

lib=target/release/libblink_cmp_fuzzy.dylib
[ -f "$lib" ] || { echo "build produced no $lib" >&2; exit 1; }

commit=$(git rev-parse HEAD 2>/dev/null | cut -c1-7)
out="lib/libblink_cmp_fuzzy.dylib${commit:+.$commit}"
mkdir -p lib

case "$(uname -s)" in
  Darwin)
    codesign --remove-signature "$lib" 2>/dev/null || true
    python3 "$(dirname "$0")/align_linkedit.py" "$lib" "$out"
    codesign -f -s - "$out"
    ;;
  *)
    cp "$lib" "$out"
    ;;
esac

echo "installed $out"
