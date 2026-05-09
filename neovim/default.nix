{
  inputs,
  ...
}:
{
  imports = [
    inputs.nixvim-config.homeModules.default
  ];
  config = {
    programs = {
      nixvim = {
        enable = true;
        profiles.ai = true;
        ai.default = "claude";
        ai.suggestions = false;
      };

      neovide = {
        enable = true;
        settings = {
          fork = true;
        };
      };
    };
  };

}
