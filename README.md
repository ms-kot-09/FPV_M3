# NeonFPV (Godot 4.5) — Mobile FPV Drone Combat

A lightweight, **playable** FPV-style drone combat prototype built for **Android 12+** with **GitHub Actions** export.

## What you can do in M3
- Choose a drone (weapon or kamikaze) in **Drone Hangar**
- Fly in FPV-ish controls (2 sticks)
- Shoot enemies (soldiers / cars / tank)
- Earn coins: **+5 coins per kill** (saved locally)

## Controls (mobile)
- **Left stick**: throttle (Y) + yaw (X)
- **Right stick**: pitch (Y) + roll (X)
- **FIRE**: shoot / explode (kamikaze)
- **BOOST**: temporary thrust boost

## Build APK/AAB via GitHub Actions (no PC build)
1. Upload this repo to GitHub.
2. Go to **Actions → Android Build → Run workflow**.
3. Download artifacts (APK/AAB) from the finished run.

### Release AAB signing (optional)
To export the **release .AAB**, add GitHub Secrets:
- `ANDROID_KEYSTORE_BASE64` — base64 of your `.keystore`
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`

If secrets are missing, the workflow will still export the **debug APK**.

## Project structure
- `godot/` — Godot project
  - `scenes/` — scenes
  - `scripts/` — gameplay code
  - `ui/` — touch UI scripts
  - `data/` — drones/weapons/i18n JSON
- `.github/workflows/android.yml` — GitHub Actions Android export

## Notes
This is an M3 playable milestone. Next upgrades:
- Better FPV physics (PID stabilization, camera vibration)
- More enemies & behaviors
- Real weapon variety per drone (spread, recoil, projectiles)
- Hangar/shop/inventory

# FPV_M3
