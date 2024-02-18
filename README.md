# notes.nvim

## Requirements

* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
* [fd](https://github.com/sharkdp/fd)
* [yq](https://github.com/mikefarah/yq)

## Installation

### lazy.nvim

```lua
return {
  'nakatuba/notes.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim'
  },
  config = function()
    require('notes').setup {
      dir = '~/notes'
    }

    vim.keymap.set('n', '<leader>nn', require('notes').new)
    vim.keymap.set('n', '<leader>no', require('notes').open)
  end
}
```
