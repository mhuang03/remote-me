local component = require("component")
local internet = require("internet")
local json = require("json")
local event = require("event")

local HOST = os.getenv("REMOTE_ME_HOST")
local PORT = 21504



local me
if component.isAvailable("me_controller") then
  me = component.me_controller
elseif component.isAvailable("me_interface") then
  me = component.me_interface
else
  error("No ME controller or interface found.")
  os.exit()
end



local function getItemsData()
  local items = me.getItemsInNetwork({label="Stone Dust"})
  local items_enc = {}
  for k, item in pairs(items) do
    table.insert(items_enc, json.encode(item))
  end
  return items_enc
end



local function sendUpdate(sock)
  local payload = getItemsData()[1]
  print("Sending payload: " .. payload)
  return sock:write(payload .. "\n")
end



local function connect()
  local sock, reason
  repeat
    sock, reason = internet.open(HOST, PORT)
    if reason then
      print("Failed to open TCP connection: " .. tostring(reason))
      print("Trying again in 5 seconds...")
      os.sleep(5)
    end
  until sock
  sock:setTimeout(0.05)
  print("Connected.")
  return sock
end


local thread = require("thread")
local t1 = thread.create(function()
  local sock = connect()
  while (true) do
    if sendUpdate(sock) == 0 or (not sock) then
      print("Connection lost. Reconnecting...")
      sock = connect()
    end
    os.sleep(1)
  end
end)

thread.waitForAll({t1})