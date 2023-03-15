# 🗃️ project.nvim

This is a fork of
**project.nvim** neovim plugin written in lua that provides
superior project management.

![Telescope Integration](https://user-images.githubusercontent.com/36672196/129409509-62340f10-4dd0-4c1a-9252-8bfedf2a9945.png)

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

### [vim-plug](https://github.com/junegunn/vim-plug)

```vim
" Vim Script
Plug "coffebar/project.nvim"

lua << EOF
  require("project_nvim").setup {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  }
EOF
```

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

## ⚙️ Configuration

**project.nvim** comes with the following defaults:

```lua
{
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

  -- If plugin 'Shatur/neovim-session-manager' is installed,
  -- set this option to false if you don't want to open projects as sessions
  -- as default action for ":Telescope projects"
  session_autoload = true,
}
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

### Telescope Integration

To enable telescope integration:
```lua
require('telescope').load_extension('projects')
```

#### Telescope Projects Picker
To use the projects picker
```lua
require'telescope'.extensions.projects.projects{}
```

#### Telescope mappings

**project.nvim** comes with the following mappings:

| Normal mode | Insert mode | Action                     |
| ----------- | ----------- | -------------------------- |
| f           | \<c-f\>     | find\_project\_files       |
| b           | \<c-b\>     | browse\_project\_files     |
| d           | \<c-d\>     | delete\_project            |
| s           | \<c-s\>     | search\_in\_project\_files |
| r           | \<c-r\>     | recent\_project\_files     |
| w           | \<c-w\>     | change\_working\_directory |

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
