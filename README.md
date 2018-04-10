# Alligator

Os objetivos do projeto Alligator são:
- Aprofundar meus conhecimentos em programação para o chip ESP8266.
- Construir uma mini estação autônoma (alimentada por energia solar) para coleta de dados meteorológicos.

A primeira versão utiliza o Raspberry Pi como controlador. O programa foi escrito em Python e está na pasta 'alligator_rpi/'.

A segunda versão (em construção), vai utilizar o ESP8266 (ESP-12) como unidade controladora.


# Alguns conceitos relacionados ao ESP8266:

- NodeMCU - Firmware bastante popular para execução de código LUA.
- esptool.py - Python script para gravar o firmware (a.k.a flashing).
- ESPlorer - Programa para fazer upload de código (sketch) para o microcontrolator (upload != flashing)

# Comandos
- Flashing de firmware
	esptool.py --port <serial-port-of-ESP8266> write_flash -fm qio 0x00000 <nodemcu-firmware>.bin


# Links úteis

- Ferramenta para upload de código LUA para o ESP (roda em Java 7): https://esp8266.ru/esplorer/
- Instructable ensinando a conectar o ESP "via" Arduino: http://www.instructables.com/id/ESP-12E-ESP8266-With-Arduino-Uno-Getting-Connected/
- Documentação e passos iniciais: https://nodemcu.readthedocs.io/en/master/en/flash/#putting-device-into-flash-mode


