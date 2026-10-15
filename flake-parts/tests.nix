# Fleet configuration assertions.
#
# These are evaluation-level checks: they inspect the fully evaluated
# `nixosConfigurations.<host>.config` and assert invariants the fleet relies on.
# They do not boot anything, so they run in seconds and are cheap enough to gate
# every push.
#
# Why not VM tests (`pkgs.testers.runNixOSTest`)? Both hosts hardcode real disk
# UUIDs and bcachefs multi-device pools in `hosts/*/filesystem.nix`, so a VM
# cannot boot them as written. VM boot tests are a follow-on to decoupling the
# disks, not something that can be bolted on here. See README "Tests".
#
# Assertion style: prefer *relationships* ("server services never reach the
# workstation") over exhaustive service lists, so intentional config changes do
# not require editing this file. Explicit lists are used only where a specific
# regression is worth guarding.
{inputs, ...}: let
  lib = inputs.nixpkgs.lib;

  hosts = inputs.self.nixosConfigurations;

  # Run a list of {name, ok, message} assertions. On failure, throw with a
  # readable report; on success, produce no derivation work.
  mkAssertionCheck = pkgs: name: assertions: let
    failures = builtins.filter (a: !a.ok) assertions;
    report = lib.concatMapStringsSep "\n" (a: "  - ${a.name}: ${a.message}") failures;
  in
    if failures == []
    then pkgs.runCommand "fleet-assertions-${name}" {} "touch $out"
    else throw "Fleet assertion failures (${name}):\n${report}";

  assertTrue = name: ok: message: {inherit name ok message;};

  # ---------------------------------------------------------------------------
  # Fleet-wide invariants: must hold on every host.
  # ---------------------------------------------------------------------------
  fleetInvariants = hostName: cfg: [
    (assertTrue "tmpfs-root-${hostName}" (cfg.fileSystems."/".fsType == "tmpfs") ''
      Expected a tmpfs root ("/"), found fsType = "${cfg.fileSystems."/".fsType}".
      A persistent root silently reintroduces state that is not declared in Nix.
    '')

    (assertTrue "persist-is-needed-for-boot-${hostName}" (cfg.fileSystems."/persist".neededForBoot == true) ''
      "/persist" must exist and be neededForBoot; otherwise preservation rules
      are applied to a mount that is not available when they run.
    '')

    (assertTrue "persist-is-preserved-${hostName}" (builtins.elem "/persist" (builtins.attrNames cfg.preservation.preserveAt)) ''
      Expected a preservation.preserveAt."/persist" rule set, found none.
    '')

    (assertTrue "preserve-dirs-nonempty-${hostName}" (cfg.preservation.preserveAt."/persist".directories != []) ''
      /persist has no preserved directories. On tmpfs root this means, for
      example, /var/lib/nixos (uid/gid maps) and the journal are lost each boot.
    '')

    (assertTrue "ssh-no-password-auth-${hostName}" (cfg.services.openssh.settings.PasswordAuthentication == false) ''
      SSH password authentication must stay disabled fleet-wide.
    '')

    (assertTrue "ssh-no-root-login-${hostName}" (cfg.services.openssh.settings.PermitRootLogin == "no") ''
      SSH root login must stay disabled.
    '')

    (assertTrue "tailscale-enabled-${hostName}" (cfg.services.tailscale.enable == true) ''
      Tailscale is the fleet's transport for off-LAN access and must be enabled.
    '')

    (assertTrue "comin-enabled-${hostName}" (cfg.services.comin.enable == true) ''
      comin is the deploy mechanism (hosts self-deploy from main). A host without
      comin will not receive configuration updates.
    '')

    (assertTrue "nix-unfree-${hostName}" (cfg.nixpkgs.config.allowUnfree == true) ''
      allowUnfree is expected fleet-wide.
    '')

    (assertTrue "flakeDir-defined-${hostName}" (cfg.my.flakeDir != "") ''
      my.flakeDir must resolve to a non-empty path.
    '')

    # `users.mutableUsers = true` combined with a tmpfs root is a known trap:
    # /etc is ephemeral, so imperative user/password changes vanish on reboot
    # and can leave a host unloggable.
    (assertTrue "stateless-root-requires-immutable-users-${hostName}" (cfg.users.mutableUsers == false) ''
      tmpfs root requires users.mutableUsers = false. With mutable users, password
      and group changes are written to the ephemeral /etc and are lost on reboot.
    '')
  ];

  # ---------------------------------------------------------------------------
  # Desktop relationship: graphical hosts get a display manager, headless do not.
  # ---------------------------------------------------------------------------
  desktopInvariants = hostName: cfg: [
    (assertTrue "graphical-implies-sddm-${hostName}" (
        cfg.my.desktop.enable -> cfg.services.displayManager.sddm.enable
      ) ''
        my.desktop.enable is true but services.displayManager.sddm.enable is false.
      '')

    (assertTrue "graphical-implies-plasma-${hostName}" (
        cfg.my.desktop.enable -> cfg.services.desktopManager.plasma6.enable
      ) ''
        my.desktop.enable is true but services.desktopManager.plasma6.enable is false.
      '')

    (assertTrue "headless-has-no-display-manager-${hostName}" (
        cfg.my.desktop.enable || !cfg.services.displayManager.sddm.enable
      ) ''
        services.displayManager.sddm.enable is true on a host with
        my.desktop.enable = false. Headless hosts should not pull in a display stack.
      '')

    (assertTrue "gaming-implies-desktop-${hostName}" (
        cfg.my.gaming.enable -> cfg.my.desktop.enable
      ) ''
        my.gaming.enable = true without my.desktop.enable = true. The gaming stack
        assumes a graphical session.
      '')
  ];

  # ---------------------------------------------------------------------------
  # Server-only services must never appear on a graphical workstation.
  # ---------------------------------------------------------------------------
  serverOnlyArionServices = ["frigate" "homeassistant" "authelia" "ialarm2mqtt" "matterjs-server" "omada"];

  serverInvariants = hostName: cfg: let
    arionServices =
      builtins.attrNames (cfg.virtualisation.arion.projects.home-infra.settings.services or {});
    leaked = builtins.filter (s: builtins.elem s arionServices) serverOnlyArionServices;
  in [
    (assertTrue "no-home-infra-on-desktop-${hostName}" (
        cfg.my.desktop.enable -> leaked == []
      ) ''
        Home-infra arion services leaked onto a desktop host: ${lib.concatStringsSep ", " leaked}.
        These belong on the server (see server-home-1).
      '')

    (assertTrue "mqtt-service-implies-broker-${hostName}" (
        (cfg.services.zigbee2mqtt.enable or false) -> (cfg.services.mosquitto.enable or false)
      ) ''
        zigbee2mqtt is enabled without a local mosquitto broker. Either enable the
        broker or point zigbee2mqtt at a remote one.
      '')
  ];

  # ---------------------------------------------------------------------------
  # Guards for removed/renamed options, so dead config cannot silently return.
  # ---------------------------------------------------------------------------
  removedOptionsInvariants = hostName: cfg: [
    (assertTrue "no-my-server-option-${hostName}" (!(cfg.my ? server)) ''
      `my.server.enable` was removed as unused. If it is being reintroduced,
      remove this assertion and wire it to something that actually reads it.
    '')

    (assertTrue "no-my-graphical-option-${hostName}" (!(cfg.my ? graphical)) ''
      `my.graphical.enable` never existed; the flag is `my.desktop.enable`.
    '')
  ];

  allAssertions = hostName: cfg:
    fleetInvariants hostName cfg
    ++ desktopInvariants hostName cfg
    ++ serverInvariants hostName cfg
    ++ removedOptionsInvariants hostName cfg;

  perHostChecks = pkgs:
    lib.mapAttrs' (
      hostName: host:
        lib.nameValuePair "fleet-assertions-${hostName}" (mkAssertionCheck pkgs hostName (allAssertions hostName host.config))
    )
    hosts;

  # ---------------------------------------------------------------------------
  # Repository-level checks, not tied to any single host's config.
  # ---------------------------------------------------------------------------
  hmUser = inputs.self.nixosConfigurations.pc-anders.config.home-manager.users.munkien;

  repoChecks = pkgs: {
    # colmena was removed deliberately (no hive config ever existed).
    "fleet-assertions-no-colmena" = mkAssertionCheck pkgs "no-colmena" [
      (assertTrue "no-colmena-input" (!(inputs ? colmena)) ''
        The `colmena` flake input is back. It was removed because it had no hive
        configuration; re-adding it requires wiring a hive and updating the
        README deploy section, not just reinstating the input.
      '')
    ];

    # User-scoped options live in the Home Manager config, not the NixOS one.
    "fleet-assertions-user-options" = mkAssertionCheck pkgs "user-options" [
      (assertTrue "no-user-media-option" (!(hmUser.my.user ? media)) ''
        `my.user.media.enable` was removed as unused (media.nix gates on
        my.desktop.enable). If reintroducing, wire it to a consumer.
      '')
      (assertTrue "user-developer-option-exists" (hmUser.my.user ? developer) ''
        `my.user.developer.enable` is consumed by modules/home/developer.nix and
        must remain declared.
      '')
      (assertTrue "user-autostart-option-exists" (hmUser.my.user ? autostart) ''
        `my.user.autostart` is consumed by modules/home/autostart.nix and must
        remain declared.
      '')
    ];
  };
in {
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    checks = lib.optionalAttrs (system == "x86_64-linux") (perHostChecks pkgs // repoChecks pkgs);
  };
}
