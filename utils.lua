local M = {}

---@class CommandResult
---@field success? boolean
---@field exitType? string
---@field exitCode? integer

---Excutes a command in the shell
---@param command any
---@return CommandResult
local function executeCommand(command)
	local shell = os.getenv("SHELL")
	local redirect = ""

	if shell ~= nil and shell:find("fish") then
		-- fish shell redirection
		redirect = " &> /dev/null"
	else
		-- bash/zsh shell redirection
		redirect = " 2>&1 /dev/null"
	end

	if Args.verbosity >= 2 then
		redirect = ""
	end

	Log("Executing command=" .. command .. redirect, 1)
	local success, exitType, exitCode = os.execute(command .. redirect)

	if not success then
		if exitType == "exit" then
			Log("Command exited with status: " .. exitCode, 1)
		elseif exitType == "signal" then
			Log("Command was killed by signal: " .. exitCode, 1)
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
	Log("\tUnzipping file " .. filename .. " to destination=" .. Args.destination, 1)
	local unzip_command = string.format("unzip -o %s -d %s", filename, Args.destination)
	return executeCommand(unzip_command)
end

local function un7zip(filename, destination)
	Log("\tUn7zipping file " .. filename .. " to destination=" .. destination, 1)
	local un7zip_command = string.format("7z x -o%s %s", destination, filename)
	return executeCommand(un7zip_command)
end

local function extract(filename, destination)
	local extension = M.getFileExtension(filename)

	if extension == ".zip" then
		return unzip(filename)
	elseif extension == ".7z" then
		return un7zip(filename, destination)
	else
		Log("File extension " .. extension .. " not supported", 1)
	end
end

------------------------------

function M.downloadAndExtract(mods)
	Log("Downloading and extracting mods...")

	for _, mod in pairs(mods) do
		Log("\thandling mod: " .. mod.name)

		local result = {}
		if mod["fetcher"] == "github" then
			result = downloadFromGithub(mod.owner, mod.repo, mod.version, mod.filename)
		elseif mod["fetcher"] == "googleDrive" then
			result = downloadFromGoogleDrive(mod.googleDriveId, mod.filename)
		elseif mod.fetcher == "direct" then
			Log("direct fetcher not implemented yet.")
		end

		if result.success then
			Log("\tdownloaded archive, extracting")
			-- TODO: special handling for SVM, TGC, SPT-Realism
			local path = result.path .. "/" .. result.filename
			local extractResult = extract(path, Args.destination)
			if extractResult ~= nil then
				Log("\textracted mod")
			else
				local msg = string.format("\tfailed to extract mod, error=%s", ToString(extractResult))
				Log(msg, 1)
			end
		else
			local msg = "\tfailed to download mod"
			if Args.verbosity > 1 then
				msg = msg
					.. string.format(
						", exitType=%s, exitCode=%d",
						result.commandResult.exitType,
						result.commandResult.exitCode
					)
			end
			Log(msg)
		end

		Log("---")
	end

	Log("Done downloading and extracting mods...", 1)
end

function M.pathExists(path)
	return require("ml").exists(path)
end

function M.loadModsFromPath(path)
	local lfs = require("lfs")
	local mods = {}

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." and M.getFileExtension(file) == ".json" then
			local mod = M.readJsonFile(path .. "/" .. file)
			Log("Loaded mod=" .. ToString(mod), 1)
			if mod ~= nil then
				table.insert(mods, mod)
			end
		end
	end

	return mods
end

function M.readJsonFile(filePath)
	Log("Attempting to read json file=" .. ToString(filePath), 1)
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

function M.getFileExtension(filePath)
	return filePath:match("^.+(%..+)$")
end

function Log(msg, verbosity)
	if verbosity == nil or verbosity == 0 then
		print("INFO: " .. msg)
		return
	end

	if Args.verbosity >= verbosity then
		print("VERBOSE: " .. msg)
	end
end

return M
