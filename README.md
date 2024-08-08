# SPTarkov Mod Manager

## Description

A dead-simple mod-manager for SPTarkov. It simply downloads your enabled mod archives
and extracts them to a specified destination directory. **NOTE**: Defaults to the
default SPTarkov Linux (lutris/MadByte installer) directory.

No attempts will be made to track files, ensure output, or anything. I made this
for myself for my own uses, but am always open to constructive feedback, and
and PR's are welcome. Lua was chosen because it's something I've been wanting to
learn.

This was written on Linux, for Linux, however if there's enough interest I'm open
to some tweaks to get it working on Windows. (Windows sux btw)

It's recommended to set your destination directory to a temporary directory as a
dry-run and ensure the output looks like what you might expect. In most cases,
one might expect to see a directory with the following structure after extracting
multiple mod archives:

```shell
.
├── BepInEx
└── user
```

From there, you can either copy the contents of this temporary dir to your
SPTarkov dir, or you can run the manager again and pass your actual SPTarkov
directory as the destination directory.

## Requirements

- Lua 5.2+
- Luarocks

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

### CLI Options

## Adding your own mods

You can add your own mods defined as JSON. Simply create a directory with any
number of JSON files and on the command line call the script with the path
`-j/--json` option. Example:

```shell
lua main.lua [-j/--json] /path/to/your/custom/mods
```

Use the supplied JSON schema in `./schema/mod-schema.json` for autocompletion
and to ensure your JSON is valid. Example:

```json
{
  "$schema": "../schemas/mod-schema.json",
  "name": "...",
  ...
}
```

**NOTE**: You can also just add your JSON files to the `mods` directory in this repo.

### Mod properties

- `name`: Name of the mod
- `url`: URL to the mod on SPTarkov filebase
- `type`: The 

## TODO

- UI? Zenity or something better?
