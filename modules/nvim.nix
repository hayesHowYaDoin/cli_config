{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.nvim;
in {
  options.features.cli.nvim = {
    enable = mkEnableOption "Enable nvim configuration flake.";
    theme = lib.mkOption {
      type = lib.types.nullOr (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "See github:hayesHowYaDoin/nvim_config for name options.";
          };
          style = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "See github:hayesHowYaDoin/nvim_config for style options.";
          };
        };
      });
      default = null;
      description = "See github:hayesHowYaDoin/nvim_config for theme options.";
    };
    colorScheme = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "See github:hayesHowYaDoin/nvim_config for nix-colors options.";
    };
  };

  config = mkIf cfg.enable {
    programs.nvim_config = {
      enable = true;
      theme =
        if cfg.theme != null
        then {inherit (cfg.theme) name style;}
        else null;
      colorScheme = cfg.colorScheme;
    };
  };
}
