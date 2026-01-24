{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.claude;
in {
  options.features.cli.claude = {
    enable = mkEnableOption "Enable Claude Code CLI configuration";

    context7 = {
      enable = mkEnableOption "Enable Context7 MCP server";
      apiKey = mkOption {
        type = types.str;
        description = "API key for Context7 MCP server, or path to file containing the key";
        example = "ctx7sk-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      mcpServers = mkIf cfg.context7.enable {
        context7 = {
          type = "http";
          url = "https://mcp.context7.com/mcp";
          env = {
            CONTEXT7_API_KEY = "{file:${cfg.context7.apiKey}}";
          };
        };
      };
    };
  };
}
