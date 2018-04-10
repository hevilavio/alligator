dht11Pin=6
TIMEOUT_ERR=-10,-11
CHECKSUM_ERR=-20,-21


function readdht11()
    status, temp, humi, temp_dec, humi_dec = dht.read11(dht11Pin)
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

temp, humi = readdht11()
print("[DEBUG] DHT11 temp="..temp..", humi="..humi)

