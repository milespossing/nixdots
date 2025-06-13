{
  programs.nixvim = {
    keymaps = [
      {
        mode = "n";
        key = "-";
	action = ":Oil<CR>";
      }
    ];
    plugins.oil = {
      enable = true;
    };
  };
}
