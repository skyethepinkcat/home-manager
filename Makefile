default: switch

switch:
	nix flake update nixvim-config && home-manager switch --flake .

build:
	home-manager build --flake .
