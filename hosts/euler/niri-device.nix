# Euler device layer — nvidia env vars + dual monitor outputs
{
  settings = {
    environment = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    };

    outputs = {
      "DP-2" = {
        mode = _: {
          props = [
            "2560x1440@59.950"
          ];
        };
        position = _: {
          props = {
            x = 0;
            y = 0;
          };
        };
      };
      "DP-1" = {
        mode = _: {
          props = [
            "2560x1440@143.970"
          ];
        };
        position = _: {
          props = {
            x = 2560;
            y = -8;
          };
        };
        transform = "90";
      };
    };
  };
}
