local actions = require('notes.actions')
local builtin = require('telescope.builtin')
local make_entry = require('notes.make_entry')

local M = {}

M.config = {
  templates = {
    {
      name = 'default',
      filename = function()
        return os.date("%Y%m%d%H%M%S.md")
      end,
      content = function()
        local datetime = os.date("%Y-%m-%d %H:%M:%S")
        return string.format([[
---
title: Untitled
date: %s
tags: []
---

# Untitled
]], datetime)
      end
    },
    {
      name = 'daily',
      dir = 'daily',
      filename = function()
        return os.date("%Y%m%d%H%M%S.md")
      end,
      content = function()
        local date = os.date("%Y-%m-%d")
        local datetime = os.date("%Y-%m-%d %H:%M:%S")
        return string.format([[
---
title: "%s"
date: %s
tags: []
---

# %s
]], date, datetime, date)
      end
    }
  }
}

function M.setup(opts)
  M.config = vim.tbl_extend('force', M.config, opts or {})
end

function M.new_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir
  opts.templates = opts.templates or M.config.templates

  if vim.fn.isdirectory(vim.fn.expand(opts.dir)) == 0 then
    vim.notify('Directory "' .. opts.dir .. '" does not exist', vim.log.levels.ERROR)
    return
  end

  local names = {}

  for _, template in ipairs(opts.templates) do
    table.insert(names, template.name)
  end

  vim.ui.select(names, nil, function(selected)
    for _, template in ipairs(opts.templates) do
      if template.name == selected then
        local filename = type(template.filename) == 'function' and template.filename() or template.filename
        local content = type(template.content) == 'function' and template.content() or template.content
        if template.dir then
          opts.dir = opts.dir .. '/' .. template.dir
        end
        vim.cmd.edit(opts.dir .. '/' .. filename)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(content, '\n', { trimempty = true }))
      end
    end
  end)
end

function M.open_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir

  if vim.fn.isdirectory(vim.fn.expand(opts.dir)) == 0 then
    vim.notify('Directory "' .. opts.dir .. '" does not exist', vim.log.levels.ERROR)
    return
  end

  builtin.find_files {
    cwd = opts.dir,
    find_command = { 'fd', '-e', 'md' },
    prompt_title = 'Open Note',
    entry_maker = make_entry.gen_from_note(opts)
  }
end

function M.insert_link(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir

  if vim.fn.isdirectory(vim.fn.expand(opts.dir)) == 0 then
    vim.notify('Directory "' .. opts.dir .. '" does not exist', vim.log.levels.ERROR)
    return
  end

  builtin.find_files {
    cwd = opts.dir,
    find_command = { 'fd', '-e', 'md' },
    prompt_title = 'Insert Link',
    entry_maker = make_entry.gen_from_note(opts),
    attach_mappings = function(_, _)
      actions.select_default:replace(actions.insert_link)
      return true
    end
  }
end

return M
