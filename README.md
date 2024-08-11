# clip.nvim

**Thought this might be a fun way to use registers.
Written in lua.**

To be honest, I have no idea why you would want to use this, 
I just thought, it might be a fun idea for my first nvim plugin.

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

There are no configuration options, but you can configure the 
highlight groups if you want to, they are listed down below.

### Highlight groups

