{
  lib,
  autoAddDriverRunpath,
  cmake,
  fetchFromGitHub,
  installShellFiles,
  stdenv,

  config,
  cudaSupport ? config.cudaSupport,
  cudaPackages ? { },

  metalSupport ? stdenv.hostPlatform.isDarwin,

  ninja,
  openssl,
  pkg-config,
  perl,
}:

let
  effectiveStdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;
  inherit (lib)
    cmakeBool
    cmakeFeature
    optionals
    optionalString
    ;

  cudaBuildInputs = with cudaPackages; [
    cuda_cudart
    libcublas
  ];
in
effectiveStdenv.mkDerivation (finalAttrs: {
  pname = "llama-prisma";
  version = "0-unstable-2026-07-14";

  src = fetchFromGitHub {
    owner = "PrismML-Eng";
    repo = "llama.cpp";
    rev = "62061f91088281e65071cc38c5f69ee95c39f14e";
    hash = "sha256-pJ/2tfNxe0Ujs5OTBc0tyIjlBAK/vZMrIhLhgxPldYw=";
  };

  nativeBuildInputs = [
    cmake
    installShellFiles
    ninja
    pkg-config
    perl
  ]
  ++ optionals cudaSupport [
    cudaPackages.cuda_nvcc
    autoAddDriverRunpath
  ];

  buildInputs =
    [ openssl ]
    ++ optionals cudaSupport cudaBuildInputs;

  cmakeFlags = [
    (cmakeBool "GGML_NATIVE" false)
    (cmakeBool "LLAMA_BUILD_EXAMPLES" false)
    (cmakeBool "LLAMA_BUILD_SERVER" true)
    (cmakeBool "LLAMA_BUILD_TESTS" false)
    (cmakeBool "LLAMA_OPENSSL" true)
    (cmakeBool "BUILD_SHARED_LIBS" false)
    (cmakeBool "GGML_CUDA" cudaSupport)
    (cmakeBool "GGML_METAL" metalSupport)
    # Build CPU backend variants for runtime dispatch
    (cmakeBool "GGML_CPU_ALL_VARIANTS" true)
    (cmakeBool "GGML_BACKEND_DL" true)
  ]
  ++ optionals cudaSupport [
    (cmakeFeature "CMAKE_CUDA_ARCHITECTURES" cudaPackages.flags.cmakeCudaArchitecturesString)
  ]
  ++ optionals metalSupport [
    # PrismML fork includes custom Metal kernels for Q2_0_g128
    (cmakeBool "LLAMA_METAL_EMBED_LIBRARY" true)
  ];

  postInstall = ''
    # Install CLI binary (not in default install target when BUILD_SHARED_LIBS=OFF)
    install -Dm755 bin/llama-cli "$out/bin/llama-cli"
    install -Dm755 bin/llama-server "$out/bin/llama-server"
    # Install benchmark tool if built
    install -Dm755 bin/llama-bench "$out/bin/llama-bench" || true
    # Install gguf-split tool if built
    install -Dm755 bin/llama-gguf-split "$out/bin/llama-gguf-split" || true
    # Install speculative decoding tool if built
    install -Dm755 bin/llama-speculative "$out/bin/llama-speculative" || true

    # Install header for development
    mkdir -p $out/include
    cp $src/include/llama.h $out/include/
    cp $src/ggml/include/ggml.h $out/include/ 2>/dev/null || true

    # Install shell completions
    $out/bin/llama-server --completion-bash > /tmp/llama-server.bash 2>/dev/null || true
    installShellCompletion --cmd llama-server --bash /tmp/llama-server.bash 2>/dev/null || true
  '';

  doCheck = false;

  meta = {
    description = "PrismML-Eng fork of llama.cpp with custom Q2_0_g128 hybrid-attention kernels for Bonsai ternary models";
    longDescription = ''
      PrismML-Eng fork of llama.cpp that includes custom low-bit kernels for
      Q2_0_g128 ternary weight format, enabling efficient inference of Prism ML's
      Bonsai ternary-weight models (e.g., Ternary-Bonsai-27B). Supports CUDA and
      Metal backends with hybrid-attention acceleration.
    '';
    homepage = "https://github.com/PrismML-Eng/llama.cpp";
    license = lib.licenses.mit;
    mainProgram = "llama-cli";
    platforms = lib.platforms.unix;
  };
})