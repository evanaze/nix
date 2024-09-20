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
}
