#!/usr/bin/env bash
# Creates the Android upload keystore and android/key.properties.
#
# Usage: bash tool/create_upload_keystore.sh [keystore-path]
# Default keystore path: ~/keystores/interview-practice-upload.jks (outside
# the repo). Passwords are typed by you and only written to
# android/key.properties, which is git-ignored. Back up the keystore and the
# passwords: losing them means you cannot update the app on Google Play
# (unless Play App Signing lets you reset the upload key).
set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
keystore="${1:-$HOME/keystores/interview-practice-upload.jks}"
alias_name="upload"
props="$repo_root/android/key.properties"

# The default JDK on this Mac crashes (SIGBUS); prefer JDK 21.
jdk21="$HOME/Library/Java/JavaVirtualMachines/openjdk-21.0.1/Contents/Home"
if [[ -x "$jdk21/bin/keytool" ]]; then keytool="$jdk21/bin/keytool"; else keytool="keytool"; fi

if [[ -e "$keystore" ]]; then
  echo "Keystore already exists: $keystore (not overwritten)." >&2
  exit 1
fi
if [[ -e "$props" ]]; then
  echo "$props already exists (not overwritten)." >&2
  exit 1
fi

read -r -s -p "Keystore password (min 6 chars): " store_pass; echo
read -r -s -p "Repeat keystore password: " store_pass2; echo
[[ "$store_pass" == "$store_pass2" ]] || { echo "Passwords differ." >&2; exit 1; }
[[ ${#store_pass} -ge 6 ]] || { echo "Password too short." >&2; exit 1; }
read -r -p "Your name or company for the certificate (CN): " cn

mkdir -p "$(dirname "$keystore")"
# PKCS12 keystores use the store password for the key as well.
"$keytool" -genkeypair -v \
  -keystore "$keystore" -storetype PKCS12 \
  -alias "$alias_name" -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass "$store_pass" -keypass "$store_pass" \
  -dname "CN=${cn}, C=VN"

umask 077
cat > "$props" <<PROPS
storePassword=$store_pass
keyPassword=$store_pass
keyAlias=$alias_name
storeFile=$keystore
PROPS

echo
echo "Created $keystore and $props (git-ignored)."
echo "Fingerprints for Firebase / Google / Meta:"
"$keytool" -list -v -keystore "$keystore" -alias "$alias_name" -storepass "$store_pass" \
  | grep -E "SHA1:|SHA256:"
sha1=$("$keytool" -exportcert -keystore "$keystore" -alias "$alias_name" -storepass "$store_pass" \
  | openssl sha1 -binary | openssl base64)
echo "Facebook key hash: $sha1"
