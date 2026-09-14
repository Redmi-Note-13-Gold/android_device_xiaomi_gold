/*
 * Copyright (C) 2021 The Android Open Source Project
 * Copyright (C) 2022-2026 The LineageOS Project
 *
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android/binder_interface_utils.h>
#include <health-impl/Health.h>
#include <health/utils.h>

#ifndef CHARGER_FORCE_NO_UI
#define CHARGER_FORCE_NO_UI 0
#endif

#if !CHARGER_FORCE_NO_UI
#include <health-impl/ChargerUtils.h>
#endif

using aidl::android::hardware::health::HalHealthLoop;
using aidl::android::hardware::health::Health;
using aidl::android::hardware::health::HealthInfo;

#if !CHARGER_FORCE_NO_UI
using aidl::android::hardware::health::charger::ChargerCallback;
using aidl::android::hardware::health::charger::ChargerModeMain;
#endif

namespace {

constexpr char kInstanceName[] = "default";
constexpr std::string_view kChargerArg{"--charger"};
constexpr int32_t kDesignCapacityUah = 5000000;
constexpr int32_t kLargestPlausibleMahCounter = 20000;

bool ChargeCounterIsMah(int32_t chargeCounter, int32_t batteryLevel, int32_t fullChargeUah) {
    if (chargeCounter <= 0 || chargeCounter > kLargestPlausibleMahCounter || batteryLevel <= 0 ||
        fullChargeUah < 1000000) {
        return false;
    }

    const int64_t expectedChargeUah =
            static_cast<int64_t>(fullChargeUah) * batteryLevel / 100;
    const int64_t scaledChargeUah = static_cast<int64_t>(chargeCounter) * 1000;

    return scaledChargeUah >= expectedChargeUah / 4 &&
           scaledChargeUah <= expectedChargeUah * 4;
}

int32_t NormalizeChargeCounter(int32_t chargeCounter, int32_t batteryLevel,
                               int32_t fullChargeUah) {
    if (ChargeCounterIsMah(chargeCounter, batteryLevel, fullChargeUah)) {
        return chargeCounter * 1000;
    }
    return chargeCounter;
}

class GoldHealth final : public Health {
  public:
    using Health::Health;

    ndk::ScopedAStatus getChargeCounterUah(int32_t* out) override {
        auto status = Health::getChargeCounterUah(out);
        if (!status.isOk()) {
            return status;
        }

        int32_t batteryLevel = 0;
        auto capacityStatus = Health::getCapacity(&batteryLevel);
        if (capacityStatus.isOk()) {
            *out = NormalizeChargeCounter(*out, batteryLevel, kDesignCapacityUah);
        }
        return status;
    }

  protected:
    void UpdateHealthInfo(HealthInfo* healthInfo) override {
        const int32_t fullChargeUah = healthInfo->batteryFullChargeUah >= 1000000
                                             ? healthInfo->batteryFullChargeUah
                                             : kDesignCapacityUah;
        healthInfo->batteryChargeCounterUah =
                NormalizeChargeCounter(healthInfo->batteryChargeCounterUah,
                                       healthInfo->batteryLevel, fullChargeUah);
    }
};

#if !CHARGER_FORCE_NO_UI
class ChargerCallbackImpl final : public ChargerCallback {
  public:
    using ChargerCallback::ChargerCallback;
    bool ChargerEnableSuspend() override { return true; }
};
#endif

}  // namespace

int main(int argc, char** argv) {
#ifdef __ANDROID_RECOVERY__
    android::base::InitLogging(argv, android::base::KernelLogger);
#endif

    auto config = std::make_unique<healthd_config>();
    ::android::hardware::health::InitHealthdConfig(config.get());
    auto binder = ndk::SharedRefBase::make<GoldHealth>(kInstanceName, std::move(config));

    if (argc >= 2 && argv[1] == kChargerArg) {
#if !CHARGER_FORCE_NO_UI
        return ChargerModeMain(binder, std::make_shared<ChargerCallbackImpl>(binder));
#endif

        LOG(INFO) << "Starting charger mode without UI.";
    } else {
        LOG(INFO) << "Starting gold health HAL.";
    }

    auto halHealthLoop = std::make_shared<HalHealthLoop>(binder, binder);
    return halHealthLoop->StartLoop();
}
