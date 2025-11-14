{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.zsh;

  # Helper to get colors from various sources
  getColors =
    if cfg.useNixColors && config.colorScheme or null != null
    then
      # Extract from nix-colors if available
      let
        scheme = config.colorScheme;
      in {
        primary = "#${scheme.palette.base08}"; # red
        secondary = "#${scheme.palette.base0D}"; # blue
        tertiary = "#${scheme.palette.base03}"; # bright black
        success = "#${scheme.palette.base0A}"; # yellow
        error = "#${scheme.palette.base08}"; # red
      }
    else if config.stylix.enable or false
    then
      # Extract from stylix if available
      let
        colors = config.stylix.base16Scheme;
      in {
        primary = "#${colors.base08}";
        secondary = "#${colors.base0D}";
        tertiary = "#${colors.base03}";
        success = "#${colors.base0A}";
        error = "#${colors.base08}";
      }
    else if cfg.colorScheme != null
    then
      # Use provided color scheme
      cfg.colorScheme
    else
      # Fallback colors
      {
        primary = "#ed8274";
        secondary = "#7daea3";
        tertiary = "#6C6C6C";
        success = "#d8a657";
        error = "#ed8274";
      };

  # Generate oh-my-posh theme JSON
  generateTheme = colors:
    pkgs.writeTextFile {
      name = "generated-omp-theme.json";
      text = builtins.toJSON {
        "$schema" = "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json";
        version = 3;
        final_space = true;
        blocks = [
          {
            alignment = "left";
            type = "prompt";
            segments = [
              {
                foreground = colors.primary;
                style = "plain";
                template = "{{ .HostName }}";
                type = "session";
              }
              {
                foreground = colors.secondary;
                style = "plain";
                template = " {{ .Path }}";
                type = "path";
                properties = {
                  style = "full";
                };
              }
            ];
          }
          {
            alignment = "left";
            type = "prompt";
            segments = [
              {
                type = "git";
                style = "plain";
                foreground = colors.tertiary;
                template = " {{ if .Working.Changed }}●{{ .HEAD }}{{ else }}{{ .HEAD }}{{ end }}";
                properties = {
                  fetch_stash_count = true;
                  fetch_upstream_icon = true;
                  branch_icon = "";
                };
              }
            ];
          }
          {
            type = "prompt";
            alignment = "left";
            newline = true;
            segments = [
              {
                type = "status";
                style = "plain";
                template = "★ ";
                foreground_templates = [
                  "{{ if gt .Code 0 }}${colors.error}{{ else }}${colors.success}{{ end }}"
                ];
                properties = {
                  always_enabled = true;
                };
              }
            ];
          }
        ];
        transient_prompt = {
          template = "★ ";
          foreground_templates = [
            "{{ if gt .Code 0 }}${colors.error}{{ else }}${colors.success}{{ end }}"
          ];
        };
      };
    };
in {
  options.features.cli.zsh = {
    enable = mkEnableOption "Enable zsh configuration.";

    theme = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = ../assets/pure.omp.json;
      description = "Path to the desired oh-my-posh theme. If null, will generate from colorScheme.";
    };

    colorScheme = mkOption {
      type = types.nullOr (types.submodule {
        options = {
          primary = mkOption {
            type = types.str;
            default = "#ed8274";
          };
          secondary = mkOption {
            type = types.str;
            default = "#7daea3";
          };
          tertiary = mkOption {
            type = types.str;
            default = "#6C6C6C";
          };
          success = mkOption {
            type = types.str;
            default = "#d8a657";
          };
          error = mkOption {
            type = types.str;
            default = "#ed8274";
          };
        };
      });
      default = null;
      description = "Color scheme for auto-generating oh-my-posh theme.";
    };

    useNixColors = mkOption {
      type = types.bool;
      default = false;
      description = "Use nix-colors color scheme if available.";
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;

      initContent = ''
        # Keybinds
        bindkey -e
        bindkey '^ ' autosuggest-accept
        bindkey '^[OA' history-search-backward
        bindkey '^[OB' history-search-forward

        # Completion styling
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

        # Shell integrations
        eval "$(fzf --zsh)"
        eval "$(zoxide init --cmd cd zsh)"
        eval "$(direnv hook zsh)"
        eval "$(oh-my-posh init zsh --config ${
          if cfg.theme != null
          then cfg.theme
          else generateTheme getColors
        })"
      '';

      history = {
        size = 5000;
        save = 5000;
        path = "$HOME/.zsh_history";
        append = true;
        share = true;
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
      };

      zplug = {
        enable = true;
        plugins = [
          {name = "wintermi/zsh-oh-my-posh";}
          {name = "zsh-users/zsh-syntax-highlighting";}
          {name = "zsh-users/zsh-completions";}
          {name = "zsh-users/zsh-autosuggestions";}
          {name = "Aloxaf/fzf-tab";}
        ];
      };

      shellAliases = {
        os = "sudo nixos-rebuild switch --flake";
        home = "home-manager switch --flake";
        ls = "eza";
        c = "clear";
        v = "nvim";
        cat = "bat";
        du = "dust";
        lgit = "lazygit";
      };
    };
  };
}
