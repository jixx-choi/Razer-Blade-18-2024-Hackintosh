# Kexts, ACPI and drivers

OpenCore: `DBG-109-2026-10-19`

## Kexts

| Kext | Version | Enabled |
|---|---|---|
| Lilu | 1.7.3 | true |
| AMFIPass | 1.4.1 | true |
| BlueToolFixup | 2.7.3 | true |
| BrightnessKeys | ? | true |
| CpuTopologyRebuild | 2.0.2 | true |
| ECEnabler | 1.0.6 | true |
| IntelBTPatcher | 2.5.0 | true |
| IntelBluetoothFirmware | 2.5.0 | true |
| NVMeFix | 1.1.4 | true |
| RTL812xLucy | 1.1.1 | true |
| RestrictEvents | 1.1.7 | true |
| VirtualSMC | 1.3.9 | true |
| SMCBatteryManager | 1.3.9 | true |
| SMCLightSensor | 1.3.9 | true |
| SMCProcessor | 1.3.9 | true |
| SMCSuperIO | 1.3.9 | true |
| Sinetek-rtsx | 9.0.0 | true |
| USBToolBox | ? | true |
| UTBDefault | 1.0 | true |
| VoodooI2C.kext/Contents/PlugIns/VoodooI2CServices | 1.0 | true |
| VoodooI2C.kext/Contents/PlugIns/VoodooGPIO | 1.1 | true |
| VoodooI2C.kext/Contents/PlugIns/VoodooInput | 1.1.7 | true |
| VoodooI2C | 2.9.1 | true |
| VoodooI2CHID | 1.0 | true |
| WhateverGreen | 1.7.2 | false |
| XHCI-unsupported | 0.9.2 | true |
| AppleALC | 1.9.8 | true |

## ACPI

- SSDT-Disable_Network_RP08.aml
- SSDT-EC.aml
- SSDT-GPI0.aml
- SSDT-MCHC.aml
- SSDT-PLUG-ALT.aml
- SSDT-RTCAWAC.aml
- SSDT-SBUS.aml
- SSDT-USB-Reset.aml
- SSDT-USBX.aml
- SSDT-XOSI.aml

## Drivers

- HfsPlus.efi
- OpenRuntime.efi
- ResetNvramEntry.efi
- apfs_aligned.efi
