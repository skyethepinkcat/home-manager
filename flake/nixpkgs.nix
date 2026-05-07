{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = [ inputs.skyepkgs.overlays.default inputs.llm-agents.overlays.shared-nixpkgs];
        config = { };
      };
    };
}
