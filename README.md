# selfhelp.nvim

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/ellisonleao/nvim-plugin-template/lint-test.yml?branch=main&style=for-the-badge)
![Lua](https://img.shields.io/badge/Made%20with%20Lua-blueviolet.svg?style=for-the-badge&logo=lua)

A simple Neovim plugin to display a floating help dialog displaying your custom key mappings.

<img width="1439" alt="Screenshot 2023-11-14 at 6 04 36 pm" src="https://github.com/jtubbenhauer/selfhelp.nvim/assets/59836155/5ea02c79-16b9-4738-9948-f125c296dae0">

## Installation

Lazy.nvim
```
{ 'jtubbenhauer/selfhelp.nvim' }
```

## Usage

Replace any mappings you'd like to add to selfhelp.nvim like so:
```
local add = require("selfhelp").add
add({
	mode = "n",
	lhs = "<leader>ss",
	rhs = ":Telescope git_status<cr>",
	desc = "Search git status",
	category = "Search",
})
```

The dialog can be displayed with the `:SelfHelp` command. `q` or `<C-c>` will close the dialog.
