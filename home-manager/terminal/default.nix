{
  programs = {
    alacritty = {
      enable = true;
      settings = {
        font.normal.family = "FireCode Nerd Font Mono";
        font.size = 16;

        keyboard.bindings = [
          {
            key = "i";
            mods = "Control";
            action = "ToggleViMode";
          }
          {
            key = "h";
            # Move left
            mods = "Control";
            action = "WordLeft";
          }
          {
            key = "l";
            mods = "Control";
            # move right
            action = "WordRightEnd";
          }
        ];
      };
    };

    kitty = {
      enable = true;
      font = {
        name = "FireCode Nerd Font Mono";
        size = 15;
      };
    };
  };
}

