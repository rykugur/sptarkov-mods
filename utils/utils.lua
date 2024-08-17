local M = {}

---gets the redirect for a shell
---@return string
function M.get_redirect_for_current_shell()
	local shell = M.get_current_shell()
	if shell == "fish" then
		return "&> /dev/null"
	else
		return "2>&1 /dev/null"
	end
end

---Get the current shell
---@return string
function M.get_current_shell()
	local shell = os.getenv("SHELL")
	return shell ~= nil and shell:match("[^/]+$") or "bash" -- assume bash
end

---Downloads a file
---@param url any
---@param destination_path any
function M.download_file(url, destination_path)
	local command = "wget -P " .. destination_path .. " " .. url
	local handle = io.popen(command)
	if not handle then
		error(DOWNLOAD_FAILED)
	end
	local result = handle:read("*a")
	handle:close()

	if not result then
		error(DOWNLOAD_FAILED)
	end
end

return M
