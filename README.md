# OMNI

Expense tracking and financial planning app.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

### Local setup

- Flutter 3.x (stable)
- Firebase CLI (`npm i -g firebase-tools`)
- FlutterFire CLI (`dart pub global activate flutterfire_cli`)

### Run (dev Firebase)

```bash
flutter run --dart-define=FIREBASE=true
```

### Emulators

```bash
firebase emulators:start
```

### CI

GitHub Actions checks analyze and tests on PRs.
