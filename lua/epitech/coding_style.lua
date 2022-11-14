local api = vim.api
local config = nil
local EpiCodingStyle = {}

local sets = {
  'setlocal buftype=nofile bufhidden=wipe nobuflisted nolist noswapfile nowrap nospell nonumber norelativenumber nofoldenable signcolumn=no',
  'syntax clear',
}

local keymaps = {
  quit = { rhs = '<cmd>lua require"packer.display".quit()<cr>', action = 'quit' },
}

EpiCodingStyle.cfg = function(_config)
  config = require("epitech.utils").cfg(_config)
end

local EpiDisplayMetatable = {
   valid_display = function(self)
    return self and self.interactive and api.nvim_buf_is_valid(self.buf) and api.nvim_win_is_valid(self.win)
  end,
  set_lines = function(self, start_idx, end_idx, lines)
    if not self:valid_display() then
      return
    end
    api.nvim_buf_set_option(self.buf, 'modifiable', true)
    api.nvim_buf_set_lines(self.buf, start_idx, end_idx, true, lines)
    api.nvim_buf_set_option(self.buf, 'modifiable', false)
  end,
  get_lines = function(self, start_idx, end_idx)
    if not self:valid_display() then
      return
    end
    return api.nvim_buf_get_lines(self.buf, start_idx, end_idx, true)
  end,
  get_current_line = function(self)
    if not self:valid_display() then
      return
    end
    return api.nvim_get_current_line()
  end,
}

EpiDisplayMetatable.__index = EpiDisplayMetatable 

local function dump_style(exportFile)
  local grep_severity = {
    MAJOR = "$(grep -c \": MAJOR:\" " .. exportFile .. ") major,",
    MINOR = "$(grep -c \": MINOR:\" " .. exportFile .. ") minor,",
    INFO = "$(grep -c \": INFO:\" " .. exportFile .. ") info",
  }
  local cmd = "echo \"$(wc -l < " .. exportFile.. ") coding style error(s)," ..  grep_severity.MAJOR .. grep_severity.MINOR .. grep_severity.INFO .. "\""

  print("reported in " .. exportFile)
  vim.fn.jobstart(cmd, {
    pty = true,
    stdout_buffered = true,
    on_stdout = function (_, d)
      EpiCodingStyle.open(d[1])
    end
  })
end

local function make_header(buf)
  local width = api.nvim_win_get_width(0)
  local pad_width = math.floor((width - string.len(config.title)) / 2.0)

  api.nvim_buf_set_lines(buf, 0, 1, true, {
    string.rep(' ', pad_width) .. config.title,
    ' ' .. string.rep(config.separator, width - 2),
  })
end

local function make_content(buf, content)
  local parsed = vim.fn.split(content, ",")
  local i = 1

  for word in string.gmatch(content, '([^,]+)') do
    vim.fn.appendbufline(buf, i + 1,word)
    i = i + 1
  end
end

local function setup_window(disp)
  api.nvim_buf_set_option(disp.buf, 'filetype', 'EpiWindow')
  api.nvim_buf_set_name(disp.buf, '[EpiWindow]')
  for _, m in pairs(keymaps) do
    if m.lhs then
      api.nvim_buf_set_keymap(disp.buf, 'n', m.lhs, m.rhs, { nowait = true, silent = true })
    end
  end
  for _, c in ipairs(sets) do
    vim.cmd(c)
  end
end

function EpiCodingStyle.open(content)
  local disp = setmetatable({}, EpiDisplayMetatable)
  vim.cmd("35vnew")

  disp.win = api.nvim_get_current_win();
  disp.buf = api.nvim_get_current_buf();

  disp.namespace = api.nvim_create_namespace("");
  setup_window(disp)
  make_header(disp.buf)
  make_content(disp.buf, content)
  -- api.nvim_buf_set_lines(disp.buf, 4, 4, false, {"mes couilles"})
end

EpiCodingStyle.quit = function ()
  EpiCodingStyle.status.running = false
  vim.fn.execute("q!", "silent")
end

local function parse_line_for_qflist(line)
  local x, y = string.find(line, "%:%d+%:")
  local lineNbr = vim.fn.str2nr(string.sub(line, x+1, y-1), 10)
  x, y = string.find(line, "^[a-zA-Z0-9%_%-%.%/]+%:")
  local filename = string.sub(line, x, y-1)
  x, y = string.find(line, "%:%u+.+$")
  local error = string.sub(line, x+1, y)

  return {filename = filename, lnum = lineNbr, text = error, valid = 1}
end

local function parse_report_file()
  local filebuffer = vim.fn.readfile(config.export_file)
  local report = {
    major = {},
    minor = {},
    info = {},
  }

  if filebuffer == nil then
    print("Cannot read of file " .. config.export_file)
    return nil
  end

  for _, line in pairs(filebuffer) do
    local x, y = string.find(line, "%:%s%u+%:")
    local target = string.lower(string.sub(line, x+2, y-1))
    table.insert(report[target], parse_line_for_qflist(line))
  end
  return report
end

local function populate_quickfix_list(report)
  if vim.fn.setqflist({}, "r", {items = report.minor}) == -1 then
    print("Failure cannot populate quickfix list")
    return nil
  end
    print("Quickfix list now full")
  vim.fn.execute("copen")
end

local function set_coding_style_extmark()
  local qfl = vim.fn.getqflist()
  local ns = api.nvim_create_namespace("EpiCodingStyle.extmark")

  for _, item in ipairs(qfl) do
    vim.fn.bufload(item.bufnr)
    api.nvim_buf_set_extmark(item.bufnr, ns, item.lnum-1, 0, {
      virt_text = { {item.text, "QuickFixLine" } },
    })
  end
end

local function remove_export_file(filename)
  if vim.fn.filereadable(filename) == 1 then
    vim.fn.execute("!rm -f ".. filename)
  end
end

api.nvim_create_user_command("EpiCodingStyleOff", function()
  local ns = api.nvim_get_namespaces()["EpiCodingStyle.extmark"]
  local qfl = vim.fn.getqflist()

  for _, value in ipairs(qfl) do
    api.nvim_buf_clear_namespace(value.bufnr, ns, 0, -1)
  end
end, {})

api.nvim_create_user_command("EpiCodingStyle", function(_)
  local absoluteExportFilePath = vim.fn.expand("$PWD/"..config.export_file)
  local spawnChecker = {
    "docker", "run", "--rm", "-i",
    "-v", config.delivery_dir .. ":/mnt/delivery",
    "-v", config.reports_dir .. ":/mnt/reports",
    "ghcr.io/epitech/coding-style-checker:latest", "/mnt/delivery", "/mnt/reports",
  }

  remove_export_file(absoluteExportFilePath)
  print("Running Coding Style checker...")
  local ret = vim.fn.jobstart(spawnChecker, {
    on_exit = function ()
      local report = parse_report_file();
      if report == nil or populate_quickfix_list(report) == nil then
      	return
      end
      set_coding_style_extmark()
      -- dump_style(config.reports_dir .. "/" .. config.export_file, report)
    end
  })

  if ret == -1 then
    print("Error while trying checking coding style.")
  end
end,
{})

return EpiCodingStyle
