{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    kernelModules = [];
    extraModulePackages = [];

    initrd = {
      kernelModules = [];
      availableKernelModules = [
        # General storage and filesystem modules
        "ahci" # SATA/AHCI controller module (common for SSDs/HDDs)
        "xhci_pci" # USB 3.0/xHCI support (if booting from USB or using USB storage)
        "virtio_pci" # VirtIO PCI transport (if running in a virtualized environment)
        "virtio_scsi" # VirtIO SCSI support (for virtualized disks)
        "sd_mod" # General SCSI disk support (important for block device access)
        "dm_mod" # Device mapper (needed for LUKS and LVM)
        "dm_crypt" # Device mapper crypt support (core component for LUKS encryption)
        "ext4" # Filesystem module for your `/` filesystem type (or replace with your root FS type)
      ];
    };
  };

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/30aa6a77-0015-4c79-860b-337692e138be";
    fsType = "ext4";
  };

  boot.initrd.luks.devices."cryptdata".device = "/dev/disk/by-uuid/d1f897a4-ed5f-420c-99ac-b077a5e7db91";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/dbacda7b-c4de-4ea7-b0b7-b21de87d35a7";
    fsType = "ext4";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/81280a79-6339-4702-be4b-f08f55f8fe52";}
  ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
