default: switch

switch:
	nix flake update nixvim-config && home-manager switch --flake . -b bak && home-manager expire-generations "-30 days"

build:
	home-manager build --flake .
