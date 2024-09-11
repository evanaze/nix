{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cron
    git
    htop
    meslo-lgs-nf
    unzip
    wget
  ];
}
