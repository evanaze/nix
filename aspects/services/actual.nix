{
  lib,
  pkgs,
  username,
  ...
}: let
  actual-cli = pkgs.buildNpmPackage {
    pname = "actual-cli";
    version = "26.4.0-nightly.20260319";

    src = pkgs.runCommand "actual-cli-src" {} ''
      mkdir -p $out
      tar xzf ${pkgs.fetchurl {
        url = "https://registry.npmjs.org/@actual-app/cli/-/cli-26.4.0-nightly.20260319.tgz";
        hash = "sha256-32ZdtebuEqgycoMbTRuBoAGAK+srq8XUAL8dHfMoaDo=";
      }} -C $out --strip-components=1
      cp ${./actual-cli-package-lock.json} $out/package-lock.json
    '';

    npmDepsHash = "sha256-pH6uVnERlG5QMzsx5wj2CepoCfEyhR3/KJQ5M3y/lsQ=";
    dontNpmBuild = true;

    nativeBuildInputs = [pkgs.makeWrapper];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/actual-cli $out/bin
      cp -r dist node_modules $out/lib/actual-cli/
      makeWrapper ${pkgs.nodejs_22}/bin/node $out/bin/actual \
        --add-flags "$out/lib/actual-cli/dist/cli.js"
      runHook postInstall
    '';

    meta.mainProgram = "actual";
  };
in {
  services.actual = {
    enable = true;
    user = username;
    settings = {
      port = 5006;
    };
  };

  # Service to sync transactions from bank daily at 2 AM
  systemd.timers."actual-sync" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "02:00:00";
      Persistent = true;
      Unit = "actual-sync.service";
    };
  };

  systemd.services."actual-sync" = {
    after = ["actual.service"];
    requires = ["actual.service"];
    description = "Sync Actual Budget bank transactions";
    script = ''
      set -eu
      ${lib.getExe actual-cli} server bank-sync
    '';
    serviceConfig = {
      Type = "oneshot";
      User = username;
    };
  };

  systemd.services.actual-tsserve = {
    after = [
      "tailscaled-autoconnect.service"
      "actual.service"
    ];
    wants = [
      "tailscaled-autoconnect.service"
      "actual.service"
    ];
    wantedBy = ["multi-user.target"];
    description = "Using Tailscale Serve to publish Actual";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = "${lib.getExe pkgs.tailscale} serve --service=svc:budget --https=4432 5006";
  };
}
