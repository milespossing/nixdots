return {
  {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    event = "VeryLazy",
    opts = {
      org_agenda_files = "~/org/**/*",
      org_default_notes_file = "~/org/inbox.org",
      org_todo_keywords = { "TODO(t)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },
      org_startup_folded = "content",
    },
  },
  {
    "chipsenkbeil/org-roam.nvim",
    ft = { "org" },
    dependencies = { "nvim-orgmode/orgmode" },
    config = function()
      require("org-roam").setup({
        directory = "~/org",
        -- optional
        org_files = {},
      })
    end,
  },
}
