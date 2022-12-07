#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#define SS_PIN 5  //D2
#define RST_PIN 27 //D1
#include <SPI.h>
#include <MFRC522.h>
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <ArduinoJson.h>
#include <EEPROM.h>

MFRC522 mfrc522(SS_PIN, RST_PIN);  
int pin = 4;

#define SERVICE_UUID        "28406d0e-73e1-11ed-a1eb-0242ac120002"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

// WiFi
const char *ssid = ""; // Enter your WiFi name
const char *password = "";  // Enter WiFi password

const char *mqtt_broker = "13.233.193.140";
const char *topic = "/lock/status";
//const char *mqtt_username = "emqx";
//const char *mqtt_password = "public";
const int mqtt_port = 1883;

WiFiClient espClient;
PubSubClient client(espClient);

BLEAdvertising *pAdvertising ;

String ssidread;
String passwdread = "";


class MyServerCallbacks: public BLEServerCallbacks {   
  void onConnect(BLEServer* pServer) {
//      pAdvertising->start();
    };
   void onDisconnect(BLEServer* pServer) {
      pAdvertising->start();
    }
};

void eepromData(String ssid, String passwd){
        for (int i = 0; i < 50; ++i) {
          EEPROM.write(i, 0);
        }
        for (int i = 0; i < ssid.length(); ++i)
        {
          EEPROM.write(i, ssid[i]);
        }
        for (int i = 0; i < passwd.length(); ++i)
        {
          EEPROM.write(25 + i, passwd[i]);
        }
        EEPROM.commit();
}
class MyCallbacks: public BLECharacteristicCallbacks {
  
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      
      char message[value.length()];

      if (value.length() > 0) {
        for (int i = 0; i < value.length(); i++){
          message[i] = value[i];
            }
        }
       DynamicJsonDocument doc(1024); 
       deserializeJson(doc, Serial);
       deserializeJson(doc, message);
       eepromData(doc["wifi"], doc["passwd"]);
       Serial.println("*********");
      }    
};


void setup() {
   Serial.begin(115200);
   pinMode(pin, OUTPUT);
   digitalWrite(pin, HIGH);
   SPI.begin();      
   mfrc522.PCD_Init(); 
   BLEDevice::init("MyESP32");
   BLEServer *pServer = BLEDevice::createServer();

   BLEService *pService = pServer->createService(SERVICE_UUID);

   BLECharacteristic *pCharacteristic = pService->createCharacteristic(
                                         CHARACTERISTIC_UUID,
                                         BLECharacteristic::PROPERTY_READ |
                                         BLECharacteristic::PROPERTY_WRITE
                                       );

   pCharacteristic->setCallbacks(new MyCallbacks());
   pServer->setCallbacks(new MyServerCallbacks());
//   pCharacteristic->setValue(message);
   pService->start();
   pAdvertising = pServer->getAdvertising();
   pAdvertising->start();
   EEPROM.begin(512); 
   for (int i = 0; i < 25; ++i){
    ssidread += char(EEPROM.read(i));
   }
   for (int i = 25; i < 50; ++i){
    passwdread += char(EEPROM.read(i));
   }
   WiFi.begin(ssidread.c_str(), passwdread.c_str());
   WifiConnect();
   client.subscribe("/lock/publishStatus");
}

void WifiConnect(){
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }
   client.setServer(mqtt_broker, mqtt_port);
   client.setCallback(callback);
   while (!client.connected()) {
       if (client.connect("1")) {
       } else {
           Serial.print("failed");
           Serial.print(client.state());
           delay(2000);
       }
    }
}

void PublishMessage(bool state){
  DynamicJsonDocument doc(64);
  doc["status"] = state;
  doc["nodeId"] = "0x01";
  char message[100];
  serializeJson(doc, message);
  client.publish(topic, message);
}

void WrongID(){
  DynamicJsonDocument doc(16);
  doc["wrong"] = true;
  char message[100];
  serializeJson(doc, message);
  client.publish(topic, message);
}

void callback(char *topic, byte *payload, unsigned int length) {
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
// if ( ! mfrc522.PICC_IsNewCardPresent()) 
//  {
//    return;
//  }
//  if ( ! mfrc522.PICC_ReadCardSerial()) 
//  {
//    return;
//  }
//  Serial.println();
//  Serial.print(" UID tag :");
//  String content= "";
//  byte letter;
//  for (byte i = 0; i < mfrc522.uid.size; i++) 
//  {
////     Serial.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
////     Serial.print(mfrc522.uid.uidByte[i], HEX);
//     content.concat(String(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " "));
//     content.concat(String(mfrc522.uid.uidByte[i], HEX));
//  }
//  content.toUpperCase();
//  Serial.println();
//  if (content.substring(1) == "BA 98 44 B3") 
//  {
//    Serial.println(" Authorized Access ");
//    Serial.println();
//    PublishMessage(true);
//    digitalWrite(pin, LOW);
//  }
//  else  {
//    Serial.println(" Access Denied ");
//    WrongID();
//  }
}
