local component = require("component")
local json = require("json")
local event = require("event")
local internet = component.internet

local HOST = os.getenv("REMOTE_ME_HOST")
local PORT = 21504

if not HOST then
  error("REMOTE_ME_HOST environment variable must be set")
end



local SocketManager = {}

function SocketManager:connect()
  local socket, reason
  repeat
    socket, reason = internet.open(HOST, PORT)
    if reason then
      print("Failed to open TCP connection: " .. tostring(reason))
      print("Trying again in 5 seconds...")
      os.sleep(5)
    end
  until socket

  print("Connected to " .. HOST .. ":" .. PORT)
  self.sock = socket
end

function SocketManager:queueData(data)
  table.insert(self.queue, data)
end

function SocketManager:sendData(data)
  local status, err = pcall(self.sock.write, self.sock, data .. "\n")
  if not status then
    print("Connection lost. Reconnecting...")
    self.sock:close()
    self:connect()
    return false
  end
  return true
end

function SocketManager:processQueue()
  event.timer(0.1, function()
    if #self.queue > 0 then
      local payload = self.queue[1]
      print("Sending payload: " .. payload)
      local success = self:sendData(payload)
      if success then
        print("Sent successfully.")
        table.remove(self.queue, 1)
      else
        print("Sending failed.")
      end
    end
  end, math.huge)
end

function SocketManager:new()
  local o = {sock=nil, queue={}}
  setmetatable(o, self)
  self.__index = self
  o:connect()
  -- o:processQueue()
  return o
end
  


return SocketManager