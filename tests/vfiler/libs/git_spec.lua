local core = require('vfiler/libs/core')
local git = require('vfiler/libs/git')

describe('git', function()
  local rootpath = vim.fn.fnamemodify('./', ':p')

  describe('get_toplevel', function()
    it('root:' .. rootpath, function()
      -- TODO:
      --local path = git.get_toplevel(rootpath)
      --assert.is_not_nil(path)
    end)
  end)

  describe('reload_status_file', function()
    local options = {}
    local path = vim.fn.fnamemodify('./README.md', ':p')
    local status

    it('default', function()
      status = git.reload_status_file(rootpath, path, options)
    end)
    it('untracked option', function()
      options = {
        untracked = ture,
      }
      status = git.reload_status_file(rootpath, path, options)
    end)
    it('ignored option', function()
      options = {
        ignored = ture,
      }
      status = git.reload_status_file(rootpath, path, options)
    end)
    it('untracked and ignored options', function()
      options = {
        untracked = ture,
        ignored = ture,
      }
      status = git.reload_status_file(rootpath, path, options)
    end)
  end)

  describe('reload_status_async', function()
    it('default', function()
      local options = {}
      local job = git.reload_status_async(rootpath, options, function(status)
        assert.is_not_nil(status)
      end)
      assert.is_not_nil(job)
      job:wait()
    end)

    it('untracked option', function()
      options = {
        untracked = ture,
      }
      job = git.reload_status_async(rootpath, options, function(status)
        assert.is_not_nil(status)
      end)
      assert.is_not_nil(job)
      job:wait()
    end)

    it('ignored option', function()
      options = {
        ignored = ture,
      }
      job = git.reload_status_async(rootpath, options, function(status)
        assert.is_not_nil(status)
      end)
      assert.is_not_nil(job)
      job:wait()
    end)

    it('untracked and ignored options', function()
      options = {
        untracked = ture,
        ignored = ture,
      }
      job = git.reload_status_async(rootpath, options, function(status)
        assert.is_not_nil(status)
      end)
      assert.is_not_nil(job)
      job:wait()
    end)
  end)
end)
