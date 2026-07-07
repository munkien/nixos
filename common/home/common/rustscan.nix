{pkgs, ...}: {
  home.packages = with pkgs; [
    rustscan
  ];
  home.file.".rustscan.toml".text = ''
    # Declaratively managed by Home Manager
    ulimit = 5000

    # Timeout in milliseconds. 1500ms is generous for a LAN,
    # preventing false negatives on slower embedded devices like IP cameras.
    timeout = 1500

    # Number of concurrent connections. The default (4500) can overwhelm
    # standard switches. 2500 provides a better baseline for reliability
    # without sacrificing too much speed.
    batch_size = 2500

    # Default Nmap arguments to run automatically on discovered ports.
    # -sV (Service Version) is critical for identifying exactly what is running.
    # -T4 speeds up the Nmap phase.
    command = ["-sV", "-T4"]
  '';
}
