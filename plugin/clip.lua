local clip = require("clip")

local function build_func (func)
  return function(_)
    func("normal")
  end
end

vim.api.nvim_create_user_command("ClipOpen", build_func(clip.popup), { nargs = "*", range = "%" })

