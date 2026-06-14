-- Rails-aware runner for Snacks scratch buffers.
--
-- Scratch files live under stdpath("data")/scratch, not in the project tree,
-- so the originating project is recovered from the scratch's `.meta` file
-- (which Snacks stamps with the cwd it was created in).

local M = {}

-- The project cwd a scratch buffer was created in, from its `.meta` sidecar.
-- Falls back to Neovim's cwd for non-scratch buffers.
function M.project_cwd(buf)
  local file = vim.api.nvim_buf_get_name(buf)
  local meta = file .. ".meta"
  if file ~= "" and vim.uv.fs_stat(meta) then
    local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(meta), "\n"))
    if ok and type(decoded) == "table" and type(decoded.cwd) == "string" then
      return decoded.cwd
    end
  end
  return vim.fn.getcwd()
end

-- Pick how to execute a Ruby file based on the project root: a Rails app runs
-- through `bin/rails runner` (boots the full app env), else `bundle exec ruby`
-- when there's a Gemfile, else plain `ruby`.
function M.ruby_command(file, root)
  if vim.uv.fs_stat(root .. "/bin/rails") then
    return { root .. "/bin/rails", "runner", file }, "bin/rails runner"
  elseif vim.uv.fs_stat(root .. "/Gemfile") then
    return { "bundle", "exec", "ruby", file }, "bundle exec ruby"
  end
  return { "ruby", file }, "ruby"
end

local output_buf, output_win, output_source, output_insert_lines

local function close_output()
  if output_win and vim.api.nvim_win_is_valid(output_win) then
    vim.api.nvim_win_close(output_win, true)
  end
end

-- Insert the last results into the originating scratch (commented, so the
-- scratch stays runnable), then return focus to it.
local function insert_into_scratch()
  if not (output_source and vim.api.nvim_buf_is_valid(output_source)) then
    return
  end
  local at = vim.api.nvim_buf_line_count(output_source)
  vim.api.nvim_buf_set_lines(output_source, at, at, false, output_insert_lines or {})
  close_output()
  local win = vim.fn.bufwinid(output_source)
  if win ~= -1 then
    vim.api.nvim_set_current_win(win)
    vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(output_source), 0 })
  end
end

-- Render command output in a floating window on top of the scratch (a split
-- would sit *under* the scratch float and steal focus to a hidden window).
local function show_output(header, result, src)
  local body = {}
  local function append(text)
    if text and text ~= "" then
      vim.list_extend(body, vim.split(text:gsub("%s+$", ""), "\n", { plain = true }))
    end
  end
  append(result.stdout)
  if result.stderr and result.stderr ~= "" then
    vim.list_extend(body, { "", "── stderr ──" })
    append(result.stderr)
  end

  local lines = { header, "" }
  vim.list_extend(lines, body)

  -- Comment-formatted copy for inserting back into the scratch.
  output_source = src
  local cs = vim.bo[src].commentstring
  cs = (cs ~= nil and cs ~= "") and cs or "# %s"
  output_insert_lines = { "" }
  for _, l in ipairs(body) do
    table.insert(output_insert_lines, l ~= "" and cs:format(l) or "")
  end

  if not (output_buf and vim.api.nvim_buf_is_valid(output_buf)) then
    output_buf = vim.api.nvim_create_buf(false, true)
    vim.bo[output_buf].bufhidden = "hide"
    vim.keymap.set(
      "n",
      "<cr>",
      insert_into_scratch,
      { buffer = output_buf, nowait = true, desc = "Insert results into scratch" }
    )
    for _, key in ipairs({ "q", "<esc>" }) do
      vim.keymap.set("n", key, close_output, { buffer = output_buf, nowait = true, desc = "Close output" })
    end
  end
  vim.bo[output_buf].modifiable = true
  vim.api.nvim_buf_set_lines(output_buf, 0, -1, false, lines)
  vim.bo[output_buf].modifiable = false

  local width = math.floor(vim.o.columns * 0.6)
  local height = math.max(1, math.min(#lines, math.floor(vim.o.lines * 0.4)))
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = vim.o.lines - height - 4,
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " Scratch Output  —  ⏎ insert · q close ",
    title_pos = "center",
    zindex = 200, -- above the scratch float
  }
  if output_win and vim.api.nvim_win_is_valid(output_win) then
    vim.api.nvim_win_set_config(output_win, win_opts)
    vim.api.nvim_set_current_win(output_win)
  else
    output_win = vim.api.nvim_open_win(output_buf, true, win_opts)
  end
  vim.wo[output_win].wrap = true
  vim.api.nvim_win_set_cursor(output_win, { 1, 0 })
end

-- Run the current Ruby scratch buffer, Rails-aware, showing output in a float.
function M.run_ruby(self)
  local buf = self.buf
  local cwd = M.project_cwd(buf)
  local root = vim.fs.root(cwd, { "Gemfile", ".git" }) or cwd
  local tmp = vim.fn.tempname() .. ".rb"
  vim.fn.writefile(vim.api.nvim_buf_get_lines(buf, 0, -1, false), tmp)
  local cmd, label = M.ruby_command(tmp, root)

  Snacks.notify.info("Running " .. label .. "…", { title = "Scratch", id = "scratch_run" })
  vim.system(cmd, { cwd = root, text = true }, function(result)
    vim.schedule(function()
      local header = ("$ %s   (%s, exit %d)"):format(label, vim.fn.fnamemodify(root, ":~"), result.code)
      show_output(header, result, buf)
      pcall(vim.fn.delete, tmp)
    end)
  end)
end

-- Options merged into the Snacks setup so Ruby scratches get the run keymap.
M.opts = {
  win_by_ft = {
    ruby = {
      keys = {
        ["run"] = {
          "<cr>",
          function(self) M.run_ruby(self) end,
          desc = "Run scratch (Rails-aware)",
          mode = "n",
        },
      },
    },
  },
}

return M
