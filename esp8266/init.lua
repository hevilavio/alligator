-- test with cloudmqtt.com


-- conectar na wifi
-- wifi.setmode(mode[, save]) -- save, default true (salva a config no flash)
--wifi.setmode(wifi.STATION)
--wifi.sta.config(SSID,SSID_PASSWORD)
--wifi.sta.autoconnect(1)

-- listar config de wifi salva no flash
--print(wifi.sta.getdefaultconfig())

m_dis={}
function dispatch(m,t,pl)
    if pl~=nil and m_dis[t] then
        m_dis[t](m,pl)
    end
end
function topic1func(m,pl)
    print("received value from topic: "..pl)
end

topic="d721559/feeds/dht11-temp"

m_dis[topic]=topic1func

-- Lua: mqtt.Client(clientid, keepalive, user, pass)
m=mqtt.Client("nodemcu2",60,"d721559","4ccea9ff41cc40b78da93a794ec5e4cc")

m:on("connect",function(m) 
    print("connection "..node.heap()) 
    m:subscribe(topic,0,function(m) print("received value from topic: ") end)
--    m:publish("d721559/feeds/dht11-temp",5,0,0) m:publish("/topic2","world",0,0)
    end )
m:on("offline", function(conn)
    print("disconnect to broker...")
    print(node.heap())
end)
m:on("message",dispatch )
-- Lua: mqtt:connect( host, port, secure, auto_reconnect, function(client) )
m:connect("io.adafruit.com",1883,0,0)
tmr.alarm(0,10000,1,function() local pl = tmr.time() 
    m:publish(topic,pl,0,0)
    end)