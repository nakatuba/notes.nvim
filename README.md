# notes.nvim

## Requirements

- [fd](https://github.com/sharkdp/fd) - A simple, fast and user-friendly alternative to 'find'
- [jq](https://github.com/jqlang/jq) - Command-line JSON processor
- [yq](https://github.com/mikefarah/yq) - yq is a portable command-line YAML, JSON, XML, CSV, TOML and properties processor

## Installation

### lazy.nvim

```lua
{
  'nakatuba/notes.nvim',
  dependencies = {
    'folke/snacks.nvim'
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
