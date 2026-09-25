.PHONY: pub-get format analyze

pub-get:
	fvm flutter pub get

format:
	fvm dart format lib

analyze:
	fvm flutter analyze
