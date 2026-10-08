/*
 * SPDX-FileCopyrightText: 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "vendor.lineage.touch-service.gold"

#include "TouchscreenGesture.h"

#include <fcntl.h>
#include <linux/ioctl.h>
#include <sys/ioctl.h>

#include <array>

#include <android-base/logging.h>
#include <android-base/unique_fd.h>

namespace aidl {
namespace vendor {
namespace lineage {
namespace touch {

namespace {

constexpr char kTouchDevice[] = "/dev/xiaomi-touch";
constexpr int32_t kTouchModeAod = 11;

constexpr int32_t kSingleTapId = 0;
// The key the touch driver sends for a single tap while the screen is off.
constexpr int32_t kSingleTapScanCode = 354;  // KEY_GOTO

}  // namespace

ndk::ScopedAStatus TouchscreenGesture::getSupportedGestures(std::vector<Gesture>* _aidl_return) {
    Gesture singleTap;
    singleTap.id = kSingleTapId;
    singleTap.name = "Single Tap";
    singleTap.keycode = kSingleTapScanCode;

    *_aidl_return = {singleTap};
    return ndk::ScopedAStatus::ok();
}

ndk::ScopedAStatus TouchscreenGesture::setGestureEnabled(const Gesture& gesture, bool enabled) {
    if (gesture.id != kSingleTapId) {
        return ndk::ScopedAStatus::fromExceptionCode(EX_ILLEGAL_ARGUMENT);
    }

    ::android::base::unique_fd fd(open(kTouchDevice, O_RDWR | O_CLOEXEC));
    if (fd.get() < 0) {
        PLOG(ERROR) << "Failed to open " << kTouchDevice;
        return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    // The driver reads {mode, value} from a buffer of 256 ints.
    std::array<int32_t, 256> payload{kTouchModeAod, enabled ? 1 : 0};
    if (ioctl(fd.get(), _IOWR('T', 0, int32_t), payload.data()) < 0) {
        PLOG(ERROR) << "Failed to " << (enabled ? "enable" : "disable") << " single tap";
        return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
    }

    return ndk::ScopedAStatus::ok();
}

}  // namespace touch
}  // namespace lineage
}  // namespace vendor
}  // namespace aidl
