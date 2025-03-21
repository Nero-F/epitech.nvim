local config = {}
local userConfig = {}

local defaultConfig = {
  coding_style = {
    keymaps = {
      quit = { rhs = '<cmd>lua require"epitech.coding_style".quit()<cr>', action = 'quit' },
    },
    keybindings = {
      quit = 'q',
    },
    title = "EpiCodingStyle",
    separator = "━",
    delivery_dir =  vim.fn.expand("$PWD"),
    reports_dir = vim.fn.simplify(vim.fn.expand("$PWD")), -- simplify is not really usefull here
    export_file = "coding-style-reports.log",
  },
  header = {
    headermap = {
      c = { b = '/*', m= '**', e= '*/' },
      h = { b = '/*', m= '**', e= '*/' },
      hpp = { b = '/*', m= '**', e= '*/' },
      cpp = {b = '/*', m = '**', e = '*/'},
      make = {b = '##', m = '##', e = '##'},
      java = {b = '//', m = '//', e = '//'},
      latex = {b = '%%', m = '%%', e = '%%'},
      html = {b = '<!--', m = '  --', e = '-->'},
      lisp = {b = ';;', m = ';;', e = ';;'},
      css = {b = '/*', m = '**', e = '*/'},
      pov = {b = '//', m = '//', e = '//'},
      pascal = {b = '{ ', m = '   ', e = '}'},
      hs = {b = '{-', m = '--', e = '-}'},
      vim = {b = '""', m = '"" ', e = '""'},
    },
    com_map_shebang = {
      sh = {s = '#!/usr/bin/env sh', b = '##', m = '##', e = '##'},
      bash= {s = '#!/usr/bin/env bash', b = '##', m= '##', e= '##'},
      zsh= {s = '#!/usr/bin/env zsh', b = '##', m = '##', e = '##'},
      php= {s = '#!/usr/bin/env php', b = '/*', m = '**', e = '*/'},
      perl= {s = '#!/usr/bin/env perl', b= '##', m= '##', e = '##'},
      python= {s = '#!/usr/bin/env python3', b = '##', m= '##', e= '##'},
      ruby= {s= '#!/usr/bin/env ruby', b= '##', m= '##', e= '##'},
      node= {s= '#!/usr/bin/env node', b= '/*', m= '**', e= '*/'},
    }
  },
  -- diagnostics = {
  --   diag_file = "ag.disp",
  --   run_cmd = {
  --     "./unit_tests",
  --     "--verbose=5",
  --     "--always-succeed", -- nvim has trouble to parse the json when criterion return something other than 0
  --     "--json="
  --   },
  -- },
}

local configurableModule = {
  coding_style = false,
  diagnostic = false,
  header = false,
}

local function require_and_configure(moduleName)
  local fullName = 'epitech.' .. moduleName
  local module = require(fullName)

  if not configurableModule[moduleName] and module.cfg then
    configurableModule[moduleName] = true
    module.cfg(userConfig[moduleName])
    return module
  end
  return module
end
local function merge_table(a, b)
  if type(a) == 'table' and type(b) == 'table' then
    for k, v in pairs(b) do
      if type(v) == 'table' and type(a[k] or false) =='table' then
        merge_table(a[k], v)
      else
        a[k] = v
      end
    end
  end
  return a
end

function config.set_defaults(userDefaults)
  if userDefaults == nil then
    userConfig = defaultConfig
  else
    userConfig = merge_table(defaultConfig, userDefaults)
  end
  require_and_configure("coding_style")
  require_and_configure("header")
end

return config
