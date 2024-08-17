package.path = package.path .. ";./.lua_modules/share/lua/5.2/?.lua"
package.cpath = package.cpath .. ";./.lua_modules/lib/lua/5.2/?.so"

local github_fetcher = require("utils.fetchers.github")

---@class SPTarkovGithubMod
local github_mod = {
	owner = "space-commits",
	repo = "SPT-Realism-Mod-Client",
}

if pcall(function()
	github_fetcher.fetch_from_github(github_mod, "./tmp")
end) then
	print("success")
else
	print("failed")
end
