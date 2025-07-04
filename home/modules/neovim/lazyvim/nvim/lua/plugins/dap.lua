return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "jbyuki/one-small-step-for-vimkind",
  },
  config = function()
    local dap = require("dap")

    dap.adapters.nlua = function(callback, _)
      callback({ type = "server", host = "127.0.0.1", port = 8086 })
    end

    dap.configurations.lua = {
      {
        type = "nlua",
        request = "attach",
        name = "Attach to running Neovim instance",
        host = function()
          return "127.0.0.1"
        end,
        port = function()
          return 8086
        end,
      },
    }
  end,
}
