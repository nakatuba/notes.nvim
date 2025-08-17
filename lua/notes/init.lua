local utils = require('notes.utils')

local M = {}

M.config = {
  dir = '~/notes'
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

function M.new_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir

  if not utils.dir_exists(opts.dir) then
    return
  end

  vim.ui.input({ prompt = 'Title: ' }, function(title)
    if not title then
      return
    end

    if title == '' then
      title = 'Untitled'
    end

    local filename = os.date("%Y%m%d%H%M%S.md")
    local datetime = os.date("%Y-%m-%d %H:%M:%S")
    local template = string.format([[
---
title: %s
date: %s
tags: []
---

# %s
]], title, datetime, title)

    vim.cmd.edit(vim.fs.joinpath(opts.dir, filename))
    vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, '\n', { trimempty = true }))
  end)
end

function M.open_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir

  if not utils.dir_exists(opts.dir) then
    return
  end

  require('snacks').picker {
    title = 'Open Note',
    items = utils.get_items(opts.dir),
    format = 'text'
  }
end

function M.insert_link(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir

  if not utils.dir_exists(opts.dir) then
    return
  end

  require('snacks').picker {
    title = 'Insert Link',
    items = utils.get_items(opts.dir),
    format = 'text',
    confirm = function(picker, item)
      picker:close()
      local note = item.value
      vim.schedule(function()
        vim.cmd.startinsert()
        vim.api.nvim_put({ '[' .. item.text .. '](' .. note.path .. ')' }, '', true, true)
      end)
    end
  }
end

return M
