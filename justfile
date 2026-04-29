switch:
	nix flake update nixvim-config skyepkgs
	home-manager switch --flake . -b backup
	home-manager expire-generations "-30 days"

build:
	home-manager build --flake .
