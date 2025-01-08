{
  pkgs,
  inputs,
  stateVersion,
  ...
}
: {
  home = {
    packages = with pkgs; [
      cmake
      extra-cmake-modules
      ninja
      qt6-virtualkeyboard
      qt6-multimedia
      qt6-5compat
      plasma-wayland-protocols
      plasma5support
      kvantum
    ];
  };
}
