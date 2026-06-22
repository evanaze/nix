{
  description = "NixOS configuration - Dendritic Pattern";

  nixConfig = {
    extra-substituters = ["https://cache.spitz-pickerel.ts.net"];
    extra-trusted-public-keys = ["cache:+h9wYaxp+qMa0hHTTnh3cAPmn1DmvlPDj27dfEh+6kA="];
    connect-timeout = 5;
  };

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      flake-parts.url = "github:hercules-ci/flake-parts";
      import-tree.url = "github:vic/import-tree";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixflix = {
      url = "github:kiriwalawren/nixflix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    openviking = {
      url = "github:Daaboulex/openviking-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    slippi = {
      url = "github:lytedev/slippi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    camoufox-nix = {
      url = "github:maximoffua/camoufox-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty = {
      url = "github:ghostty-org/ghostty";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llama-cpp = {
      url = "github:ggml-org/llama.cpp/04eb4c446d22b63449d5dc41c038987d4d8cc3a6";
      };
    };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);
}
