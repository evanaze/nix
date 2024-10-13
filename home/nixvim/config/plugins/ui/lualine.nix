_: {
  plugins.lualine = {
    enable = true;
    settings = {
      sections = {
        lualine_a = [
          "mode"
          {
            icon = " ";
          }
        ];
        lualine_b = [
          "branch"
          {
            icon = "";
          }
          "diff"
          {
            symbols = {
              added = " ";
              modified = " ";
              removed = " ";
            };
          }
        ];
        lualine_c = [
          "diagnostics"
          {
            sources = ["nvim_lsp"];
            symbols = {
              error = " ";
              warn = " ";
              info = " ";
              hint = "󰝶 ";
            };
          }
          "filetype"
          {
            icon_only = true;
            separator = "";
            padding = {
              left = 1;
              right = 0;
            };
          }
          "filename"
          {
            path = 1;
          }
        ];
        lualine_x = [
          "navic"
        ];
        lualine_y = [
          "progress"
        ];
        lualine_z = [
          "location"
        ];
      };
      theme = "catppuccin";
      extensions = [
        "fzf"
        "neo-tree"
      ];
      options = {
        disabled_filetypes = {
          statusline = ["startup" "alpha"];
        };
        globalstatus = true;
      };
    };
  };
}
