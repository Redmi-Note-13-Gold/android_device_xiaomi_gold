# To do

What is untested, wrong, not done or not possible on this device, beyond the rows of LineageOS's device support requirements. Those rows are in the [status table](https://github.com/Star-caorui/lineageos-gold#status).

## Not tested

- Fast charging on units with the LN8000 charge pump
- Dual SIM
- China Telecom SIM
- Video calls

## Known issues

| | |
| --- | --- |
| Offline charging while an alarm is set | With an alarm set in the Clock app, a powered-off phone on a charger can show the Redmi logo over and over instead of the charging screen. With no alarm set it goes straight to the charging screen. Cause not found yet. |
| Charging power with the screen on | Fast charging works on a unit with the SC8551 charge pump: with Xiaomi's 33 W charger the adapter passes Xiaomi's check, the PPS profile is chosen and the battery takes about 15 W at first. With the screen on, Xiaomi's thermal daemon then raises the charging thermal level and it settles at 8 to 10 W. With the daemon stopped it held about 20 W at 54 %, with the battery at 41 °C and the charge pump at 54 °C. On stock the system switches the daemon between scene profiles (charging with the screen off, games, video); nothing does that here, so it always uses the default profile. Not compared with stock yet. Chargers that fail Xiaomi's check start lower, as on stock. |
| Bluetooth audio after a game sound | With Bluetooth headphones on a software codec (AAC, SBC), everything on Bluetooth can go silent once a game plays a sound, until the headphones reconnect. Android 17's Bluetooth module switches the codec to a game configuration when a game sound starts and back when it stops, and each switch closes and reopens the audio session. Stock's audio HAL disables its Bluetooth port when the session closes and waits for the framework to reopen the stream; the framework only does that when the codec configuration changed, which happens on the first switch only. The game configuration only matters for codecs configured by the audio HAL, so a fix is to skip the switch for other codecs: an 18-line patch to `packages/modules/Bluetooth`, tested on the test unit, not carried. |
| 5G NSA on some carriers | On some SIMs 5G does not show and the phone stays on LTE, seen on Tri in Indonesia. MediaTek's RIL offers NR only when the modem answers `AT+E5GOPT?` with 5 or 7 (NR with EN-DC); for that SIM it answered 3, NR and SA without EN-DC, so 5G NSA was off. Turning EN-DC on through `TelephonyManager.setNrDualConnectivityState` brought 5G up on that unit. Whether the setting stays across a reboot is not known yet, and nothing turns it on by itself. 5G SA networks are not affected. |
| Fast charger on the lock screen | The lock screen does not say when the charger is a fast one. The charger driver does not report the standard current and voltage limits. |
| Add-ons across updates | Every update logs `Backuptool postinstall step failed. ret=32512`, and it is harmless. LineageOS's update_engine decides whether to run the add-on scripts by reading an ext4 mount count, and does so for every partition with a post-install step. For system it reads 0 and skips, which is right with no add-ons installed. For vendor, which is EROFS, the same bytes are not a mount count; it reads a large number, mounts vendor and fails to find the script there. Carrying real add-ons over an update has not been tried. |
| SELinux denials | Two have been logged now and then and not traced: the positioning daemon reading a property, the media provider at the root directory. No effect seen. |
| DNG photos | Decoding several DNG files at the same moment can crash the app, about once in twenty tries with four threads. It is a race in AOSP's DNG library and is not patched. |

## Not done

