local core = require 'vfiler/core'

local Column = require 'vfiler/columns/column'
local Syntax = require 'vfiler/columns/syntax'

local IndentColumn = {}

function IndentColumn.new()
  local self = core.inherit(IndentColumn, Column, 'indent')
  self.icon = '|'

  self._syntax = Syntax.new {
    syntaxes = {
      indent = {
        group = 'vfilerIndent',
        start_mark = 'I@\\',
        highlight = 'vfilerDirectory',
      },
    },
    end_mark = '\\@I',
    ignore_group = 'vfilerIndent_Ignore',
  }
  return self
end

function IndentColumn:get_text(context, lnum, width)
  local item = context:get_item(lnum)
  if item.level > 0 then
    return self._syntax:surround_text(
      'indent', (' '):rep(item.level) .. self.icon
    )
  end
  return '', 0
end

function IndentColumn:get_width(context, width)
  local max_level = 0
  for _, item in ipairs(context.items) do
    if item.level > max_level then
      max_level = item.level
    end
  end
  return max_level > 0 and (max_level + self.icon:len()) or 0
end

function IndentColumn:highlights()
  return self._syntax:highlights()
end

function IndentColumn:syntaxes()
  return self._syntax:syntaxes()
end

return IndentColumn
