default: update_trivial switch

switch:
	home-manager switch --flake . -b backup

update_trivial:
	nix flake update nixvim-config skyepkgs claude-prompt

expire:
	home-manager expire-generations "-30 days"

build:
	home-manager build --flake .
trace:
	home-manager build --flake . --show-trace --no-out-link
diff: build
	nix run nixpkgs#nvd diff ~/.local/state/nix/profiles/home-manager ./result
