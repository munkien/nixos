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
  # Rollback safety: Automatic Boot Assessment + the health gate.
  #
  # These guard the mechanism that lets an unreachable host recover by itself.
  # They are deliberately explicit: getting this wrong silently leaves a machine
  # with no way back, which is worse than an obvious boot failure.
  # ---------------------------------------------------------------------------
  rollbackInvariants = hostName: cfg: [
    (assertTrue "boot-counting-enabled-${hostName}" cfg.boot.loader.systemd-boot.bootCounting.enable ''
      Automatic Boot Assessment is disabled. Without it a generation that fails to
      boot is never rolled back automatically. Requires systemd-boot (x86_64).
    '')

    (assertTrue "boot-counting-tries-positive-${hostName}" (cfg.boot.loader.systemd-boot.bootCounting.tries >= 2) ''
      bootCounting.tries must be >= 2, otherwise a generation is marked bad after a
      single failure and a transient problem rolls back a good revision.
    '')

    (assertTrue "boot-counting-fits-configuration-limit-${hostName}" (
        cfg.boot.loader.systemd-boot.bootCounting.tries
        < cfg.boot.loader.systemd-boot.configurationLimit
      ) ''
        bootCounting.tries must be lower than configurationLimit, otherwise the
        previous generation may already have been garbage-collected from /boot and
        there is nothing to fall back to.
      '')

    (assertTrue "health-check-enabled-${hostName}" cfg.my.healthCheck.enable ''
      The health gate is disabled, so boot-complete.target is reached as soon as
      userspace comes up. A generation that boots but has no network would then be
      blessed and never rolled back — the exact case for a host you cannot reach.
    '')

    # The dependency direction that makes the gate actually work. A plain
    # WantedBy is a WEAK dependency: a failing unit would leave boot-complete
    # reachable and the generation still blessed. Per systemd.special(7) the
    # target must Requires= the unit and be ordered after it.
    (assertTrue "health-check-required-by-boot-complete-${hostName}" (
        builtins.elem "fleet-health-check.service" (cfg.systemd.targets."boot-complete".requires or [])
      ) ''
        boot-complete.target does not Requires= fleet-health-check.service. With only a
        weak (Wants/WantedBy) relationship, a FAILING health check would still let the
        target be reached and the generation blessed, defeating the gate entirely.
      '')

    (assertTrue "health-check-ordered-before-boot-complete-${hostName}" (
        builtins.elem "boot-complete.target" (cfg.systemd.services.fleet-health-check.before or [])
      ) ''
        fleet-health-check.service is not ordered Before=boot-complete.target, so it may
        run after the boot has already been blessed.
      '')

    (assertTrue "health-check-runs-after-network-${hostName}" (
        builtins.elem "network-online.target" (cfg.systemd.services.fleet-health-check.after or [])
      ) ''
        fleet-health-check.service does not run after network-online.target, so the
        default-route check could evaluate before networking is up and false-positive.
      '')

    (assertTrue "health-check-expects-display-manager-correctly-${hostName}" (
        cfg.my.healthCheck.expectDisplayManager == cfg.my.desktop.enable
      ) ''
        my.healthCheck.expectDisplayManager disagrees with my.desktop.enable. A headless
        host expecting a display manager (or vice versa) would either never roll back or
        roll back good generations.
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
    ++ rollbackInvariants hostName cfg
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
