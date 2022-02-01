local core = require('vfiler/libs/core')

local NameColumn = {}

function NameColumn.new()
  local Column = require('vfiler/columns/column')
  local self = core.inherit(NameColumn, Column, {
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
      link = {
        group = 'vfilerName_Link',
        start_mark = 'n@l\\',
        highlight = 'vfilerLink',
      },
      hidden = {
        group = 'vfilerName_Hidden',
        start_mark = 'n@h\\',
        highlight = 'vfilerHidden',
      },
    },
    end_mark = '\\n@',
  })
  self.variable = true
  self.stretch = true

  self.min_width = 8
  self.max_width = 0
  return self
end

function NameColumn:get_width(items, width)
  if self.max_width <= 0 then
    return math.max(width, self.min_width)
  end
  return core.math.within(width, self.min_width, self.max_width)
end

function NameColumn:_get_text(item, width)
  local name = item.name
  -- append directory mark
  if item.is_directory then
    name = name .. '/'
  end
  return core.string.truncate(name, width, '..', math.floor(width / 2))
end

function NameColumn:_get_syntax_name(item, width)
  local syntax
  if item.selected then
    syntax = 'selected'
  elseif item.name:sub(1, 1) == '.' then
    syntax = 'hidden'
  elseif item.is_link then
    syntax = 'link'
  elseif item.is_directory then
    syntax = 'directory'
  else
    syntax = 'file'
  end
  return syntax
end

return NameColumn