| | |
| --- | --- |
| 108 MP, portrait and 16 MP front photos | The camera HAL only offers them to the stock camera app, so the rear camera outputs 12 MP and the front 4 MP. Porting that app is not planned. |
| Stronger video stabilisation | It takes a patch to the camera app, and we do not carry one. |
| Xiaomi's camera app from a root module | The Leica camera modules for AOSP ROMs open to a black preview and ignore taps. The app looks up the 18-argument constructor of `StreamConfigurationMap` that Android 14 had; LineageOS has only the current ones, while crDroid, Lunaris and AxionOS add the old ones back with two patches to `frameworks/base`. We do not carry platform patches so far. |
| More screen-off gestures | Double tap and single tap are offered. The FocalTech touch driver also lists swipes and letters; nobody has checked that the touch firmware reports them. |
| Volume boost | Stock's 200% speaker volume is driven by MIUI's framework: past the top step it sends `SpkVolIdx` and `SuperStream` to the audio HAL, which switches the scene of Awinic's amplifier algorithm. Here the HAL takes the two keys but never switches, because it does not see a stream of that type playing, and nothing in LineageOS sends them. Only units with the AW87xxx amplifier could show an effect; the test unit has the SIA81xx. The HAL also has a switch for louder calls, `SET_SUPER_VOLUME`, which nothing sets yet. |
| Dolby, MiSound, spatial audio | Stock's effect libraries are not included. |
| DC dimming and colour modes | On stock these come from Xiaomi's `displayfeature` service, which only MIUI's settings talk to. LineageOS would show them through LiveDisplay, and that needs a small service of our own, like the one in LineageOS's android_device_motorola_mt6879-common, which offers anti-flicker and sunlight enhancement by writing one panel node each. The panel driver has nodes under `/sys/class/mi_display/disp-DSI-0/` (`dc_status`, `cabc_mode`, `disp_param`, `gir`); nobody has tried what writing them does. |
| Game-mode touch tuning | Driven by Xiaomi's `touchfeature` service, which is not included. |
| "Hey Google" with the screen off | Untested. The sound trigger HAL and the enrollment apps are stock's and in place, but trying it needs the Google app. |
| Xiaomi and Alexa wake words | The models are not included. |
| Per-carrier VoLTE settings | VoLTE is switched on for every carrier with a debug property. |
| Wi-Fi country code | wpa_supplicant is built without a driver command library, so the framework cannot hand the driver a country code. On the test unit the driver uses China's channel list by itself. |
| Wi-Fi SAR power reduction | Not active. On stock the trigger is not in the vendor image. |
| SAR and front colour sensors | Present, unused. |
| MPEG-4 and H.263 hardware encoding | Not ported. |
| Hotspot connection tracking | Closed TCP connections of hotspot clients stay in the kernel's table for up to five days, a behaviour of AOSP's tethering offload. No measurable cost, so not patched. |
| Always-on display | The panel runs in video mode, so while it shows anything the display path stays on and the system cannot suspend (about 290 mA). Switched to command mode in doze (branch `aod-experiment` of the modules repo), the panel keeps its last frame from its own RAM with no frames sent, which is what a suspending AOD needs. What does not work yet: the panel's TE signal does not come back through the MT6382 bridge; a frame written in command mode tears and then the screen goes black; leaving doze does not bring video mode back. Next to try: send updates in video mode and stop the stream in between. |
| Offline charging screen | Wakes with the power key only, as in AOSP. |
| ADB in recovery | Not pre-authorised. |
| Factory reset protection | Left off. The framework would read the FRP partition, and a build without Google apps has no way to clear what a Google-equipped system left there: coming from one, the screen lock could not be set. With the bootloader unlocked, `fastboot erase frp` removes the protection anyway. |
| Status bar and cutout | The overflow dot has uneven space around it, and in landscape apps are inset on the cutout side only. Both are stock Android behaviour. |

## Not possible

| | |
| --- | --- |
| Hotspot on another band than Wi-Fi | There is a single Wi-Fi radio: while connected to 5 GHz Wi-Fi the hotspot can only use the same channel. |
| Wi-Fi 6 | The chip reports no HE capability. The link tops out at 433 Mbps. |
| Hotspot hardware offload | The modem's offload driver reports itself disabled. |
| Sunlight enhancement switch | The panel has one brightness range, and its upper half is the high brightness mode that auto-brightness already uses. |
| Key attestation with device IDs | Fails with `CANNOT_ATTEST_IDS`. Ordinary attestation works. |
