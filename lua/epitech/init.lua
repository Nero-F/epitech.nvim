local M = {}

M.getAcademicYear = function ()
  return 2022
end

local appendPreProcDirectives = function(ft)
  local rhs_ext = ft == "hpp" and "_HPP_" or "_H_"
  local filename = string.upper(vim.fn.expand("%:t:r") .. rhs_ext)

  local cppDirectives = {
    "#ifndef " .. filename,
    "#define " .. filename,
    "",
    "#endif /* " .. filename .. " */",
  }

  vim.fn.append(vim.fn.line('.'), cppDirectives)
end

HEADERMAP = {
  c = { b = '/*', m= '**', e= '*/' },
  h = { b = '/*', m= '**', e= '*/' },
  hpp = { b = '/*', m= '**', e= '*/' },
  cpp = {b = '//', m = '//', e = '//'},
  make = {b = '##', m = '##', e = '##'},
  java = {b = '//', m = '//', e = '//'},
  latex = {b = '%%', m = '%%', e = '%%'},
  html = {b = '<!--', m = '  --', e = '-->'},
  lisp = {b = ';;', m = ';;', e = ';;'},
  css = {b = '/*', m = '**', e = '*/'},
  pov = {b = '//', m = '//', e = '//'},
  pascal = {b = '{ ', m = '   ', e = '}'},
  haskell = {b = '{-', m = '-- ', e = '-}'},
  vim = {b = '""', m = '"" ', e = '""'},
}

local getProjectName = function()
  local cwd = vim.fn.getcwd()
  local i, j = string.find(cwd, "/[a-zA-Z0-9 .]+$")

  if i == nil then
    print("Could nor determine the name of the project..")
    return nil
  end
  return ' ' .. string.sub(cwd, i+1, j)

end

local putHeader = function(targetedHeader, fileDesc, projName)
  local header = {
    targetedHeader.b,
    targetedHeader.m .. " EPITECH PROJECT, " .. M.getAcademicYear(), -- TODO: this need to done 
    targetedHeader.m .. projName,
    targetedHeader.m .. " File description:" ,
    targetedHeader.m .. " " .. fileDesc,
    targetedHeader.e
  }

  vim.fn.append(0, header)
end

-- user input logic
local askUserInputAndPutHeader = function(targetedHeader, callback)
  local projNameTmp = getProjectName()
  local defaultString = "" 

  if projNameTmp then
    defaultString = " (default: ".. projNameTmp .. ")  "
  end

  vim.ui.input("PROJECT NAME?" .. defaultString, function(projName)
    if projName == nil then
      projName = projNameTmp
    else
      projName = ' ' .. projName
    end
    local fileDescTmp = vim.fn.expand("%:t:r")
    defaultString = " (default:".. fileDescTmp .. ")"

    vim.ui.input("Description" .. defaultString, function(fileDesc)
      if fileDesc == nil then
        fileDesc = fileDescTmp
      else
        fileDesc = ' ' .. fileDescTmp
      end
      putHeader(targetedHeader, fileDesc, projName)
    end)
  end)
end


M.EpiHeader = function()
  local ft = vim.bo.filetype;
  local targetedHeader = HEADERMAP[ft]

  if targetedHeader == nil then
    print("Filetype not supported...")
    return nil
  end

  if ft == 'h' and ft == "hpp" then
    appendPreProcDirectives(ft)
  end
  askUserInputAndPutHeader(targetedHeader) -- In this order cuz input are non-blocking
end

vim.keymap.set('n', '<leader>h', M.EpiHeader, { noremap=true, silent=false })

M.EpiHeader()

