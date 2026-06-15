{
  flake.modules.nixos.smartctlExporter = {...}: {
  services.prometheus.exporters.smartctl = {
    enable = true;
    port = 9633;
  };
};
}
