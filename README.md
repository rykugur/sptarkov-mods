# SPTarkov Mod Manager

## Description

A dead-simple mod-manager for SPTarkov. It simply downloads your enabled mod archives
and extracts them to a specified destination directory. **NOTE**: defaults to `./tmp`
if not specified.

No attempts will be made to track files, ensure output, or anything. I made this
for myself for my own uses, because I was tired of keeping 20+ tabs around and
manually refreshing/download/extracting when updates happened. Instead, I thought
it would be a decent enough idea to just track them in json, update a few values
as needed, and profit.

I am always open to constructive feedback, and PR's are welcome. Lua was chosen
because it's something I've been wanting to learn.

This was written on Linux, for Linux, however if there's enough interest I'm open
to some tweaks to get it working on Windows. (Windows sux btw)

## Requirements

- Lua 5.2+
- `luarocks`
- `jq`
- `curl`
- `wget`

## Installation

```shell
git clone https://github.com/rykugur/sptarkov-mods
luarocks install --tree ./.lua_modules luafilesystem dkjson argparse microlight
```

## Usage

```shell
cd sptarkov-mods
lua main.lua --help
```

In most cases, a simple:

```shell
lua main.lua
```

will download and extract all archives to `./tmp` and will extract all mods to `./dest`.
At this point, `./dest` should look like the structure below:

```shell
tree -L 1 dest
dest
├── BepInEx
└── user
```

From here, you can just copy/paste the contents of `./tmp` to your SPTarkov
directory.

If you want the mods to be extracted directly to your SPTarkov directory, you
can specify the destination directory with the `-d/--destination` option. Example:

```shell
lua main.lua --destination ~/Games/escape-from-tarkov/escape-from-tarkov/drive_c/SPTarkov
```

However, if you choose this method you won't have the middle step of checking and
verifying the output files/structure.

### CLI Options

## Adding your own mods

You can add your own mods defined as JSON. Simply create a directory with any
number of JSON files and on the command line call the script with the path
`-j/--json` option. Example:

```shell
lua main.lua [-j/--json] /path/to/your/custom/mods
```

Use the supplied JSON schema in `./schema/mod-schema.json` for autocompletion
and to ensure your JSON is valid. Use any mod in the `./mods` directory as an
example to get started.

**NOTE**: You can also just add your JSON files to the `mods` directory in this repo
and they'll be picked up automatically.

### Mod properties

- `name`: Name of the mod (generally will match the name on Filebase)
- `url`: URL to the mod on SPTarkov filebase
- `fetcher`: The fetcher to use to download the mod archive
- `owner`: Specific to github fetcher; the owner of the mod (the
  github owner/author)
- `repo`: Specific to github fetcher; the repo of the mod (generally
  theauthor's github)
`version`: The version of the mod
`filename`: The filename of the mod archive to download*
`googleDriveId`: Specific to the googleDrive fetcher; the file ID of the
  mod archive on Google Drive
- `dependencies`: An array of dependencies for the mod (currently not
  implemented / WIP)

\* because there is no standard when it comes to SPTarkov mod naming, and
even in some cases what the archive structure looks like, this is
necessary.

### Gotchas

- Until I get around to adding file tracking, you'll want to manually delete
  downloaded files; if not, you may end up installing multiple different
  versions of the same mod.

## TODO

- UI? Zenity or something better?
- Add file tracking?
- Mods that need special handling: SVM, SPT-Realism, Tactical Gear Component
