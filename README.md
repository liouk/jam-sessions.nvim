# :saxophone: JamSessions
Simple yet effective neovim session management plugin.

## Features
- Stores all session files in one directory
- Detects git repo to use as the session name; otherwise defaults to current working dir
- Uses fzf to choose a session to load or delete; if fzf does not exist, it uses neovim's native select mechanism (`vim.ui.select`)

## Requirements
- NeoVim >= 0.8.3 (probably earlier versions too, but not tested)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for internal functions
- (optional) [fzf](https://github.com/junegunn/fzf) and [fzf.vim](https://github.com/junegunn/fzf.vim) to search/select sessions

## Installation
### [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
return {
  'liouk/jam-sessions.nvim',
  dependencies = { 'junegunn/fzf', 'junegunn/fzf.vim', 'nvim-lua/plenary.nvim' },
  cmd = { 'SaveSession', 'LoadSession', 'DeleteSession' },
  config = function()
    require('jam-sessions').setup({
      dir = '/where/to/store/sessions/',
    })
  end,
}
```

## Configuration
The session files are by default stored in NeoVim's user data directory (`stdpath('data')` -- see [`:h stdpath`](https://neovim.io/doc/user/builtin.html#stdpath()) for more info).

JamSessions comes with the following defaults:
```lua
{
  dir = '<stdpath('data')>/sessions/', -- dir where session files are saved
}
```

## Usage
The plugin exposes the following commands:

#### SaveSession
Running `:SaveSession <name>` saves the current session to a file inside the selected session directory. If the current working directory is a git repo, the name of the session file will be equal to the repo's name. In any other case, the name of the session file will be the name of the current working dir. Session files will have the `.vim` extension. The default name can be overriden by providing an argument to the command, which will be used as the session file name.

#### LoadSession
Running `:LoadSession <name>` starts `fzf` or `vim.ui.select` on the selected session directory to choose a session file, and then loads the chosen session. If a session name is given, then it will load the given session.

#### DeleteSession
Running `:DeleteSession <name>` starts `fzf` or `vim.ui.select` on the selected session directory to choose a session file, and then deletes the chosen session. If a session name is given, then it will delete the given session.
