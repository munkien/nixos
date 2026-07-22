{pkgs, ...}: {
  systemd.tmpfiles.rules = [
    "d /persist/ollama 0777 root root -"
  ];

  services.ollama = {
    enable = true;
    user = "ollama";
    group = "ollama";

    package = pkgs.ollama-rocm;
    openFirewall = true;

    modelsDir = "/persist/ollama/models";

    loadModels = [
      "llama3"
      #"gemma3"
      #"deepseek-r1:latest"
    ];
  };

  # systemd.services.ollama.serviceConfig = {
  #   ReadWritePaths = [ "/persist/ollama/models" ];
  # };

  # systemd.services.ollama-model-loader.serviceConfig = {
  #   ReadWritePaths = [ "/persist/ollama/models" ];
  # };
}
