let
  module = {
    config,
    lib,
    pkgs,
    ...
  }: let
    glancePort = 8320;
    glanceCaddyPort = 8321;
    tailnet = "spitz-pickerel.ts.net";
  in {
    config = lib.mkIf (config.networking.hostName == "jupiter") {
      sops.secrets.glance = {};

      # Serve Glance through Caddy with an in-memory HTTP page cache so that
      # opening a new tab returns the already-rendered page instantly instead of
      # Glance re-rendering every widget template on each request.
      services.caddy = {
        enable = true;
        virtualHosts."http://:${toString glanceCaddyPort}" = {
          extraConfig = ''
            cache {
              ttl 2m
            }
            reverse_proxy 127.0.0.1:${toString glancePort} {
              header_up X-Forwarded-Proto https
              header_up X-Forwarded-For {remote_host}
              header_up X-Forwarded-Host {host}
            }
          '';
        };
      };

      services.glance = {
        enable = true;
        openFirewall = false;
        environmentFile = config.sops.secrets.glance.path;
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
            "background-color" = "232 23 18";
            "contrast-multiplier" = 1.2;
            "primary-color" = "220 83 75";
            "positive-color" = "105 48 72";
            "negative-color" = "351 74 73";
          };
          pages = [
            {
              name = "Home";
              width = "default";
              "hide-desktop-navigation" = true;
              columns = [
                {
                  size = "small";
                  widgets = [
                    {
                      type = "calendar";
                      first-day-of-week = "sunday";
                    }
                    {
                      type = "custom-api";
                      title = "Donetick Today";
                      title-url = "\${DONETICK_BASE_URL}";
                      cache = "15m";
                      url = "\${DONETICK_BASE_URL}/eapi/v1/chore";
                      headers = {
                        Accept = "application/json";
                        secretkey = "\${DONETICK_API_TOKEN}";
                      };
                      template = ''
                        {{ $today := now.Format "2006-01-02" }}
                        {{ $shown := 0 }}
                        {{ $items := .JSON.Array "" }}

                        {{ if eq (len $items) 0 }}
                          {{ $items = .JSON.Array "res" }}
                        {{ end }}

                        {{ if gt (len $items) 0 }}
                          <ul class="list list-gap-10">
                            {{ range $items }}
                              {{ if and (lt $shown 7) (.Bool "isActive") (.Exists "nextDueDate") }}
                                {{ $due := .String "nextDueDate" | parseTime "rfc3339" }}
                                {{ $dueDate := $due.Format "2006-01-02" }}
                                {{ if eq $dueDate $today }}
                                  {{ $shown = add $shown 1 }}
                                  <li>
                                    <div class="flex items-center gap-10">
                                      <span class="size-h4 color-primary text-truncate">{{ .String "name" }}</span>
                                    </div>
                                  </li>
                                {{ end }}
                              {{ end }}
                            {{ end }}
                          </ul>
                        {{ end }}

                        {{ if eq $shown 0 }}
                          <p class="color-subdue">No tasks due today.</p>
                        {{ end }}
                      '';
                    }
                    {
                      type = "weather";
                      units = "imperial";
                      location = "Denver, Colorado, United States";
                    }
                  ];
                }
                {
                  size = "full";
                  widgets = [
                    {
                      type = "custom-api";
                      title = "Astronomy Picture of the Day";
                      cache = "1d";
                      url = "https://api.nasa.gov/planetary/apod?api_key=\${NASA_API_KEY}";
                      headers = {
                        Accept = "application/json";
                      };
                      template = ''
                        {{- if eq (.JSON.String "media_type") "image" -}}
                          <div style="display:flex; flex-direction:column; justify-content:center; align-items:center; width:100%; height:100%;">
                            <p class="color-primary" style="margin-bottom:8px; font-weight:bold; text-align:center;">
                              <a
                                href="https://apod.nasa.gov/apod/astropix.html"
                                target="_blank"
                                rel="noopener noreferrer"
                                style="color: inherit; text-decoration: none;"
                              >
                                {{ .JSON.String "title" }}
                              </a>
                            </p>
                            <img
                              src="{{ .JSON.String "url" }}"
                              alt="{{ .JSON.String "title" }}"
                              style="max-width:100%; height:auto; display:block; border-radius:4px;"
                            />
                          </div>
                        {{- else -}}
                          <p class="color-negative" style="text-align:center;">No image available today.</p>
                        {{- end }}
                      '';
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
                {
                  size = "small";
                  widgets = [
                    {
                      type = "custom-api";
                      title = "LeetCode Daily Question";
                      cache = "6h";
                      url = "https://leetcode.com/graphql";
                      method = "POST";
                      headers = {
                        Accept = "application/json";
                      };
                      body-type = "json";
                      body = {
                        query = ''
                          query questionOfToday {
                            activeDailyCodingChallengeQuestion {
                              link
                              question {
                                questionId
                                title
                                difficulty
                                paidOnly
                                topicTags {
                                  name
                                  slug
                                }
                              }
                            }
                          }
                        '';
                        operationName = "questionOfToday";
                      };
                      template = ''
                        <div class="leetcode-card">
                          <style>
                            .leetcode-card {
                              max-width: 600px;
                              margin: 8px auto;
                              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                              transition: transform 0.2s ease, box-shadow 0.2s ease;
                            }
                            .leetcode-card h1 {
                              font-size: 24px;
                              margin: 0 0 16px;
                              line-height: 1.3;
                            }
                            .leetcode-card h1 a {
                              color: #8CAAEE;
                              text-decoration: none;
                              transition: color 0.2s ease;
                            }
                            .leetcode-card h1 a:hover {
                              color: #BAC8FF;
                              text-decoration: underline;
                            }
                            .leetcode-card p {
                              margin: 8px 0;
                              color: #C6D0F5;
                              font-size: 16px;
                            }
                            .leetcode-card .difficulty {
                              font-weight: 600;
                              color: #A5ADCE;
                            }
                            .leetcode-card .difficulty.Easy {
                              color: #A6D189;
                            }
                            .leetcode-card .difficulty.Medium {
                              color: #E5C890;
                            }
                            .leetcode-card .difficulty.Hard {
                              color: #E78284;
                            }
                            .leetcode-card .topics {
                              display: flex;
                              flex-wrap: wrap;
                              gap: 8px;
                              margin: 12px 0;
                            }
                            .leetcode-card .topic-tag {
                              background: #CA9EE6;
                              color: #303446;
                              padding: 4px 12px;
                              border-radius: 16px;
                              font-size: 14px;
                              font-weight: 500;
                              transition: transform 0.2s ease;
                            }
                            .leetcode-card .topic-tag:hover {
                              transform: scale(1.05);
                            }
                            .leetcode-card .premium {
                              color: #E78284;
                              font-weight: 600;
                              margin-top: 12px;
                            }
                            @media (max-width: 600px) {
                              .leetcode-card {
                                padding: 16px;
                                margin: 8px;
                              }
                              .leetcode-card h1 {
                                font-size: 20px;
                              }
                              .leetcode-card p {
                                font-size: 14px;
                              }
                              .leetcode-card .topic-tag {
                                font-size: 12px;
                                padding: 3px 10px;
                              }
                            }
                          </style>
                          <h1>
                            <a href="https://leetcode.com{{ .JSON.String "data.activeDailyCodingChallengeQuestion.link" }}" target="_blank">
                              {{ .JSON.String "data.activeDailyCodingChallengeQuestion.question.questionId" }} - {{ .JSON.String "data.activeDailyCodingChallengeQuestion.question.title" }}
                            </a>
                          </h1>
                          <p class="difficulty {{ .JSON.String "data.activeDailyCodingChallengeQuestion.question.difficulty" }}"><strong>Difficulty:</strong> {{ .JSON.String "data.activeDailyCodingChallengeQuestion.question.difficulty" }}</p>
                          <p><strong>Topics:</strong></p>
                          <div class="topics">
                            {{ if .JSON.Exists "data.activeDailyCodingChallengeQuestion.question.topicTags" }}
                              {{ range .JSON.Array "data.activeDailyCodingChallengeQuestion.question.topicTags" }}
                                <span class="topic-tag">{{ .String "name" }}</span>
                              {{ end }}
                            {{ else }}
                              <span class="topic-tag">None</span>
                            {{ end }}
                          </div>
                          {{ if .JSON.Bool "data.activeDailyCodingChallengeQuestion.question.paidOnly" }}
                            <p class="premium">This is a Premium question</p>
                          {{ end }}
                        </div>
                      '';
                    }
                    {
                      type = "custom-api";
                      title = "Trending Media";
                      title-url = "\${OVERSEERR_URL}/discover/trending";
                      url = "\${OVERSEERR_URL}/api/v1/discover/trending";
                      cache = "15m";
                      headers = {
                        accept = "application/json";
                        x-api-key = "\${OVERSEERR_API_KEY}";
                      };
                      parameters = {
                        language = "en";
                        page = "1";
                      };
                      options = {
                        show-media-type = true;
                        show-media-desc = true;
                      };
                      template = ''
                        {{ $showMediaType := .Options.BoolOr "show-media-type" true }}
                        {{ $showMediaDesc := .Options.BoolOr "show-media-desc" true }}

                        {{ if eq .Response.StatusCode 200 }}
                          {{ $items := .JSON.Array "results" }}
                          {{ if gt (len $items) 0 }}
                            <ul class="list list-gap-10 collapsible-container" data-collapse-after="5">
                            {{ range $items }}
                              <li class="flex items-start gap-10 thumbnail-container thumbnail-parent">
                                {{ $mediaType := .String "mediaType" }}
                                {{ $mediaTitle := "" }}
                                {{ $mediaTypeUpper := "" }}
                                {{ if eq $mediaType "movie" }} {{ $mediaTitle = .String "title" }} {{ $mediaTypeUpper = "Movie" }}{{ else }}{{ $mediaTitle = .String "name" }} {{ $mediaTypeUpper = "TV" }}{{ end }}
                                {{ $overseerrUrl := concat "''${OVERSEERR_URL}" "/" $mediaType "/" ( .String "id" ) }}
                                {{ $tmdbUrl := concat "https://www.themoviedb.org" "/" $mediaType "/" ( .String "id" ) }}
                                <a href={{ $overseerrUrl }} target="_blank">
                                <img src={{ concat "https://image.tmdb.org/t/p/w300" (.String "posterPath") }} style="border-radius: 5px; min-width: 5rem; max-width: 5rem;" class="card">
                                </a>
                                <div class="flex-1" style="padding-right: 5px;">
                                  <p class="color-positive size-h4 text-truncate-2-lines margin-top-5" title="{{ $mediaTitle }}"><a href={{ $overseerrUrl }} target="_blank">{{ $mediaTitle }}</a></p>
                                  <p class="size-h4" title="TMDB Rating"><a href={{ $tmdbUrl }} target="_blank">TMDB: {{ mul (.Float "voteAverage") 10 | toInt }}% {{ if $showMediaType }}| {{ $mediaTypeUpper }}{{ end }}</a></p>
                                  {{ if $showMediaDesc }}<p class="color-subdue size-h4 text-truncate-2-lines" title="{{ .String "overview" }}">{{ .String "overview" }}</p>{{ end }}
                                </div>
                              </li>
                            {{ end }}
                            </ul>
                          {{ else }}
                            <details style="margin-top:0.5rem">
                              <summary> Raw JSON:</summary>
                              <pre stye="font-size:10px">
                          {{ (printf "%+v" .JSON) }}
                              </pre>
                            </details>
                          {{ end }}
                        {{ end }}
                      '';
                    }
                    {
                      type = "custom-api";
                      title = "Tailscale Devices";
                      title-url = "https://login.tailscale.com/admin/machines";
                      url = "https://api.tailscale.com/api/v2/tailnet/-/devices";
                      headers = {
                        Authorization = "Bearer \${TAILSCALE_API_KEY}";
                      };
                      cache = "10m";
                      options = {};
                      template = ''
                        <style>
                          .device-info-container-tailscale {
                            position: relative;
                            overflow: hidden;
                            height: 1.5em;
                          }

                          .device-info-tailscale {
                            display: flex;
                            transition: transform 0.2s ease, opacity 0.2s ease;
                          }

                          .device-ip-tailscale {
                            position: absolute;
                            top: 0;
                            left: 0;
                            transform: translateY(-100%);
                            opacity: 0;
                            transition: transform 0.2s ease, opacity 0.2s ease;
                          }

                          .device-info-container-tailscale:hover .device-info-tailscale {
                            transform: translateY(100%);
                            opacity: 0;
                          }

                          .device-info-container-tailscale:hover .device-ip-tailscale {
                            transform: translateY(0);
                            opacity: 1;
                          }

                          .update-indicator-tailscale {
                            width: 8px;
                            height: 8px;
                            border-radius: 50%;
                            background-color: var(--color-primary);
                            display: inline-block;
                            margin-left: 4px;
                            vertical-align: middle;
                          }

                          .offline-indicator-tailscale {
                            width: 8px;
                            height: 8px;
                            border-radius: 50%;
                            background-color: var(--color-negative);
                            display: inline-block;
                            margin-left: 4px;
                            vertical-align: middle;
                          }

                          .device-name-container-tailscale {
                            display: flex;
                            align-items: center;
                            gap: 8px;
                          }

                          .indicators-container-tailscale {
                            display: flex;
                            align-items: center;
                            gap: 4px;
                          }
                        </style>
                        <ul class="list list-gap-10 collapsible-container" data-collapse-after="{{ .Options.IntOr "collapseAfter" 3 }}">
                          {{ range .JSON.Array "devices" }}
                          <li>
                            <div class="flex items-center gap-10">
                              <div class="device-name-container-tailscale grow">
                                <span class="size-h4 block text-truncate color-primary">
                                  {{ findMatch "^([^.]+)" (.String "name") }}
                                </span>
                                <div class="indicators-container-tailscale">
                                  {{ if and (not ($.Options.BoolOr "disableUpdateIndicator" false)) (.Bool "updateAvailable") }}
                                  <span class="update-indicator-tailscale" data-popover-type="text" data-popover-text="Update Available"></span>
                                  {{ end }}

                                  {{ if not ($.Options.BoolOr "disableOfflineIndicator" false) }}
                                  {{ $lastSeen := .String "lastSeen" | parseTime "rfc3339" }}
                                  {{ if not ($lastSeen.After (offsetNow "-10s")) }}
                                  {{ $lastSeenTimezoned := $lastSeen.In now.Location }}
                                  <span class="offline-indicator-tailscale" data-popover-type="text"
                                    data-popover-text="Offline - Last seen {{ $lastSeenTimezoned.Format " Jan 2 3:04pm" }}"></span>
                                  {{ end }}
                                  {{ end }}

                                </div>
                              </div>
                            </div>
                            <div class="device-info-container-tailscale">
                              <ul class="list-horizontal-text device-info-tailscale">
                                <li>{{ .String "os" }}</li>
                                <li>
                                  {{ if and ($.Options.BoolOr "prioritiseTags" false) (.Exists "tags.0") }}
                                    {{ trimPrefix "tag:" (.String "tags.0") }}
                                  {{ else }}
                                    {{ .String "user" }}
                                  {{ end }}
                                </li>
                              </ul>
                              <div class="device-ip-tailscale">
                                {{ .String "addresses.0"}}
                              </div>
                            </div>
                          </li>
                          {{ end }}
                        </ul>
                      '';
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
          "caddy.service"
          "glance.service"
        ];
        wants = [
          "tailscaled-autoconnect.service"
          "tailscaled.service"
          "caddy.service"
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
          ${lib.getExe pkgs.tailscale} serve --service=svc:home --https=443 http://127.0.0.1:${toString glanceCaddyPort}
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
