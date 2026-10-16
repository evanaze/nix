let
  # Calendar IDs for Google accounts can be found in the Google Calendar web
  # app: Settings > Settings for my calendars > scroll to "Integrate calendar"
  # > copy the "Calendar ID".
  googleCalendarUrl = id: "https://apidata.googleusercontent.com/caldav/v2/${id}/events/";
  module = {username, ...}: {
    home-manager.users.${username} = {pkgs, ...}: {
      accounts.calendar.accounts = {
        "evanaze@gmail.com" = {
          primary = true;
          thunderbird.enable = true;
          remote = {
            type = "caldav";
            userName = "evanaze@gmail.com";
            url = googleCalendarUrl "https://calendar.google.com/calendar/embed?src=evanaze%40gmail.com&ctz=America%2FDenver";
          };
        };
        "evanazzvd@gmail.com" = {
          thunderbird.enable = true;
          remote = {
            type = "caldav";
            userName = "evanazzvd@gmail.com";
            url = googleCalendarUrl "https://calendar.google.com/calendar/embed?src=evanazzvd%40gmail.com&ctz=America%2FDenver";
          };
        };
        "evan@stackmagic.io" = {
          thunderbird.enable = true;
          remote = {
            type = "caldav";
            userName = "evan@stackmagic.io";
            url = "https://cal.spitz-pickerel.ts.net";
          };
        };
      };
    };
  };
in {
  flake.modules.nixos = {
    desktopCalendar = module;
    desktop = module;
  };
}
