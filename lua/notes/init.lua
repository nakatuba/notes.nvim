local actions = require('notes.actions')
local builtin = require('telescope.builtin')
local make_entry = require('notes.make_entry')

local M = {}

---@class Config
M.config = {
  dir = '~/notes',
  daily_notes = {
    dir = '~/notes/daily'
  }
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

function M.new_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir

  if vim.fn.isdirectory(vim.fn.expand(opts.dir)) == 0 then
    vim.notify('Directory "' .. opts.dir .. '" does not exist', vim.log.levels.ERROR)
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

  vim.cmd.edit(vim.fs.joinpath(opts.dir, filename))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, '\n', { trimempty = true }))
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
    find_command = { 'fd', '-d', '1', '-e', 'md' },
    prompt_title = 'Open Note',
    entry_maker = make_entry.gen_from_note(opts)
  }
end

function M.new_daily_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.daily_notes.dir

  if vim.fn.isdirectory(vim.fn.expand(opts.dir)) == 0 then
    vim.notify('Directory "' .. opts.dir .. '" does not exist', vim.log.levels.ERROR)
    return
  end

  local filename = os.date("%Y%m%d.md")

  if vim.fn.filereadable(vim.fn.expand(vim.fs.joinpath(opts.dir, filename))) == 1 then
    vim.cmd.edit(vim.fs.joinpath(opts.dir, filename))
    return
  end

  local date = os.date("%Y-%m-%d")
  local datetime = os.date("%Y-%m-%d %H:%M:%S")
  local template = string.format([[
---
title: "%s"
date: %s
tags: []
---

# %s
]], date, datetime, date)

  vim.cmd.edit(vim.fs.joinpath(opts.dir, filename))
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, '\n', { trimempty = true }))
end

function M.open_daily_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.daily_notes.dir

  if vim.fn.isdirectory(vim.fn.expand(opts.dir)) == 0 then
    vim.notify('Directory "' .. opts.dir .. '" does not exist', vim.log.levels.ERROR)
    return
  end

  builtin.find_files {
    cwd = opts.dir,
    find_command = { 'fd', '-d', '1', '-e', 'md' },
    prompt_title = 'Open Daily Note',
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
    find_command = { 'fd', '-d', '1', '-e', 'md' },
    prompt_title = 'Insert Link',
    entry_maker = make_entry.gen_from_note(opts),
    attach_mappings = function()
      actions.select_default:replace(actions.insert_link)
      return true
    end
  }
end

return M
