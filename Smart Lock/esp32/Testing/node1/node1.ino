#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#define SS_PIN 5  //D2
#define RST_PIN 27 //D1
#include <SPI.h>
#include <MFRC522.h>

MFRC522 mfrc522(SS_PIN, RST_PIN);  
int variable = 0;
int pin = 4;

// WiFi
const char *ssid = "Raghavendiran"; // Enter your WiFi name
const char *password = "apple@5g";  // Enter WiFi password

const char *mqtt_broker = "13.233.193.140";
const char *topic = "/lock/status";
//const char *mqtt_username = "emqx";
//const char *mqtt_password = "public";
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

void setup() {
   Serial.begin(115200);
   pinMode(pin, OUTPUT);
   digitalWrite(pin, HIGH);
   SPI.begin();      
   mfrc522.PCD_Init(); 
   WiFi.begin(ssid, password);
   WifiConnect();
   client.subscribe("/lock/publishStatus");
   client.subscribe("/lock/publishStatus");
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

void PublishMessage(bool state){
  DynamicJsonDocument doc(1024);
  doc["status"] = state;
  doc["nodeId"] = "0x01";
  char message[100];
  serializeJson(doc, message);
  client.publish(topic, message);
}

void WrongID(){
  DynamicJsonDocument doc(1024);
  doc["wrong"] = true;
  char message[100];
  serializeJson(doc, message);
  client.publish(topic, message);
}

void callback(char *topic, byte *payload, unsigned int length) {
 Serial.print("Message arrived in topic: ");
 Serial.println(topic);
 Serial.print("Message:");
 char message[length];
 for (int i = 0; i < length; i++) {
  message[i] = ((char)payload[i]);
 }
 DynamicJsonDocument doc(1024); 
 deserializeJson(doc, message);
 bool state = doc["deviceState"]; 
 const char* deviceUID = doc["deviceID"];
 if(doc["deviceID"] == "0x01"){
   Serial.println(state); 
   if (state == true){
          Serial.println("Lock is OPEN");
          digitalWrite(pin, LOW);
   }
   else {
          digitalWrite(pin, HIGH);
          Serial.println("Lock is CLOSED");
   }
 }
}
void loop() {
 client.loop();
 if ( ! mfrc522.PICC_IsNewCardPresent()) 
  {
    return;
  }
  if ( ! mfrc522.PICC_ReadCardSerial()) 
  {
    return;
  }
  Serial.println();
  Serial.print(" UID tag :");
  String content= "";
  byte letter;
  for (byte i = 0; i < mfrc522.uid.size; i++) 
  {
     Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
     Serial.print(mfrc522.uid.uidByte[i], HEX);
     content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "));
     content.concat(String(mfrc522.uid.uidByte[i], HEX));
  }
  content.toUpperCase();
  Serial.println();
  if (content.substring(1) == "BA 98 44 B3") 
  {
    Serial.println(" Authorized Access ");
    Serial.println();
    PublishMessage(true);
    digitalWrite(pin, LOW);
  }
  else  {
    Serial.println(" Access Denied ");
    WrongID();
  }
}
