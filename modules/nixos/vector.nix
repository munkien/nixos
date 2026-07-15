{
  config,
  inputs,
  lib,
  ...
}: {
  age.secrets.vector-uri = {
    rekeyFile = "${inputs.self}/secrets/common/vector-uri.age";
    mode = "0400";
    owner = "vector";
    group = "vector";
    generator.script = "alnum";
  };

  services.vector = {
    enable = true;
    # Ensure Vector has permission to read the system journal
    journaldAccess = true;

    settings = {
      sources.journald = {
        type = "journald";
      };

      # Filter: Keep only Emergency(0), Alert(1), Critical(2), Error(3)
      transforms.error_filter = {
        type = "filter";
        inputs = ["journald"];
        condition = ".priority <= 3";
      };

      # Sink: Forward to ntfy
      sinks.ntfy = {
        type = "http";
        inputs = ["error_filter"];
        uri = "https://ntfy.sh/your-secret-topic";
        method = "post";
        encoding = {
          codec = "json";
        };
        # Optional: Auth if you use a self-hosted ntfy instance with access control
        # auth = { strategy = "bearer"; token = "YOUR_TOKEN"; };
      };
    };
  };
}
