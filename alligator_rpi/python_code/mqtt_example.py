import paho.mqtt.client as mqtt
import sys

default_topic="SYS/test-95701/dht11/temperature"

# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
	print("connected with result code "+str(rc))

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
	print(msg.topic + " " + msg.payload.decode('utf-8'))

def get_topic():
	if len(sys.argv) > 1 and sys.argv[1] == '--topic':
		return sys.argv[2]
	
	return default_topic;
	

client = mqtt.Client()
client.on_connect = on_connect
client.connect("iot.eclipse.org", 1883, 60)
	
if len(sys.argv) > 1 and sys.argv[1] == '--publish':
	print('publish mode')
	message = sys.argv[2]
	result, mid = client.publish(topic, message, qos=0, retain=True)
	print("Mensagem publicada, return_code={} message_id={} ".format(result, mid))

else:
	print('subscribe mode')
	client.on_message = on_message
	client.subscribe(get_topic())		

	# Blocking call that processes network traffic, dispatches callbacks and
	# handles reconnecting.
	# Other loop*() functions are available that give a threaded interface and a
	# manual interface.
	client.loop_forever()

