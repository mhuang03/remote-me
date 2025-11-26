local component = require("component")
local SocketManager = require("socketmanager")



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



local sm = SocketManager:new()

local thread = require("thread")
local t1 = thread.create(function()
  while (true) do
    local payload = getItemsData()[1]
    local status = sm:queueData(payload)
    os.sleep(1)
  end
end)

thread.waitForAll({t1})