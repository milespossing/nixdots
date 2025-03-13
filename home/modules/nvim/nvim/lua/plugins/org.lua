return {
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    init = function()
      vim.opt.conceallevel = 2
      vim.opt.concealcursor = "nc"
    end,
    opts = {
      org_agenda_files = "~/org/**/*",
      org_default_notes_file = "~/org/inbox.org",
      org_todo_keywords = { "TODO(t)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },
    },
  },
  {
    "chipsenkbeil/org-roam.nvim",
    tag = "0.1.1",
    ft = { "org" },
    dependencies = {
      {
        "nvim-orgmode/orgmode",
        tag = "0.3.7",
      },
    },
    config = function()
      require("org-roam").setup({
        directory = "~/org",
        -- optional
        org_files = {},
      })
    end,
  },
}
