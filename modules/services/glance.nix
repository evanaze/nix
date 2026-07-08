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
      sops.secrets.glance = {};

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
                {
                  size = "full";
                  widgets = [
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
                  ];
                }
                {
                  size = "small";
                  widgets = [
                    {
                      type = "calendar";
                      first-day-of-week = "sunday";
                    }
                    {
                      type = "custom-api";
                      title = "Weather Forecast";
                      body-type = "string";
                      cache = "1h";
                      options = {
                        location = "\${WEATHER_LOCATION}";
                      };
                      template = ''
                        {{/* THESE VALUES CAN BE CHANGED BY ADDING AN ENTRY TO THE OPTIONS SECTION */}}
                          {{ $temp_unit := .Options.StringOr "temp_unit" "celsius" }}
                          {{ $weekend_color := .Options.StringOr "weekend_color" "var(--color-separator)" }}
                          {{ $overlay_color := .Options.StringOr "overlay_color" "hsl(var(--bghs), var(--bgl), 50%)" }}
                          {{/* the following variables define the coloring of the sunny/cloudy/etc. weather icons*/}}
                            {{ $color_clear := .Options.StringOr "color_clear" "var(--color-text-highlight)" }}
                            {{ $color_partly := .Options.StringOr "color_partly" "var(--color-text-highlight)"}}
                            {{ $color_cloud := .Options.StringOr "color_cloud" "var(--color-text-highlight)"}}
                            {{ $color_smog := .Options.StringOr "color_smog" "var(--color-text-highlight)"}}
                            {{ $color_drizzle := .Options.StringOr "color_drizzle" "var(--color-text-highlight)"}}
                            {{ $color_rain := .Options.StringOr "color_rain" "var(--color-text-highlight)"}}
                            {{ $color_freezing_rain := .Options.StringOr "color_freezing_rain" "var(--color-text-highlight)"}}
                            {{ $color_snow := .Options.StringOr "color_snow" "var(--color-text-highlight)F"}}
                            {{ $color_thunderstorm := .Options.StringOr "color_thunderstorm" "var(--color-text-highlight)"}}
                            {{ $color_other := .Options.StringOr "color_other" "var(--color-text-highlight)"}}
                          {{/* the following variables define the temperature gradient coloring for the daily rectangles */}}
                          {{ $color_red := .Options.StringOr "color_red" "var(--color-negative)" }}
                          {{ $color_yellow := .Options.StringOr "color_yellow" "var(--color-text-subdue)" }}
                          {{ $color_blue := .Options.StringOr "color_blue" "var(--color-positive)" }}
                          {{ $color_white := .Options.StringOr "color_white" "var(--color-text-highlight)" }}
                          {{ $temp_red := .Options.FloatOr "temp_red" 27 }}
                          {{ $temp_yellow := .Options.FloatOr "temp_yellow" 20 }}
                          {{ $temp_blue := .Options.FloatOr "temp_blue" 10.0 }}
                          {{ $temp_white := .Options.FloatOr "temp_white" 0 }}
                          {{ if eq $temp_unit "fahrenheit" }}
                            {{ $temp_red = .Options.FloatOr "temp_red" 80.0 }}
                            {{ $temp_yellow = .Options.FloatOr "temp_yellow" 70.0 }}
                            {{ $temp_blue = .Options.FloatOr "temp_blue" 50.0 }}
                            {{ $temp_white = .Options.FloatOr "temp_white" 30.0 }}
                          {{end}}

                        {{/* Request 1: get latitude and longitude for user's city */}}
                        {{ $location_string := replaceAll " " "%20" (.Options.StringOr "location" "") }}
                        {{ $url1 := printf "https://geocoding-api.open-meteo.com/v1/search?name=%s&count=20&language=en&format=json" $location_string }}
                        {{ $req1 := newRequest $url1 | getResponse }}
                        {{ $latitude := $req1.JSON.String "results.0.latitude" }}
                        {{ $longitude := $req1.JSON.String "results.0.longitude" }}

                        {{/* Request 2: get daily weather forecast based on latitude and longitude */}}
                        {{ $url2 := printf "https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&temperature_unit=%s&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=America/New_York" $latitude $longitude $temp_unit}}
                        {{ $req2 := newRequest $url2 | getResponse }}

                        <div style="display: flex; justify-content: center; align-items: center; flex-direction: column;">

                          {{/* Show abbreivated day of week */}}
                          {{ $dates := $req2.JSON.Array "daily.time" }}
                          <div style="position: relative; width: 100%; height: 25px;">
                            {{ range $index, $date := $dates }}

                              {{/* prepare to print M Tu W Th F Sa Su */}}
                              {{ $dateString := .String "" }}
                              {{ $parsedDate := $dateString | parseTime "DateOnly" }}
                              {{ $dayOfWeek := $parsedDate.Format "Monday" | trimSuffix "day" | trimSuffix "on" | trimSuffix "es" | trimSuffix "edn" |
                                  trimSuffix "urs" | trimSuffix "ri" | trimSuffix "tur" | trimSuffix "n" }}

                              {{/* highlight weekends (Sa Su) */}}
                              {{ $day_color := "" }}
                              {{ if eq $dayOfWeek "Sa" "Su" }}
                                {{ $day_color = $weekend_color }}
                              {{ end }}

                              <div style="text-align: center; width: 10%; height: 25px; line-height: 25px; margin: 0 10% 0 3%; left: {{ mul $index 14 }}%; position: absolute; background-color: {{ $day_color | safeCSS }} ">
                                <p class="size-h4 color-paragraph">{{ $dayOfWeek }}</p>
                              </div>
                            {{ end }}
                          </div>

                          {{/* Show numeric day of month */}}
                          <div style="position: relative; width: 100%; height: 25px;">
                            {{ range $index, $date := $dates }}
                              {{ $dateString := .String "" }}
                              {{ $trimmedDate := replaceMatches "[0-9]+-[0-9]+-" "" $dateString }}
                              <div style="text-align: center; width: 10%; height: 25px; line-height: 25px; margin: 0 10% 0 3%; left: {{ mul $index 14 }}%; position: absolute;">
                                <p class="size-h4 color-paragraph">{{ $trimmedDate }}</p>
                              </div>
                            {{ end }}
                          </div>

                          {{/* Show weather conditions using fontawesome icons */}}
                          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
                          {{ $codes := $req2.JSON.Array "daily.weathercode" }}

                          <div style="position: relative; width: 100%; height: 30px;">
                            {{ range $index, $thiscode := $codes }}
                              {{ $code := .Int "" }}

                              <div style="text-align: center; width: 10%; height: 25px; line-height: 25px; margin: 0 10% 0 3%; left: {{ mul $index 14 }}% ; position: absolute;">
                              {{ $wtype := "" }}
                              {{ $wicon := "" }}
                              {{ $wcolor := "" }}
                              {{ if eq $code 0 }}
                                {{ $wtype = "Clear" }}
                                {{ $wicon = "fas fa-sun" }}
                                {{ $wcolor = $color_clear }}
                              {{ else if eq $code 1 2 }}
                                {{ $wtype = "Part Clear" }}
                                {{ $wicon = "fas fa-cloud-sun" }}
                                {{ $wcolor = $color_partly }}
                              {{ else if eq $code 3 }}
                                {{ $wtype = "Cloudy" }}
                                {{ $wicon = "fas fa-cloud" }}
                                {{ $wcolor = $color_cloud }}
                              {{ else if eq $code 45 48 }}
                                {{ $wtype = "Fog" }}
                                {{ $wicon = "fas fa-smog" }}
                                {{ $wcolor = $color_smog }}
                              {{ else if eq $code 51 53 55 56 57 }}
                                {{ $wtype = "Drizzle" }}
                                {{ $wicon = "fas fa-cloud-rain" }}
                                {{ $wcolor = $color_drizzle }}
                              {{ else if eq $code 61 63 65 80 81 82 }}
                                {{ $wtype = "Rain" }}
                                {{ $wicon = "fas fa-cloud-showers-heavy" }}
                                {{ $wcolor = $color_rain }}
                              {{ else if eq $code 66 67 }}
                                {{ $wtype = "Freezing Rain" }}
                                {{ $wicon = "fas fa-snowflake" }}
                                {{ $wcolor = $color_freezing_rain }}
                              {{ else if eq $code 71 73 75 77 85 86 }}
                                {{ $wtype = "Snow" }}
                                {{ $wicon = "fas fa-snowman" }}
                                {{ $wcolor = $color_snow }}
                              {{ else if eq $code 95 96 99 }}
                                {{ $wtype = "Thunderstorm" }}
                                {{ $wicon = "fas fa-bolt" }}
                                {{ $wcolor = $color_thunderstorm }}
                              {{ else }}
                                {{ $wtype = "Other" }}
                                {{ $wicon = "fa-solid fa-question" }}
                                {{ $wcolor = $color_other }}
                              {{ end }}
                              <i class={{ $wicon }} style="font-size: 20px; color: {{ $wcolor | safeCSS }};" title = {{$wtype }}></i>
                              </div>
                            {{ end }}
                          </div>
                        </div>

                        {{/* ===== show daily min and max temperatures ===== */}}
                        {{ $maxTemps := $req2.JSON.Array "daily.temperature_2m_max" }}
                        {{ $minTemps := $req2.JSON.Array "daily.temperature_2m_min" }}

                        {{/* get overall max and min temp over week's range */}}
                        {{/* to determine vertical scale */}}
                        <div style="display: flex; justify-content: flex-start; align-items: center;">

                          {{ $max_max := 0 }}
                          {{ range $maxTemps }}
                              {{ if gt (.Int "") $max_max }}
                                {{ $max_max = (.Int "") }}
                              {{ end }}
                          {{ end }}
                          {{ $min_min := 999 }}
                          {{ range $minTemps }}
                              {{ if lt (.Int "") $min_min }}
                                {{ $min_min = (.Int "") }}
                              {{ end }}
                          {{ end }}

                          {{/* add a small buffer */}}
                          {{ $max_max = add $max_max 1 }}
                          {{ $min_min = sub $min_min 1 }}

                          {{/* outer div to contain the temp chart */}}
                          <div style="position: relative; width: 100%; height: 75px;">
                            {{/* get relative % heights for each daily max and min */}}
                            {{ $temp_range := sub $max_max $min_min }}

                            {{ range $index, $thisHigh := $maxTemps }}
                                {{ $thisLow := index $minTemps $index }}
                                {{ $thisHigh = $thisHigh.Float "" }}
                                {{ $thisLow = $thisLow.Float "" }}

                                {{ $thisHighPct := sub 1 (div (sub $max_max $thisHigh) $temp_range) }}
                                {{ $thisLowPct := div (sub $thisLow $min_min) $temp_range }}

                                {{/* define color gradient per. values between $temp_red and $temp_yellow are shown as a color gradient from $color_red to $color_yellow */}}
                                {{/* for colors partially in range, can represent as negative percent */}}
                                {{ $thisTempRange := sub $thisHigh $thisLow }}
                                {{ $red_pos := mul 100 (div (sub $thisHigh $temp_red) $thisTempRange) | toInt }}
                                {{ $yel_pos := mul 100 (div (sub $thisHigh $temp_yellow) $thisTempRange) | toInt }}
                                {{ $blu_pos := mul 100 (div (sub $thisHigh $temp_blue) $thisTempRange) | toInt }}
                                {{ $whi_pos := mul 100 (div (sub $thisHigh $temp_white) $thisTempRange) | toInt }}
                                {{ $gradient_string := printf "%s %d%%, %s %d%%, %s %d%%, %s %d%%" $color_red $red_pos $color_yellow $yel_pos $color_blue $blu_pos $color_white $whi_pos }}

                                {{/* output daily div */}}
                                <div style="left: {{ mul $index 14 | add 3 }}%; bottom: {{ mul $thisLowPct 100 | toInt }}%;
                                  height: {{ mul (sub $thisHighPct $thisLowPct) 100 | toInt }}%; position: absolute;
                                  background:linear-gradient({{ $gradient_string | safeCSS }}); width: 10%; text-align: center; border-radius: 10px;">

                                  {{/* Based on rectangle height & position, print high and low temperatures either inside or outside the rectangle. */}}
                                  {{ $top_pos := -2 }}
                                  {{ $bot_pos := -2 }}
                                  {{ $pos_thresh := 0.20 }}
                                  {{ if lt (div $thisTempRange $temp_range) $pos_thresh }}
                                    {{ $top_pos = -17 }}
                                    {{ $bot_pos = -19 }}
                                  {{ else if and (lt (div $thisTempRange $temp_range) (mul $pos_thresh 2)) (lt (sub 1 $thisHighPct) $thisLowPct) }}
                                    {{ $bot_pos = -19 }}
                                  {{ else if and (lt (div $thisTempRange $temp_range) (mul $pos_thresh 2)) (gt (sub 1 $thisHighPct) $thisLowPct) }}
                                    {{ $top_pos = -17 }}
                                  {{ end }}
                                    <div style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; background-color: {{ $overlay_color | safeCSS }}; z-index: 1;  border-radius: 10px;">
                                      <p style='color: #F0F0F0; position: absolute; top: {{ $top_pos }}px; left: 0px; right: 0px'>{{ $thisHigh | toInt }}</p>
                                      <p style='color: #F0F0F0; position: absolute; bottom: {{ $bot_pos }}px; left: 0px; right:0px'>{{ $thisLow | toInt }}</p>
                                    </div>
                                  </div>
                            {{ end }}

                          </div>
                        </div>
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
