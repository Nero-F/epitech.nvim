local EpiHeader = {}
local config = nil

EpiHeader.cfg = function(_config)
  config = require("epitech.utils").cfg(_config)
end

local getAcademicYear = function ()
  return os.date("%Y")
end

local function append_preproc_directives(ft)
  local rhs_ext = ft == "hpp" and "_HPP_" or "_H_"
  local filename = string.upper(vim.fn.expand("%:t:r") .. rhs_ext)

  local cppDirectives = { 
    define = {
      "#ifndef " .. filename,
      "#define " .. filename,
      "",
      "#endif /* " .. filename .. " */",
    },
    pragma = {
      "#pragma once"
    }
  }
  if ft == "h" then
    vim.fn.append(vim.fn.line('.'), cppDirectives.define)
  else
    vim.ui.select({"define", "pragma"}, { }, function(choice)
      vim.fn.append(vim.fn.line('.'), cppDirectives[choice])
    end)
  end
end

local putHeader = function(targetedHeader, fileDesc, projName)
  local header = {
    targetedHeader.b,
    targetedHeader.m .. " EPITECH PROJECT, " .. getAcademicYear(), -- TODO: this need to done 
    targetedHeader.m .. projName,
    targetedHeader.m .. " File description:" ,
    targetedHeader.m .. " " .. fileDesc,
    targetedHeader.e,
  }

  vim.fn.append(0, header)
end

local function get_project_name()
  local cwd = vim.fn.getcwd()
  local i, j = string.find(cwd, "/[%w%-%._]+$")

  if i == nil then
    print("Could not determine the name of the project..")
    return nil
  end
  return ' ' .. string.sub(cwd, i+1, j)
end

local function ask_user_input_and_put_header(targetedHeader, ft)
  local projNameTmp = get_project_name()
  local defaultString = ""

  if projNameTmp then
    defaultString = " (default: ".. projNameTmp .. ")  "
  end

  vim.ui.input("PROJECT NAME?" .. defaultString, function(projName)
    if projName == "" or projName == nil then
      projName = projNameTmp
    else
      projName = ' ' .. projName
    end
    local fileDescTmp = vim.fn.expand("%:t")
    defaultString = " (default:".. fileDescTmp .. ")"

    vim.ui.input("Description" .. defaultString, function(fileDesc)
      if fileDesc == "" or fileDesc == nil then
        fileDesc = fileDescTmp
      end
      putHeader(targetedHeader, fileDesc, projName)
      if ft == 'h' or ft == "hpp" then
        append_preproc_directives(ft)
      end
    end)
  end)
end

vim.api.nvim_create_user_command("EpiHeader", function(_)
  local ft = vim.fn.expand("%:e")
  local filename = vim.fn.expand("%:t"):lower()
  local targetedHeader = config.headermap[ft]

  if targetedHeader == nil and (filename == "makefile" or filename:match("^makefile%.")) then
    targetedHeader = config.headermap["make"]
  end

  if targetedHeader == nil then
    print("Filetype not supported...")
    return nil
  end

  ask_user_input_and_put_header(targetedHeader, ft)
end, { nargs = 0 })

-- WIP
--[[ local bufn = 6
local handleResult = function(chanId, data, event)
  local buffer = vim.fn.readfile("f", "b")
  vim.api.nvim_buf_set_lines(bufn, 0, -1, false, buffer)
  local buffString = vim.fn.join(buffer, "")
  local decoded = vim.json.decode(buffString)
  P(decoded.id)

end

vim.api.nvim_create_user_command("EpiTestsRun", function(opts)
  local ret = vim.fn.jobstart("./unit_tests --json=f --always-succeed", {
    pty=true,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = handleResult,
    -- on_stderr = doTheJob2, -- for some reason this does not work :/
  })
  P(ret)
end, {}) ]]
return EpiHeader
