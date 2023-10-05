.PHONY: install check

install:
	dart pub get

check:
	dart format lib --line-length 100 --set-exit-if-changed;
	dart scripts/generate_big_codebase.dart;
	dart test;
