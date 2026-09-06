let
  module = {
    lib,
    pkgs,
    ...
  }: {
    services.caddy = {
      enable = true;

      # Caddy built with the Souin (cache-handler) plugin so pages (e.g. Glance)
      # can be served from an in-memory HTTP cache. Opening a new tab then serves
      # the already-rendered page instantly instead of re-rendering every widget
      # template on each request. The cache only activates where a `cache`
      # directive is present, so other virtual hosts are unaffected.
      package = lib.mkDefault (pkgs.caddy.withPlugins {
        plugins = ["github.com/caddyserver/cache-handler@v0.16.0"];
        hash = "sha256-41uiGaunQpwi2vpK+Kuy4eGpbTqjSdRhekPT1UeT9AY=";
      });
    };
  };
in {
  flake.modules.nixos = {
    servicesCaddy = module;
    services = module;
  };
}
