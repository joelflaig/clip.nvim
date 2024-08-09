local M = {
  opts = {
    popup = {
      -- if values are smaller than 1, they are treated as percentages
      dims = {
        height = 10,
        width = 0.35,
      },
      title = "─Clip",
      title_pos = "left",
      style = "rounded",
    }
  }
}

---Sets up autocmds and keymaps for the given buffer
---@param bufnr integer
---@param mode string -- May be "copy" or "paste"
local function setup_autocmds_and_keymaps(bufnr, mode)
  if mode == "copy" then
  elseif mode == "paste" then
    vim.keymap.set("n", "<CR>", function()
      vim.api.nvim_paste(
        vim.api.nvim_get_current_line(),
        true, 1
      )
    end, { buffer = bufnr, silent = true })

  else
    error("Invalid mode")
  end
end

---Opens a popup
---@param mode string -- May be "copy" or "paste"
---@return integer,integer
local function popup(mode)
  local height = M.opts.popup.dims.height
  local width = M.opts.popup.dims.width

  if height < 1 then
    height = math.floor(vim.o.lines * M.opts.popup.dims.height)
  end

  if width < 1 then
    width = math.floor(vim.o.columns * M.opts.popup.dims.width)
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local win_id = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    title = M.opts.popup.title or "─Clip",
    title_pos = M.opts.popup.title_pos or "left",
    row = math.floor(((vim.o.lines - height) / 2) - 1),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    style = "minimal",
    border = M.opts.popup.style or "rounded",
  })

  if win_id == 0 then
    vim.notify("ui#_create_window failed to create window, win_id returned 0")
    error("Failed to create window")
  end

  setup_autocmds_and_keymaps(bufnr, mode)

  vim.api.nvim_set_option_value("number", true, {
    win = win_id,
  })

  return win_id, bufnr
end

function M.paste(_)
  M.reg = ""
  popup("paste")
end

function M.copy(details)
  M.reg = ""
  M.stash = details.fargs[1]
  popup("copy")
end

function M.setup(opts)
  if not vim.tbl_isempty(opts) then
    M.opts = opts
  end
end

local function build_func (func)
  return function(detail)
    local args = detail.fargs
    func(args[1])
  end

end

vim.api.nvim_create_user_command("ClipPaste", build_func(M.paste), { nargs = "*", range = "%" })
vim.api.nvim_create_user_command("ClipCopy", build_func(M.copy), { nargs = "*", range = "%" })

