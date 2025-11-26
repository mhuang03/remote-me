local shell = require("shell")
local filesystem = require("filesystem")
local computer = require("computer")

shell.setWorkingDirectory("/home/remote-me/")
print("Removing previous installation...")
shell.execute("rm -rf *")

print("Downloading _filelist.txt ...")
shell.execute("wget https://raw.githubusercontent.com/mhuang03/remote-me/main/oc/_filelist.txt")
for filename in io.lines("_filelist.txt") do
  print("Downloading " .. filename .. " ...")
  shell.execute("wget https://raw.githubusercontent.com/mhuang03/remote-me/main/oc/" .. filename)
end

print("Done!")