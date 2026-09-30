{ pkgs, osConfig, ... }:
{
  home = {
    username = "niceeli";
    homeDirectory = "/home/niceeli";
    stateVersion = osConfig.system.stateVersion;

    packages = with pkgs; [
      ripgrep
      fd
      jq
      btop
      fastfetch
    ];
  };

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      settings = {
        user = {
          name = "Eli Cardoso-Grdovic";
          email = "tape-infix.3m@icloud.com";
          signingkey = "CFF4A1D451688F83";
        };
        init.defaultBranch = "master";
      };
    };

    nushell.enable = true;

    bash = {
      enable = true;
      initExtra = ''
        if [[ $(ps --no-header --pid=$PPID --format=comm) != "nu" && -z ''${BASH_EXECUTION_STRING} ]]; then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${pkgs.nushell}/bin/nu $LOGIN_OPTION
        fi
      '';
    };

    oh-my-posh = {
      enable = true;
      enableNushellIntegration = true;
      settings = builtins.fromJSON (builtins.readFile ./config.omp.json);
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
