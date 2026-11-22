#!/usr/bin/env bash
# Prints the SHA-1 and SHA-256 fingerprints Firebase needs for Google and
# phone sign-in on Android.
#
# Usage:
#   tool/print_sha.sh                                   # debug keystore
#   tool/print_sha.sh path/to/upload.jks alias [storepass]
#
# Note: on this Mac the default JDK crashes (SIGBUS); the script prefers a
# working JDK 21 under ~/Library/Java when it exists.
set -euo pipefail

keystore="${1:-$HOME/.android/debug.keystore}"
alias_name="${2:-androiddebugkey}"
storepass="${3:-android}"

keytool_bin="keytool"
for candidate in \
  "$HOME/Library/Java/JavaVirtualMachines/openjdk-21.0.1/Contents/Home/bin/keytool" \
  "${JAVA_HOME:-}/bin/keytool"; do
  if [ -x "$candidate" ]; then keytool_bin="$candidate"; break; fi
done

if [ ! -f "$keystore" ]; then
  echo "Keystore not found: $keystore" >&2
  exit 1
fi

echo "Keystore: $keystore (alias: $alias_name)"
"$keytool_bin" -list -v -keystore "$keystore" -alias "$alias_name" \
  -storepass "$storepass" 2>/dev/null | grep -E "SHA1:|SHA256:" | sed 's/^[[:space:]]*//'
