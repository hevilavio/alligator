# /bin/bash


if [ ! -d "Adafruit_Python_DHT" ]; then
	git clone https://github.com/adafruit/Adafruit_Python_DHT.git
fi

cd Adafruit_Python_DHT && python3 setup.py install
pip3 install paho-mqtt
pip3 install adafruit-io

