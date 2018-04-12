local M = {}


LED_PIN=4
TMRID_LED = 4
TMRID_CALLBACK = 5
MS_BETWEEN_PATTERN = 5000
DEFAULT_MS_LED_ON_NORMAL = 200
DEFAULT_MS_LED_ON_QUICK = 50


local lighton=0
local blink_count=0


gpio.mode(LED_PIN,gpio.OUTPUT)


local function register_blink_pattern(ms_blink, times_to_blink)
    blink_count=0
    tmr.alarm(TMRID_LED, ms_blink, tmr.ALARM_AUTO,function()
        if lighton==0 then
            lighton=1
            gpio.write(LED_PIN,gpio.LOW)
        else
            lighton=0
            gpio.write(LED_PIN,gpio.HIGH)
            blink_count = blink_count + 1
        end

    
        if blink_count >= times_to_blink then
            blink_times = 0
            gpio.write(LED_PIN,gpio.HIGH)

            -- stop the current pattern and schedule it to start again 
            print("max blink times reached. ms="..ms_blink..", times="..times_to_blink)
            tmr.unregister(TMRID_LED)

            -- [[
            tmr.alarm(TMRID_CALLBACK, MS_BETWEEN_PATTERN, tmr.ALARM_SINGLE, function()
                print("recheduling blinking. delay="..MS_BETWEEN_PATTERN..", ms="..ms_blink..", times="..times_to_blink)
                register_blink_pattern(ms_blink, times_to_blink)
            end)
            --]]
    
        end
    end)
end

function M.startup()
    stop_blink()
    register_blink_pattern(DEFAULT_MS_LED_ON_NORMAL, 200000)
end

function M.normal_operation()
    stop_blink()
    register_blink_pattern(DEFAULT_MS_LED_ON_QUICK, 2)
end

function M.blink_pattern(p)
    stop_blink()
    register_blink_pattern(DEFAULT_MS_LED_ON_NORMAL, p)
end

function M.blink_pattern_quick(p)
    stop_blink()
    register_blink_pattern(DEFAULT_MS_LED_ON_QUICK, p)
end

function stop_blink()
    tmr.unregister(TMRID_LED)
    tmr.unregister(TMRID_CALLBACK)
    
    gpio.write(LED_PIN,gpio.HIGH)
end

--blink_pattern_quick(1)
--startupBlink()

return M
