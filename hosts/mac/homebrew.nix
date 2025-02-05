{...}: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
    brews = [
      "direnv"
      "jq"
      "yt-dlp"
    ];
    casks = [
      "bitwarden"
      "brave-browser"
      "cursor"
      "docker"
      "duplicati"
      "iterm2"
      "keyboardcleantool"
      "nordvpn"
      "proton-mail"
      "proton-mail-bridge"
      "proton-pass"
      "raindropio"
      "spotify"
      "tailscale"
      "visual-studio-code"
      "vlc"
      "zoom"
    ];
  };
}
