{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cron
    devenv
    git
    htop
    meslo-lgs-nf
    unzip
    vim
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
