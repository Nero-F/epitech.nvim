<h1 align="center">Epitech.nvim</h1>
<p align="center">Epitech's neovim plugin </p>

## Description

This plugin aims to make epitech's student life easier while using vim
</br>
It offers some pretty fine functionality such as embeded coding style reports, headers and so on

##### The plugin is mainly for 1st year student as upper grade studs doesn't need some of its functionalities but feel free to use it or contribute (: .

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```viml 
use 'Nero-F/epitech.nvim'
```

Using [vim-plug](https://github.com/junegunn/vim-plug)
```viml 
Plug 'Nero-F/epitech.nvim'
```

Using [dein](https://github.com/Shougo/dein.vim)
```viml
call dein#add('Nero-F/epitech.nvim')
```

## Configurations
```lua
require("epitech").setup({
  coding_style = {
    -- Default configurations for coding_style goes here
    delivery_dir =  "a folder", -- default: current directory
    reports_dir = "a folder", -- default: current directory
    export_file = "a filename", -- default: "coding-style-reports.log"
  },
})
```

## Disclaimer

This plugin is still under development, I only code it for fun, to practice a little bit of lua and to help my junior students at school.

### Contributing

All contributions are welcome! Just open a pull request. Please read CONTRIBUTING.md
