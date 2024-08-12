local Utils = {}

---@alias SPTarkovMod
---| '"name"' # Name of the mod
---| '"filename"' # Name of the file to download
---| '"fetcher"' # Fetcher to use to download the file
---| '"owner"' # GitHub owner
---| '"repo"' # GitHub repo
---| '"version"' # Mod version
---| '"googleDriveId"' # Google Drive file ID

---Download a file from GitHub
---@param mod SPTarkovMod
---@param downloadDir any # Directory to download the file to
---@return boolean
local function downloadFromGithub(mod, downloadDir)
	LogIfVerbose("------ Downloading file " .. mod.filename .. " from GitHub to download dir=" .. downloadDir)
	-- local url = string.format("https://github.com/%s/%s/releases/download/%s/%s", owner, repo, version, filename)
	-- return Utils.doDownload(url, downloadDir, filename)
end

local function downloadFromGoogleDrive(file_id, filename, downloadDir)
	LogIfVerbose("------ Downloading file " .. filename .. " from Google Drive to download dir=" .. downloadDir)
	local url = string.format("https://docs.google.com/uc?export=download&id=%s", file_id)
	return Utils.doDownload(url, downloadDir, filename)
end

local function downloadDirect(url, destination) end

local function unzip(filename, destination)
	LogIfVerbose("------ Unzipping file " .. filename .. " to destination=" .. destination)
	local unzip_command = string.format("unzip -o %s -d %s", filename, destination)
	return Utils.executeCommand(unzip_command)
end

local function un7zip(filename, destination)
	LogIfVerbose("------ Un7zipping file " .. filename .. " to destination=" .. destination)
	local un7zip_command = string.format("7z x -o%s %s", destination, filename)
	return Utils.executeCommand(un7zip_command)
end

local function doDownload(url, downloadDir, filename)
	local download_command = string.format('wget -O %s/%s "%s"', downloadDir, filename, url)
	return Utils.executeCommand(download_command)
end

function Utils.downloadAndExtract(mods, extractDir, downloadDir)
	LogIfVerbose("Downloading and extracting mods...")

	for _, mod in pairs(mods) do
		LogIfVerbose("\tHandling mod: " .. mod.name)

		local downloaded = true
		if mod["fetcher"] == "github" then
			downloaded = downloadFromGithub(mod, downloadDir)
		elseif mod["fetcher"] == "googleDrive" then
			-- downloaded = Utils.downloadFromGoogleDrive(mod.googleDriveId, mod.filename, downloadDir)
		elseif mod.fetcher == "direct" then
			print("implement me")
		end

		test()

		if downloaded then
			LogIfVerbose("\tDownloaded " .. mod.name .. " successfully, extracting to " .. extractDir)
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

function Utils.executeCommand(command)
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

return Utils
