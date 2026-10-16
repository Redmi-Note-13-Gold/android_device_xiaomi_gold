/*
 * SPDX-FileCopyrightText: 2023 The Android Open Source Project
 * SPDX-FileCopyrightText: 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "Audio_ParameterParser"

#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>

#include "ParameterParser.h"

using vendor::audio::parserservice::ParameterParser;

int main() {
    const std::string instance =
            std::string(::aidl::android::media::audio::IHalAdapterVendorExtension::descriptor) +
            "/default";
    auto parser = ndk::SharedRefBase::make<ParameterParser>();
    // Exits when it cannot register, so that init starts it again instead of it idling unseen.
    binder_status_t status = AServiceManager_addService(parser->asBinder().get(), instance.c_str());
    CHECK_EQ(status, STATUS_OK) << "Failed to register " << instance;
    ABinderProcess_joinThreadPool();
    return EXIT_FAILURE;  // should not reach
}
