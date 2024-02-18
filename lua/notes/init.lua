local builtin = require('telescope.builtin')
local entry_display = require('telescope.pickers.entry_display')

local M = {}

M.config = {}

function M.setup(opts)
  M.config = vim.tbl_extend('force', M.config, opts or {})
end

function M.new()
  if vim.fn.isdirectory(vim.fn.expand(M.config.dir)) == 0 then
    vim.notify('Directory "' .. M.config.dir .. '" does not exist', vim.log.levels.ERROR)
    return
  end

  local filename = os.date("%Y%m%d%H%M%S.md")
  local datetime = os.date("%Y-%m-%d %H:%M:%S")
  local template = string.format([[
---
title: Untitled
date: %s
tags: []
---

# Untitled
]], datetime)

  vim.cmd.edit(M.config.dir .. '/' .. filename)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, '\n', { trimempty = true }))
end

function M.open()
  if vim.fn.isdirectory(vim.fn.expand(M.config.dir)) == 0 then
    vim.notify('Directory "' .. M.config.dir .. '" does not exist', vim.log.levels.ERROR)
    return
  end

  local displayer = entry_display.create {
    separator = ' │ ',
    items = {
      { width = 0.5 },
      { remaining = true }
    }
  }

  local make_display = function(entry)
    local metadata = entry.value

    return displayer {
      metadata.title,
      table.concat(metadata.tags, ' ')
    }
  end

  builtin.find_files {
    cwd = M.config.dir,
    find_command = { 'fd', '--extension', 'md', '--absolute-path' },
    prompt_title = 'Open Note',
    entry_maker = function(entry)
      local json = vim.fn.system({ 'yq', '--front-matter=extract', entry, '-o', 'json' })
      local metadata = vim.json.decode(json, { luanil = { object = true, array = true } })

      if metadata == nil then
        return
      end

      for i, tag in ipairs(metadata.tags) do
        metadata.tags[i] = '#' .. tag
      end

      return {
        value = metadata,
        ordinal = metadata.title .. ' ' .. table.concat(metadata.tags, ' '),
        display = make_display,
        path = entry
      }
    end
  }
end

return M
