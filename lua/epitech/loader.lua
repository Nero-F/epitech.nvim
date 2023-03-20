local api = vim.api

local loader = {
  key = nil,
  bufid = nil,
  winid = nil,
  active = false,
  closed = false,
  spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏', },
  def_checker_txt =  " CS Checker",
  checker_txt = " CS Checker",
}


function loader:init()
  local i = 0
  self.active = true

  local ui = api.nvim_list_uis()[1]

  local width = #self.checker_txt + 1
  local height = 10
  local offset = 0
  local row = (ui.width/2) - width/2
  local col = (ui.width) - width

  if self.bufid == nil or not api.nvim_buf_is_valid(self.bufid) then
    self.bufid = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(self.bufid, "filetype", "spinner")
  end
  if self.winid == nil or not api.nvim_win_is_valid(self.winid) then
    self.winid = api.nvim_open_win(self.bufid, false, {
      relative='editor',
      width = width,
      height = height,
      row = 0,
      col = col,
      style = 'minimal',
      anchor = 'NW',
      focusable = false,
      zindex = nil,
      noautocmd = true,
      border = 'none'
    })
  end
end

function loader:updateTxt(str, thread) 
  self.checker_txt = str
  coroutine.resume(tread)
end

function loader:close()
  print(self.winid)
  if self.winid ~= nil and api.nvim_buf_is_valid(self.bufid) then
    api.nvim_win_hide(self.winid)
  end
end

function loader:disp_waiter(thread)
  local timer = vim.loop.new_timer()
  local i = 0

  timer:start(0, 250, vim.schedule_wrap(function()
    coroutine.resume(thread)
    if self.active == false then
      timer:close()
      coroutine.resume(thread, "stop")
      self:close()
    end
    i = i + 1
  end))
end

return loader
