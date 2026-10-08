#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    'device/xiaomi/gold',
    'hardware/mediatek',
#    'hardware/mediatek/libaedv',
    'hardware/mediatek/libmtkperf_client',
    'hardware/xiaomi',
]

blob_fixups: blob_fixups_user_type = {

    'vendor/lib64/hw/fingerprint.fpc.default.so': blob_fixup()
        .binary_regex_replace(
            br'fingerprint\.fpc\x00',
            b'fingerprint\x00\x00\x00\x00\x00',
        ),

    'vendor/lib64/hw/fingerprint.goodix.default.so': blob_fixup()
        .binary_regex_replace(
            br'fingerprint\.goodix\x00',
            b'fingerprint\x00\x00\x00\x00\x00\x00\x00\x00',
        ),

    'vendor/lib64/libgoodixhwfingerprint.so': blob_fixup()
        .replace_needed('libvendor.xiaomi.hardware.fx.tunnel@1.0.so', 'vendor.xiaomi.hardware.fx.tunnel@1.0.so'),

    ('vendor/bin/mnld',
     'vendor/lib64/libcam.utils.sensorprovider.so',
     'vendor/lib64/libaalservice.so'): blob_fixup()
        .replace_needed(
            'android.hardware.sensors-V2-ndk.so',
            'android.hardware.sensors-V3-ndk.so',
        ),

    # From device_xiaomi_duchamp
    'vendor/bin/hw/android.hardware.security.keymint@3.0-service.mitee': blob_fixup()
        .replace_needed(
            'android.hardware.security.keymint-V3-ndk.so',
            'android.hardware.security.keymint-V3-ndk-prebuilt.so',
        ),


    # From device_xiaomi_duchamp
    'vendor/lib64/libmtkcam_hal_aidl_common.so': blob_fixup()
        .replace_needed('android.hardware.camera.common-V2-ndk.so', 'android.hardware.camera.common-V1-ndk.so'),

    # worst patching spree you will see in your life
    ('vendor/lib/hw/mapper.mediatek.so',
     'vendor/lib64/hw/mapper.mediatek.so',
     'vendor/lib/egl/libGLES_mali.so',
     'vendor/lib64/egl/libGLES_mali.so',
     'vendor/bin/hw/android.hardware.graphics.allocator-V2-service-mediatek',
     'vendor/lib64/vendor.mediatek.hardware.camera.isphal-V1-ndk.so',
     'vendor/lib64/hw/android.hardware.graphics.allocator-V2-mediatek.so',
     'vendor/lib64/vendor.mediatek.hardware.pq_aidl-V4-ndk.so',
     'vendor/lib/vendor.mediatek.hardware.pq_aidl-V4-ndk.so',
     'vendor/lib64/vendor.mediatek.hardware.pq_aidl-V2-ndk.so',
     'vendor/lib/vendor.mediatek.hardware.pq_aidl-V2-ndk.so',
     'vendor/lib64/hw/hwcomposer.mtk_common.so',
     'vendor/lib64/libmtkcam_grallocutils.so',
     'vendor/lib64/libcodec2_fsr.so',
     'vendor/lib/libcodec2_fsr.so',
     'vendor/lib/libgpud.so',
     'vendor/lib64/libgpud.so'): blob_fixup()
        .replace_needed('android.hardware.graphics.common-V5-ndk.so', 'android.hardware.graphics.common-V7-ndk.so'),

    # From android_device_xiaomi_rosemary
    ('vendor/lib64/libMiVideoFilter.so'): blob_fixup()
        .clear_symbol_version('AHardwareBuffer_allocate')
        .clear_symbol_version('AHardwareBuffer_describe')
        .clear_symbol_version('AHardwareBuffer_lock')
        .clear_symbol_version('AHardwareBuffer_lockPlanes')
        .clear_symbol_version('AHardwareBuffer_release')
        .clear_symbol_version('AHardwareBuffer_unlock'),

    'vendor/lib/libvcodec_oal.so': blob_fixup()
        .clear_symbol_version('__aeabi_memcpy')
        .clear_symbol_version('__aeabi_memset')
        .clear_symbol_version('__gnu_Unwind_Find_exidx'),

    # libtinyxml
    ('vendor/lib64/libsilkybrightnesscore.so',
     'vendor/lib64/hw/vendor.mediatek.hardware.pq_aidl-impl.so',
     'vendor/lib64/hw/hwcomposer.mtk_common.so',
     'vendor/lib64/libpqxmlparser.so'): blob_fixup()
        .replace_needed(
            'libtinyxml2.so',
            'libtinyxml2-v34.so',
        ),

    'vendor/lib64/hwcomposer.mtk_common.so': blob_fixup()
        .add_needed('libprocessgroup_shim.so'),

    # Apple clients cannot join a WPA3 hotspot while the driver checks the PMKID itself
    'vendor/firmware/wifi.cfg': blob_fixup()
        .add_line_if_missing('SapCheckPmkidInDriver 0'),

    # BT_VND_OP_USERIAL_CLOSE takes no parameter, and the HAL passes nullptr, but this
    # library reads a flag from it before closing the UART. Use 0 (a normal close)
    # instead: ldrb w0, [x19] -> mov w0, wzr
    'vendor/lib64/libbt-vendor.so': blob_fixup()
        .binary_regex_replace(
            b'\x3c\x00\x00\x94\x60\x02\x40\x39\x5a\x00\x00\x94',
            b'\x3c\x00\x00\x94\xe0\x03\x1f\x2a\x5a\x00\x00\x94',
        ),

    # hardware/xiaomi's sensors HAL exposes the pick-up sensor as the standard pick-up
    # gesture, but only knows it under this type name
    'vendor/lib64/hw/sensors.mt6833.so': blob_fixup()
        .binary_regex_replace(
            br'xiaomi\.sensor\.pick_up\x00',
            b'xiaomi.sensor.pickup\x00\x00',
        ),

    # mtk pq
    'vendor/lib64/vendor.mediatek.hardware.pq_aidl-V7-ndk.so': blob_fixup()
        .replace_needed('android.hardware.graphics.common-V4-ndk.so',
        'android.hardware.graphics.common-V7-ndk.so')


}  # fmt: skip

module = ExtractUtilsModule(
    'gold',
    'xiaomi',
    add_firmware_proprietary_file=True,
    blob_fixups=blob_fixups,
    namespace_imports=namespace_imports,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
