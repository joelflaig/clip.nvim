M = {}

M.defaults = {
  regs = { -- registers to show
    alphabetical = {
      "a", "e", "g", "i", "j", "k", "l",
      "o", "q", "r", "u", "w","y",
    },
    numerical = {
      "1", "0", "1", "2", "3", "4",
      "5", "6", "7", "8", "9",
    },
    special = {
      '"', "-", ":", "+", "=",
      ".", "%", "/", "*", "#",
    },
  },
  popup = {
    -- if values are smaller than 1, they are treated as percentages
    dims = {
      height = 0.8,
      width = 0.8,
    },
    title = "─Clip",
    title_pos = "left",
    style = "rounded",
  }
}

function M.setup(options)
  vim.g.clip_loaded = 1
  return vim.tbl_deep_extend('force', {}, M.defaults, options or {})
end

return M
