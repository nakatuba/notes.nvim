# notes.nvim

## Requirements

- [fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'

## Installation

```shell
asdf plugin add lua
asdf install lua 5.1.5
asdf global lua 5.1.5
```

### lazy.nvim

```lua
{
  'vhyrro/luarocks.nvim',
  priority = 1000,
  opts = {
    rocks = { 'yaml' },
    luarocks_build_args = { '--with-lua=' .. vim.fn.system('asdf where lua') }
  }
}
```

```lua
{
  'nakatuba/notes.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'vhyrro/luarocks.nvim'
  },
  config = function()
    require('notes').setup {
      dir = '~/notes',
      daily_notes = {
        dir = '~/notes/daily'
      }
    }

    vim.keymap.set('n', '<leader>nn', require('notes').new_note)
    vim.keymap.set('n', '<leader>no', require('notes').open_note)
    vim.keymap.set('n', '<leader>nd', require('notes').open_daily_note)
  end
}
```
