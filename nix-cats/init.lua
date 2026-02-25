require('nixCatsUtils').setup {
  non_nix_value = true,
}
require 'config.options'
require 'config.autocommands'
require 'config.lazy-plugins'
if require('nixCatsUtils').enableForCategory 'full' then
  require 'config.lsp'
end
require 'config.keymaps'
