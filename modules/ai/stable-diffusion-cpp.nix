{pkgs, ...}: let
  module = {
    environment.systemPackages = [pkgs.stable-diffusion-cpp-cuda];
  };
in {
  flake.modules.nixos = {
    aiStableDiffusionCpp = module;
    aiServer = module;
  };
}
