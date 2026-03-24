-- Neovim configuration entry point
-- Loaded after Nix-managed plugins are on the rtp.
--
-- Lua and compiled Fennel share the same namespace:
--   require("config.options")   -- source: lua/ or fnl/
--   require("plugins.editor")   -- works regardless of source language
--
-- Fennel macros (fnl/*.fnlm) are compile-time only and produce
-- no runtime dependency. Use nfnl macros in .fnl files via:
--   (import-macros {: if-let : when-let} :nfnl.macros)

-- Enable the native Lua module cache (before any requires)
vim.loader.enable()

-- Core options and leader keys
require 'config.options'

-- blink.cmp setup (start plugin — must be configured before LSP)
require('blink.cmp').setup(require 'config.blink-cmp')

-- Load all plugin specs via lze (opt plugins only)
local lze = require 'lze'
lze.load 'plugins'

require 'config.lsp'

require 'config.keymaps'

require 'config.theme'

require 'config.alpha'
