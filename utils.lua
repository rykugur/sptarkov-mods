local Utils = {}

function Utils.downloadAndExtract(mods, destination, downloadDir)
	for _, mod in pairs(mods) do
		if mod["fetcher"] == "github" then
			Utils.downloadFromGithub(mod.owner, mod.repo, mod.version, mod.filename, downloadDir)
		elseif mod["fetcher"] == "googleDrive" then
			Utils.downloadFromGoogleDrive(mod.googleDriveId, mod.filename or mod.name, downloadDir)
		elseif mod.fetcher == "direct" then
			print("implement me")
			-- local url = mod.url
			-- local filename = mod.filename
			-- local download_command = string.format("curl -L %s -o %s/%s", url, destination, filename)
			-- os.execute(download_command)
		end
	end

	local lfs = require("lfs")
	for file in lfs.dir(downloadDir) do
		if file ~= "." and file ~= ".." then
			local filePath = downloadDir .. "/" .. file
			if Utils.getFileExtension(filePath) == ".zip" then
				Utils.unzip(filePath, destination)
			elseif Utils.getFileExtension(filePath) == ".7z" then
				Utils.un7zip(filePath, destination)
			else
				print("File extension " .. Utils.getFileExtension(filePath) .. " not supported")
			end
		end
	end
end

function Utils.downloadFromGithub(owner, repo, version, filename, downloadDir)
	MaybeLogVerbose("Downloading file " .. filename .. " from GitHub to download dir=" .. downloadDir)
	local url = string.format("https://github.com/%s/%s/releases/download/%s/%s", owner, repo, version, filename)
	Utils.doDownload(url, downloadDir, filename)
end

function Utils.downloadFromGoogleDrive(file_id, filename, downloadDir)
	MaybeLogVerbose("Downloading file " .. filename .. " from Google Drive to download dir=" .. downloadDir)
	local url = string.format("https://docs.google.com/uc?export=download&id=%s", file_id)
	Utils.doDownload(url, downloadDir, filename)
end

function Utils.downloadDirect(url, destination) end

function Utils.unzip(filename, destination)
	MaybeLogVerbose("Unzipping file " .. filename .. " to destination=" .. destination)
	local unzip_command = string.format("unzip -o %s -d %s > /dev/null 2>&1", filename, destination)
	os.execute(unzip_command)
end

function Utils.un7zip(filename, destination)
	MaybeLogVerbose("Un7zipping file " .. filename .. " to destination=" .. destination)
	local un7zip_command = string.format("7z x -o%s %s > /dev/null 2>&1", destination, filename)
	os.execute(un7zip_command)
end

function Utils.doDownload(url, downloadDir, filename)
	local download_command = string.format("wget -O %s/%s %s > /dev/null 2>&1", downloadDir, filename, url)
	os.execute(download_command)
end

function Utils.pathExists(path)
	return require("ml").exists(path)
end

function Utils.loadModsFromPath(path)
	local lfs = require("lfs")
	local mods = {}

	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." and Utils.getFileExtension(file) == ".json" then
			local mod = Utils.readJsonFile(path .. "/" .. file)
			MaybeLogVerbose("Loaded mod=" .. ToString(mod))
			if mod ~= nil then
				table.insert(mods, mod)
			end
		end
	end

	return mods
end

function Utils.readJsonFile(filePath)
	MaybeLogVerbose("Attempting to read json file=" .. ToString(filePath))
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
