local Config = require('jam-sessions.config')
local Path = require('plenary.path')
local Job = require('plenary.job')
local Scan = require('plenary.scandir')

local M = {}

local function endswith(str, suffix)
  local lstr = str:len()
  local lsuf = suffix:len()
  return str:sub(lstr-lsuf+1, lstr) == suffix
end

local function git_repo_root()
  local remote
  Job:new({
    command = 'git',
    args = {'rev-parse', '--show-toplevel'},
    cwd = vim.fn.getcwd(),
    on_exit = function(j)
      remote = j:result()[1]
    end,
  }):sync()

  return remote
end

local function get_session_name()
  local name = git_repo_root()
  if name == '' or name == nil then
    name = vim.fn.getcwd()
  end

  local parts = vim.split(name, '/', true)
  return parts[#parts]
end

local function select(action_label, action_func)
  local items = Scan.scan_dir(Config.options.dir, { hidden = true, depth = 1 })
  for i = 1, #items do
    local parts = vim.split(items[i], '/', true)
    items[i] = parts[#parts]
  end

  -- https://github.com/junegunn/fzf/issues/1778#issuecomment-697208274
  -- https://github.com/nanotee/nvim-lua-guide/issues/15#issuecomment-1107657154
  if vim.g.loaded_fzf_vim then
    local fzf_run = vim.fn['fzf#run']
    local fzf_wrap = vim.fn['fzf#wrap']
    local wrapped = fzf_wrap('select session', {
      source = items,
      sink = 'edit',
      dir = Config.options.dir,
      options = {'--prompt', action_label:gsub("^%l", string.upper) .. ' Session> '},
    })
    wrapped['sink*'] = nil
    wrapped.sink = function(sel)
      action_func(sel)
    end
    fzf_run(wrapped)
    return
  end

  local selected_session = ''
  vim.ui.select(
    items,
    { prompt = 'Select a session file to ' .. action_label .. ':' },
    function(sel)
      if not sel then return end
      selected_session = Config.options.dir .. '/' .. sel
    end
  )
  action_func(selected_session)
end

function M.setup(opts)
  Config.setup(opts)
end

function M.save_session(...)
  local args = { ... }
  local sessions_path = Config.options.dir
  vim.fn.mkdir(sessions_path, 'p')

  local filename = ''
  local ext = '.vim'
  if #args == 1 and args[1] ~= '' then
    filename = tostring(Path:new(sessions_path, args[1]))
    if endswith(filename, ext) then
      ext = ''
    end
  else
    local session_name = get_session_name()
    filename = tostring(Path:new(sessions_path, session_name))
  end

  filename = filename..ext
  vim.api.nvim_command('mksession! ' .. filename)
  vim.notify('jam-sessions: session saved in '..filename, vim.log.levels.INFO)
end

function M.load_session(...)
  local args = { ... }
  if #args == 1 and args[1] ~= '' then
    local ext = '.vim'
    local filename = tostring(Path:new(Config.options.dir, args[1]))
    if endswith(filename, ext) then ext = '' end
    vim.api.nvim_command('source ' .. filename .. ext)
    return
  end

  select('load', function(sel) vim.api.nvim_command('source ' .. sel) end)
end

function M.delete_session(...)
  local args = { ... }
  if #args == 1 and args[1] ~= '' then
    local ext = '.vim'
    local filename = tostring(Path:new(Config.options.dir, args[1]))
    if endswith(filename, ext) then ext = '' end
    vim.fn.delete(filename .. ext)
    return
  end

  select('delete', function(sel) vim.fn.delete(sel) end)
end

return M
