let
  module = {pkgs, ...}: {
    # https://github.com/leejet/stable-diffusion.cpp
    environment.systemPackages = [pkgs.stable-diffusion-cpp-cuda];
  };
in {
  flake.modules.nixos = {
    aiStableDiffusionCpp = module;
    aiServer = module;
  };
}
