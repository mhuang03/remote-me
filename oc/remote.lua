local internet = require("internet")
local json = require("json")
local event = require("event")

local HOST = os.getenv("REMOTE_ME_HOST")
local PORT = 21504



local SocketManager = {}

function SocketManager:new()
  local o = {sock=nil, queue={}}
  setmetatable(o, self)
  self.__index = self
  o:processQueue()
  return o
end

function SocketManager:connect()
  local socket, reason
  repeat
    socket, reason = internet.connect(HOST, PORT)
    if reason then
      print("Failed to open TCP connection: " .. tostring(reason))
      print("Trying again in 5 seconds...")
      os.sleep(5)
    end
  until socket
  print("Connected.")
  self.sock = socket
end

function SocketManager:queueData(data)
  table.insert(self.queue, data)
end

function SocketManager:sendData(data)
  if not self.sock.finishConnect() then
    self.connect()
  end

  local bytesWritten = sock:write(data .. "\n")
  if bytesWritten == 0 then
    print("Connection lost during write.")
    sock:close()
    self.sock = nil
    return false
  end
  return true
end

function SocketManager:processQueue()
  event.timer(0.1, function()
    if #self.queue > 0 then
      local payload = queue[1]
      local success = self:sendData(payload)
      if success then
        table.remove(self.queue, 1)
      end
    end
  end, math.huge)
end
  

return {SocketManager=SocketManager}