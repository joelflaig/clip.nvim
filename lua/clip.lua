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
  local str

  if reg == "alph" then
    for _,v in ipairs(M.opts.regs.alphabetical) do
      str = tostring(tbl[v])
      str = string.gsub(str, "\n", "󰌑")
      str = v..": "..str
      table.insert(res, str)
    end

  elseif reg == "num" then
    for _,v in ipairs(M.opts.regs.numerical) do
      str = tostring(tbl[v])
      str = string.gsub(str, "\n", "󰌑")
      str = v..": "..str
      table.insert(res, str)
    end
  elseif reg == "num" then
    for _,v in ipairs(M.opts.regs.special) do
      str = tostring(tbl[v])
      str = string.gsub(str, "\n", "󰌑")
      str = v..": "..str
      table.insert(res, str)
    end
  end
  return res
end

---Change register content
---@param reg string
---@param value string
local function change_content(reg, value)
  vim.fn.setreg(reg, value)

  for _,i in ipairs(M.opts.regs.alphabetical) do
    if i == reg then
      alph[i] = value
      return
    end
  end

  for _,i in ipairs(M.opts.regs.numerical) do
    if i == reg then
      num[i] = value
      return
    end
  end

  for _,i in ipairs(M.opts.regs.special) do
    if i == reg then
      special[i] = value
      return
    end
  end
end

local function get_visual_selection(vmode, cbufnr)
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(cbufnr, s_start[2], s_end[2] + 1, false)
  if vmode == "V" then
    return table.concat(lines, '\n')
  elseif vmode == "v" then
    lines[1] = string.sub(lines[1], s_start[3], -1)
    if n_lines == 1 then
      lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
    else
      lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
    end
    return table.concat(lines, '\n')
  elseif vmode == "" then
    for i = 1,#lines do
      lines[i] = string.sub(lines[i], s_start[3], s_end[3])
    end
    return table.concat(lines, '\n')
  end
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
---@param cbufnr integer
---@param winid integer
---@param mode string -- May be "normal" or "copy"
---@param vmode string
local function setup_autocmds_and_keymaps(bufnr, cbufnr, winid, mode, vmode)
  if mode == "normal" then

    vim.o.modifiable = false

    for _,i in ipairs(M.opts.regs.alphabetical) do
      vim.keymap.set("n", string.upper(i), function()
        local str = alph[i]
        close(bufnr, winid)
        vim.api.nvim_paste(str, true, 1)
      end, { buffer = bufnr, silent = true })
    end

    for _,i in ipairs(M.opts.regs.numerical) do
      vim.keymap.set("n", i, function()
        local str = num[i]
        close(bufnr, winid)
        vim.api.nvim_paste(str, true, 1)
      end, { buffer = bufnr, silent = true })
    end

    for _,i in ipairs(M.opts.regs.special) do

      vim.keymap.set("n", i, function()
        local str = special[i]
        close(bufnr, winid)
        vim.api.nvim_paste(str, true, 1)
      end, { buffer = bufnr, silent = true })
    end

    vim.keymap.set("n", "q", function()
      close(bufnr, winid)
    end, { buffer = bufnr, silent = true })

  elseif mode == "copy" then
    vim.o.modifiable = false

    for _,i in ipairs(M.opts.regs.alphabetical) do
      vim.keymap.set("n", string.upper(i), function()
        change_content(i, get_visual_selection(vmode, cbufnr))
        close(bufnr, winid)
      end, { buffer = bufnr, silent = true })
    end

    for _,i in ipairs(M.opts.regs.numerical) do
      vim.keymap.set("n", i, function()
        change_content(i, get_visual_selection(vmode, cbufnr))
        close(bufnr, winid)
      end, { buffer = bufnr, silent = true })
    end

    for _,i in ipairs(M.opts.regs.special) do
      vim.keymap.set("n", i, function()
        change_content(i, get_visual_selection(vmode, cbufnr))
        close(bufnr, winid)
      end, { buffer = bufnr, silent = true })
    end

    vim.keymap.set("n", "q", function()
      close(bufnr, winid)
    end, { buffer = bufnr, silent = true })

  else
    error("Invalid mode")
  end
end

---Initializes the content of the register tables
local function init_content()
  for _,i in ipairs(M.opts.regs.alphabetical) do
    alph[i] = vim.fn.getreg(i)
  end

  for _,i in ipairs(M.opts.regs.numerical) do
    num[i] = vim.fn.getreg(i)
  end

  for _,i in ipairs(M.opts.regs.special) do
    special[i] = vim.fn.getreg(i)
  end
end

---Renders register content to a given buffer
---@param bufnr integer
---@param mode string
local function render_content(bufnr, mode)
  vim.o.modifiable = true
  if (mode == "normal") or (mode == "copy") then
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
  vim.o.modifiable = false
end

---Opens a popup
---@param mode string -- May be "normal" or "copy"
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


  local cbufnr = vim.api.nvim_get_current_buf()
  local vmode = vim.fn.visualmode()

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

  setup_autocmds_and_keymaps(bufnr,cbufnr, win_id, mode, vmode)
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

function M.paste()
  M.popup("normal")
end

function M.copy()
  M.popup("copy")
end

return M
