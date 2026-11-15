#!/usr/bin/env python3
"""Reject blank, white, or non-portrait simulator screenshots.

Exits 0 when the image looks like a rendered dark UI. Prints size and
luminance stats either way so a failing log is enough to retune thresholds.
"""

import struct
import sys
import zlib


def read_png(path):
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise SystemExit("not a png")
    pos = 8
    width = height = color_type = interlace = None
    idat = b""
    while pos + 8 <= len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        tag = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        pos += 12 + length
        if tag == b"IHDR":
            width, height, bit_depth, color_type, _comp, _filt, interlace = struct.unpack(
                ">IIBBBBB", chunk
            )
            if bit_depth != 8 or color_type not in (2, 6) or interlace != 0:
                raise SystemExit(
                    f"unsupported png bit={bit_depth} color={color_type} interlace={interlace}"
                )
        elif tag == b"IDAT":
            idat += chunk
        elif tag == b"IEND":
            break
    if width is None or not idat:
        raise SystemExit("incomplete png")
    return width, height, color_type, zlib.decompress(idat)


def paeth(left, up, up_left):
    estimate = left + up - up_left
    pa, pb, pc = abs(estimate - left), abs(estimate - up), abs(estimate - up_left)
    if pa <= pb and pa <= pc:
        return left
    if pb <= pc:
        return up
    return up_left


def decode_rows(width, height, color_type, raw):
    channels = 3 if color_type == 2 else 4
    stride = width * channels
    rows = []
    prev = bytearray(stride)
    index = 0
    expected = height * (stride + 1)
    if len(raw) < expected:
        raise SystemExit(f"short png data {len(raw)} < {expected}")
    for _y in range(height):
        filter_type = raw[index]
        index += 1
        row = bytearray(raw[index:index + stride])
        index += stride
        for x in range(stride):
            left = row[x - channels] if x >= channels else 0
            up = prev[x]
            up_left = prev[x - channels] if x >= channels else 0
            if filter_type == 0:
                value = row[x]
            elif filter_type == 1:
                value = (row[x] + left) & 255
            elif filter_type == 2:
                value = (row[x] + up) & 255
            elif filter_type == 3:
                value = (row[x] + ((left + up) // 2)) & 255
            elif filter_type == 4:
                value = (row[x] + paeth(left, up, up_left)) & 255
            else:
                raise SystemExit(f"bad filter {filter_type}")
            row[x] = value
        prev = row
        rows.append(row)
    return channels, rows


def luminance_stats(path):
    width, height, color_type, raw = read_png(path)
    channels, rows = decode_rows(width, height, color_type, raw)
    step = 4
    samples = []
    for y in range(0, height, step):
        row = rows[y]
        for x in range(0, width, step):
            i = x * channels
            red, green, blue = row[i], row[i + 1], row[i + 2]
            samples.append(0.2126 * red + 0.7152 * green + 0.0722 * blue)
    samples.sort()
    mean = sum(samples) / len(samples)
    spread = samples[int(len(samples) * 0.95)] - samples[int(len(samples) * 0.05)]
    return width, height, mean, spread, len(samples)


def evaluate(path):
    width, height, mean, spread, count = luminance_stats(path)
    print(f"size={width}x{height} mean={mean:.1f} spread={spread:.1f} samples={count}")
    if width < 300 or height < 500 or height <= width:
        print("reject: expected a portrait phone screenshot")
        return 2
    # Flat black, flat gray, or a white launch screen.
    if spread < 12 or mean > 210 or mean < 3:
        print("reject: frame looks blank")
        return 3
    return 0


def main():
    if len(sys.argv) != 2:
        print("usage: check_screenshot.py screenshot.png", file=sys.stderr)
        return 1
    try:
        return evaluate(sys.argv[1])
    except SystemExit as exc:
        print(exc, file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
