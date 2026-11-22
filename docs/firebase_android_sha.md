# Android SHA fingerprints for Firebase

Firebase needs the SHA-1 and SHA-256 of every key that signs the app, or
**Google sign-in** and **phone (OTP) sign-in** fail on Android.

Add them in Firebase Console → Project settings → Your apps → Android app
`com.interview.practice` → **Add fingerprint**, then download the new
`google-services.json` into `android/app/`.

## Debug key (this Mac: `~/.android/debug.keystore`)

Used by `flutter run` and debug builds. Each developer machine has its own
debug key, so every teammate adds theirs.

| Type | Fingerprint |
|---|---|
| SHA-1 | `C5:01:59:7D:3D:02:E5:67:43:87:C9:09:A6:F5:8C:38:C9:C8:06:AF` |
| SHA-256 | `D7:3D:5E:B2:3B:5F:0D:29:21:52:9D:E7:E2:00:B8:33:58:2E:73:82:61:7B:99:41:36:E0:88:B0:52:38:0D:56` |

## Release / Google Play (to add later)

- **Upload key**: the keystore you create for release builds
  (`android/app/build.gradle` still signs release with the debug key).
- **App signing key**: when the app is on Google Play, copy its SHA-1/SHA-256
  from Play Console → Setup → App integrity → App signing.

Add both to Firebase as well.

## Getting fingerprints again

```bash
tool/print_sha.sh                                 # debug keystore
tool/print_sha.sh path/to/upload.jks upload-alias # a release keystore
```

Keystores and passwords are never committed (`android/.gitignore` ignores
`*.jks`, `*.keystore` and `key.properties`).
