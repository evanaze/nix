# aspects/core/packages.nix - Common system packages
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    cachix
    cron
    devenv
    dig
    expect
    git
    htop
    lsof
    meslo-lgs-nf
    nmap
    tree
    unzip
    wget
  ];
}
