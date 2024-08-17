local M = {}

local utils = require("utils.utils")
local github_api = require("utils.api.github")

---Fetches a mod archive from GitHub
---@param mod SPTarkovGithubMod
function M.fetch_from_github(mod, destination_path)
	local latest_release = github_api.get_latest_release(mod.owner, mod.repo)

	local download_url = latest_release.assets[1].browser_download_url
	utils.download_file(download_url, destination_path)
end

return M
