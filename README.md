# Reckon

**Your position, even when GPS isn't looking.**

Reckon is the mobile companion app for the Reckon-AI GPS-denied vehicle positioning system.
It keeps a live map tracking a vehicle's position through tunnels, parking structures, and dense
urban canyons — anywhere GPS drops out — by falling back to an on-device ML model that reads the
phone's own accelerometer and gyroscope, then blends smoothly back onto GPS the moment signal
returns. The goal is that you can never tell, just by looking at the map, which mode is active.

[![Build](https://github.com/jeevansai-hub/Reckon/actions/workflows/build.yml/badge.svg)](https://github.com/jeevansai-hub/Reckon/actions/workflows/build.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-informational)
![Status](https://img.shields.io/badge/model-stub%20(pre--v1)-yellow)

---

## Why this exists

GPS fails constantly and predictably — tunnels, multi-level parking, tall-building "urban canyon"
multipath, and increasingly, deliberate jamming and spoofing. Every system that depends on a
position estimate (navigation, fleet tracking, driver assistance) either freezes or degrades the
instant that happens. Reckon's answer is a trained LSTM, not classical physics integration, that
has learned the real relationship between noisy phone-sensor data and true motion — trained on
[IO-VNBD](Project-Context/IO-VNBD-Repository-Breakdown.md), a public research dataset built exactly
for this.

This repo is the **product surface** — what a driver or a judge actually sees and touches. The
model itself is trained in a separate ML pipeline; see
[`Project-Context/00-PROJECT-CONTEXT.md`](Project-Context/00-PROJECT-CONTEXT.md) for that side, and
[`Project-Context/01-MOBILE-APP-CONTEXT.md`](Project-Context/01-MOBILE-APP-CONTEXT.md) for this
app's full plan, architecture, and roadmap in depth.

## Screens

| Screen | What it does |
|---|---|
| **Splash** | A signal-lock animation — radar rings converge and the Reckon mark draws itself in as the "signal" locks. |
| **Onboarding** | Three-page pitch walkthrough: GPS drops → your phone already has what it needs → no visible seam on handback. |
| **Live map** | The core screen. OSM map, a pulsing mode chip (GPS / Sensor-only / Reconnecting), running trip distance, and a "Simulate outage" control for on-demand demos. |
| **Trip summary** | The reconstructed path for the current trip plus distance/point stats — the same before/after idea the ML repo's own evaluation produces, but live and on-device. |
| **Settings** | Demo toggles — hide the mode chip for a clean "look, it's seamless" moment, haptic feedback on mode change, offline OSM extract switch. |

## How positioning mode switches

```
Phone sensors (accelerometer, gyroscope, magnetometer, GPS)
        │
        ▼
 Sensor Manager ── buffers readings into rolling windows
        │
        ▼
 Signal Quality Monitor ── watches GPS accuracy, decides the mode
        │
        ├── GPS available ──────────────► pass GPS position straight through
        │
        └── GPS lost ──► On-Device Model (TFLite) ──► distance + heading change
                                │
                          Position Integrator ── accumulates into a path
                                │
                          Map-Matcher ── snaps onto the road network
                                │
        ┌── GPS reacquired ──► Fusion Blender ── blends back onto GPS over 2-5s
        ▼
 Map Renderer ── draws the final position, live
```

This mirrors the five-layer architecture shared with the ML side
(see `Project-Context/01-MOBILE-APP-CONTEXT.md` §6), running in real time on-device instead of
offline on recorded data. Today, the "On-Device Model" step is a [`StubModel`](lib/core/model/stub_model.dart)
that returns plausible random output — see [Model contract](#model-contract) below.

## Model contract

The one place the app and the ML training repo touch. The app can be built and demoed almost
entirely against a stub matching this exact shape, without ever running the ML repo's Python code.

| | |
|---|---|
| **Format** | TensorFlow Lite (`.tflite`) |
| **Input** | 100 timesteps × 6 channels: gravity-corrected accelerometer (x, y, z) + gyroscope (yaw, pitch, roll) |
| **Output** | `(distanceMetres, headingChangeRadians)` — not raw (dx, dy) in a global frame |
| **Cadence** | One inference per window; a new window every `stride` samples (currently 50 → every 5s) |
| **Delivery** | A tagged release in the ML repo (`model-v1`) with the `.tflite` file attached |

Swapping [`StubModel`](lib/core/model/stub_model.dart) for real `tflite_flutter` inference should be
a drop-in replacement once `model-v1` is exported.

## Tech stack

| Layer | Choice | Why |
|---|---|---|
| Framework | [Flutter](https://flutter.dev) | Single codebase for Android + iOS |
| On-device inference | `tflite_flutter` (planned) | Free, open-source, matches the model export format |
| Map rendering | [`flutter_map`](https://pub.dev/packages/flutter_map) + OpenStreetMap tiles | No API key, no billing, unlike Google Maps/Mapbox SDKs |
| Sensors | [`sensors_plus`](https://pub.dev/packages/sensors_plus) | Native accelerometer/gyroscope access |
| State management | [`provider`](https://pub.dev/packages/provider) | Simple, standard, sufficient for this app's scope |
| Fonts | Orbitron (display) + Manrope (body) via `google_fonts` | HUD/technical feel for a navigation-resilience pitch |

**Deliberately avoided:** Google Maps SDK, Mapbox SDK — both carry paid usage tiers beyond a free
credit; OSM covers the same need for free.

## Getting started

This dev environment doesn't have the Flutter SDK installed, so nothing here has been run or built
locally yet — [`.github/workflows/build.yml`](.github/workflows/build.yml) builds a debug APK and
runs `flutter analyze`/`flutter test` on every push as a correctness check in the meantime. Grab the
latest built APK from that workflow's **Artifacts** if you just want to try it on an Android phone
without installing anything.

To run it yourself with the Flutter SDK installed:

```bash
flutter create --platforms=android,ios .   # generates the platform folders (gitignored)
flutter pub get
flutter run
```

## Project structure

```
lib/
├── main.dart
├── core/
│   ├── theme/            # dark HUD palette + text theme
│   ├── model/             # stub model matching the real .tflite contract
│   └── widgets/            # shared glass-panel HUD widget
├── providers/
│   ├── navigation_provider.dart   # mode state machine: GPS / sensor-only / fusion
│   └── settings_provider.dart      # demo toggles, shared app-wide
└── features/
    ├── splash/             # signal-lock logo animation
    ├── onboarding/          # 3-page pitch walkthrough
    ├── home/                # live map, mode chip, outage demo, outage countdown
    ├── trip_summary/         # reconstructed path + trip stats
    └── settings/              # demo toggle screen
```

## Status

- [x] Dark HUD theme, splash animation, onboarding, live map, trip summary, settings
- [x] Mode state machine (GPS / sensor-only / fusion) with simulated outage demo
- [x] Stub model matching the real `.tflite` contract exactly
- [x] CI: `flutter analyze` + `flutter test` + debug APK build on every push
- [ ] Real device testing (no Flutter SDK in this dev environment yet)
- [ ] Swap `StubModel` for `tflite_flutter` once `model-v1` ships from the ML repo
- [ ] On-device map-matching against a local OSM extract for offline demo routes
- [ ] iOS build verification

## Related

- **ML training repo** — trains and exports the `.tflite` model this app will eventually run;
  see [`Project-Context/00-PROJECT-CONTEXT.md`](Project-Context/00-PROJECT-CONTEXT.md).
- **Dataset** — [IO-VNBD](Project-Context/IO-VNBD-Repository-Breakdown.md), the public research
  dataset the model is trained and evaluated against.

Built for Smart India Hackathon 2026.
