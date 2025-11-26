local shell = require("shell")
local filesystem = require("filesystem")
local computer = require("computer")

shell.setWorkingDirectory("/home/remote-me/")
print("Removing previous installation...")
shell.execute("rm -rf *")

print("Downloading...")
shell.execute("wget https://raw.githubusercontent.com/mhuang03/remote-me/main/oc/_filelist.txt")
shell.execute("wget -i _filelist.txt")

shell.setWorkingDirectory("/home/")
print("Done!")