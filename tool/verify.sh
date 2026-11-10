#!/usr/bin/env bash
# Runs every quality gate for easy_glow. Usage: ./tool/verify.sh
set -euo pipefail
cd "$(dirname "$0")/.."

step() { printf '\n\033[1;36m▶ %s\033[0m\n' "$1"; }

step "flutter pub get"
flutter pub get
if [ ! -d example/android ] && [ ! -d example/ios ] && [ ! -d example/web ]; then
  step "Generating example platform folders (first run)"
  (cd example && flutter create . --project-name easy_glow_example --org com.example >/dev/null)
fi
(cd example && flutter pub get)

step "dart format"
dart format . && dart format --output=none --set-exit-if-changed .

step "dart analyze"
dart analyze --fatal-infos --fatal-warnings

step "flutter test"
flutter test

step "dart doc (API coverage)"
dart doc --dry-run .

step "flutter pub publish --dry-run"
flutter pub publish --dry-run

if command -v pana >/dev/null 2>&1; then
  step "pana (pub points estimate)"
  pana --no-warning .
else
  printf '\nTip: `dart pub global activate pana` then re-run to see your pub points locally.\n'
fi

printf '\n\033[1;32m✔ All checks passed.\033[0m\n'
