# aspects/shell/zsh.nix - Combined system and home-manager zsh configuration
{
  pkgs,
  username,
  hostname,
  ...
}: {
  # System-level zsh configuration
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # System packages needed for zsh functionality
  environment.systemPackages = with pkgs; [
    doppler
    fd
    fzf
    gh
    pass
    pure-prompt
    ripgrep
    zoxide
    zsh-fast-syntax-highlighting
  ];

  # Home-Manager Configuration
  home-manager.users.${username} = {
    programs = {
      zsh = {
        enable = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        enableCompletion = true;
        history.size = 10000;

        initContent = ''
          function epush() {
              git add .
              git commit -m "$*"
              git pull
              git push
          }

          function ebranch() {
              bname="$1"
              git checkout main
              git pull
              git checkout -b $bname
              git push -u origin $bname
          }

          function dbranch() {
              bname=$(git rev-parse --abbrev-ref HEAD)
              git checkout main
              git pull
              git branch -D $bname
          }

          autoload -U promptinit; promptinit

          # Style Prompt
          zstyle :prompt:pure:prompt color red
          zstyle :prompt:pure:git:branch color green
          zstyle :prompt:pure:virtualenv color yellow

          prompt pure
        '';

        shellAliases = {
          dka = "docker container kill $(docker ps -q)}";
          econf = "pushd $HOME/.config/nix && nvim .";
          findpi = "arp -na | grep -i 2c:cf:67";
          gconflicts = "git diff --name-only --diff-filter=U --relative";
          gsminit = "git submodule update --init --recursive";
          gsmupd = "git submodule update --remote --recursive";
          ll = "ls -al";
          cd = "z";
          n = "nvim .";
          t = "tree -L 2";
          dup = "devenv up";
          showsvcs = "systemctl --type=service --state=running";
          svc-stat = "journalctl -xe -u $1";
          sshpi = "ssh evanaze@mercury.spitz-pickerel.ts.net";
          sshdt = "ssh evanaze@earth.spitz-pickerel.ts.net";
          sshnas = "ssh evanaze@jupiter.spitz-pickerel.ts.net";
          update = "pushd $HOME/.config/nix && git pull && nix flake update && epush updating flake inputs && popd";
          unpack = "fd . $1/ -x mv {} .";
          updnvim = "pushd $HOME/.config/nix && nix flake update nixvim && epush updating nixvim && popd";
          npush = "pushd $HOME/.config/nix && epush $@ && popd";
          # Host-specific rebuild alias
          rebuild = "sudo nixos-rebuild switch --flake $HOME/.config/nix#${hostname}";
        };
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };
  };
}
