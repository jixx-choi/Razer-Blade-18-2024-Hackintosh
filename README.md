# Razer Blade 18 (2024) Hackintosh — OpenCore EFI

<p align="left">
  <img src="https://dl.razerzone.com/src2/14072/14072-1-en-v1.png" alt="Razer Blade 18 (2024)" width="200">
</p>

OpenCore EFI for the **Razer Blade 18 (2024, RZ09-0509)** running **macOS Tahoe 26** with the RTX 4080 Laptop GPU accelerated by the [NullMoth](https://github.com/nullmoth/nvidia-macos-driver) NVIDIA driver.

> ⚠️ This EFI is tuned for one specific machine. Use it as a reference, generate your **own** SMBIOS serials, and back up your working EFI before trying it.

## Hardware

| Component | Model | Status |
|---|---|---|
| Laptop | Razer Blade 18 (2024), RZ09-0509 |  |
| CPU | Intel Core i9-14900HX (Raptor Lake-HX, 8P + 16E) | ✅ Working |
| dGPU | NVIDIA GeForce RTX 4080 Laptop (10de:27e0) | ✅ Accelerated (NullMoth) |
| iGPU | Intel UHD Graphics (8086:A788) | ❌ Not supported by macOS |
| Display | BOE NE180QDM-NM1, 18" 2560×1600 Mini-LED | ✅ Working (see notes) |
| Audio | Realtek HDA codec, AppleALC `alcid=13` | ✅ Speakers working (see notes) |
| Wi-Fi | Intel Wi-Fi 7 BE200 (320MHz, 802.11a/b/g/n/ac/ax/be) | ❌ Not working (card swap planned) |
| Bluetooth | Intel BE200 Bluetooth<br> (IntelBluetoothFirmware + IntelBTPatcher + BlueToolFixup) | ✅ Working |
| Ethernet | Realtek RTL8125 2.5GbE (RTL812xLucy) | ✅ Working |
| Memory | DDR5-5600 SO-DIMM 16GB*2<br> Samsung M425R2GA3BB0-CWMOD |  |
| Trackpad | I2C HID<br> (VoodooI2C + VoodooI2CHID, polling mode) | ✅ Working |
| SD Card Reader | Realtek PCIE CardReader<br> (VEN_10EC & DEV_525A)| ❓ Not Tested |
| SSD 1	| Samsung PM9A1 1 TB (MZVL21T0HCLR)| ✅ Windows 11 Installed |
| SSD 2 | Samsung PM981 256 GB (MZVLB256HAHQ) | ✅ Mac OS Installed |

## Software

| Item | Version |
|---|---|
| macOS | Tahoe 26.7.1 |
| SMBIOS | MacBookPro16,2 |
| Bootloader | OpenCore — see [`docs/kexts.md`](docs/kexts.md) |
| NVIDIA driver | NullMoth 2.5.x |

The full kext list with versions is in [`docs/kexts.md`](docs/kexts.md).

## What works

- [x] RTX 4080 Laptop acceleration (Metal) via NullMoth
- [x] Native 2560×1600 at 60 / 240 / 300 Hz
- [x] **Backlight control** (NBCI `_DSM` with an ACPI patch, see below)
- [x] Built-in speakers (AppleALC layout 13 + speaker amp init script)
- [x] Battery status and charging, including USB-C PD charging
- [x] CPU name in *About This Mac* (RestrictEvents)
- [x] Display name and native color profile (display override)

## What doesn't work / known issues

- [ ] **Intel iGPU**: Raptor Lake-HX UHD is not supported by macOS.
- [ ] **Sleep**: wake reboots the machine, so sleep is disabled (`pmset`).
- [ ] **Wi-Fi**: stock Intel card. Needs a replacement.
- [ ] **HiDPI scaled modes** (e.g. 2048×1280 Retina): they validate in the driver but don't appear in the mode list (reported to NullMoth).
- [ ] **Custom refresh rates** (e.g. 120 Hz): only EDID modes are accepted.
- [ ] **HDR**: works on Windows and the panel reports HDR support in its EDID, but the NullMoth driver currently exposes SDR only, so HDR is not available on macOS.
- [ ] Brightness resets to 100% on every boot

## Key configuration

### Backlight (ACPI patch)

The NBCI backlight methods return an empty package because of the package count in the OEM SSDT. Patch it under `ACPI → Patch`:

| Comment | Find | Replace | OemTableId | TableSignature | Count |
|---|---|---|---|---|---|
| BLPG package count | `QkxQRxJEBiA=` | `QkxQRxJEBgc=` | `T2VtTnYyVAA=` | `U1NEVA==` | 1 |
| MLBL package count | `TUxCTBJDBiA=` | `TUxCTBJDBgc=` | `T2VtTnYyVAA=` | `U1NEVA==` | 1 |

Then add `nvrmacpibl=1` to boot-args.

### Boot-args

```
nvrmacpibl=1 alcid=13 alcverbs=1 nvfb=1 nvaccel=1 nvfbheads=4 -nvkmsnosmooth
amfi_get_out_of_my_way=0x1 amfi=0x80 ipc_control_port_options=0
revpatch=sbvmm,cpuname revcpu=1 ctrsmt=full -ibtcompatbeta -vi2c-force-polling
debug=0x100 keepsyms=1
```

| Arg | Purpose |
|---|---|
| `nvrmacpibl=1` | Backlight through ACPI NBCI (NullMoth) |
| `alcid=13`, `alcverbs=1` | AppleALC layout for this codec |
| `nvfb=1 nvaccel=1 nvfbheads=4 -nvkmsnosmooth` | NullMoth framebuffer and acceleration |
| `amfi_get_out_of_my_way=0x1 amfi=0x80 ipc_control_port_options=0` | Required by NullMoth |
| `revpatch=sbvmm,cpuname revcpu=1` | RestrictEvents: OTA updates + CPU name |
| `ctrsmt=full` | CpuTopologyRebuild: P-core / E-core topology |
| `-ibtcompatbeta` | IntelBluetoothFirmware on newer macOS |
| `-vi2c-force-polling` | VoodooI2C trackpad in polling mode |
| `debug=0x100 keepsyms=1` | Keep panic logs readable (optional) |

### Speakers

Layout 13 enables the codec, but the speaker amplifiers need extra verbs after every boot. [`Extras/speakers`](Extras/speakers) contains a LaunchDaemon that sends them at boot (requires `alc-verb` from AppleALC).

```bash
cd Extras/speakers && sudo bash install.sh
```

### Sleep

```bash
sudo pmset -a sleep 0 hibernatemode 0 standby 0 autopoweroff 0
```

## Installation

1. Generate your own SMBIOS (**MacBookPro16,2**) with [GenSMBIOS](https://github.com/corpnewt/GenSMBIOS) and fill `PlatformInfo → Generic` (`SystemSerialNumber`, `MLB`, `SystemUUID`, `ROM`). The values in this repo are blank.
2. Copy `EFI` to the EFI partition of your USB drive or SSD.
3. Install NullMoth by following its own instructions.
4. Install the speaker script from `Extras/speakers`.

## BIOS settings

Razer's BIOS exposes very few options. These are the ones that matter:

| Setting | Value |
|---|---|
| BIOS version | 1.04 / EC 1.2 |
| Secure Boot | Disabled |
| Undervolting Protection | Disabled |
| GPU Mode (MUX) | **Discrete / dGPU only**, set in Razer Synapse on Windows. Required: the internal display must be wired to the RTX 4080. |
| CFG Lock | Not exposed in BIOS, handled with `AppleXcpmCfgLock` in config.plist |

## Credits

- [Acidanthera](https://github.com/acidanthera): OpenCore, Lilu, AppleALC, VirtualSMC, RestrictEvents, BrightnessKeys, NVMeFix, BlueToolFixup ([BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM))
- [NullMoth](https://github.com/nullmoth/nvidia-macos-driver): NVIDIA driver for macOS
- [OpenIntelWireless/IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware): IntelBluetoothFirmware, IntelBTPatcher
- [Mieze/RTL812xLucy](https://github.com/Mieze/RTL812xLucy): Realtek RTL8125 Ethernet
- [VoodooI2C](https://github.com/VoodooI2C/VoodooI2C): I2C trackpad
- [b00t0x/CpuTopologyRebuild](https://github.com/b00t0x/CpuTopologyRebuild): hybrid CPU topology
- [1Revenger1/ECEnabler](https://github.com/1Revenger1/ECEnabler): battery EC reads
- [cholonam/Sinetek-rtsx](https://github.com/cholonam/Sinetek-rtsx): Realtek card reader
- [USBToolBox](https://github.com/USBToolBox/kext): USB
- [RehabMan/OS-X-USB-Inject-All](https://github.com/RehabMan/OS-X-USB-Inject-All): XHCI-unsupported
- [Dortania](https://github.com/dortania): OpenCore Install Guide, AMFIPass (from OpenCore Legacy Patcher)
- Speaker verb sequence adapted from [yadu-tv/rb14-2023-audio-fix](https://github.com/yadu-tv/rb14-2023-audio-fix)

