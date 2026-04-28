# aspects/ai/default.nix - AI services configuration aggregator
{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    pi-coding-agent
  ];
}
