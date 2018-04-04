import time
import util
import dht11
import mqtt_publisher as mqtt

FEED_TEMPERATURE = 'dht11_temp'
FEED_HUMIDITY = 'dht11_hum'
SECONDS_TO_SLEEP = 60


util.log_info('Starting Alligator!')
client = mqtt.init_client()

while True:
	humidity, temperature = dht11.get_sensor_info()

	mqtt.publish(client, FEED_HUMIDITY, humidity)
	mqtt.publish(client, FEED_TEMPERATURE, temperature)

	util.log_info('sleeping for {} seconds from now...'.format(SECONDS_TO_SLEEP))
	time.sleep(SECONDS_TO_SLEEP)

