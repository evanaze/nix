{
  pkgs,
  username,
  ...
}: {
  environment = {
    systemPackages = with pkgs; [
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
  };

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
              # branch=$(git rev-parse --abbrev-ref HEAD)
              # ticket=$(echo $branch | cut -d / -f2 -)
              git add .
              git commit -m "$*"
              git pull
              git push
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
          n = "nvim .";
          dup = "devenv up";
          showsvcs = "systemctl --type=service --state=running";
          svcsts = "journalctl -xe -u $1";
          sshpi = "ssh evanaze@hs.spitz-pickerel.ts.net";
          sshdt = "ssh evanaze@father.spitz-pickerel.ts.net";
          update = "pushd $HOME/.config/nix && nix flake update && epush updating flake inputs && popd";
          updnvim = "pushd $HOME/.config/nix && nix flake update nixvim && epush updating nixvim && popd";
          npush = "pushd $HOME/.config/nix && epush $@ && popd";
        };
      };
    };
  };
}
