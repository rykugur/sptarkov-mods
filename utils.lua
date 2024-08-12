local utils = {}

---@class SPTarkovMod
---@field name string
---@field url string
---@field fetcher string
---@field owner? string
---@field repo? string
---@field version? string
---@field filename? string
---@field googleDriveId? string
---@field dependencies? string[]

---@class CommandResult
---@field success? boolean
---@field exitType? string
---@field exitCode? integer

---@class DownloadResult
---@field success? boolean
---@field filename? string
---@field path? string
---@field commandResult CommandResult

---Excutes a command in the shell
---@param command any
---@return CommandResult
local function executeCommand(command)
	utils.log("Executing command=" .. command, 1)
	local success, exitType, exitCode = os.execute(command)

	if not success then
		if exitType == "exit" then
			utils.log("Command exited with status: " .. exitCode, 1)
		elseif exitType == "signal" then
			utils.log("Command was killed by signal: " .. exitCode, 1)
		end
	end

	return { success = success, exitType = exitType, exitCode = exitCode }
end

---@param url any
---@param downloadDir any
---@param filename any
---@return DownloadResult
local function doDownload(url, downloadDir, filename)
	local download_command = string.format('wget -O %s/%s "%s"', downloadDir, filename, url)
	local commandResult = executeCommand(download_command)
	return { success = commandResult.success, filename = filename, path = downloadDir, commandResult = commandResult }
end

local function downloadFromGithub(owner, repo, version, filename)
	local url = string.format("https://github.com/%s/%s/releases/download/%s/%s", owner, repo, version, filename)
	return doDownload(url, Args.downloaddir, filename)
end

local function downloadFromGoogleDrive(file_id, filename)
	local url = string.format("https://docs.google.com/uc?export=download&id=%s", file_id)
	return doDownload(url, Args.downloaddir, filename)
end

local function downloadDirect(url, destination) end

local function unzip(filename)
	local unzip_command = string.format("unzip -o %s -d %s", filename, Args.destination)
	return executeCommand(unzip_command)
end

local function un7zip(filename, destination)
	utils.log("------ Un7zipping file " .. filename .. " to destination=" .. destination, 1)
	local un7zip_command = string.format("7z x -o%s %s", destination, filename)
	return executeCommand(un7zip_command)
end

local function extract(filename, destination)
	local extension = utils.getFileExtension(filename)

	-- TODO: finish this
	if extension == ".zip" then
		return unzip(filename)
	elseif extension == ".7z" then
		return un7zip(filename, destination)
	else
		utils.log("File extension " .. extension .. " not supported", 1)
	end
end

------------------------------

function utils.downloadAndExtract(mods)
	utils.log("Downloading and extracting mods...", 1)

	for _, mod in pairs(mods) do
		utils.log("\thandling mod: " .. mod.name, 1)

		local result = {}
		if mod["fetcher"] == "github" then
			result = downloadFromGithub(mod.owner, mod.repo, mod.version, mod.filename)
		elseif mod["fetcher"] == "googleDrive" then
			result = downloadFromGoogleDrive(mod.googleDriveId, mod.filename)
		elseif mod.fetcher == "direct" then
			utils.log("direct fetcher not implemented yet.")
		end

		if result.success then
			utils.log("\tdownloaded, extracting...", 1)
			-- TODO: special handling for SVM
			local path = result.path .. "/" .. result.filename
			local extractResult = extract(path, Args.destination)
			if extractResult ~= nil then
				utils.log("\textracted mod " .. mod.name .. " successfully", 1)
			else
				local msg = string.format("\tfailed to extract mod %s, error=%s", mod.name, ToString(extractResult))
				utils.log(msg, 1)
			end
		else
			local msg = string.format(
				"\tfailed to download mod %s, exitType=%s, exitCode=%d",
				mod.name,
				result.commandResult.exitType,
				result.commandResult.exitCode
			)
			utils.log(msg, 1)
		end
	end

	utils.log("Done downloading and extracting mods...", 1)
end

-- function Utils.downloadAndExtract2(mods, destination, downloadDir)
-- 	for _, mod in pairs(mods) do
-- 		if mod["fetcher"] == "github" then
-- 			Utils.downloadFromGithub(mod.owner, mod.repo, mod.version, mod.filename, downloadDir)
-- 		elseif mod["fetcher"] == "googleDrive" then
-- 			Utils.downloadFromGoogleDrive(mod.googleDriveId, mod.filename, downloadDir)
-- 		elseif mod.fetcher == "direct" then
-- 			Log("implement me")
-- 		end
-- 	end
--
-- 	local lfs = require("lfs")
-- 	for file in lfs.dir(downloadDir) do
-- 		if file ~= "." and file ~= ".." then
-- 			local filePath = downloadDir .. "/" .. file
-- 			if Utils.getFileExtension(filePath) == ".zip" then
-- 				if string.match(file, "ServerValueModifier") then
-- 					local tmpDst = destination .. "/user/mods"
-- 					Utils.unzip(filePath, tmpDst)
-- 				else
-- 					Utils.unzip(filePath, destination)
-- 				end
-- 			elseif Utils.getFileExtension(filePath) == ".7z" then
-- 				Utils.un7zip(filePath, destination)
-- 			else
-- 				Log("File extension " .. Utils.getFileExtension(filePath) .. " not supported")
-- 			end
-- 		end
-- 	end
-- end

function utils.pathExists(path)
	return require("ml").exists(path)
end

function utils.loadModsFromPath(path)
	local lfs = require("lfs")
	local mods = {}

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." and utils.getFileExtension(file) == ".json" then
			local mod = utils.readJsonFile(path .. "/" .. file)
			utils.log("Loaded mod=" .. ToString(mod), 1)
			if mod ~= nil then
				table.insert(mods, mod)
			end
		end
	end

	return mods
end

function utils.readJsonFile(filePath)
	utils.log("Attempting to read json file=" .. ToString(filePath), 1)
	local dkjson = require("dkjson")
	local file = io.open(filePath, "r")
	if file == nil then
		return nil
	end
	local content = file:read("*all")
	file:close()
	local json = dkjson.decode(content)
	return json
end

function utils.getFileExtension(filePath)
	return filePath:match("^.+(%..+)$")
end

function utils.log(msg, verbosity)
	if verbosity == nil or verbosity == 0 then
		print("INFO: " .. msg)
		return
	end

	if Args.verbosity >= verbosity then
		print("VERBOSE: " .. msg)
	end
end

return utils
