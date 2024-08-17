local M = {}

local dkjson = require("dkjson")

---@class GithubAsset
---@field name string
---@field browser_download_url string

---@class GithubRelease
---@field tag_name string
---@field name string
---@field assets GithubAsset[]

---List releases for a GitHub repository
---@param owner string
---@param repo string
---@return GithubRelease[]
function M.list_releases(owner, repo)
	local url = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/releases"
	local curl = "curl -s " .. url
	local handle = io.popen(curl)
	if not handle then
		error(CURL_FAILED)
	end
	local result = handle:read("*a")
	handle:close()
	return dkjson.decode(result, 1, nil)
end

---Get the latest release for a GitHub repository
---@param owner string
---@param repo string
---@return GithubRelease
function M.get_latest_release(owner, repo)
	local url = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/releases/latest"
	local curl = "curl -s " .. url
	local handle = io.popen(curl)
	if not handle then
		error(CURL_FAILED)
	end
	local result = handle:read("*a")
	handle:close()
	return dkjson.decode(result, 1, nil)
end

return M
