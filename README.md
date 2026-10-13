# Redmi Note 13 5G/13R Pro/POCO X6 Neo 5G (gold/iron) Device Tree

Device tree for LineageOS 23.2. This is a fork of [Dhterech's tree](https://github.com/Dhterech/android_device_xiaomi_gold) with our changes on top, one per commit: [the list](https://github.com/Star-caorui/android_device_xiaomi_gold/compare/6c5bdc8...lineage-23.2).

What works and what does not is in [lineageos-gold](https://github.com/Star-caorui/lineageos-gold#status). How to build is in [local_manifests](https://github.com/Star-caorui/local_manifests/tree/lineage-23.2).

The kernel is prebuilt, the stock one. `extract-kernel.sh` fills `device/xiaomi/gold-kernel` from the stock package, the same one `extract-files.py` takes the vendor blobs from. The results of both are also kept as repositories, [android_device_xiaomi_gold-kernel](https://github.com/Star-caorui/android_device_xiaomi_gold-kernel) and [android_vendor_xiaomi_gold](https://github.com/Star-caorui/android_vendor_xiaomi_gold), each with a history that starts from the unchanged stock files.

Tested on one China unit (2312DRAABC, `gold_cn`). The configuration for the Indian and Global (`iron`) models comes from upstream; nobody here has tested it.

## Credits
Dhterech, whose tree this is, and those he credits: based on xiaomi-mt6833-dev/device_xiaomi_mt6833-common, aeronruless (telegram) and linastorvaldz (github)'s work, with mt6897-devs/device_xiaomi_duchamp and LineageOS/android_device_xiaomi_rosemary as reference.

Dhterech's tree is built on claxten10's [mt6833-devs/android_device_xiaomi_gold](https://github.com/mt6833-devs/android_device_xiaomi_gold).

The commits on top of Dhterech's follow other trees in places; each says so in its message:

- cristidclxvi's [android_device_xiaomi_camellia](https://github.com/cristidclxvi/android_device_xiaomi_camellia): how double tap to wake is switched, and two Wi-Fi settings.
- LineageOS's [android_device_motorola_mt6768-common](https://github.com/LineageOS/android_device_motorola_mt6768-common): the stock AIDL audio service, the IMS files, the mtkpower stubs and the GNSS declarations.
- LineageOS's android_device_motorola_mt6879-common, android_device_xiaomi_rosemary and android_device_xiaomi_mt6768-common, and crDroid's android_device_xiaomi_everpal, for what to take from the stock images and how.
- LineageOS's android_device_motorola_lamu, for building against a prebuilt kernel's headers.
- bengris32, whose patch for Motorola's ImsService ours repeats on this device's build of the app.
- Dhterech's [android_kernel_xiaomi_gold](https://github.com/Dhterech/android_kernel_xiaomi_gold), for the layout of the prebuilt kernel directory and for loading `wmt_drv.ko` from the vendor module list.
```
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
```
