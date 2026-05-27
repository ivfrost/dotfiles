# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz";
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "backup";
  home-manager.users.ivfrost = import ./home.nix;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Madrid";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "es_ES.UTF-8";
    LC_IDENTIFICATION = "es_ES.UTF-8";
    LC_MEASUREMENT = "es_ES.UTF-8";
    LC_MONETARY = "es_ES.UTF-8";
    LC_NAME = "es_ES.UTF-8";
    LC_NUMERIC = "es_ES.UTF-8";
    LC_PAPER = "es_ES.UTF-8";
    LC_TELEPHONE = "es_ES.UTF-8";
    LC_TIME = "es_ES.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Disable xterm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable zsh
  programs.zsh.enable = true;

  # Set default fonts
  fonts.fontconfig.defaultFonts = {
    monospace = [ "BlexMono Nerd Font Mono:style=Regular" ];
    sansSerif = [ "Adwaita Sans" ];
  };

  # Enable the GNOME Desktop Environment.
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome = {
    enable = true;
  
    extraGSettingsOverrides = ''
      [org.gnome.shell]
      always-show-log-out=true
    '';
  };

  # Allow Flatpak apps to talk to GNOME Shell
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
    ];
  };

  # Configure keymap in X10
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };


  # Configure GNOME Shell Extensions
programs.dconf = {
  enable = true;

  profiles.user.databases = [
    {
      settings = {
        "org/gnome/shell" = {
          disable-user-extensions = false;
          enabled-extensions = [
            "windowIsReady_Remover@nunofarruca@gmail.com"
            "tilingshell@ferrarodomenico.com"
            "search-light@icedman.github.com"
            "rounded-window-corners@fxgn"
            "night-light-slider-updated@vilsbeg.codeberg.org"
            "gsconnect@andyholmes.github.io"
            "clipboard-indicator@tudmotu.com"
            "caffeine@patapon.info"
            "appindicatorsupport@rgcjonas.gmail.com"
            "advanced-alt-tab@G-dH.github.com"
          ];
        };

        # Tiling Shell — remove gaps + hide indicator
        "org/gnome/shell/extensions/tilingshell" = {
          gaps-inner = lib.gvariant.mkInt32 0;
          gaps-outer = lib.gvariant.mkInt32 0;
          show-indicator = false;
        };

        # Clipboard Indicator — hide icon
        "org/gnome/shell/extensions/clipboard-indicator" = {
          display-icon = false;
          enable-keybindings = true;
        };
      };
    }
  ];
};


  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable flatpak
  services.flatpak.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ivfrost = {
    isNormalUser = true;
    description = "ivfrost";
    extraGroups = [ "networkmanager" "wheel" "plugdev" "uaccess" "input" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
#  thunderbird
    ];
  };

# Theme Qt Applications
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

# Install firefox
  programs.firefox.enable = true;

# Allow unfree packages
  nixpkgs.config.allowUnfree = true;

# Disable GNOME applications
  environment.gnome.excludePackages = with pkgs; [
	cheese
	snapshot
	eog
	epiphany
	gedit
	totem
	yelp
	evince
	file-roller
	geary
	seahorse
	gnome-tour
        decibels	
	gnome-text-editor
	gnome-clocks
	gnome-contacts
	gnome-font-viewer
	gnome-logs
	gnome-maps
	gnome-music
	gnome-photos
	gnome-screenshot
	gnome-connections
	gnome-software
	gnome-console
	papers
  ];

# List packages installed in system profile. To search, run:
# $ nix search wget
  environment.systemPackages = with pkgs; [
#  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
#  wget
	# GNOME Extensions
	gnome-settings-daemon
	gnomeExtensions.advanced-alttab-window-switcher
	gnomeExtensions.advanced-alttab-window-switcher
	gnomeExtensions.appindicator
	gnomeExtensions.clipboard-indicator
	gnomeExtensions.caffeine
	gnomeExtensions.gsconnect
	gnomeExtensions.hide-top-bar
	gnomeExtensions.night-light-slider-updated
	gnomeExtensions.rounded-window-corners-reborn
	gnomeExtensions.search-light
	gnomeExtensions.window-is-ready-remover
	gnomeExtensions.tiling-shell

  nerd-fonts.blex-mono
	xsel
	xclip
  adwaita-qt
  adwaita-qt6
  qgnomeplatform
  qgnomeplatform-qt6
	neovim
	firefox
	ungoogled-chromium
	gnome-tweaks
	ghostty
	git
	stow
	docker
	starship
	atuin
	zoxide
	gnome-browser-connector
	vscode
	webcord
	planify
	obs-studio

	# KDE Packages
	kdePackages.qt6ct
	kdePackages.kdenlive
	kdePackages.okular

	cine
	amberol
	gimp
	nodejs_26
	nautilus-python
	obsidian
	tor-browser
	mpv
	pavucontrol
	transmission_4-gtk
	bruno
	gnome-decoder
  ];

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

# List services that you want to enable:

# Enable the OpenSSH daemon.
# services.openssh.enable = true;

# Open ports in the firewall.
# networking.firewall.allowedTCPPorts = [ ... ];
# networking.firewall.allowedUDPPorts = [ ... ];
# Or disable the firewall altogether.
# networking.firewall.enable = false;

# This value determines the NixOS release from which the default
# settings for stateful data, like file locations and database versions
# on your system were taken. It‘s perfectly fine and recommended to leave
# this value at the release version of the first install of this system.
# Before changing this value read the documentation for this option
# (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

# Enable SSH access
  services.openssh.enable = true;

# Enable experimental features
  nix.settings.experimental-features = ["nix-command" "flakes"];

# udev rules for VIA
services.udev.extraRules = ''
  # Keychron K3 Max - allow user access to hidraw devices
  SUBSYSTEMS=="usb", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0a30", MODE="0666", GROUP="plugdev"
  SUBSYSTEMS=="hidraw", ATTRS{idVendor}=="3434", ATTRS{idProduct}=="0a30", MODE="0666", GROUP="plugdev"
'';
}
