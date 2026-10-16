#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/gold

# Virtual A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS := \
    dtbo \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vendor \
    vendor_dlkm

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-2a-dotprod
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a76

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv8-2a
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a55

# boot/vendor_boot image
AB_OTA_PARTITIONS += \
    boot \
    vendor_boot

BOARD_RAMDISK_USE_LZ4 := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true

# The bootloader loads the ramdisks of vendor_boot and never the one in boot.
# bootimg.mk lays the two images out as stock does.
BOARD_CUSTOM_BOOTIMG := true
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/bootimg.mk

BOARD_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864

BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2

BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x11088000
BOARD_KERNEL_TAGS_OFFSET := 0x07c08000
BOARD_DTB_OFFSET := 0x07c08000
BOARD_BOOT_HEADER_VERSION := 4

BOARD_MKBOOTIMG_ARGS := --base $(BOARD_KERNEL_BASE)
BOARD_MKBOOTIMG_ARGS += --kernel_offset $(BOARD_KERNEL_OFFSET)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := gold
TARGET_NO_BOOTLOADER := true

# Display
TARGET_SCREEN_DENSITY := 440
TARGET_USES_VULKAN := true

# Kernel
TARGET_KERNEL_NO_GCC := true
TARGET_KERNEL_VERSION := 6.6
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)-kernel/dtbo.img
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)-kernel/dtb

# What the kernel is made of, picked in the environment; both default to stock.
# - GOLD_GKI, the kernel image and the GKI modules in system_dlkm: stock is the
#   build of Google's GKI that stock ships; latest is Google's newest of the same
#   KMI generation (gold-kernel's gki/); source builds them from source.
# - GOLD_VENDOR_MODULES, the modules in vendor_boot and vendor_dlkm: stock is
#   Xiaomi's and MediaTek's; source builds them from source.
# Stock vendor modules only load on Google's kernel. Building from source needs
# the kernel repositories of local_manifests' gold-kernel-source group. The DTB
# and DTBO are the stock ones either way.
GOLD_GKI ?= stock
GOLD_VENDOR_MODULES ?= stock
GOLD_GKI_LATEST := 16498190

ifeq ($(filter stock latest source,$(GOLD_GKI)),)
    $(error GOLD_GKI is stock, latest or source, not '$(GOLD_GKI)')
endif
ifeq ($(filter stock source,$(GOLD_VENDOR_MODULES)),)
    $(error GOLD_VENDOR_MODULES is stock or source, not '$(GOLD_VENDOR_MODULES)')
