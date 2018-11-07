{ config, pkgs, lib, ... }:
{

  # NixOS wants to enable GRUB by default
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  boot.kernelParams = ["cma=32M"];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
			fsType = "ext4";
	  };
  };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  environment.systemPackages = 
  [ pkgs.emacs
    pkgs.openssh
    pkgs.vsftpd
    pkgs.dnsmasq
    pkgs.git
  ];

  services.sshd.enable = true;
  #services.vsftpd.enable = true;
  #services.dnsmasq.enable = true;

}
