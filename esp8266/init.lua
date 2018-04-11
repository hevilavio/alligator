--[[
TODO:

- random device_id on mqtt connection (same device id receives a 'disconnection' event when it re-connect
- retry_attempt no mqtt connection (try 5x before giving up)


--]]



M = {}
local adc = require("adc_reader")
local dht = require("dht11")
local mqttcli = require("adafruit_io_mqtt")


local STARTUP_MAX_ATTEMPTS = 5


M.startup_attempts = 0
M.selftest_ok = false


function selftest()
    print("[SELFTEST] SCHEDULED")
    tmr.alarm(1,3000,tmr.ALARM_AUTO,function()
        print("[SELFTEST] START")

        a0_value = adc.read_A0_volt()
        print("[SELFTEST] ADC A0 VOLT = "..a0_value)
        
        temp, humi = dht.readdht11()
        print("[SELFTEST] DHT11 TEMP = "..temp..", humi = "..humi)

        mqtt_init_code = mqttcli.client_init_code
        
        print("[SELFTEST] MQTT INIT CODE = "..mqtt_init_code)
    
        M.selftest_ok = (a0_value > 0) and (temp > 0) and (humi > 0) and (mqtt_init_code == 0)

        print("[SELFTEST] FINISH, OK="..tostring(M.selftest_ok))

        if M.selftest_ok or M.startup_attempts > STARTUP_MAX_ATTEMPTS then
            print("unregistering self test alarm. attempts="..M.startup_attempts)
            tmr.unregister(1)
        end

        M.startup_attempts = M.startup_attempts+1
        
    end)
end

function main()

    print("[MAIN] SCHEDULED")
    tmr.alarm(2, 4000, tmr.ALARM_AUTO, function()
        print("[MAIN] Starting alligator")
        if M.selftest_ok ~= true then
            print("[MAIN] Delaying execution. self_test is not ok")
            
            if M.startup_attempts > STARTUP_MAX_ATTEMPTS then
                print("[MAIN] Aborting execution. Max. attempts reached. startup_attempts="..startup_attempts)
                tmr.unregister(2)
            end

            return
        end

        
        print("[MAIN] Ready to start code loop")

        --tmr code loop goes here
        tmr.alarm(3, (15 * 1000), tmr.ALARM_AUTO, function()
            print("[LOOP] Collecting values")

            a0_value = adc.read_A0_volt()
            temp, humi = dht.readdht11()

            mqttcli.pub("d721559/feeds/dht11-temp", temp)
            mqttcli.pub("d721559/feeds/dht11-hum", humi)
            mqttcli.pub("d721559/feeds/bat-volt", a0_value)
            
            print("[LOOP] End")
        end)
        --

        tmr.unregister(2)
    
    end)

end



print("[STARTUP] Scheduling processes")

mqttcli.init_client()


selftest()
main()





-- conectar na wifi
-- wifi.setmode(mode[, save]) -- save, default true (salva a config no flash)
--wifi.setmode(wifi.STATION)
--wifi.sta.config(SSID,SSID_PASSWORD)
--wifi.sta.autoconnect(1)

-- listar config de wifi salva no flash
--print(wifi.sta.getdefaultconfig())

