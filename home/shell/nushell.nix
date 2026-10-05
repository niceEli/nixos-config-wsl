{ config, ... }:
{
  home.sessionVariables = {
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    RUSTUP_HOME = "${config.xdg.dataHome}/rustup";
    GRADLE_USER_HOME = "${config.xdg.dataHome}/gradle";
    DOCKER_CONFIG = "${config.xdg.configHome}/docker";
    KUBECONFIG = "${config.xdg.configHome}/kube/config";
  };

  home.sessionPath = [ "${config.home.homeDirectory}/.local/bin" ];

  programs = {
    nushell = {
      enable = true;

      settings.edit_mode = "vi";

      shellAliases = {
        q = "exit";
        ll = "ls -l";
        nd = "nix develop -c nu";
        scoop = "pwsh.exe C:/Users/niceEli/scoop/shims/scoop.ps1";
        winget = "winget.exe";
        choco = "choco.exe";
        wsl = "wsl.exe";
        mpv = "mpv.exe";
        ffmpeg = "ffmpeg.exe";
        ffplay = "ffplay.exe";
        ffprobe = "ffprobe.exe";
        pwsh = "pwsh.exe";
        e = "nvim";
        t = "tmux";
      };

      extraConfig = ''
        $env.config.hooks.pre_execution = [
          {||
            let size = (term size)
            $env.COLUMNS = $size.columns
            $env.LINES = $size.rows
          }
        ]

        $env.config.hooks.command_not_found = {|cmd|
          let exe = $"($cmd).exe"
          if (which $exe | is-empty) == false {
            $"did you mean ($exe)?"
          }
        }

        def nix-develop [...args] {
          nix develop ...$args -c nu
        }
      '';
    };

    # replaces the zoxide cache-file dance
    zoxide = {
      enable = true;
      enableNushellIntegration = true;
      options = [ "--cmd cd" ];
    };

    # replaces the hand-rolled PWD hook
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableNushellIntegration = true;
    };
  };
}
