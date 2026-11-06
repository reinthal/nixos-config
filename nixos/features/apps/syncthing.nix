# Hub-and-spoke Syncthing: every host talks only to the TrueNAS hub.
# Spokes never learn about each other; changes propagate through the hub.
# On TrueNAS: add each spoke's device ID with auto-accept on, introducer OFF.
{lib, ...}: let
  hub = "truenas";

  # Folder IDs must match on all devices. Each folder is shared with the hub only.
  folders = {
    # documents = {path = "~/Documents"; label = "Documents";};
  };
in {
  services.syncthing = {
    enable = true;
    group = "users";
    user = "kog";
    dataDir = "/home/kog/Documents";
    configDir = "/home/kog/.config/syncthing";
    openDefaultPorts = true;

    # Nix is the source of truth; devices/folders added in the GUI get reverted.
    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices.${hub} = {
        id = "GDECV66-SLK62UR-RABYMJD-6WBEYHL-EV55B2I-KUPKNRA-N4YX4XN-ZNLM2QU";
        addresses = ["tcp://nas.reinthal.me:22000"];
      };

      folders =
        lib.mapAttrs (id: f: f // {inherit id; devices = [hub];}) folders;

      options = {
        # Static hub address; don't publish our IP to discovery servers.
        globalAnnounceEnabled = false;
        relaysEnabled = false;
        natEnabled = false;
        urAccepted = -1;
      };
    };
  };
}
