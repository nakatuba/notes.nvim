# notes.nvim

## Requirements

- [fd](https://github.com/sharkdp/fd)

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
      dir = '~/notes'
    }

    vim.keymap.set('n', '<leader>nn', require('notes').new)
    vim.keymap.set('n', '<leader>no', require('notes').open)
  end
}
```
