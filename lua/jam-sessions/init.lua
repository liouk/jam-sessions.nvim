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

local function select_session(action)
  local items = Scan.scan_dir(Config.options.dir, { hidden = true, depth = 1 })
  for i = 1, #items do
    local parts = vim.split(items[i], '/', true)
    items[i] = parts[#parts]
  end
  local selected = ''
  vim.ui.select(
    items,
    { prompt = 'Select a session file to ' .. action .. ':' },
    function(sel)
      if not sel then return end
      selected = sel
    end
  )

  return selected
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

  local status = pcall(vim.call,
    'fzf#vim#files',
    Config.options.dir,
    {source = 'ls -a *.vim .*.vim', sink = 'source', options = {'--prompt', 'Open Session> '}}
  )

  if not status then
    local session_file = select_session('load')
    if session_file == '' then return end
    vim.api.nvim_command('source ' .. Config.options.dir .. '/' .. session_file)
  end
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

  local status = pcall(vim.call,
    'fzf#vim#files',
    Config.options.dir,
    {source = 'ls -a *.vim .*.vim', sink = 'silent! !rm', options = {'--prompt', 'Delete Session> '}}
  )

  if not status then
    local session_file = select_session('delete')
    if session_file == '' then return end
    vim.fn.delete(Config.options.dir .. '/' .. session_file)
  end
end

return M
