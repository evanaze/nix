let
  # fastmcp 3.2.3's test suite fails against the anyio version in current
  # nixpkgs (cancel-scope RuntimeError in stateful proxy tests).
  fastmcpOverlay = final: prev: {
    pythonPackagesExtensions =
      (prev.pythonPackagesExtensions or [])
      ++ [
        (_pyFinal: pyPrev: {
          fastmcp = pyPrev.fastmcp.overridePythonAttrs (_old: {
            doCheck = false;
          });
        })
      ];
  };

  module = {username, ...}: {
    nixpkgs.overlays = [fastmcpOverlay];
    home-manager.users.${username} = {
      programs.mcp = {
        enable = true;
        servers = {
          nixos = {
            command = "mcp-nixos";
          };
          nocodb-leads = {
            url = "https://nocodb.spitz-pickerel.ts.net/mcp/ncv4hm8lp1enp7fk";
            headers."xc-mcp-token" = "\${env:NOCODB_LEADS_MCP_TOKEN}";
          };
          nocodb-competitors = {
            url = "https://nocodb.spitz-pickerel.ts.net/mcp/nc7ekmhb4vs5tzmx";
            headers."xc-mcp-token" = "\${env:NOCODB_COMPETITORS_MCP_TOKEN}";
          };
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
