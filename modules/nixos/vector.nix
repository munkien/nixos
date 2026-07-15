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

  systemd.services.vector.serviceConfig = {
    EnvironmentFile = config.age.secrets.vector-uri.path;
    # Wait for local filesystems to be ready
    RequiresMountsFor = ["/var/lib/vector"];
  };

  services.vector = {
    enable = true;
    validateConfig = false;
    journaldAccess = true;

    settings = {
      sources.journald = {
        type = "journald";
      };

      transforms.error_filter = {
        type = "filter";
        inputs = ["journald"];
        condition = ''
          if exists(.priority) {
            # Try to cast to int. If it fails, default to 0 (Emergency) so it passes the <= 5 check.
            p = to_int(.priority) ?? 0
            p <= 5
          } else {
            # If the priority field is completely missing, send the log to be safe.
            true
          }
        '';
      };

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
