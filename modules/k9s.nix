{...}: {
  programs.k9s = {
    enable = true;
    settings = {
      k9s = {
        logger = {
          textWrap = true;
          sinceSeconds = 6000;
        };
      };
    };
  };
}
