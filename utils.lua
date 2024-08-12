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

---Download a file from GitHub
---@param mod SPTarkovMod
---@return boolean
local function downloadFromGithub(mod)
	LogIfVerbose("------ Downloading file " .. mod.filename .. " from GitHub to download dir=" .. Args.downloaddir)
	-- local url = string.format("https://github.com/%s/%s/releases/download/%s/%s", owner, repo, version, filename)
	-- return Utils.doDownload(url, downloadDir, filename)
end

local function downloadFromGoogleDrive(file_id, filename)
	LogIfVerbose("------ Downloading file " .. filename .. " from Google Drive to download dir=" .. Args.downloaddir)
	-- local url = string.format("https://docs.google.com/uc?export=download&id=%s", file_id)
	-- return Utils.doDownload(url, downloadDir, filename)
end

local function downloadDirect(url, destination) end

local function unzip(filename)
	LogIfVerbose("------ Unzipping file " .. filename .. " to destination=" .. Args.destination)
	local unzip_command = string.format("unzip -o %s -d %s", filename, Args.destination)
	-- return Utils.executeCommand(unzip_command)
end

local function un7zip(filename, destination)
	LogIfVerbose("------ Un7zipping file " .. filename .. " to destination=" .. destination)
	local un7zip_command = string.format("7z x -o%s %s", destination, filename)
	-- return Utils.executeCommand(un7zip_command)
end

local function doDownload(url, downloadDir, filename)
	local download_command = string.format('wget -O %s/%s "%s"', downloadDir, filename, url)
	-- return Utils.executeCommand(download_command)
end

local function executeCommand(command)
	LogIfVerbose("Executing command=" .. command)
	local success, exitType, exitCode = os.execute(command)

	if not success then
		if exitType == "exit" then
			LogIfVerbose("Command exited with status: " .. exitCode)
		elseif exitType == "signal" then
			LogIfVerbose("Command was killed by signal: " .. exitCode)
		end
	end

	return success
end

------------------------------

local Utils = {}

function Utils.downloadAndExtract(mods)
	LogIfVerbose("Downloading and extracting mods...")

	for _, mod in pairs(mods) do
		LogIfVerbose("\tHandling mod: " .. mod.name)

		local downloaded = true
		if mod["fetcher"] == "github" then
			downloaded = downloadFromGithub(mod)
		elseif mod["fetcher"] == "googleDrive" then
			-- downloaded = Utils.downloadFromGoogleDrive(mod.googleDriveId, mod.filename, downloadDir)
		elseif mod.fetcher == "direct" then
			print("implement me")
		end

		if downloaded then
			LogIfVerbose("\tDownloaded " .. mod.name .. " successfully, extracting to " .. Args.destination)
		end
	end

	LogIfVerbose("Done downloading and extracting mods...")
end

-- function Utils.downloadAndExtract2(mods, destination, downloadDir)
-- 	for _, mod in pairs(mods) do
-- 		if mod["fetcher"] == "github" then
-- 			Utils.downloadFromGithub(mod.owner, mod.repo, mod.version, mod.filename, downloadDir)
-- 		elseif mod["fetcher"] == "googleDrive" then
-- 			Utils.downloadFromGoogleDrive(mod.googleDriveId, mod.filename, downloadDir)
-- 		elseif mod.fetcher == "direct" then
-- 			print("implement me")
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
-- 				print("File extension " .. Utils.getFileExtension(filePath) .. " not supported")
-- 			end
-- 		end
-- 	end
-- end

function Utils.pathExists(path)
	return require("ml").exists(path)
end

function Utils.loadModsFromPath(path)
	local lfs = require("lfs")
	local mods = {}

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." and Utils.getFileExtension(file) == ".json" then
			local mod = Utils.readJsonFile(path .. "/" .. file)
			LogIfVerbose("Loaded mod=" .. ToString(mod))
			if mod ~= nil then
				table.insert(mods, mod)
			end
		end
	end

	return mods
end

function Utils.readJsonFile(filePath)
	LogIfVerbose("Attempting to read json file=" .. ToString(filePath))
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

function Utils.getFileExtension(filePath)
	return filePath:match("^.+(%..+)$")
end

return Utils
