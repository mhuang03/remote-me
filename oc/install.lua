--[[
  wget https://raw.githubusercontent.com/mhuang03/remote-me/main/oc/install.lua -f /home/install.lua
  /home/install.lua
]]

local shell = require("shell")
local filesystem = require("filesystem")
local computer = require("computer")

if not filesystem.exists("/home/remote-me") then
  filesystem.makeDirectory("/home/remote-me")
  shell.setWorkingDirectory("/home/remote-me/")
else
  shell.setWorkingDirectory("/home/remote-me/")
  print("Removing previous installation...")
  shell.execute("rm -rf *")
end

print("Downloading...")
shell.execute("wget https://raw.githubusercontent.com/mhuang03/remote-me/main/oc/_filelist.txt")
shell.execute("wget -i _filelist.txt")

shell.setWorkingDirectory("/home/")
filesystem.remove("/home/install.lua")
print("Done!")