local clip = require("clip")

local function build_func (func)
  return function(_)
    func()
  end
end

vim.api.nvim_create_user_command("ClipPaste", build_func(clip.paste), { nargs = "*", range = "%" })
vim.api.nvim_create_user_command("ClipCopy", build_func(clip.copy), { nargs = "*", range = "%" })

