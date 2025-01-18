{...}: {
  programs.qutebrowser = {
    enable = true;
    settings = {
      tabs = {
        tabs_are_windows = false;
        show = "multiple";
      };
      url.default_page = "about:blank";
    };
    searchEngines = {
      DEFAULT = "https://google.com.au/search?hl=en&q={}";
      "!yt" = "https://www.youtube.com/results?search_query={}";
    };
  };
}
