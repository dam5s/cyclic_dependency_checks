.PHONY: setup check

setup:
	dart pub get
	dart pub global activate melos

check:
	dart format lib --line-length 100 --set-exit-if-changed
	dart scripts/generate_big_codebase.dart
	dart test
