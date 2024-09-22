{
  pkgs,
  pkgs-24,
  ...
}: {
  environment.systemPackages = with pkgs; [
    cron
    pkgs-24.devenv
    git
    htop
    meslo-lgs-nf
    unzip
    wget
  ];

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    ipv4 = true;
    ipv6 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
