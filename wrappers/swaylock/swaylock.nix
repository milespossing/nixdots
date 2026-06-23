{
  pkgs,
  wlib,
  basePackage ? pkgs.swaylock-effects,
}:
wlib.evalPackage [
  wlib.wrapperModules.swaylock
  {
    inherit pkgs;
    package = basePackage;
    settings = {
      clock = true;
      timestr = "%I:%M %p";
      datestr = "%A, %B %d";

      screenshots = true;
      effect-blur = "10x4";
      effect-vignette = "0.5:0.5";
      fade-in = 0.2;

      font = "DepartureMono Nerd Font";
      font-size = 20;

      indicator = true;
      indicator-radius = 100;
      indicator-thickness = 7;
      indicator-caps-lock = true;

      inside-color = "1e1e2ecc";
      inside-clear-color = "1e1e2ecc";
      inside-ver-color = "89b4facc";
      inside-wrong-color = "f38ba8cc";

      ring-color = "cba6f7ff";
      ring-clear-color = "a6e3a1ff";
      ring-ver-color = "89b4faff";
      ring-wrong-color = "f38ba8ff";

      key-hl-color = "89b4faff";
      bs-hl-color = "f38ba8ff";

      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";

      separator-color = "00000000";

      text-color = "cdd6f4ff";
      text-clear-color = "cdd6f4ff";
      text-ver-color = "cdd6f4ff";
      text-wrong-color = "cdd6f4ff";

      text-caps-lock-color = "fab387ff";
    };
  }
]
