#!/usr/bin/env python3
"""Pad a Mach-O dylib so LC_SYMTAB.stroff is 8-byte aligned.

macOS 26's dyld rejects images whose LINKEDIT string pool starts on a
non-8-aligned file offset ("mis-aligned LINKEDIT string pool"). Both Apple ld
and lld can emit stroff at 4 mod 8. This inserts zero padding immediately
before the string pool and shifts every LINKEDIT offset at or after it.
"""
import struct
import sys

MH_MAGIC_64 = 0xFEEDFACF
LC_REQ_DYLD = 0x80000000
LC_SEGMENT_64 = 0x19
LC_SYMTAB = 0x02
LC_DYSYMTAB = 0x0B
LC_DYLD_INFO = 0x22
LC_DYLD_INFO_ONLY = 0x22 | LC_REQ_DYLD
# linkedit_data_command kinds: (dataoff, datasize)
LINKEDIT_DATA = {
    0x1D,  # LC_CODE_SIGNATURE
    0x1E,  # LC_SEGMENT_SPLIT_INFO
    0x26,  # LC_FUNCTION_STARTS
    0x29,  # LC_DATA_IN_CODE
    0x2B,  # LC_DYLIB_CODE_SIGN_DRS
    0x2E,  # LC_LINKER_OPTIMIZATION_HINT
    0x33 | LC_REQ_DYLD,  # LC_DYLD_EXPORTS_TRIE
    0x34 | LC_REQ_DYLD,  # LC_DYLD_CHAINED_FIXUPS
}


def align(path, out):
    buf = bytearray(open(path, "rb").read())
    magic, _, _, _, ncmds, _, _, _ = struct.unpack_from("<8I", buf, 0)
    if magic != MH_MAGIC_64:
        sys.exit(f"not a 64-bit little-endian Mach-O: {magic:#x}")

    # locate stroff
    off, stroff = 32, None
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from("<2I", buf, off)
        if cmd == LC_SYMTAB:
            stroff = struct.unpack_from("<I", buf, off + 16)[0]
        off += cmdsize
    if stroff is None:
        sys.exit("no LC_SYMTAB")

    # locate strsize alongside stroff
    off = 32
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from("<2I", buf, off)
        if cmd == LC_SYMTAB:
            strsize = struct.unpack_from("<I", buf, off + 20)[0]
        off += cmdsize

    # dyld wants every LINKEDIT chunk 8-aligned, so pad both before the string
    # pool (to align its start) and after it (to align whatever follows).
    pad = (-stroff) % 8
    strend = stroff + pad + strsize
    pad2 = (-strend) % 8
    if pad == 0 and pad2 == 0:
        print(f"stroff {stroff:#x} and string-pool end already 8-aligned; nothing to do")
        open(out, "wb").write(bytes(buf))
        return 0

    def bump(o):
        """Offsets shift by whichever insertion points precede them."""
        if o >= stroff:
            o += pad
        if o >= strend:
            o += pad2
        return o

    # rewrite every load-command offset that points into the file
    off = 32
    for _ in range(ncmds):
        cmd, cmdsize = struct.unpack_from("<2I", buf, off)
        if cmd == LC_SEGMENT_64:
            segname = buf[off + 8 : off + 24].rstrip(b"\0")
            fileoff, filesize = struct.unpack_from("<2Q", buf, off + 40)
            if segname == b"__LINKEDIT":
                struct.pack_into("<Q", buf, off + 48, filesize + pad + pad2)
                vmsize = struct.unpack_from("<Q", buf, off + 32)[0]
                struct.pack_into("<Q", buf, off + 32, vmsize + pad + pad2)
            elif fileoff >= stroff:
                struct.pack_into("<Q", buf, off + 40, bump(fileoff))
        elif cmd == LC_SYMTAB:
            symoff, nsyms, so, ss = struct.unpack_from("<4I", buf, off + 8)
            struct.pack_into("<4I", buf, off + 8, bump(symoff), nsyms, so + pad, ss + pad2)
        elif cmd == LC_DYSYMTAB:
            vals = list(struct.unpack_from("<18I", buf, off + 8))
            for i in (6, 8, 10, 12, 14, 16):  # *off fields
                if vals[i]:
                    vals[i] = bump(vals[i])
            struct.pack_into("<18I", buf, off + 8, *vals)
        elif cmd in (LC_DYLD_INFO, LC_DYLD_INFO_ONLY):
            vals = list(struct.unpack_from("<10I", buf, off + 8))
            for i in (0, 2, 4, 6, 8):  # rebase/bind/weak/lazy/export offs
                if vals[i]:
                    vals[i] = bump(vals[i])
            struct.pack_into("<10I", buf, off + 8, *vals)
        elif cmd in LINKEDIT_DATA:
            dataoff, datasize = struct.unpack_from("<2I", buf, off + 8)
            if dataoff:
                struct.pack_into("<I", buf, off + 8, bump(dataoff))
        off += cmdsize

    # insert the later padding first so the earlier offset stays valid
    buf[strend:strend] = b"\0" * pad2
    buf[stroff:stroff] = b"\0" * pad
    open(out, "wb").write(bytes(buf))
    print(f"padded {pad} before / {pad2} after: stroff {stroff:#x} -> {stroff + pad:#x}")
    return 0


if __name__ == "__main__":
    src = sys.argv[1]
    dst = sys.argv[2] if len(sys.argv) > 2 else src
    sys.exit(align(src, dst))
