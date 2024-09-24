.PHONY: setup check

setup:
	dart pub get
	dart pub global activate melos
	cd test_resources/example_melos_codebase; dart pub get

check:
	dart format lib --line-length 100 --set-exit-if-changed
	dart scripts/generate_big_codebase.dart
	dart test
