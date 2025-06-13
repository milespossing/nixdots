{
  programs.nixvim = {
    plugins.snacks = {
      enable = true;
      settings = {
        indent.enabled = true;
	scroll.enabled = true;
      };
    };
  };
}
