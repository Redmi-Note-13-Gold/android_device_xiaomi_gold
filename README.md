# Redmi Note 13 5G/13R Pro/POCO X6 Neo 5G (gold/iron) Device Tree

Device tree for LineageOS 24.0 (Android 17). It is checked out at `device/xiaomi/gold`.

| | |
| --- | --- |
| Releases, what works, tested models | [lineageos-gold](https://github.com/Star-caorui/lineageos-gold#readme) |
| Known issues, what is untested or not done | [ISSUES.md](https://github.com/Star-caorui/lineageos-gold/blob/main/ISSUES.md) |
| How to build | [local_manifests](https://github.com/Star-caorui/local_manifests/tree/lineage-24.0#readme) |
| Stock kernel and modules | [android_device_xiaomi_gold-kernel](https://github.com/Star-caorui/android_device_xiaomi_gold-kernel/tree/lineage-24.0#readme) |
| Proprietary files | [android_vendor_xiaomi_gold](https://github.com/Star-caorui/android_vendor_xiaomi_gold/tree/lineage-24.0#readme) |

## Origin

Forked from [Dhterech's tree](https://github.com/Dhterech/android_device_xiaomi_gold) at `6c5bdc8` and maintained on its own since: [our commits](https://github.com/Star-caorui/android_device_xiaomi_gold/compare/6c5bdc8...lineage-24.0).

## Scripts

Both read the same stock package. Which one, and how to run them, is in the README of the repository each fills.

| Script | What it fills |
| --- | --- |
| `extract-files.py` | `vendor/xiaomi/gold`, kept as [android_vendor_xiaomi_gold](https://github.com/Star-caorui/android_vendor_xiaomi_gold/tree/lineage-24.0#regenerating) |
| `extract-kernel.sh` | `device/xiaomi/gold-kernel`, kept as [android_device_xiaomi_gold-kernel](https://github.com/Star-caorui/android_device_xiaomi_gold-kernel/tree/lineage-24.0#regenerating) |
| `fetch-gki.sh` | `device/xiaomi/gold-kernel/gki/<build>`, from one of Google's GKI builds instead of the stock package (see [GKI builds](https://github.com/Star-caorui/android_device_xiaomi_gold-kernel/tree/lineage-24.0#gki-builds)) |

## Credits

| Who | For what |
| --- | --- |
| [Dhterech](https://github.com/Dhterech/android_device_xiaomi_gold) | The tree this one was forked from |
| xiaomi-mt6833-dev/device_xiaomi_mt6833-common, aeronruless (Telegram), linastorvaldz (GitHub) | Dhterech's tree is based on their work |
| mt6897-devs/device_xiaomi_duchamp, LineageOS/android_device_xiaomi_rosemary | Dhterech's references |
| claxten10's [mt6833-devs/android_device_xiaomi_gold](https://github.com/mt6833-devs/android_device_xiaomi_gold) | The tree Dhterech's is built on |

Our commits follow other trees in places. Each one says so in its message.

| Followed | In what |
| --- | --- |
| cristidclxvi's [android_device_xiaomi_camellia](https://github.com/cristidclxvi/android_device_xiaomi_camellia) | How double tap to wake is switched, and two Wi-Fi settings |
| LineageOS's [android_device_motorola_mt6768-common](https://github.com/LineageOS/android_device_motorola_mt6768-common) | The stock AIDL audio service, the IMS files, the mtkpower stubs, the GNSS declarations, the power hint for games, and the seven changes for LineageOS 24.0 by Nolen Johnson, Michael Bestas, Nicholas Lim, Elias Gheeraert, Mashopy and Giovanni Ricca |
| LineageOS's android_device_motorola_mt6879-common, android_device_xiaomi_rosemary and android_device_xiaomi_mt6768-common, and crDroid's android_device_xiaomi_everpal | What to take from the stock images and how |
| LineageOS's android_device_motorola_lamu | Building against a prebuilt kernel's headers |
| bengris32 | His patch for Motorola's ImsService, which ours repeats on this device's build of the app |
| Dhterech's [android_kernel_xiaomi_gold](https://github.com/Dhterech/android_kernel_xiaomi_gold) | The layout of the prebuilt kernel directory, and loading `wmt_drv.ko` from the vendor module list |

## License

```
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
```
