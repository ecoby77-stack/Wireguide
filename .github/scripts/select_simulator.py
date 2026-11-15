#!/usr/bin/env python3
"""Pick or create an iOS 17+ iPhone simulator and write its id to GITHUB_OUTPUT."""

import json
import os
import subprocess
import sys

PREFERRED = [
    "iPhone 17 Pro",
    "iPhone 17",
    "iPhone 16 Pro",
    "iPhone 16",
    "iPhone 15 Pro",
    "iPhone 15",
    "iPhone 14 Pro",
    "iPhone 14",
    "iPhone 13",
    "iPhone SE (3rd generation)",
]


def simctl(*args):
    return subprocess.check_output(["xcrun", "simctl", *args], text=True)


def runtime_version(identifier):
    if not identifier or ("iOS-" not in identifier and "iOS " not in identifier):
        return None
    tail = identifier.split("iOS-")[-1] if "iOS-" in identifier else identifier.split("iOS ")[-1]
    parts = []
    for piece in tail.replace(".", "-").split("-"):
        if piece.isdigit():
            parts.append(int(piece))
        elif parts:
            break
    if not parts:
        return None
    while len(parts) < 3:
        parts.append(0)
    return tuple(parts[:3])


def rank_device(name, version):
    try:
        pref = PREFERRED.index(name)
    except ValueError:
        pref = len(PREFERRED) + 1
    return (pref, -version[0], -version[1], -version[2], name)


def choose_existing():
    data = json.loads(simctl("list", "devices", "available", "-j"))
    found = []
    for runtime, devices in data.get("devices", {}).items():
        version = runtime_version(runtime)
        if not version or version[0] < 17:
            continue
        for device in devices:
            if not device.get("isAvailable", True):
                continue
            name = device.get("name", "")
            if not name.startswith("iPhone"):
                continue
            found.append((name, device["udid"], version, runtime))
    if not found:
        return None
    found.sort(key=lambda item: rank_device(item[0], item[2]))
    return found[0]


def _supported_names(runtime):
    supported = set()
    for entry in runtime.get("supportedDeviceTypes", []):
        if isinstance(entry, str):
            supported.add(entry)
        elif isinstance(entry, dict):
            if entry.get("name"):
                supported.add(entry["name"])
            if entry.get("identifier"):
                supported.add(entry["identifier"])
    return supported


def create_device():
    runtimes = json.loads(simctl("list", "runtimes", "-j")).get("runtimes", [])
    usable = []
    for runtime in runtimes:
        if runtime.get("isAvailable") is False:
            continue
        ident = runtime.get("identifier", "")
        version = runtime_version(ident) or runtime_version(str(runtime.get("version", "")))
        if not version or version[0] < 17:
            continue
        usable.append((version, ident, runtime))
    if not usable:
        print("No available iOS 17+ simulator runtime", file=sys.stderr)
        print(simctl("list", "runtimes"), file=sys.stderr)
        sys.exit(1)
    usable.sort(reverse=True)
    version, runtime_id, runtime = usable[0]
    supported = _supported_names(runtime)
    types = json.loads(simctl("list", "devicetypes", "-j")).get("devicetypes", [])
    iphones = [item for item in types if str(item.get("name", "")).startswith("iPhone")]

    def acceptable(device_type):
        name = device_type.get("name", "")
        ident = device_type.get("identifier", "")
        return not supported or name in supported or ident in supported

    chosen = None
    for want in PREFERRED:
        for device_type in iphones:
            if device_type.get("name") == want and acceptable(device_type):
                chosen = device_type
                break
        if chosen:
            break
    if chosen is None:
        for device_type in iphones:
            if acceptable(device_type):
                chosen = device_type
                break
    if chosen is None:
        print("No iPhone simulator device type installed", file=sys.stderr)
        print(simctl("list", "devicetypes"), file=sys.stderr)
        sys.exit(1)

    name = chosen["name"]
    ident = chosen["identifier"]
    print(f"Creating {name} on {runtime_id}")
    created = simctl("create", "WireGuide iPhone", ident, runtime_id).strip().splitlines()
    udid = created[-1].strip()
    return name, udid, version, runtime_id


def main():
    selected = choose_existing()
    if selected:
        name, udid, version, runtime = selected
        print(f"Selected existing {name} ({udid}) iOS {version} runtime {runtime}")
    else:
        name, udid, version, runtime = create_device()
        print(f"Created {name} ({udid}) iOS {version}")

    output = os.environ.get("GITHUB_OUTPUT")
    if not output:
        print("GITHUB_OUTPUT is not set", file=sys.stderr)
        sys.exit(1)
    with open(output, "a", encoding="utf-8") as handle:
        handle.write(f"device_id={udid}\n")
        handle.write(f"device_name={name}\n")


if __name__ == "__main__":
    main()
