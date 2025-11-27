local component = require("component")
local json = require("json")
local thread = require("thread")
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



local function getStoneDustData()
  local items = me.getItemsInNetwork({label="Stone Dust"})
  local items_enc = {}
  for k, item in pairs(items) do
    table.insert(items_enc, json.encode(item))
  end
  return items_enc
end



local function sendItemsData(sman)
  sman:sendData("100")  -- start of items data
  local itemsIter = me.allItems()
  for chunk in itemsIter do
    local chunk_enc = {}
    for _, item in pairs(items) do
      table.insert(chunk_enc, json.encode(item))
    end
    local jsonList = "[" .. table.concat(chunk_enc, ",") .. "]"
    sman:sendData("101" .. jsonList)
  end
  sman:sendData("111")  -- end of items data
end




local sm = SocketManager:new()

local t1 = thread.create(function()
  while (true) do
    sendItemsData(sm)
    os.sleep(1)
  end
end)

thread.waitForAll({t1})