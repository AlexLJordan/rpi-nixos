{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./mysyncthing.nix
  ];

  ### Hardware ###
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [
    (pkgs.stdenv.mkDerivation {
      name = "broadcom-rpi3bplus-extra";
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/RPi-Distro/firmware-nonfree/b518de4/brcm/brcmfmac43455-sdio.txt";
        sha256 = "0r4bvwkm3fx60bbpwd83zbjganjnffiq1jkaj0h20bwdj9ysawg9";
      };
      phases = [ "installPhase" ];
      installPhase = ''
        mkdir -p $out/lib/firmware/brcm
        cp $src $out/lib/firmware/brcm/brcmfmac43455-sdio.txt
      '';
    })
  ];

  ### Booting ###
  # # NixOS wants to enable GRUB by default
  # boot.loader.grub.enable = false;
  # # Enables the generation of /boot/extlinux/extlinux.conf
  # boot.loader.generic-extlinux-compatible.enable = true;

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/disk/by-uuid/2178-694E"; # or "nodev" for efi only

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # !!! Needed for the virtual console to work on the RPi 3, as the default of 16M doesn't seem to be enough.
  # If X.org behaves weirdly (I only saw the cursor) then try increasing this to 256M.
  boot.kernelParams = [ "cma=32M" ];

  # # File systems configuration
  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-label/NIXOS_SD";
	#     fsType = "ext4";
	#   };
  # };

  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  ### System settings ###
  time.timeZone = "Europe/Berlin";
  system.autoUpgrade = {
    enable = true;
    channel = "https://nixos.org/channels/nixos-unstable/";
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?

  environment.systemPackages = [
    pkgs.emacs
    pkgs.git
    pkgs.tmux
  ];

  ### Networking ###
  # basic network settings
  networking.hostName = "pixos";
  networking.nameservers = [
    "51.15.98.97"
    "8.8.8.8"
    "8.8.1.1"
  ];
  networking.wireless.enable = true;

  # enable ports of some services:
  networking.firewall.allowedTCPPorts = [
    21
    5232
    8384
  ];
  networking.firewall.connectionTrackingModules = [ "ftp" ];
  networking.firewall.autoLoadConntrackHelpers = true;

  ### Users ###
  # FTP users
  users.users = {
    alex = {
      isNormalUser = true;
      home = "/home/alex";
      description = "Alex' FTP User";
      extraGroups = [ "ftp" ];
      hashedPassword = "$6$G9Ssf8ipbaM5gv$a53/6ueFM5GBwShE/0KeKrlDgnZusaBw5rDzcgoHsmGZFBpEgB9d9wePKonDr3XKQOWjyQRiSOm2wAsEeYZnO/";
    };
    mara = {
      isNormalUser = true;
      home = "/home/mara";
      description = "Maras FTP User";
      extraGroups = [ "ftp" ];
      hashedPassword = "$6$03LKsca5YVE$SmE4FazzOcRxNc6O0KCgaxOvw1yIGeXHMo.xY5yKvppkdwYx18K/CzMcpPmuVx3L7kidXgzMTgmt.uy315AO61";
    };
  };

  ### Services ###
  services = {

    # ssh server config:
    sshd = {
      enable = true;
      openssh.authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC0mHoxuNITXYrGkI4ryeVNVkXRphJzgZk4j4cQzmNejmiXKfeAt66RuSY40hLyM8ZtBjPpAEe9FhZsLQkylV69xMnyMp6HIHJDeAKzQaaebzDAjXAHmmhf+IPWqEq1V7LDWCMQ1t2XMttFANOyb3rivI8iGTgUdyfGuCcu8MnCRheQOag5LH/IVZ60m4Vh0/7XPajcO+D1E6LvpHBDkxR9n630nezUgrvgWaIYbs/Hk58la/V8AEFR5kAe/R3noH34iDM2uE01ONOzsjyBocjMKHSQbTD8855hGRavfhkycID4gDNJ5o++cMvW3dtRB1hWPURRKXcnkMTxbv6lokiN user@ssh"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHU0/GRtRZZ+pGFvEy9FhdeP7qJqOWF3g4r67VgF6xXGkJurVrPeOWLYngQe51UzYSGNRoh2z4cH2H6jz+B4rbHDsflK4kFumckaP3Uwk5F6bGzxYHFmFEDLYsHruSntopkR1jFEGW6+3RqAh4qTwhhwOjaN1RMP5FwmoYYtU4uR9qAWVxcZFz7BdnuNH36ubPfOvsAKDQWKmb8p4KaVZyKHvltIKsqXu7okGeA3cuNFlc086gph/Tzyi+At2yhumsZ4jZlILqPGD/zBHZ8glnN8LlziYVXsK0p+/Jwy6PjOnexwj6hd5rO4fFUBEkok2zXpzSNDT6HpGGI70gVfJp user@ssh"
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDYiHKlbX7qcPZ4upKTwdbHzIpt41VuOpsehUryjA3r2jwdBes5qMSDYCxdI07/VoIYXyMLaShE3vy9517POibgBDLqB+auothcgZYD1vi/9lWqObs+nR7o/YxRa8d38RS5jH1IZe6Sjp8/Cwj8baTtoBnEyxrhveirYhNgRJF1Qtl9bftK5aAeR61Repw+1uCXXKUpuAwazy+XpkKrr3g9gBVQd1LgzJCwYcQNUB6aqzMK1mdwkBBHTZuZplIS8LpEbRk/kaBglTWCKXWI56djjZV73qrKF8s8LN73tFoi3p/OWWg4Z/KKf1oqHuwEFF0uIdUdUvFMQxz6KirmMtz7 user@ssh"
      ];
      passwordAuthentication = false;
    };

    # emacs server config:
    emacs = {
      enable = false;
      defaultEditor = true;
      package = import /etc/nixos/emacs.d { pkgs = pkgs; };
    };

    # hostAP server config:
    hostapd = {
      enable = false;
      interface = "test";
      ssid = "pixOS AP";
      wpa_passphrase = "rickroll64"
    };

    # # ftp server config:
    # vsftpd = {
    #   enable = true;
    #   writeEnable = true;
    #   localUsers = true;
    # };

    # # dns and dhcp server config:
    # dnsmasq = {
    #   enable = false;
    # };

    # # caldav server config:
    # radicale = {
    #   enable = true;
    #   config = ''
    #     [server]
    #     hosts = 0.0.0.0:5232
    #     [auth]
	  #     type = htpasswd
    #     htpasswd_filename = /etc/nixos/htaccess
	  #     # encryption method used in the htpasswd file
	  #     htpasswd_encryption = bcrypt
    #   '';
    # };

    # # syncthing server config:
    # mysyncthing = {
    #   enable = true;
    #   guiAddress = "0.0.0.0:8384";
    # };
  };
}
