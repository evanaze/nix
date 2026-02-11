{pkgs, ...}: {
  llama-cpp =
    (pkgs.llama-cpp.override {
      cudaSupport = true;
      rocmSupport = false;
      metalSupport = false;
      # Enable BLAS for optimized CPU layer performance (OpenBLAS)
      blasSupport = true;
    }).overrideAttrs
    (oldAttrs: rec {
      version = "7205";
      src = pkgs.fetchFromGitHub {
        owner = "ggml-org";
        repo = "llama.cpp";
        tag = "b${version}";
        hash = "sha256-1CcYbc8RWAPVz8hoxKEmbAgQesC1oGFZ3fhfuU5vmOc=";
        leaveDotGit = true;
        postFetch = ''
          git -C "$out" rev-parse --short HEAD > $out/COMMIT
          find "$out" -name .git -print0 | xargs -0 rm -rf
        '';
      };
      # Enable native CPU optimizations (AVX, AVX2, etc.)
      cmakeFlags =
        (oldAttrs.cmakeFlags or [])
        ++ [
          "-DGGML_NATIVE=ON"
        ];
      # Disable Nix's march=native stripping
      preConfigure = ''
        export NIX_ENFORCE_NO_NATIVE=0
        ${oldAttrs.preConfigure or ""}
      '';
    });

  # llama-swap from GitHub releases
  llama-swap = pkgs.runCommand "llama-swap" {} ''
    mkdir -p $out/bin
    tar -xzf ${
      pkgs.fetchurl {
        url = "https://github.com/mostlygeek/llama-swap/releases/download/v175/llama-swap_175_linux_amd64.tar.gz";
        hash = "sha256-zeyVz0ldMxV4HKK+u5TtAozfRI6IJmeBo92IJTgkGrQ=";
      }
    } -C $out/bin
    chmod +x $out/bin/llama-swap
  '';

  # Configure llama-swap as a systemd service
  systemd.services.llama-swap = {
    description = "llama-swap - OpenAI compatible proxy with automatic model swapping";
    after = ["network.target"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "simple";
      User = "basnijholt";
      Group = "users";
      # Point to your declarative config file
      ExecStart = "${pkgs.llama-swap}/bin/llama-swap --config /etc/llama-swap/config.yaml --listen 0.0.0.0:9292 --watch-config";
      Restart = "always";
      RestartSec = 10;

      # Environment for CUDA support
      Environment = [
        "PATH=/run/current-system/sw/bin"
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
      ];
    };
  };
}
