let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    glancePort = 8320;
    tailnet = "spitz-pickerel.ts.net";
  in {
    config = lib.mkIf (config.networking.hostName == "jupiter") {
      services.glance = {
        enable = true;
        openFirewall = false;
        settings = {
          server = {
            host = "127.0.0.1";
            port = glancePort;
            proxied = true;
          };
          branding = {
            "app-name" = "Home";
            "logo-text" = "⌂";
          };
          theme = {
            "background-color" = "240 8 9";
            "primary-color" = "43 50 70";
            "contrast-multiplier" = 1.1;
          };
          pages = [
            {
              name = "Home";
              width = "slim";
              "hide-desktop-navigation" = true;
              columns = [
                {
                  size = "full";
                  widgets = [
                    {
                      type = "search";
                      autofocus = true;
                    }
                    {
                      type = "monitor";
                      title = "Services";
                      cache = "1m";
                      sites = [
                        {
                          title = "AI";
                          url = "https://ai.${tailnet}";
                          icon = "mdi:brain";
                        }
                        {
                          title = "Budget";
                          url = "https://budget.${tailnet}";
                          icon = "mdi:cash";
                        }
                        {
                          title = "Media";
                          url = "https://media.${tailnet}";
                          icon = "si:jellyfin";
                        }
                        {
                          title = "Photos";
                          url = "https://photos.${tailnet}";
                          icon = "si:immich";
                        }
                        {
                          title = "Memory";
                          url = "https://memory.${tailnet}";
                          icon = "mdi:database-search";
                        }
                        {
                          title = "Monitoring";
                          url = "https://monitoring.${tailnet}";
                          icon = "si:grafana";
                        }
                      ];
                    }
                    {
                      type = "bookmarks";
                      groups = [
                        {
                          title = "Server";
                          links = [
                            {
                              title = "Search";
                              url = "https://search.${tailnet}";
                            }
                            {
                              title = "Todo";
                              url = "https://todo.${tailnet}";
                            }
                            {
                              title = "Alerts";
                              url = "https://alerts.${tailnet}";
                            }
                            {
                              title = "Cache";
                              url = "https://cache.${tailnet}";
                            }
                          ];
                        }
                        {
                          title = "Common";
                          links = [
                            {
                              title = "GitHub";
                              url = "https://github.com";
                            }
                            {
                              title = "NixOS Search";
                              url = "https://search.nixos.org";
                            }
                            {
                              title = "Tailscale";
                              url = "https://login.tailscale.com/admin/machines";
                            }
                          ];
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        };
      };

      systemd.services.glance-tsserve = {
        after = [
          "tailscaled-autoconnect.service"
          "tailscaled.service"
          "glance.service"
        ];
        wants = [
          "tailscaled-autoconnect.service"
          "tailscaled.service"
          "glance.service"
        ];
        wantedBy = ["multi-user.target"];
        description = "Using Tailscale Serve to publish Glance";
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "10s";
        };
        script = ''
          ${lib.getExe pkgs.tailscale} serve clear svc:home || true
          ${lib.getExe pkgs.tailscale} serve --service=svc:home --https=443 http://127.0.0.1:${toString glancePort}
        '';
      };
    };
  };
in {
  flake.modules.nixos = {
    servicesGlance = module;
    services = module;
  };
}
