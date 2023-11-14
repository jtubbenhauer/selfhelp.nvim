--- @class Mapping
--- @field mode string
--- @field lhs string
--- @field rhs string
--- @field desc string
--- @field category? string
--- @field opts? table

--- @class DisplayItem
--- @field lhs string
--- @field desc string
--- @field category? string

--- @class Highlight
--- @field hl_group string
--- @field lnum number
--- @field start_col number
--- @field end_col number

local sort_fn = function(a, b)
  if a.category == nil or b.category == nil then
    return false
  end
  return a.category < b.category
end

local M = {}

--- @type DisplayItem[]
M.display_items = {}

--- @param mapping Mapping
M.add = function(mapping)
  vim.api.nvim_set_keymap(mapping.mode, mapping.lhs, mapping.rhs, mapping.opts or {})
  table.insert(M.display_items, { lhs = mapping.lhs, desc = mapping.desc, category = mapping.category })
end

M.display_help = function()
  local items = M.display_items
  table.sort(items, sort_fn)

  --- @type Highlight[]
  local highlights = {}
  local lines = {}
  local max_line = 1
  local current_category = nil
  local lnum = 1
  local first_category = true

  for _, item in pairs(items) do
    if item.category ~= current_category then
      current_category = item.category
      local category_display = string.format(" %s", current_category or "Uncategorised")
      if not first_category then
        table.insert(lines, "")
        lnum = lnum + 1
      end
      table.insert(lines, category_display)
      table.insert(highlights, { "Comment", lnum, 0, string.len(category_display) })
      lnum = lnum + 1
      first_category = false
    end

    local lhs_display = ""
    if string.len(item.lhs) < 15 then
      lhs_display = item.lhs .. string.rep(" ", 15 - string.len(item.lhs))
    else
      lhs_display = item.lhs
    end

    local line = string.format("  %s   %s", lhs_display, item.desc)
    max_line = math.max(max_line, vim.api.nvim_strwidth(line))
    table.insert(lines, line)
    table.insert(highlights, { "Special", lnum, 1, vim.api.nvim_strwidth(lhs_display) })
    lnum = lnum + 1
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  local ns = vim.api.nvim_create_namespace("SelfHelp")
  for _, hl in ipairs(highlights) do
    local hl_group, lnum, start_col, end_col = unpack(hl)
    end_col = math.min(end_col, string.len(lines[lnum]))
    vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, start_col, {
      end_col = end_col,
      hl_group = hl_group,
    })
  end
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = bufnr })
  vim.keymap.set("n", "<c-c>", "<cmd>close<CR>", { buffer = bufnr })
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")

  local editor_width = vim.o.columns
  local editor_height = vim.o.lines - vim.o.cmdheight
  local winid = vim.api.nvim_open_win(bufnr, true, {
    relative = "editor",
    row = math.max(0, (editor_height - #lines) / 2),
    col = math.max(0, (editor_width - max_line - 1) / 2),
    width = math.min(editor_width, max_line + 1),
    height = math.min(editor_height, #lines),
    zindex = 150,
    style = "minimal",
    border = "rounded",
  })

  local function close()
    if vim.api.nvim_win_is_valid(winid) then
      vim.api.nvim_win_close(winid, true)
    end
  end
  vim.api.nvim_create_autocmd("BufLeave", {
    callback = close,
    once = true,
    nested = true,
    buffer = bufnr,
  })
  vim.api.nvim_create_autocmd("WinLeave", {
    callback = close,
    once = true,
    nested = true,
  })
end

return M
