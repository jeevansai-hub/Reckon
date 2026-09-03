# Reckon — mobile app

The companion app for the Reckon-AI GPS-denied positioning system. See
[`Project-Context/01-MOBILE-APP-CONTEXT.md`](Project-Context/01-MOBILE-APP-CONTEXT.md) for the
full app plan, and [`Project-Context/00-PROJECT-CONTEXT.md`](Project-Context/00-PROJECT-CONTEXT.md)
for the ML pipeline this app will eventually run on-device.

Currently wired against a [`StubModel`](lib/core/model/stub_model.dart) that returns plausible
random output matching the real model's exact input/output contract, so the app can be built and
demoed end to end before `model-v1` is exported from the training repo.

## Running locally

This dev environment doesn't have the Flutter SDK installed, so the app hasn't been run or built
here — [`.github/workflows/build.yml`](.github/workflows/build.yml) builds a debug APK on every
push as a correctness check in the meantime. To run it yourself:

```bash
flutter create --platforms=android,ios .   # generates the platform folders (gitignored)
flutter pub get
flutter run
```

## Structure

```
lib/
├── main.dart
├── core/
│   ├── theme/          # dark HUD palette + text theme
│   ├── model/           # stub model matching the real .tflite contract
│   └── widgets/          # shared glass-panel HUD widget
├── providers/
│   └── navigation_provider.dart   # mode state machine: GPS / sensor-only / fusion
└── features/
    ├── splash/           # signal-lock logo animation
    ├── onboarding/        # 3-page pitch walkthrough
    ├── home/              # live map, mode chip, outage demo
    ├── trip_summary/       # reconstructed path + trip stats
    └── settings/           # demo toggles
```
