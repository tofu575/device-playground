.PHONY: pub-get format analyze test

pub-get:
	fvm flutter pub get

format:
	fvm dart format lib test

analyze:
	fvm flutter analyze

test:
	fvm flutter test
