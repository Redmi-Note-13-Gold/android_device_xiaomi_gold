/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <fcntl.h>
#include <sys/ioctl.h>

#include <array>

#include <aidl/android/hardware/power/BnPower.h>
#include <android-base/logging.h>
#include <android-base/unique_fd.h>

namespace aidl::google::hardware::power::impl::pixel {

using ::aidl::android::hardware::power::Mode;

namespace {

constexpr char kTouchDevice[] = "/dev/xiaomi-touch";
// Touch_Doubletap_Mode in the stock xiaomi_touch driver.
constexpr int32_t kDoubleTapMode = 14;

// The focaltech driver drops double taps unless this mode is set, whatever
// its own gesture switch says. On this kernel the payload is {mode, value}
// with no touch id in front, and the driver copies 256 ints regardless of the
// size encoded in the request.
void SetDoubleTapToWake(bool enabled) {
    ::android::base::unique_fd fd(open(kTouchDevice, O_RDWR | O_CLOEXEC));
    if (fd < 0) {
        PLOG(ERROR) << "Cannot open " << kTouchDevice;
        return;
    }
    std::array<int32_t, 256> payload{kDoubleTapMode, enabled ? 1 : 0};
    if (TEMP_FAILURE_RETRY(ioctl(fd.get(), _IOWR('T', 0, int32_t), payload.data())) < 0) {
        PLOG(ERROR) << "Cannot set double tap to wake";
    }
}

}  // namespace

bool isDeviceSpecificModeSupported(Mode type, bool* _aidl_return) {
    if (type == Mode::DOUBLE_TAP_TO_WAKE) {
        *_aidl_return = true;
        return true;
    }
    return false;
}

bool setDeviceSpecificMode(Mode type, bool enabled) {
    if (type == Mode::DOUBLE_TAP_TO_WAKE) {
        SetDoubleTapToWake(enabled);
        return true;
    }
    return false;
}

}  // namespace aidl::google::hardware::power::impl::pixel
