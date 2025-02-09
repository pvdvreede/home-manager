{...}: {
  services.frigate = {
    enable = true;
    hostname = "frigate";
    settings = {
      cameras = {};
    };
  };
}
