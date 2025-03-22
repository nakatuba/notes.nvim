# notes.nvim

## Requirements

- [fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'

## Installation

### lazy.nvim

```lua
{
  'nakatuba/notes.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim'
  },
  config = function()
    require('notes').setup {
      dir = '~/notes'
    }

    vim.keymap.set('n', '<leader>nn', require('notes').new_note)
    vim.keymap.set('n', '<leader>no', require('notes').open_note)
  end
}
```
