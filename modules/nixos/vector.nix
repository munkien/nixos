{
  config,
  inputs,
  lib,
  ...
}: {
  age.generators.alnum-ntfy = {pkgs, ...}: ''
    echo -n "NTFY_URL=https://ntfy.sh/"
    head /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9' | head -c 32
  '';
  age.secrets.vector-uri = {
    rekeyFile = "${inputs.self}/secrets/common/vector-uri.age";
    mode = "0400";
    generator.script = "alnum-ntfy";
  };
  systemd.services.vector.serviceConfig.EnvironmentFile = config.age.secrets.vector-uri.path;

  services.vector = {
    enable = true;
    validateConfig = false;
    journaldAccess = true;

    settings = {
      sources.journald = {
        type = "journald";
      };

      # Filter: Keep only Emergency(0), Alert(1), Critical(2), Error(3)
      transforms.error_filter = {
        type = "filter";
        inputs = ["journald"];
        condition = ".priority <= 5";
      };

      # Sink: Forward to ntfy
      sinks.ntfy = {
        type = "http";
        inputs = ["error_filter"];
        uri = ''${file:/run/agenix/vector-uri}'';
        method = "post";
        encoding = {
          codec = "json";
        };
      };
    };
  };

  preservation.preserveAt."/persist" = {
    directories = [
      "/var/lib/vector"
    ];
  };
}
