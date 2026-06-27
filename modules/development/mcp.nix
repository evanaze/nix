let
  module = {
    programs.mcp = {
      enable = true;
      servers = {
        nixos = {
          command = "mcp-nixos";
        };
        nocodb-leads = {
          url = "https://nocodb.spitz-pickerel.ts.net/mcp/ncv4hm8lp1enp7fk";
          headers."xc-mcp-token" = "{env:NOCODB_LEADS_MCP_TOKEN}";
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    developmentMcp = module;
    development = module;
  };
}
