local M = {}


local C = require("constants")

LED_PIN=4
MS_BETWEEN_PATTERN = 5000
DEFAULT_MS_LED_ON_NORMAL = 200
DEFAULT_MS_LED_ON_ERROR = 500
DEFAULT_MS_LED_ON_QUICK = 50


local lighton=0
local blink_count=0

gpio.mode(LED_PIN,gpio.OUTPUT)


local function register_blink_pattern(ms_led_on, times_to_blink)
    blink_count=0
    tmr.alarm(C.TMRID_LED, ms_led_on, tmr.ALARM_AUTO, function()
        if lighton==0 then
            -- turn ON
            lighton=1
            gpio.write(LED_PIN,gpio.LOW)
        else
            -- turn OFF
            lighton=0
            gpio.write(LED_PIN,gpio.HIGH)
            blink_count = blink_count + 1
        end

    
        if blink_count >= times_to_blink then
            blink_times = 0
            gpio.write(LED_PIN,gpio.HIGH)

            -- stop the current pattern and schedule it to start again 
            --print("[LED_HELPER] max blink times reached. ms_led_on="..ms_led_on..", times="..times_to_blink)
            tmr.unregister(C.TMRID_LED)

            -- [[
            tmr.alarm(C.TMRID_CALLBACK, MS_BETWEEN_PATTERN, tmr.ALARM_SINGLE, function()
                --print("[LED_HELPER] recheduling blinking. ms_led_on="..ms_led_on..", times="..times_to_blink)
                register_blink_pattern(ms_led_on, times_to_blink)
            end)
            --]]
    
        end
    end)
end


function stop_blink()
    tmr.unregister(C.TMRID_LED)
    tmr.unregister(C.TMRID_CALLBACK)
    
    gpio.write(LED_PIN,gpio.HIGH)
end

function M.startup()
    stop_blink()
    register_blink_pattern(DEFAULT_MS_LED_ON_NORMAL, 200000)
end

function M.normal_operation()
    stop_blink()
    register_blink_pattern(DEFAULT_MS_LED_ON_QUICK, 1)
end


function M.error_code(code)
    stop_blink()
    register_blink_pattern(DEFAULT_MS_LED_ON_ERROR, code)
end

function M.blink_pattern_quick(p)
    stop_blink()
    register_blink_pattern(DEFAULT_MS_LED_ON_QUICK, p)
end


--blink_pattern_quick(1)
--startupBlink()

return M
