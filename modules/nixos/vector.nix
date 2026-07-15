{
  config,
  inputs,
  lib,
  ...
}: {
  age.generators.alnum-ntfy = {pkgs, ...}: ''
    printf "https://ntfy.sh/"
    head /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9' | head -c 32
  '';

  age.secrets.vector-uri = {
    rekeyFile = "${inputs.self}/secrets/common/vector-uri.age";
    mode = "0400";
    generator.script = "alnum-ntfy";
    owner = "vector";
  };

  users.users.vector = {
    isSystemUser = true;
    group = "vector";
    extraGroups = ["systemd-journal"];
  };
  users.groups.vector = {};

  services.vector = {
    enable = true;
    validateConfig = true;
    journaldAccess = true;

    settings = {
      sources.journald = {
        type = "journald";
      };

      sources.vector_logs = {
        type = "internal_logs";
      };

      transforms.error_filter = {
        type = "filter";
        inputs = ["journald" "vector_logs"];
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

      transforms.map_priority = {
        type = "remap";
        inputs = ["error_filter"];
        source = ''
          # Journald: 0=Emerg, 1=Alert, 2=Crit, 3=Err
          # Ntfy:     5=Urgent, 4=High,  3=Default, 2=Low

          p = to_int(.priority) ?? 3

          # Mapping
          if p == 0 { .ntfy_priority = 5 }      # Emergency -> Urgent
          else if p == 1 { .ntfy_priority = 5 } # Alert     -> Urgent
          else if p == 2 { .ntfy_priority = 4 } # Critical  -> High
          else if p == 3 { .ntfy_priority = 3 } # Error     -> Default
          else { .ntfy_priority = 2 }           # Warning   -> Low
        '';
      };

      transforms.rate_limit = {
        type = "throttle";
        inputs = ["map_priority"];
        window_secs = 3456;
        threshold = 10;
      };

      sinks.local_debug = {
        type = "console";
        inputs = ["throttle"];
        encoding = {
          codec = "text";
        };
      };

      # sinks.ntfy = {
      #   type = "http";
      #   inputs = ["rate_limit"];
      #   #uri = ''${file:/run/agenix/vector-uri}'';
      #   uri = "https://ntfy.sh/c9yfH2zh2S6P2DFXtHEUxVFT49A5opk8";
      #   method = "put";
      #   request.headers = {
      #     "Title" = ''${file:/run/agenix/vector-uri}'';
      #     "Priority" = "{{ .ntfy_priority }}";
      #     "Tags" = "warning, skull";
      #   };
      #   encoding = {
      #     codec = "text";
      #   };
      # };
    };
  };
}
