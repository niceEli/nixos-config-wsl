{ ... }:

{
  programs.tmux = {
    enable = true;

    prefix = "C-Space";

    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    escapeTime = 0;
    terminal = "tmux-256color";
    sensibleOnTop = false;

    extraConfig = ''
      set -g focus-events on
      set -g renumber-windows on
      set -g status-keys vi
      set -g set-clipboard on

      set -as terminal-features ",*:RGB"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      unbind '"'
      unbind %
      bind s split-window -v -c "#{pane_current_path}"
      bind v split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"

      bind z resize-pane -Z

      bind -r n next-window
      bind -r p previous-window
      bind Tab last-window

      bind [ copy-mode
      bind -T copy-mode-vi v   send -X begin-selection
      bind -T copy-mode-vi V   send -X select-line
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y   send -X copy-pipe-and-cancel "clip.exe"
      bind -T copy-mode-vi Escape send -X cancel
      bind -T copy-mode-vi H send -X start-of-line
      bind -T copy-mode-vi L send -X end-of-line
      bind p paste-buffer

      set -g status-position top
      set -g status-interval 5
      set -g status-style "bg=#1e1e2e,fg=#cdd6f4"
      set -g status-left-length 40
      set -g status-right-length 80

      set -g status-left "#[bg=#{?client_prefix,#f38ba8,#cba6f7},fg=#1e1e2e,bold]  #S #[bg=#1e1e2e,fg=default] "
      set -g status-right "#[fg=#6c7086]#{b:pane_current_path}  #[bg=#313244,fg=#cdd6f4] %a %d %b  %H:%M "

      set -g status-justify left
      setw -g window-status-separator ""
      setw -g window-status-format         "#[fg=#6c7086] #I #W "
      setw -g window-status-current-format "#[bg=#313244,fg=#89b4fa,bold] #I #W#{?window_zoomed_flag, 󰁌,} "
      setw -g window-status-activity-style "fg=#fab387"
      setw -g monitor-activity on
      set -g visual-activity off

      set -g pane-border-style "fg=#313244"
      set -g pane-active-border-style "fg=#cba6f7"
      set -g pane-border-lines heavy

      set -g message-style "bg=#313244,fg=#cdd6f4"
      set -g message-command-style "bg=#313244,fg=#a6e3a1"
      setw -g mode-style "bg=#cba6f7,fg=#1e1e2e"
    '';
  };
}

