let
  module = {pkgs, ...}: {
    # https://github.com/leejet/stable-diffusion.cpp
    #
    # nixos-26.05 ships master-625-f683c88 (2026-05-18), which predates Qwen
    # Image 2.1 support (upstream PR #1994, 2026-09-20). Override src to a
    # current master so sd-cli can load qwen_image_2.1 weights. Remove this
    # override once the channel catches up.
    environment.systemPackages = [
      (pkgs.stable-diffusion-cpp-cuda.overrideAttrs (old: {
        version = "master-8cd731e";
        src = pkgs.fetchFromGitHub {
          owner = "leejet";
          repo = "stable-diffusion.cpp";
          rev = "8cd731e7b4667eb8f40a153315b9a7125d09a58d";
          fetchSubmodules = true;
          hash = "sha256-NZUNtYNSDhAEpm+4Ja/RD/0ynZAGynczBcrjxo234+Y=";
        };
      }))
    ];
  };
in {
  flake.modules.nixos = {
    aiStableDiffusionCpp = module;
    aiServer = module;
  };
}
