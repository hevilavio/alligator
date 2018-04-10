-- test with cloudmqtt.com

require "adc_reader"
require "dht11"

function selftest()
    print("[SELFTEST] SCHEDULED")
    tmr.alarm(1,2000,tmr.ALARM_SINGLE,function()
        print("[SELFTEST] START")
        -- from adc_reader
        print("[SELFTEST] A0 VOLT = "..read_A0_volt())
        
        -- from dht11
        temp, humi = readdht11()
        print("[SELFTEST] DHT11 TEMP = "..temp..", humi = "..humi)
    
        print("[SELFTEST] FINISH")
    end)
end



selftest()

-- conectar na wifi
-- wifi.setmode(mode[, save]) -- save, default true (salva a config no flash)
--wifi.setmode(wifi.STATION)
--wifi.sta.config(SSID,SSID_PASSWORD)
--wifi.sta.autoconnect(1)

-- listar config de wifi salva no flash
--print(wifi.sta.getdefaultconfig())

