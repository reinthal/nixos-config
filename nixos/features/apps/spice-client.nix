{pkgs, ...}: {
  # SPICE client for viewing remote VMs (Proxmox console, libvirt, etc.)
  environment.systemPackages = [pkgs.virt-viewer];

  # Only needed for SPICE USB redirection (sets up the ACL helper)
  virtualisation.spiceUSBRedirection.enable = true;

  # Make .vv files open in remote-viewer automatically
  xdg.mime.defaultApplications."application/x-virt-viewer" = "remote-viewer.desktop";
}
