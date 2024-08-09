local M = {
  opts = {
    regs = { -- registers to show
      alphabetical = {
        "a"
      },
      numerical = {
        "1"
      },
      special = {
        "%"
      },
    },
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

local function close(bufnr, winid)
  if bufnr ~= nil and vim.api.nvim_buf_is_valid(bufnr) then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end

  if winid ~= nil and vim.api.nvim_win_is_valid(winid) then
    vim.api.nvim_win_close(winid, true)
  end
end

---Sets up autocmds and keymaps for the given buffer
---@param bufnr integer
---@param mode string -- May be "copy" or "paste"
local function setup_autocmds_and_keymaps(bufnr, winid, mode)
  if mode == "copy" then
  elseif mode == "paste" then
    vim.keymap.set("n", "<CR>", function()
      vim.api.nvim_paste(
        vim.api.nvim_get_current_line(),
        true, 1
      )
    end, { buffer = bufnr, silent = true })

    vim.keymap.set("n", "<Esc>", function()
      close(bufnr, winid)
    end, { buffer = bufnr, silent = true })

  else
    error("Invalid mode")
  end
end

---Sets the content of the given buffer
---@param bufnr integer
---@param mode string
local function set_content(bufnr, mode)
  if mode == "paste" then
    local alph = {}
    local num = {}
    local special = {}

    table.insert(alph, "Alphabetical registers:")
    for _,i in ipairs(M.opts.regs.alphabetical) do
      table.insert(alph, vim.fn.getreg(i))
    end
    table.insert(alph, "")

    table.insert(num, "Numerical registers:")
    for _,i in ipairs(M.opts.regs.numerical) do
      table.insert(num, vim.fn.getreg(i))
    end
    table.insert(num, "")

    table.insert(special, "Special registers:")
    for _,i in ipairs(M.opts.regs.special) do
      table.insert(special, vim.fn.getreg(i))
    end
    table.insert(special, "")

    vim.api.nvim_buf_set_lines(bufnr, 0, #alph, false, alph)
    vim.api.nvim_buf_set_lines(bufnr, #alph + 1, #num, false, num)
    vim.api.nvim_buf_set_lines(bufnr, #num + 1, #special, false, special)
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

  set_content(bufnr, mode)
  setup_autocmds_and_keymaps(bufnr, win_id, mode)

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

