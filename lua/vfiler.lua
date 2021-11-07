local action = require 'vfiler/action'
local config = require 'vfiler/config'
local core = require 'vfiler/core'
local vim = require 'vfiler/vim'

local VFiler = require 'vfiler/vfiler'

local M = {}

config.setup {
  mappings = {
    ['.']         = action.toggle_show_hidden,
    ['<CR>']      = action.open,
    ['<S-Space>'] = action.toggle_select_up,
    ['<Space>']   = action.toggle_select_down,
    ['<Tab>']     = action.switch_to_filer,
    ['gg']        = action.move_cursor_top,
    ['h']         = action.close_tree_or_cd,
    ['j']         = action.loop_cursor_down,
    ['k']         = action.loop_cursor_up,
    ['l']         = action.open_tree,
    ['q']         = action.quit,
    ['r']         = action.rename,
    ['C']         = action.copy,
    ['D']         = action.delete,
    ['G']         = action.move_cursor_bottom,
    ['K']         = action.new_directory,
    ['L']         = action.switch_drive,
    ['M']         = action.move,
    ['N']         = action.new_file,
    ['P']         = action.paste,
    ['S']         = action.change_sort,
  },
}

function M.parse_command_args(args)
  return vim.to_vimdict(config.parse(args))
end

function M.start_command(args)
  local options, dirpath = config.parse_options(args)
  if not options then
    return false
  end
  local configs = {
    options = options,
    mappings = core.table.copy(config.configs.mappings),
  }
  return M.start(dirpath, configs)
end

function M.start(...)
  local args = {...}
  local configs = core.table.merge(args[2] or {}, config.configs)
  local options = configs.options

  local dirpath = args[1]
  if not dirpath or dirpath == '' then
    dirpath = vim.fn.getcwd()
  end

  -- TODO:
  options.name = 'test'

  local vfiler = VFiler.find(options.name)
  if vfiler then
    -- TODO: open action
  end
  action.start(dirpath, configs)
  return true
end

return M
