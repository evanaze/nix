{
  sops-nix,
  username,
  ...
}: {
  modules = [
    sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets.yaml;
    age.keyFile = "home/${username}/.config/sops/age/keys.txt";
  };
}
