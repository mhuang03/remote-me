local internet = require("internet")
local json = require("json")
local event = require("event")

local HOST = os.getenv("REMOTE_ME_HOST")
local PORT = 21504



local function createSocketManager()
  local SocketManager = {}
  local sock = nil

  local queue = {}
  
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
    sock = socket
  end

  function SocketManager:queueData(data)
    table.insert(queue, data)
  end
  
  function SocketManager:sendData(data)
    if not sock.finishConnect() then
      self.connect()
    end

    local bytesWritten = sock:write(data .. "\n")
    if bytesWritten == 0 then
      print("Connection lost during write.")
      sock:close()
      sock = nil
      return false
    end
    return true
  end

  event.timer(0.1, function()
    if #queue > 0 then
      local payload = queue[1]
      local success = self:sendData(payload)
      if success then
        table.remove(queue, 1)
      end
    end
  end, math.huge)
  
  return SocketManager
end

return {createSocketManager = createSocketManager}