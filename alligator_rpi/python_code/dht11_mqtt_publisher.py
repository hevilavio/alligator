import random
import sys
import time
import util

from Adafruit_IO import MQTTClient
try:
    import Adafruit_DHT
except ImportError as e:
    util.log_info('Error on optional imports: {}'.format(e))

ADAFRUIT_IO_KEY      = 'XXX'
ADAFRUIT_IO_USERNAME = 'd721559'  # See https://accounts.adafruit.com
FEEDS = ['dht11_temp', 'dht11_hum']
SECONDS_TO_SLEEP = 60
SENSOR_PIN = 17
	
def connected(client):
    # Connected function will be called when the client is connected to Adafruit IO.
    # This is a good place to subscribe to feed changes.  The client parameter
    # passed to this function is the Adafruit IO MQTT client so you can make
    # calls against it easily.
    for feed_name in FEEDS:
        util.log_info('Connected to Adafruit IO!  Listening for {} changes...'.format(feed_name))
        client.subscribe(feed_name)

def disconnected(client):
    # Disconnected function will be called when the client disconnects.
    util.log_info('Disconnected from Adafruit IO!')
    sys.exit(1)

def message(client, feed_id, payload):
    # Message function will be called when a subscribed feed has a new value.
    # The feed_id parameter identifies the feed, and the payload parameter has
    # the new value.
    util.log_info('Feed {0} received new value: {1}'.format(feed_id, payload))


def get_sensor_info():
    try:
        return Adafruit_DHT.read_retry(Adafruit_DHT.DHT11, SENSOR_PIN)
    except Exception as e:
        util.log_info(str(e))
        return (1, 2)

def run():
    # Create an MQTT client instance.
    client = MQTTClient(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)

    # Setup the callback functions defined above.
    client.on_connect    = connected
    client.on_disconnect = disconnected
    client.on_message    = message

    # Connect to the Adafruit IO server.
    client.connect()

    # The first option is to run a thread in the background so you can continue
    # doing things in your program.
    client.loop_background()


    # Now send new values every 10 seconds.
    util.log_info('Publishing a new message every {} seconds (press Ctrl-C to quit)...'.format(SECONDS_TO_SLEEP))
    while True:
        humidity, temperature = get_sensor_info()
        client.publish(FEEDS[0], temperature)
        client.publish(FEEDS[1], humidity)
        util.log_info('sleeping for {} seconds from now...'.format(SECONDS_TO_SLEEP))
        time.sleep(SECONDS_TO_SLEEP)
