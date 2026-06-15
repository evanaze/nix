{
  plugins.obsidian = {
    enable = false;
    settings = {
      workspaces = [
        {
          name = "Knowledge Base";
          path = "~/Documents/Knowledge\ Base";
        }
      ];
      templates = {
        subdir = "templates";
        dateFormat = "%Y-%m-%d";
        timeFormat = "%H:%M";
        substitutions = {};
      };

      dailyNotes = {
        folder = "0_Daily_Notes";
        dateFormat = "%Y-%m-%d";
        aliasFormat = "%B %-d, %Y";
      };
    };
  };
}
