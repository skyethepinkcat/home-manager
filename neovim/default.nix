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
