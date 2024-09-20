{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cron
    devenv
    git
    htop
    meslo-lgs-nf
    unzip
    wget
  ];
}
