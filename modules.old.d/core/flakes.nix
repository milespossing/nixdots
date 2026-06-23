{
  nix.registry.mpc = {
    from = {
      type = "indirect";
      id = "mpc";
    };
    to = {
      type = "github";
      owner = "milespossing";
      repo = "flakes";
    };
  };
}
