# qalculator.nvim
Calculate column sum as well as solve expression using Qalc as backend


## Installation

```vim
Plug 'adeelcap15/qalculator'
```

## Example Mapping

```lua
vim.api.nvim_create_user_command('Qalculate',
	function(opts)
		require("qalculator").calculate(opts.fargs[1])
	end,
	{
		nargs = 1,
		complete = function(ArgLead, CmdLine, CursorPos)
			return { "sum", "expr" }
		end,
	})
```

The input comes from the register. You can change it. The default register 
is register a.
