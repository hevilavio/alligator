import util
import time
from Adafruit_IO import MQTTClient

# See https://io.adafruit.com, https://accounts.adafruit.com
ADAFRUIT_IO_USERNAME = 'd721559'
ADAFRUIT_IO_KEY      = '?'

def connected(client):
    # Connected function will be called when the client is connected to Adafruit IO.
    # This is a good place to subscribe to feed changes.  The client parameter
    # passed to this function is the Adafruit IO MQTT client so you can make
    # calls against it easily.
    util.log_info('Connected to Adafruit IO!')
    #client.subscribe('dht11_temp')


def disconnected(client):
    # Disconnected function will be called when the client disconnects.
    util.log_info('Disconnected from Adafruit IO!')
    sys.exit(1)

def message(client, feed_id, payload):
    # Message function will be called when a subscribed feed has a new value.
    # The feed_id parameter identifies the feed, and the payload parameter has
    # the new value.
    util.log_info('Feed {0} received new value: {1}'.format(feed_id, payload))

def init_client():
	util.log_info('connecting to adafruit.io. username={}'.format(ADAFRUIT_IO_USERNAME))
	client = MQTTClient(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

    # Setup the callback functions defined above.
	client.on_connect = connected
	client.on_disconnect = disconnected
	client.on_message = message

	client.connect()
	client.loop_background()

	return client

def publish(mqtt_client, feed, message):
	
	util.log_info('publishing message {} to feed {}'.format(message, feed))
	mqtt_client.publish(feed, message)


def test_code():
	client = init_client()
	client.publish('dht11_temp', '34')
	time.sleep(2)


#test_code()