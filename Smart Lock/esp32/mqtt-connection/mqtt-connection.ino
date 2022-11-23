#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// WiFi
const char *ssid = "Raghavendiran"; // Enter your WiFi name
const char *password = "apple@5g";  // Enter WiFi password

// MQTT Broker
const char *mqtt_broker = "13.235.99.169";
const char *topic = "/lock/status";
//const char *mqtt_username = "emqx";
//const char *mqtt_password = "public";
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
   Serial.begin(115200);
   pinMode(2, OUTPUT);
   digitalWrite(2, HIGH);
   WiFi.begin(ssid, password);
   WifiConnect();
  
   PublishMessage();
   client.subscribe(topic);
}

void WifiConnect(){
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.println("Connecting to WiFi..");
    }
   Serial.println("Connected to the WiFi network");
   client.setServer(mqtt_broker, mqtt_port);
   client.setCallback(callback);
   while (!client.connected()) {
       String client_id = "esp32-client-";
       client_id += String(WiFi.macAddress());
       Serial.printf("The client %s connects to the public aws mqtt broker\n", client_id.c_str());
       //if (client.connect(client_id.c_str(), mqtt_username, mqtt_password)) {
       if (client.connect(client_id.c_str())) {
           Serial.println("Public AWS broker connected");
       } else {
           Serial.print("failed with state ");
           Serial.print(client.state());
           delay(2000);
       }
    }
}

void PublishMessage(){
  DynamicJsonDocument doc(1024);
  doc["status"] = true;
  doc["nodeID"] = "0x01";
  char message[100];
  serializeJson(doc, message);
//  client.publish(topic, message);
}

void callback(char *topic, byte *payload, unsigned int length) {
 Serial.print("Message arrived in topic: ");
 Serial.println(topic);
 Serial.print("Message:");
 char message[length];
 for (int i = 0; i < length; i++) {
  message[i] = ((char)payload[i]);
 }
 DynamicJsonDocument doc(64); 
 deserializeJson(doc, message);
 bool state = doc["status"]; 
 const char* deviceUID = doc["nodeID"]; 
 if (state == true){
        Serial.println("Lock is OPEN");
        digitalWrite(2, LOW);
 }
 else {
        digitalWrite(2, HIGH);
        Serial.println("Lock is CLOSED");
 }
}

void loop() {
 client.loop();
}
