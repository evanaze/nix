_: {
  plugins = {
    markdown-preview = {
      enable = true;
      settings = {
        browser = "firefox";
        echo_preview_url = 1;
        port = "6969";
        preview_options = {
          disable_filename = 1;
          disable_sync_scroll = 1;
          sync_scroll_type = "middle";
        };
        theme = "dark";
      };
    };
  };
}
