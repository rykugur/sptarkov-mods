package.path = package.path .. ";./.lua_modules/share/lua/5.2/?.lua"
package.cpath = package.cpath .. ";./.lua_modules/lib/lua/5.2/?.so"

local argparse = require("argparse")
local lfs = require("lfs")
local ml = require("ml")
ToString = ml.tstring

local utils = require("utils")

---@class Args
---@field cachedir? string
---@field destination string
---@field downloaddir string
---@field keep boolean
---@field json? string
---@field verbosity number

local parser = argparse("sptmm", "A simple mod manager for SPTarkov")
parser:option("--cachedir", "Path to the cache directory; useful if you already have the archive files downloaded")
-- TODO: should this be changed to an --extract flag, and when not supplied do not extract?
parser:option("--destination", "Destination path to extract archives to."):default("./dest")
parser:option("--downloaddir", "Path to download archives to. Defaults to ./tmp"):default("./tmp")
parser:flag("--keep", "If present downloaded archive files will not be deleted"):default(false)
parser:option("-j --json", "Path to your custom JSON-defined mods")
parser:flag("-v --verbose", "Sets verbosity level (-v, -vv, -vvv)"):count("0-2"):target("verbosity"):default(0)

---@type Args
Args = parser:parse()

if not utils.pathExists(Args.destination) then
	utils.log('destination directory "' .. Args.destination .. '" does not exist or is not a directory. Creating.')
	lfs.mkdir(Args.destination)
end

if not utils.pathExists(Args.downloaddir) then
	utils.log('download directory "' .. Args.downloaddir .. '" does not exist or is not a directory. Creating.')
	lfs.mkdir(Args.downloaddir)
end

local mods = {}

utils.log("Loading mod defs from ./mods/*.json")
local baseMods = utils.loadModsFromPath("./mods")
-- ml.update(mods, baseMods[1])
table.insert(mods, baseMods[1])

print("DERP99: baseMods[1]=", ToString(baseMods[1]))

if Args.json ~= nil and utils.pathExists(Args.json) then
	utils.log("Reading custom mods from json file=" .. Args.json)
	local customMods = utils.loadModsFromPath(Args.json)
	if customMods ~= nil then
		ml.update(mods, baseMods)
	end
end

utils.log("Loaded " .. #mods .. " mod defs")

utils.downloadAndExtract(mods)
