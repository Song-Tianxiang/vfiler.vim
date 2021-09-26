local core = require 'vfiler/core'

local Column = require 'vfiler/columns/column'
local Syntax = require 'vfiler/columns/syntax'

local NameColumn = {}

function NameColumn.new()
  local self = core.inherit(NameColumn, Column, 'name')
  self.variable = true
  self.stretch = true

  self.min_width = 32
  self.max_width = 0

  self._syntax = Syntax.new {
    syntaxes = {
      selected = {
        group = 'vfilerName_Selected',
        start_mark = 'n@s\\',
        highlight = 'vfilerSelected',
      },
      file = {
        group = 'vfilerName_File',
        start_mark = 'n@f\\',
        highlight = 'vfilerFile',
      },
      directory = {
        group = 'vfilerName_Directory',
        start_mark = 'n@d\\',
        highlight = 'vfilerDirectory',
      },
    },
    end_mark = '\\n@',
    ignore_group = 'vfilerName_Ignore',
  }
  return self
end

function NameColumn:get_text(context, lnum, width)
  local item = context:get_item(lnum)
  local name = item.name
  local syntax_name = ''
  if item.selected then
    syntax_name = 'selected'
  elseif item.isdirectory then
    name = name .. '/' -- append directory mark
    syntax_name = 'directory'
  else
    syntax_name = 'file'
  end
  -- TODO:
  return self._syntax:surround_text(
    syntax_name, core.trancate(name, width, '..', width / 2)
  )
end

function NameColumn:get_width(context, width)
  if self.max_width <= 0 then
    return math.max(width, self.min_width)
  end
  return math.min(math.max(width, self.min_width), self.max_width)
end

function NameColumn:highlights()
  return self._syntax:highlights()
end

function NameColumn:syntaxes()
  return self._syntax:syntaxes()
end

return NameColumn
