local core = require('vfiler/libs/core')
local fs = require('vfiler/libs/filesystem')
local git = require('vfiler/libs/git')
local vim = require('vfiler/libs/vim')

local Directory = require('vfiler/items/directory')
local Session = require('vfiler/session')

local Context = {}
Context.__index = Context

--- Create a context object
---@param configs table
function Context.new(configs)
  local self = setmetatable({}, Context)
  self:_initialize()
  self.options = core.table.copy(configs.options)
  self.events = core.table.copy(configs.events)
  self.mappings = core.table.copy(configs.mappings)
  self._session = Session.new(self.options.session)
  self._git_enabled = self:_check_git_enabled()
  return self
end

--- Copy to context
function Context:copy()
  local configs = {
    options = self.options,
    events = self.events,
    mappings = self.mappings,
  }
  local new = Context.new(configs)
  new._session = self._session:copy()
  return new
end

--- Save the path in the current context
---@param path string
function Context:save(path)
  if not self.root then
    return
  end
  self._session:save(self.root, path)
end

--- Get the parent directory path of the current context
function Context:parent_path()
  if self.root.parent then
    return self.root.parent.path
  end
  return core.path.parent(self.root.path)
end

--- Switch the context to the specified directory path
---@param dirpath string
function Context:switch(dirpath)
  dirpath = core.path.normalize(dirpath)
  -- perform auto cd
  if self.options.auto_cd then
    vim.fn.execute('lcd ' .. dirpath, 'silent')
  end

  -- reload git status
  local job
  if self._git_enabled then
    if not (self.gitroot and dirpath:match(self.gitroot)) then
      self.gitroot = git.get_toplevel(dirpath)
    end
    if self.gitroot then
      job = self:_reload_gitstatus_job()
    end
  end

  self.root = Directory.new(fs.stat(dirpath))
  self.root:open()

  local path = self._session:load(self.root)
  if job then
    job:wait()
  end
  return path
end

--- Switch the context to the specified drive path
---@param drive string
function Context:switch_drive(drive)
  local dirpath = self._session:get_path_in_drive(drive)
  if not dirpath then
    dirpath = drive
  end
  return self:switch(dirpath)
end

--- Update from another context
---@param context table
function Context:update(context)
  self.options = core.table.copy(context.options)
  self.mappings = core.table.copy(context.mappings)
  self.events = core.table.copy(context.events)
  self._git_enabled = self:_check_git_enabled()
end

function Context:_check_git_enabled()
  if not self.options.git.enabled or vim.fn.executable('git') ~= 1 then
    return false
  end
  return self.options.columns:match('git%w*') ~= nil
end

function Context:_initialize()
  self.clipboard = nil
  self.extension = nil
  self.linked = nil
  self.root = nil
  self.gitroot = nil
  self.gitstatus = {}
  self.in_preview = {
    preview = nil,
    once = false,
  }
end

function Context:_reload_gitstatus_job()
  local git_options = self.options.git
  local options = {
    untracked = git_options.untracked,
    ignored = git_options.ignored,
  }
  return git.reload_status(self.gitroot, options, function(status)
    self.gitstatus = status
  end)
end

return Context
