import util

try:
    import Adafruit_DHT
except ImportError as e:
    util.log_info('Error on optional imports: {}'.format(e))

SECONDS_TO_SLEEP = 60
SENSOR_PIN = 17
	
def get_sensor_info():
    try:
        return Adafruit_DHT.read_retry(Adafruit_DHT.DHT11, SENSOR_PIN)
    except Exception as e:
        util.log_info('Error while getting dht11 info. Error=[{}]'.format(str(e)))
        return (1, 2)