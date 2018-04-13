--[[
TODO:

- random device_id on mqtt connection (same device id receives a 'disconnection' event when it re-connect
- logging to flash memory
- led error code

--]]

local adc = require("adc_reader")
local dht = require("dht11")
local mqttcli = require("mqtt_connector")
local ledhelper = require("led_helper")
local C = require("constants")
 
local triggered_low_voltage_alarm = 0
local startup_attempts = 0
local selftest_ok = false


function selftest()
    print("[SELFTEST] SCHEDULED")
    
    tmr.alarm(C.TMRID_SELFTEST_FUNCTION, C.SELFTEST_SCHEDULE_INTERVAL_MS, tmr.ALARM_AUTO, function()
        print("[SELFTEST] START")

        a0_value = adc.read_A0_volt()
        print("[SELFTEST] ADC A0 VOLT = "..a0_value)
        
        temp, humi = dht.readdht11()
        print("[SELFTEST] DHT11 TEMP = "..temp..", humi = "..humi)

        mqtt_init_code = mqttcli.client_init_code
        print("[SELFTEST] MQTT INIT CODE = "..mqtt_init_code)
    
        selftest_ok = (a0_value > 1) and (temp > 0) and (humi > 0) and (mqtt_init_code == 0)
        print("[SELFTEST] FINISH, OK="..tostring(selftest_ok))

        if selftest_ok or startup_attempts >= C.MAX_STARTUP_ATTEMPTS then
            print("unregistering self test alarm. attempts="..startup_attempts..", selftest_ok="..tostring(selftest_ok))
            tmr.unregister(C.TMRID_SELFTEST_FUNCTION)
        end

        startup_attempts = startup_attempts+1
    end)
end

--[[
    Verify if the battery voltage is enough to keep running. Case its not, set the ESP fall into deep sleep mode
--]]
function verify_battery_voltage(v)
    print("[VOLT] verify_battery_voltage, current is "..v.."V, threshold is "..C.BAT_LOW_VOLT_LIMIT.."V")

    if v < C.BAT_LOW_VOLT_LIMIT then
        print("[VOLT] Voltage is too low. Scheduling sleep mode for "..C.LOW_VOLTAGE_SLEEP_SEC.."s")

        
        print("[VOLT] Setting ON the low voltage alarm")
        mqttcli.pub("d721559/feeds/low-voltage-alarm", "ON")

        triggered_low_voltage_alarm = 1
        ledhelper.blink_pattern_quick(200)
        
        tmr.alarm(C.TMRID_SLEEP_LOW_VOLTAGE, C.GACEFULLY_WAIT_BEFORE_SLEEP_MS, tmr.ALARM_SINGLE, function()
            -- dsleep receives parameter in nanoseconds
            node.dsleep(C.LOW_VOLTAGE_SLEEP_SEC * 1000 * 1000)
        end)
        
    elseif triggered_low_voltage_alarm == 0 then
        triggered_low_voltage_alarm = 1
        print("[VOLT] Setting OFF the low voltage alarm")
        
        mqttcli.pub("d721559/feeds/low-voltage-alarm", "OFF")
    end
end

function main()

    print("[MAIN] SCHEDULED")
    tmr.alarm(C.TMRID_MAIN_FUNCTION, C.MAIN_SCHEDULE_INTERVAL_MS, tmr.ALARM_AUTO, function()
        print("[MAIN] Starting main function")
        
        if selftest_ok ~= true then
            print("[MAIN] Delaying execution. self_test is not ok")
            
            if startup_attempts >= C.MAX_STARTUP_ATTEMPTS then
                print("[MAIN] Aborting execution. Max. startup attempts reached. startup_attempts="..startup_attempts)
                tmr.unregister(C.TMRID_MAIN_FUNCTION)
                ledhelper.error_code(C.BLINK_CODE_ABORTING_EXEC)
            end
            return
        end


        verify_battery_voltage(adc.read_A0_volt())

        print("[MAIN] Scheduling program lopp in interval="..C.PROGRAM_LOOP_SCHEDULE_INTERVAL_MS.."ms")
        
        ledhelper.normal_operation()
        
        -- Call program_loop() directly (first time) and then delegate the subsequent calls to tmr.alarm(...)
        program_loop()
        tmr.alarm(C.TMRID_PROGRAM_LOOP, C.PROGRAM_LOOP_SCHEDULE_INTERVAL_MS, tmr.ALARM_AUTO, function()
            program_loop()
        end)

        print("[MAIN] Unregistering main loop")
        tmr.unregister(C.TMRID_MAIN_FUNCTION)
    end)
end

function program_loop()
    print("[PROGRAM_LOOP] Collecting snesor values")

    a0_value = adc.read_A0_volt()
    temp, humi = dht.readdht11()

    print("[PROGRAM_LOOP] Publishing to MQTT broker")
    mqttcli.pub("d721559/feeds/dht11-temp", temp)
    mqttcli.pub("d721559/feeds/dht11-hum", humi)
    mqttcli.pub("d721559/feeds/bat-volt", a0_value)
    
    verify_battery_voltage(a0_value)
    
    print("[PROGRAM_LOOP] End")
end


print("[STARTUP] Scheduling processes")

-- [[
mqttcli.init_client()
ledhelper.startup()
selftest()
main()

-- conectar na wifi
-- wifi.setmode(mode[, save]) -- save, default true (salva a config no flash)
--wifi.setmode(wifi.STATION)
--wifi.sta.config(SSID,SSID_PASSWORD)
--wifi.sta.autoconnect(1)

-- listar config de wifi salva no flash
--print(wifi.sta.getdefaultconfig())
--]]

