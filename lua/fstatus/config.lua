local default_config = {
  modified = "[M]",
  modified_highlight = "Conditional",
}

local M = vim.deepcopy(default_config)

M.update = function(opts)
	local newconf = vim.tbl_deep_extend("force", default_config, opts or {})

	if not newconf.enabled then return end

	for k, v in pairs(newconf) do
		M[k] = v
	end
end

return M
