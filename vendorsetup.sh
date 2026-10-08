# Soong only swaps a module's kernel headers for the prebuilt archive when it finds this
# in the environment; TARGET_PREBUILT_KERNEL_HEADERS in BoardConfig.mk alone does not
# reach it.
export TARGET_PREBUILT_KERNEL_HEADERS=device/xiaomi/gold/kernel-headers/kernel-uapi-headers.tar.gz
