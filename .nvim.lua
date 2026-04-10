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
					expr = "(builtins.getFlake (builtins.toString ./.)).homeConfigurations.ii69854.options",
				},
				flakeparts = {
					expr = "(builtins.getFlake ./.).debug.options",
				},
				flakeparts2 = {
					expr = "(builtins.getFlake ./.).debug.currentSystem.options",
				},
			},
		},
	},
})

vim.lsp.enable("nixd")
