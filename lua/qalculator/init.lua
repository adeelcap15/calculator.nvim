local namespace_id = "qalculator"
local namespace = vim.api.nvim_create_namespace(namespace_id)

local config = {
	register = "a", -- Default register
}

local function setup(new_config)
	-- extend default config with new keys
	config = vim.tbl_deep_extend('force', config, new_config)
end

local function sum_col(data)
	local result = 0
	for i = 1, #data do
		if (tonumber(data[i]) ~= nil) then
			data[i] = tonumber(data[i])
		else
			data[i] = 0
		end
		result = result + tonumber(data[i])
	end
	return result
end

local function calc_expression(cmd)
	local output = vim.fn.system(cmd)
	return output
end

local function displayResultVirtual(result)
	local ns = vim.api.nvim_create_namespace("calc")
	local lcur = vim.api.nvim_call_function("line", { "." }) - 1
	-- vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
	-- vim.api.clear_namespace(ns, 0, -1)
	local highlight = "String"
	vim.api.nvim_buf_set_extmark(0, ns, lcur, 0, { virt_text = { { result, highlight } }, virt_text_pos = "right_align" })
end

local function is_error(result)
	local isError = false
	if string.find(result, "error: ") then
		isError = true
	elseif string.find(result, "warning: ") then
		isError = true
	elseif string.find(result, "npwarning: ") then
		isError = true
	elseif string.find(result, '=') == nil then
		isError = true
	end
	return isError
end

local function calculate(operation)
	operation = operation or "expr"
	operation = string.lower(operation)
	if operation == "sum" then
		local a = vim.fn.getreg(config.register);
		local r = vim.fn.substitute(a, "\n", ",", 'g');
		local t = vim.fn.split(r, ",")
		local res = sum_col(t)
		vim.api.nvim_set_current_line(tostring(res))
		return res
	end

	if operation == "expr" then
		local a = vim.fn.getreg(config.register);
		-- local cmd = "echo \"scale=2;" .. a .. "\" | bc -l"
		local cmd2 = "qalc '" .. a .. "'"
		local r = calc_expression(cmd2)

		local isError = is_error(r)
		--Match everything after last '='
		r = string.gsub(r, "\n", "")
		rb = string.match(r, '= ([^=]*)$')
		if rb == nil then
			rb = r
		end
		local line = vim.api.nvim_get_current_line()
		-- local nline = vim.api.nvim_set_current_line(line .. " = " .. r)
		-- line = line.sub(line, 1, line.find(line, "\n") - 1)
		local nlineb = line .. " = " .. rb
		local nline = r
		-- print(cmd)
		if (isError) then
			vim.api.nvim_err_writeln(nlineb)
		else
			vim.api.nvim_out_write(nlineb)
			vim.api.nvim_set_current_line(nlineb)
			displayResultVirtual(nline)
		end
		-- vim.api.nvim_set_current_line(nlineb)

		return nlineb
	end
end


local M = {
	config = config,
	setup = setup,
	calculate = calculate,
}

M.testMessage = function()
	print("Hello World! precision " .. config.precision)
end


return M
