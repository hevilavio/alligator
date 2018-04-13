local M = {}

DHT11_PIN=6
TIMEOUT_ERR=-1
CHECKSUM_ERR=-20


function M.readdht11()
    status, temp, humi, temp_dec, humi_dec = dht.read11(DHT11_PIN)
    if status == dht.OK then
        -- Float firmware using this example
        print("[DHT] Temperature:"..temp..";".."Humidity:"..humi)
    
        return temp, humi
    elseif status == dht.ERROR_CHECKSUM then
        print( "[DHT] Checksum error." )
        return CHECKSUM_ERR, 0
    elseif status == dht.ERROR_TIMEOUT then
        print( "[DHT] timed out." )
        return TIMEOUT_ERR, 0
    end
end

return M

