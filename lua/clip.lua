--- Copyright (c) 2024 joelflaig. All Rights Reserved.
--- Licensed under MIT license.

local config = require("clip.config")

local M = {}

local alph = {}
local num = {}
local special = {}

---Pack table as list
---@param tbl table
---@param reg string -- "alph", "num" or "spec"
local function pack(tbl, reg)
  local res = {}

  if reg == "alph" then
    for _,v in ipairs(M.opts.regs.alphabetical) do
      table.insert(res, tbl[v])
    end

  elseif reg == "num" then
    for _,v in ipairs(M.opts.regs.numerical) do
      table.insert(res, tbl[v])
    end
  elseif reg == "num" then
    for _,v in ipairs(M.opts.regs.special) do
      table.insert(res, tbl[v])
    end
  end
  return res
end

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
---@param winid integer
---@param mode string -- May be "normal" or "edit"
local function setup_autocmds_and_keymaps(bufnr, winid, mode)
  if mode == "normal" then

    for r,i in ipairs(M.opts.regs.alphabetical) do
      vim.keymap.set("n", string.upper(i), function()
        local str = tostring(alph[i])
        vim.api.nvim_paste(str, true, 1)
        close(bufnr, winid)
      end, { buffer = bufnr, silent = true })
    end

    for _,i in ipairs(M.opts.regs.numerical) do
      vim.keymap.set("n", i, function()
        local str = num[i]
        vim.api.nvim_paste(str, true, 1)
        close(bufnr, winid)
      end, { buffer = bufnr, silent = true })
    end

    for _,i in ipairs(M.opts.regs.special) do
      vim.keymap.set("n", i, function()
        local str = special[i]
        vim.api.nvim_paste(str, true, 1)
        close(bufnr, winid)
      end, { buffer = bufnr, silent = true })
    end

    vim.keymap.set("n", "q", function()
      close(bufnr, winid)
    end, { buffer = bufnr, silent = true })

  elseif mode == "edit" then
  else
    error("Invalid mode")
  end
end

---Initializes the content of the register tables
local function init_content()

  local str

  for _,i in ipairs(M.opts.regs.alphabetical) do
    str = vim.fn.getreg(i)
    str = string.gsub(str, "\n", "󰌑")

    alph[i] = i..": "..str
  end

  for _,i in ipairs(M.opts.regs.numerical) do
    str = vim.fn.getreg(i)
    str = string.gsub(str, "\n", "󰌑")

    num[i] = i..": "..str
  end

  for _,i in ipairs(M.opts.regs.special) do
    str = vim.fn.getreg(i)
    str = string.gsub(str, "\n", "󰌑")

    special[i] = i..": "..str
  end
end

---Renders register content to a given buffer
---@param bufnr integer
---@param mode string
local function render_content(bufnr, mode)
  if mode == "normal" then
    local a = pack(alph, "alph")
    table.insert(a, 1, "Alphabetical registers:")
    table.insert(a, "")

    local n = pack(num, "num")
    table.insert(n, 1, "Numerical registers:")
    table.insert(n, "")

    local s = pack(special, "spec")
    table.insert(s, 1, "Special registers:")
    table.insert(s, "")

    vim.api.nvim_buf_set_lines(bufnr, 0, #a, false, a)
    vim.api.nvim_buf_set_lines(bufnr, #a + 1, #a + #n, false, n)
    vim.api.nvim_buf_set_lines(bufnr, #a + #n + 1, #a + #n + #s, false, s)
  else
    error("Invalid mode")
  end
end

---Opens a popup
---@param mode string -- May be "normal" or "edit"
---@return integer,integer
function M.popup(mode)
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

  setup_autocmds_and_keymaps(bufnr, win_id, mode)
  render_content(bufnr, mode)

  vim.api.nvim_set_option_value("number", true, {
    win = win_id,
  })

  return win_id, bufnr
end

function M.setup(opts)
  if not vim.tbl_isempty(opts) then
    M.opts = config.setup(opts)
  else
    M.opts = config.defaults
  end
  init_content()
end

return M
