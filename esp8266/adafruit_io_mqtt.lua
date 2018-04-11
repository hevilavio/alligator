local M = {}

local MQTT_USER = "d721559"
local MQTT_PWD = "4ccea9ff41cc40b78da93a794ec5e4cc"
local DEVICE_ID = "nodemcu-aligattor"
local KEEP_ALIVE_SECONDS = 60
local MQTT_HOST = "io.adafruit.com"
local MQTT_PORT = 1883
local TOPIC_BASE = "d721559"

local TOPIC_TEMP = TOPIC_BASE.."/feeds/dht11-temp"


local INIT_CODE_CONNECTED = 0
local INIT_CODE_DISCONNECTED = 1
local INIT_CODE_NOT_INITIALIZED = 1


M.client_init_code = INIT_CODE_NOT_INITIALIZED


--[[
    Function to dispatch messages received from the broker

    To be able to receive messsages, you must:
        1. Subscribe throgh (ex: 'client:subscribe')
        2. Set one fuction to handle the messages (ex: dispatch_topics[TOPIC_TEMP]=tempCallback)
--]]
client = nil
local dispatch_topics={}

local function dispatch(m, t, pl)
    if pl~=nil and dispatch_topics[t] then
        dispatch_topics[t](m, pl)
    end
end

function tempCallback(m,pl)
    print("tempCallback, received value from topic: "..pl)
end
dispatch_topics[TOPIC_TEMP]=tempCallback


function handle_mqtt_error(client, reason) 
  print("handle_mqtt_error. Not connected! error_code="..reason)
end


function M.init_client()
    client=mqtt.Client(DEVICE_ID, KEEP_ALIVE_SECONDS, MQTT_USER, MQTT_PWD)
    client:on("connect",function(m) 
        print("on_connect call. heap="..node.heap()) 
    --[[
        client:subscribe(TOPIC_TEMP, 0, function(m) 
            print("Subscribed to "..TOPIC_TEMP.." with success") 
        end)
    --]]
    end)
    client:on("offline", function(conn)
        --print("disconnected from broker...")
        --M.client_init_code = INIT_CODE_DISCONNECTED
    end)
    client:on("message", dispatch)

    client:connect(MQTT_HOST, MQTT_PORT, 0, 0, function(client) 
        M.client_init_code = INIT_CODE_CONNECTED
        print("connected to mqtt broker") 
    end, 
    handle_mqtt_error)
end

---------------------------------
---- PUBLIC FUNCTIONS -----------
---------------------------------
function M.pub(topic, val)
    if M.client_init_code ~= INIT_CODE_CONNECTED then
        print("client not initialized properly, call init_client(). code="..tostring(M.client_init_code))
        return false 
    end

    print("publishing ["..val.."] to ["..topic.."]")
    ret = client:publish(topic, val, 0, 0)
    print("publish success="..tostring(ret))
    return ret
end


-- IMPROVMENT
-- Method init_client should wait for connection established. So, it can be called from outside
-- modules
--M.init_client()

--[[
tmr.alarm(1, 3000, tmr.ALARM_SINGLE, function()
    M.pub(TOPIC_TEMP, 10)
end)
--]]

return M