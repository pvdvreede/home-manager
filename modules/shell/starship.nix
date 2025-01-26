{...}: {
  programs.starship = {
    enable = true;
    settings = {
      format = "$all";
      add_newline = true;
      container = {
        disabled = true;
      };
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
}
