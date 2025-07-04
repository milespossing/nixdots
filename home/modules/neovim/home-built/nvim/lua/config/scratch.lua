local options = {
  { "Clojure", idx = 0, score = 0 },
}

local function get_scratch_path()
  if vim.g.windows then
    return vim.fs.joinpath(vim.fn.stdpath("data"), "scratch")
  else
    return vim.fs.joinpath(vim.fn.expand("~"), ".local", "share", "scratch")
  end
end

local scratch_picker = function()
  Snacks.picker.pick({
    title = "Scratch Files",
    format = "text",
    finder = function()
      return vim
        .iter({
          {
            text = "Clojure",
            file = "Scratch.clj",
            data = {
              name = "scratch.clj",
            },
          },
          {
            text = "Http",
            file = "Scratch.http",
            data = {
              name = "scratch.http",
            },
          },
        })
        :map(function(i)
          return vim.tbl_extend("force", i, {
            file = vim.fs.joinpath(vim.fn.stdpath("config"), "scratch", i.file),
          })
        end)
        :totable()
    end,
    confirm = function(picker, item)
      picker:close()
      if item then
        local path = get_scratch_path()
        vim.fn.mkdir(path, "p")

        local time = tostring(os.time())
        local name = time .. item.data.name
        local target = vim.fs.joinpath(path, name)

        local input = assert(io.open(item.file, "rb"))
        local content = input:read("*all")
        input:close()

        local output = assert(io.open(target, "wb"))
        output:write(content)
        output:close()

        vim.cmd("edit " .. vim.fn.fnameescape(target))
      end
    end,
  })
end

vim.api.nvim_create_user_command("Scratch", scratch_picker, {})
