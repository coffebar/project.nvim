# 🗃️ project.nvim

This is a fork of
**project.nvim** neovim plugin written in lua that provides
superior project management.


https://user-images.githubusercontent.com/3100053/225754164-b4141431-29fd-4587-9c2f-f9fc531a6986.mp4


## Fork difference and reason

This fork is focused on IDE-like working with projects approach.

It's integrated with Session Manager to store all opened tabs and buffers for each project.

More dependencies for a better overall user experience.

## ⚡ Requirements

- Neovim >= 0.8.0
- [Neovim Session Manager](https://github.com/Shatur/neovim-session-manager)
- [Telescope](https://github.com/nvim-telescope/telescope.nvim)

## ✨ Features

- Automagically cd to project directory using nvim lsp
- If no lsp then uses pattern matching to cd to root directory
- Telescope integration `:Telescope projects`
  - Access your recently opened projects from telescope!
  - Asynchronous file io, so it will not slow down neovim when reading the history
    file on startup.
- Neovim Session Manager integration to store sessions
  - Install Neovim Session Manager and `:Telescope projects` command will navigate you to chosen project's directory and your previously opened buffers will be restored.

## 📦 Installation

Install the plugin with your preferred package manager:

### [packer](https://github.com/wbthomason/packer.nvim)

```lua
-- Lua
use {
  "coffebar/project.nvim",
  config = function()
    require("project_nvim").setup {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    }
  end
}
```

#### Add extension to telescope:

```lua
require('telescope').load_extension('projects')
```

#### Recommended settings for Session Manager

```lua
local Autoload = require("session_manager.config").AutoloadMode
local mode = Autoload.LastSession
local project_root, _ = require("project_nvim.project").get_project_root()
if project_root ~= nil then
	mode = Autoload.CurrentDir
end

session_manager.setup({
	autoload_mode = mode, -- Define what to do when Neovim is started without arguments.
	autosave_last_session = true, -- Automatically save last session on exit and on session switch.
	autosave_ignore_not_normal = false, -- keep it false
	autosave_ignore_filetypes = { -- All buffers of these file types will be closed before the session is saved.
		"ccc-ui",
		"gitcommit",
		"qf",
	},
	autosave_only_in_session = true, -- Always autosaves session. If true, only autosaves after a session is active.
})
```

## Commands

Plugin will add these commands:

- `Telescope projects` - select a project to open;
- `AddProject` - manually save current project to list and save session for it;
- `ProjectRoot` - set current dir as project root;

## ⚙️ Configuration

**project.nvim** comes with the following defaults:

```lua
require("project_nvim").setup({
  -- Manual mode doesn't automatically change your root directory, so you have
  -- the option to manually do so using `:ProjectRoot` command.
  manual_mode = false,

  -- Methods of detecting the root directory. "lsp" uses the native neovim
  -- lsp, while "pattern" uses vim-rooter like glob pattern matching. Here
  -- order matters: if one is not detected, the other is used as fallback. You
  -- can also delete or rearrange the detection methods.
  detection_methods = { "lsp", "pattern" },

  -- All the patterns used to detect root dir, when "pattern" is in
  -- detection_methods
  patterns = { 
    "!>home",
    "!=tmp",
    ".git",
    ".idea",
    ".svn",
    "PKGBUILD",
    "composer.json",
    "package.json",
    "Makefile",
    "README.md",
    "Cargo.toml",
  },

  -- Table of lsp clients to ignore by name
  -- eg: { "efm", ... }
  ignore_lsp = {},

  -- Don't calculate root dir on specific directories
  -- Ex: { "~/.cargo/*", ... }
  exclude_dirs = {
    "~/.local/*",
    "~/.cache/*",
    "~/.cargo/*",
    "~/.node_modules/*",
  },

  -- Show hidden files in telescope
  show_hidden = false,

  -- When set to false, you will get a message when project.nvim changes your
  -- directory.
  silent_chdir = false,

  -- What scope to change the directory, valid options are
  -- * global (default)
  -- * tab
  -- * win
  scope_chdir = "global",

  -- Path where project.nvim will store the project history for use in
  -- telescope
  datapath = vim.fn.stdpath("data"),

})
```

Even if you are pleased with the defaults, please note that `setup {}` must be
called for the plugin to start.

### Pattern Matching

**project.nvim**'s pattern engine uses the same expressions as vim-rooter, but
for your convenience, I will copy paste them here:

To specify the root is a certain directory, prefix it with `=`.

```lua
patterns = { "=src" }
```

To specify the root has a certain directory or file (which may be a glob), just
give the name:

```lua
patterns = { ".git", "Makefile", "*.sln", "build/env.sh" }
```

To specify the root has a certain directory as an ancestor (useful for
excluding directories), prefix it with `^`:

```lua
patterns = { "^fixtures" }
```

To specify the root has a certain directory as its direct ancestor / parent
(useful when you put working projects in a common directory), prefix it with
`>`:

```lua
patterns = { ">Latex" }
```

To exclude a pattern, prefix it with `!`.

```lua
patterns = { "!.git/worktrees", "!=extras", "!^fixtures", "!build/env.sh" }
```

List your exclusions before the patterns you do want.


#### Telescope mappings

**project.nvim** comes with the following mappings:

| Normal mode | Insert mode | Action                     |
| ----------- | ----------- | -------------------------- |
| d           | \<c-d\>     | delete\_project            |

## API

Get a list of recent projects:

```lua
local project_nvim = require("project_nvim")
local recent_projects = project_nvim.get_recent_projects()

print(vim.inspect(recent_projects))
```

## 🤝 Contributing

- All pull requests are welcome.
- If you encounter bugs please open an issue.
