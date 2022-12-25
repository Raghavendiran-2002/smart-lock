import paho.mqtt.client as mqtt
from time import sleep


def on_connect(rc):
    if rc == 0:
        print("connected to broker")
    else:
        print("Connection failed")


def on_message(client, userdata, message):
    msg = message.payload
    print("message received : ", msg)
