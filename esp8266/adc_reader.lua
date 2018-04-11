local M = {}

local r1=10 * 1000
local r2=2.3 * 1000

-- There is an Voltage Divider attached to A0
function M.read_A0_volt()
    print("[ADC] starting ADC read")
    
    value=adc.read(0)
    vOut = value/1000
    vIn = (vOut/(r2/(r1+r2)))
    
    print("[ADC] value ADC/1000="..vOut)
    print("[ADC] vIn="..vIn)
    return vIn
end

return M
--print("[DEBUG] A0 voltage = "..read_A0_volt())