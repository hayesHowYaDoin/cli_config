{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.git;
in {
  options.features.cli.git = {
    enable = mkEnableOption "enable extended zsh configuration";
    userName = mkOption {
      type = types.str;
      example = "hayesHowYaDoin";
      description = "User name associated with the desired git account.";
    };
    userEmail = mkOption {
      type = types.str;
      example = "jordanhayes98@gmail.com";
      description = "User email associated with the desired git account.";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      lfs.enable = true;
      settings.user = {
        name = cfg.userName;
        email = cfg.userEmail;
      };
    };
  };
}