endif
ifeq ($(GOLD_GKI)-$(GOLD_VENDOR_MODULES),source-stock)
    $(error GOLD_GKI=source needs GOLD_VENDOR_MODULES=source: stock vendor modules only load on Google's kernel)
endif

# Google's kernel image, its GKI modules and their symbol versions
ifeq ($(GOLD_GKI),latest)
GOLD_GKI_DIR := $(DEVICE_PATH)-kernel/gki/$(GOLD_GKI_LATEST)
else
GOLD_GKI_DIR := $(DEVICE_PATH)-kernel
endif

# Modules of MIUI's app freezer (Millet). They load on this kernel, but nothing outside
# MIUI talks to them. Binder itself is provided by GKI; binder_prio remains.
GOLD_UNUSED_VENDOR_KERNEL_MODULES := \
    binder_gki.ko \
    millet_binder.ko \
    millet_core.ko \
    millet_hs.ko \
    millet_oem_cgroup.ko \
    millet_pkg.ko \
    millet_sig.ko

# The touchscreen drivers are only in vendor_dlkm on stock, which recovery
# does not mount. A copy goes into the vendor ramdisk, with the two modules
# they need there, and init.recovery.mt6833.rc loads them.
GOLD_RECOVERY_TOUCH_MODULES := \
    mt6359p-accdet.ko \
    hq_notifier.ko \
    xiaomi_touch.ko \
    focaltech_tp.ko \
    gt9916r.ko

ifeq ($(GOLD_VENDOR_MODULES),stock)

# A source directory that does not exist, so that kernel.mk takes the prebuilt
# kernel quietly also where kernel/xiaomi/gold, its default, is synced for the
# source build. The config is not used on this path.
TARGET_KERNEL_SOURCE := kernel/xiaomi/gold-6.6
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    gold.config

TARGET_FORCE_PREBUILT_KERNEL := true
TARGET_PREBUILT_KERNEL := $(GOLD_GKI_DIR)/kernel
BOARD_SYSTEM_DLKM_SRC := $(GOLD_GKI_DIR)/system_dlkm
TARGET_PREBUILT_KERNEL_HEADERS := $(DEVICE_PATH)/kernel-headers/kernel-uapi-headers.tar.gz

BOARD_VENDOR_KERNEL_MODULES := $(filter-out \
    $(addprefix $(DEVICE_PATH)-kernel/vendor_dlkm/,$(GOLD_UNUSED_VENDOR_KERNEL_MODULES)), \
    $(wildcard $(DEVICE_PATH)-kernel/vendor_dlkm/*.ko))

BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)-kernel/modules.load.vendor))
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(filter-out \
    $(GOLD_UNUSED_VENDOR_KERNEL_MODULES), \
    $(BOARD_VENDOR_KERNEL_MODULES_LOAD))

BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(DEVICE_PATH)-kernel/vendor_ramdisk/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)-kernel/modules.load.vendor_ramdisk))

BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)-kernel/modules.load.recovery))

BOARD_VENDOR_RAMDISK_KERNEL_MODULES += \
    $(addprefix $(DEVICE_PATH)-kernel/vendor_dlkm/,$(GOLD_RECOVERY_TOUCH_MODULES))

BOOT_KERNEL_MODULES := $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD) $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD)

else

# From source: the Android common kernel, MediaTek's device modules and
# MediaTek's connectivity, GPU and fpsgo modules, all from Xiaomi's releases.
# Userspace keeps the prebuilt uapi headers that vendorsetup.sh points Soong at.
# With GOLD_GKI=stock or latest the kernel is built only for the vendor modules
# to build against, and kernel-prebuilt ships Google's image and GKI modules.
GOLD_KERNEL_DIR := kernel/xiaomi
TARGET_KERNEL_SOURCE := $(GOLD_KERNEL_DIR)/gold

# gki_defconfig as Google builds it, then MediaTek's and gold's fragments.
# gold.config keeps the options of the kernel itself as in gki_defconfig.
TARGET_KERNEL_CONFIG := gki_defconfig
TARGET_KERNEL_CONFIG_EXT := \
    $(GOLD_KERNEL_DIR)/gold-modules/kernel/configs/mgk_64_k66.config \
    $(GOLD_KERNEL_DIR)/gold-modules/kernel/configs/mt6833_overlay.config \
    $(GOLD_KERNEL_DIR)/gold-modules/kernel/configs/gold.config

# How MediaTek's trees find each other: the device modules' Kconfig is read
# through KCONFIG_EXT_PREFIX (relative to the kernel source), and the other
# modules link against them and against each other through these paths.
# kernel.mk builds the external modules beside KERNEL_OBJ, not in the checkouts.
TARGET_KERNEL_ADDITIONAL_FLAGS := \
    KCONFIG_EXT_PREFIX=../gold-modules/ \
    DEVICE_MODULES_REL_DIR=../gold-modules \
    DEVICE_MODULES_PATH=$(abspath $(GOLD_KERNEL_DIR)/gold-modules) \
    DEVCIE_MODULES_INCLUDE=-I$(abspath $(GOLD_KERNEL_DIR)/gold-modules)/include \
    MTK_KERNEL_MODULES_PATH=$(abspath $(GOLD_KERNEL_DIR)/gold-mediatek_modules) \
    MTK_KERNEL_MODULES_OUT=$(abspath $(OUT_DIR)/target/product/$(TARGET_DEVICE)/obj/gold-mediatek_modules) \
    KBUILD_EXTRA_SYMBOLS=$(abspath $(DEVICE_PATH)/kernel-prebuilt/stock.symvers)

# In this order: each one links against those before it. kernel-prebuilt
# comes last: it adds stock modules where gold's own drivers are not built
# from source yet (see its Makefile).
TARGET_KERNEL_EXT_MODULE_ROOT := $(GOLD_KERNEL_DIR)
TARGET_KERNEL_EXT_MODULES := \
    gold-modules \
    gold-mediatek_modules/connectivity/common \
    gold-mediatek_modules/connectivity/wlan/adaptor/build/connac1x \
    gold-mediatek_modules/connectivity/wlan/core/gen4m/build/connac1x/6833 \
    gold-mediatek_modules/connectivity/bt/mt66xx/wmt \
    gold-mediatek_modules/connectivity/gps/gps_stp \
    gold-mediatek_modules/connectivity/fmradio \
    gold-mediatek_modules/gpu \
    gold-mediatek_modules/fpsgo_cus \
    gold-mediatek_modules/met_drv_v3 \
    gold-mediatek_modules/met_drv_v3/met_api \
    gold-mediatek_modules/sched_cus \
    ../../$(DEVICE_PATH)/kernel-prebuilt

# On Google's kernel, kernel-gki comes first, so that all of them get the
# CRCs of Google's build, and kernel-prebuilt is told where that build is.
ifneq ($(GOLD_GKI),source)
TARGET_KERNEL_EXT_MODULES := ../../$(DEVICE_PATH)/kernel-gki $(TARGET_KERNEL_EXT_MODULES)
TARGET_KERNEL_ADDITIONAL_FLAGS += GOLD_GKI_DIR=$(abspath $(GOLD_GKI_DIR))
endif

# MIUI's memory reporting is left out as well. miev, MIUI's event reporting,
# stays: xiaomi_touch calls into it. So are MIUI's charging event chains
# (hq_notify) and the charging fault reports to miev (xm_chg_dfs): only
# stock's charger drivers used them. Huaqin's kallsyms
# lookup (hq_kallsyms) only served stock's sound modules, and /proc/cpumaxfreq
# (cpumaxfreq) only MIUI's settings.
GOLD_KERNEL_MODULES_LEFT_OUT := $(GOLD_UNUSED_VENDOR_KERNEL_MODULES) mi_memory.ko \
    hq_notify.ko xm_chg_dfs.ko hq_kallsyms.ko cpumaxfreq.ko

# Google's modules go to system_dlkm, as on stock; everything else that is
# built goes to vendor_dlkm, and the ones listed for the vendor ramdisk are
# copied there as well. The load lists are stock's.
SYSTEM_KERNEL_MODULES := $(notdir $(wildcard $(GOLD_GKI_DIR)/system_dlkm/lib/modules/*.ko))
BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(GOLD_GKI_DIR)/system_dlkm/lib/modules/modules.load))

# Stock's lists, with sec.ko under its new name (see the masp Makefile in
# gold-modules) and without Google's modules, which are in system_dlkm.
gold_stock_load_list = $(patsubst sec.ko,mtk_sec.ko,$(filter-out \
    $(GOLD_KERNEL_MODULES_LEFT_OUT) $(SYSTEM_KERNEL_MODULES), \
    $(strip $(shell cat $(DEVICE_PATH)-kernel/$(1)))))
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(call gold_stock_load_list,modules.load.vendor)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(call gold_stock_load_list,modules.load.vendor_ramdisk)
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(call gold_stock_load_list,modules.load.recovery)

BOOT_KERNEL_MODULES := $(filter-out $(GOLD_KERNEL_MODULES_LEFT_OUT), \
    $(BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD) \
    $(BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD) \
    $(GOLD_RECOVERY_TOUCH_MODULES))

endif

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_SUPER_PARTITION_SIZE := 9126805504

BOARD_USES_METADATA_PARTITION := true

BOARD_SUPER_PARTITION_GROUPS := mediatek_dynamic_partitions
BOARD_MEDIATEK_DYNAMIC_PARTITIONS_SIZE := 9122611200
BOARD_MEDIATEK_DYNAMIC_PARTITIONS_PARTITION_LIST := \
    system \
    system_ext \
    system_dlkm \
    product \
    vendor \
    vendor_dlkm \
    odm_dlkm

BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := erofs

BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4

TARGET_COPY_OUT_ODM_DLKM := odm_dlkm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm

TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_SYSTEM := system
TARGET_COPY_OUT_SYSTEM_EXT := system_ext

# Platform
TARGET_BOARD_PLATFORM := mt6833
BOARD_SHIPPING_API_LEVEL := 30

# Props
TARGET_VENDOR_PROP += $(DEVICE_PATH)/prop/vendor.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/prop/product.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/prop/system_ext.prop

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/init/fstab.mt6833

# RIL
ENABLE_VENDOR_RIL_SERVICE := true

# SEPolicy
include device/mediatek/sepolicy_vndr/SEPolicy.mk
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public

# SPL
BOOT_SECURITY_PATCH := 2026-02-01
VENDOR_SECURITY_PATCH := 2026-02-01

# vintf
DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE := $(DEVICE_PATH)/compatibility_matrix.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    hardware/xiaomi/vintf/xiaomi_framework_compatibility_matrix.xml \
    hardware/mediatek/vintf/mediatek_framework_compatibility_matrix.xml

# WiFi
WPA_SUPPLICANT_VERSION := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER := NL80211
WIFI_DRIVER_FW_PATH_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_FW_PATH_STA := "STA"
WIFI_DRIVER_FW_PATH_AP := "AP"
WIFI_DRIVER_FW_PATH_P2P := "P2P"
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wmtWifi"
WIFI_DRIVER_STATE_ON := "1"
WIFI_DRIVER_STATE_OFF := "0"
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true

# Reserve space for gapps
include vendor/lineage/config/BoardConfigReservedSize.mk

# Verified Boot
AB_OTA_PARTITIONS += \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor

BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --set_hashtree_disabled_flag
BOARD_AVB_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_ALGORITHM := SHA256_RSA4096

BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_SYSTEM := system system_ext system_dlkm product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_VBMETA_VENDOR := vendor vendor_dlkm odm_dlkm
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA4096
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 3

# Inherit the proprietary files
include vendor/xiaomi/gold/BoardConfigVendor.mk
