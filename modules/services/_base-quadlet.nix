{
  lib,
  config,
  ...
}: {
  autoStart = true;
  serviceConfig = {
    Restart = "always";
    TimeoutStartSec = 300;
  };
  containerConfig = {
    autoUpdate = "registry";
    healthInterval = "60s";
    healthOnFailure = "restart";
    healthRetries = 5;
    healthStartPeriod = "10s";
    healthStartupInterval = "5s";
    healthStartupRetries = 15;
    networks = ["homelab"];
    dropCapabilities = ["ALL"];
    stopTimeout = 900;
    readOnly = true;
    userns = "auto:size=65536";
    environments = {
      TZ = config.time.timeZone;
    };
  };
}
