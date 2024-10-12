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
              # modified = " ";
              removed = " ";
            };
          }
        ];
        lualine_c = [
          "diagnostics"
          {
            extraConfig = {
              sources = ["nvim_lsp"];
              symbols = {
                error = " ";
                warn = " ";
                info = " ";
                hint = "󰝶 ";
              };
            };
          }
          "filetype"
          {
            extraConfig = {
              icon_only = true;
              separator = "";
              padding = {
                left = 1;
                right = 0;
              };
            };
          }
          {
            name = "filename";
            extraConfig = {
              path = 1;
            };
          }
        ];
        lualine_x = [
          "navic"
          {
            name.__raw = ''
              function()
                local icon = " "
                local status = require("copilot.api").status.data
                return icon .. (status.message or " ")
              end,

              cond = function()
               local ok, clients = pcall(vim.lsp.get_clients, { name = "copilot", bufnr = 0 })
               return ok and #clients > 0
              end,
            '';
          }
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
