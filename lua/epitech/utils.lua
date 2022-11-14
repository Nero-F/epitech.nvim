local utils = {}

utils.cfg = function(_config)
  local config = _config

  if config.keybindings then
    for name, lhs in pairs(config.keybindings) do
      if config.keymaps[name] then
	config.keymaps[name].lhs = lhs
      end
    end
  end
  return config
end


utils.disp_important = function(content)
  local encoded = vim.fn.json_encode(content)
  vim.fn.writefile({encoded}, "test.json", "b")
  vim.fn.execute("!cat test.json | jq")
end


return utils
