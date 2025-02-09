{pkgs, ...}: {
  home.packages = with pkgs; [
    # cli
    godot_4
    gdtoolkit_4
  ];
}
