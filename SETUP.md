# Quick setup from ZIP

This archive contains the complete Flutter application source, tests, architecture and configuration. The execution environment used to assemble it did not have the Flutter SDK installed, so generated platform folders are intentionally omitted rather than pretending the project was locally compiled.

After extracting:

```bash
cd employee_management_app
flutter create .
flutter pub get
```

Then configure Firebase:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Enable Email/Password and Google providers in Firebase Authentication. For Android/iOS, the FlutterFire command adds the required native configuration files.

Finally:

```bash
flutter test
flutter run
```

The MockAPI employee endpoints require no API key.
