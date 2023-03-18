-- Inspiration from:
-- https://github.com/nvim-telescope/telescope-project.nvim
local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
  return
end

local Path = require("plenary.path")
local has_session_manager, manager = pcall(require, "session_manager")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local telescope_config = require("telescope.config").values
local actions = require("telescope.actions")
local state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")

local history = require("project_nvim.utils.history")
local project = require("project_nvim.project")

local utils
if has_session_manager then
  utils = require("session_manager.utils")
end
----------
-- Actions
----------

local function create_finder()
  local results = history.get_recent_projects()

  -- Reverse results
  for i = 1, math.floor(#results / 2) do
    results[i], results[#results - i + 1] = results[#results - i + 1], results[i]
  end
  local displayer = entry_display.create({
    separator = " ",
    items = {
      {
        width = 30,
      },
      {
        remaining = true,
      },
    },
  })

  local function make_display(entry)
    return displayer({ entry.name, { string.gsub(entry.value, vim.env.HOME, "~"), "Comment" } })
  end

  return finders.new_table({
    results = results,
    entry_maker = function(entry)
      local name = vim.fn.fnamemodify(entry, ":t")
      return {
        display = make_display,
        name = name,
        value = entry,
        ordinal = name .. " " .. entry,
      }
    end,
  })
end

local function change_working_directory(prompt_bufnr)
  local selected_entry = state.get_selected_entry()
  if selected_entry == nil then
    actions.close(prompt_bufnr)
    return
  end
  local project_path = selected_entry.value
  actions.close(prompt_bufnr)
  -- session_manager will change session
  if not has_session_manager then
    vim.notify(
      "Warning: neovim-session-manager in not installed!\r\n"
        .. "Consider to install 'Shatur/neovim-session-manager' or \r\n"
        .. "delete 'project.nvim'"
    )
  end
  if has_session_manager then
    -- before switch project
    -- save current session
    manager.save_current_session()
    -- vim.notify("autosave_session before " .. project_path)
  end
  project.set_pwd(project_path, "telescope")
end

local function delete_session(path)
  -- Delete a session from the session manager storage
  if has_session_manager then
    local sessions = utils.get_sessions()
    for idx, session in ipairs(sessions) do
      if session.dir.filename == path then
        return Path:new(sessions[idx].filename):rm()
      end
    end
  end
end

local function delete_project(prompt_bufnr)
  local selectedEntry = state.get_selected_entry()
  if selectedEntry == nil then
    actions.close(prompt_bufnr)
    return
  end
  local choice = vim.fn.confirm("Delete '" .. selectedEntry.value .. "' from project list?", "&Yes\n&No", 2)

  if choice == 1 then
    history.delete_project(selectedEntry)
    delete_session(selectedEntry.value)

    local finder = create_finder()
    state.get_current_picker(prompt_bufnr):refresh(finder, {
      reset_prompt = true,
    })
  end
end

---Main entrypoint for Telescope.
---@param opts table
local function projects(opts)
  opts = opts or {}

  pickers
    .new(opts, {
      prompt_title = "Recent Projects",
      finder = create_finder(),
      previewer = false,
      sorter = telescope_config.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        map("n", "d", delete_project)
        map("i", "<c-d>", delete_project)

        local on_project_selected = function()
          change_working_directory(prompt_bufnr)
        end
        actions.select_default:replace(on_project_selected)
        return true
      end,
    })
    :find()
end

return telescope.register_extension({
  exports = {
    projects = projects,
  },
})
