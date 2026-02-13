default: switch

switch:
	home-manager switch --flake .

build:
	home-manager build --flake .
