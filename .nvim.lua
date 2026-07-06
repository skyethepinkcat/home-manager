vim.lsp.config("nixd", {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_markers = { "flake.nix", ".git" },
	settings = {
		nixd = {
			nixpkgs = {
				expr = "import (builtins.getFlake (toString ./.)).inputs.nixpkgs {}",
			},
			options = {
				homemanager = {
					expr = "(builtins.getFlake (builtins.toString ./.)).currentSystem.legacyPackages.homeConfigurations.skye.options",
				},
				flakeparts = {
					expr = "(builtins.getFlake (builtins.toString ./.)).currentSystem.options",
				},
			},
		},
	},
})

vim.lsp.enable("nixd")
