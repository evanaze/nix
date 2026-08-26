{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  protobuf,
  openssl,
  libclang,
  perl,
}:
rustPlatform.buildRustPackage {
  pname = "dragonfly-gguf-client";
  version = "0-unstable-2026-06-29";

  src = fetchFromGitHub {
    owner = "JustDory";
    repo = "dragonfly-gguf-client";
    rev = "43bda5801c2f97e1ebb8d7ccdb920572ee965237";
    hash = "sha256-dB4+UEXLwJGeUcmkDF/PdQDnTWxKQZibIcnKJZLm9oA=";
  };

  patches = [
    ./dfget-no-daemon-gguf.patch
  ];

  cargoHash = "sha256-MA7LWtCF84gCFvwzI6r9pbWdyr+VPuVe219TeewSp34=";

  nativeBuildInputs = [
    pkg-config
    protobuf
    rustPlatform.bindgenHook
    perl
  ];

  buildInputs = [
    openssl
    libclang
  ];

  cargoBuildFlags = [
    "-p"
    "dragonfly-client"
    "--bin"
    "dfget"
    "--bin"
    "dfdaemon"
  ];

  # Upstream checks pull in broader integration paths than this package output,
  # so keep verification at the package/build and binary smoke-test level here.
  doCheck = false;

  env = {
    PROTOC = lib.getExe protobuf;
    RUSTFLAGS = "--cfg tokio_unstable";
  };

  meta = {
    description = "Dragonfly GGUF client binaries built from source";
    homepage = "https://github.com/JustDory/dragonfly-gguf-client";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "dfget";
  };
}
