local utils = require('notes.utils')

local M = {}

M.config = {
  dir = '~/notes',
  types = { 'literature', 'permanent' },
  highlights = {
    literature = 'Green',
    permanent = 'Blue',
    tags = 'Purple'
  }
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})
end

function M.new_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir
  opts.types = opts.types or M.config.types

  if not utils.dir_exists(opts.dir) then
    return
  end

  vim.ui.select(opts.types, { prompt = 'Type: ' }, function(type)
    if not type then
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

      vim.cmd.edit(vim.fs.joinpath(opts.dir, type, filename))
      vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(template, '\n', { trimempty = true }))
    end)
  end)
end

function M.open_note(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir
  opts.highlights = opts.highlights or M.config.highlights

  if not utils.dir_exists(opts.dir) then
    return
  end

  require('snacks').picker {
    title = 'Open Note',
    items = utils.get_items(opts.dir),
    format = utils.get_format(opts.highlights)
  }
end

function M.insert_link(opts)
  opts = opts or {}

  opts.dir = opts.dir or M.config.dir
  opts.highlights = opts.highlights or M.config.highlights

  if not utils.dir_exists(opts.dir) then
    return
  end

  require('snacks').picker {
    title = 'Insert Link',
    items = utils.get_items(opts.dir),
    format = utils.get_format(opts.highlights),
    confirm = function(picker, item)
      picker:close()
      local note = item.value
      local current_dir = vim.fn.resolve(vim.fn.expand('%:p:h'))
      local target_path = vim.fn.resolve(item.file)
      local relative_path = utils.get_relative_path(current_dir, target_path)
      vim.schedule(function()
        vim.cmd.startinsert()
        vim.api.nvim_put({ '[' .. note.title .. '](' .. relative_path .. ')' }, '', true, true)
      end)
    end
  }
end

return M
