local core = require 'vfiler/core'

local Column = require 'vfiler/columns/column'
local Syntax = require 'vfiler/columns/syntax'

local ModeColumn = {}

function ModeColumn.new()
  local self = core.inherit(ModeColumn, Column, 'mode')
  self.format = '%Y/%m/%d %H:%M'

  self._syntax = Syntax.new {
    syntaxes = {
      executable = {
        group = 'vfilerMode_Executable',
        start_mark = 'm@e\\',
        highlight = 'vfilerModeExecutable',
      },
      other = {
        group = 'vfilerMode_Other',
        start_mark = 'm@o\\',
        highlight = 'vfilerMode',
      },
    },
    end_mark = '\\m@',
    ignore_group = 'vfilerMode_Ignore',
  }
  return self
end

function ModeColumn:get_text(context, lnum, width)
  local item = context:get_item(lnum)
  local mode = '-'

  if item.islink then
    mode = 'l'
  elseif item.isdirectory then
    mode = 'd'
  end
  mode = mode .. item.mode:sub(1, 3)

  local key = 'other'
  if mode:sub(#mode, #mode) == 'x' then
    key = 'executable'
  end
  return self._syntax:surround_text(key, mode)
end

function ModeColumn:get_width(context, width)
  return 4
end

function ModeColumn:highlights()
  return self._syntax:highlights()
end

function ModeColumn:syntaxes()
  return self._syntax:syntaxes()
end

return ModeColumn
