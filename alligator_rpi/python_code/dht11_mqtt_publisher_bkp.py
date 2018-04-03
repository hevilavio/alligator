#!/usr/bin/env python3

import sys
import time
import paho.mqtt.client as mqtt
import util

try:
	import Adafruit_DHT
except ImportError as e:
	util.log_info('Error on optional imports: {}'.format(e))


def on_connect(client, userdata, flags, rc):
    util.log_info("connected with result code "+str(rc))

def publish_message(c, topic, payload):
	util.log_info('about do publish on topic {}, payload=[{}]'.format(topic, payload))
	result, mid = c.publish(topic, payload, qos=0, retain=True)
	util.log_info("message published, return_code={} message_id={} ".format(result, mid))

def get_sensor_info():
	try:
		return Adafruit_DHT.read_retry(Adafruit_DHT.DHT11, SENSOR_PIN)
	except Exception as e:
		util.log_info(str(e))
		return (1, 2)

## config
mqtt_host="iot.eclipse.org"
topic_temperature="SYS/test-95701/dht11/temperature"
topic_humidity="SYS/test-95701/dht11/humidity"
SENSOR_PIN=17
## config end

c1 = mqtt.Client()
c1.on_connect = on_connect
c1.connect(mqtt_host, 1883, 60)

c2 = mqtt.Client()
c2.on_connect = on_connect
c2.connect(mqtt_host, 1883, 60)

count = 0
while True:
	util.log_info('going to loop {}'.format(count))	
	humidity, temperature = get_sensor_info()
	#humidity, temperature = 1,2

	date_time = time.strftime("%Y-%m-%d %H:%M") + " at "
	publish_message(c1, topic_humidity, date_time + str(humidity))
	publish_message(c2, topic_temperature, date_time + str(temperature))
	
	count+=1
	time.sleep(60)

