package.path = package.path .. ";./.lua_modules/share/lua/5.2/?.lua"
package.cpath = package.cpath .. ";./.lua_modules/lib/lua/5.2/?.so"

local argparse = require("argparse")
local ml = require("ml")
ToString = ml.tstring
function MaybeLogVerbose(msg)
	if Verbose then
		print(msg)
	end
end

local utils = require("utils")

local parser = argparse("sptarkov-mods", "A simple mod manager for SPTarkov")
parser:option("--cachedir", "Path to the cache directory; useful if you already have the archive files downloaded")
parser
	:option("--destination", "Destination path to extract archives to.")
	:default(os.getenv("HOME") .. "/Games/escape-from-tarkov/drive_c/SPTarkov")
parser:option("--download", "Path to download archives to. Defaults to ./tmp"):default("./tmp")
parser:flag("--keep", "If present downloaded archive files will not be deleted"):default(false)
parser:option("-j --json", "Path to your custom JSON-defined mods")
parser:flag("-v --verbose", "Enable verbose output"):default(false)

local args = parser:parse()

Verbose = args.verbose or false

if not utils.pathExists(args.destination) then
	print('destination directory "' .. args.destination .. '" does not exist or is not a directory.')
	os.exit(1)
end

if not utils.pathExists(args.download) then
	print('download directory "' .. args.download .. '" does not exist or is not a directory.')
	os.exit(1)
end

local mods = {}

MaybeLogVerbose("Loading mods from ./mods")
local baseMods = utils.loadModsFromPath("./mods")
ml.update(mods, baseMods)
MaybeLogVerbose("----------------")

if args.json ~= nil and utils.pathExists(args.json) then
	MaybeLogVerbose("Reading custom mods from json file=" .. args.json)
	local customMods = utils.loadModsFromPath(args.json)
	if customMods ~= nil then
		ml.update(mods, baseMods)
	end
	MaybeLogVerbose("----------------")
end

MaybeLogVerbose("Downloading and extracting mods")
utils.downloadAndExtract(mods, args.destination, args.download)
MaybeLogVerbose("----------------")
