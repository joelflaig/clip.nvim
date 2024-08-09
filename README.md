# clip.nvim

**A list-like view for all your vim registers, written in lua.**

## Prerequisites

- `neovim`

## Installation

Using `packer.nvim`:

```lua
use "joelflaig/clip.nvim"
```

Using `lazy.nvim`:

```lua
{
  "joelflaig/clip.nvim",
  event = "VimEnter",
  opts = {
    -- configuration options
  }
}
```

## Configuration

```lua
opts = {
  regs = { -- registers to show
    alphabetical = {
    },
    numerical = {
    },
    special = {
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
```

