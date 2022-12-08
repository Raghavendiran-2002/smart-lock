

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <ArduinoJson.h>
#include <EEPROM.h>
#include <WiFi.h>


// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "28406d0e-73e1-11ed-a1eb-0242ac120002"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

const char* ssid = "";
const char* passwd = "";
WiFiClient espClient;

BLEAdvertising *pAdvertising ;

void eepromData(String ssid, String passwd){
        for (int i = 0; i < 96; ++i) {
          EEPROM.write(i, 0);
        }
        Serial.println(ssid);
        Serial.println("");
        Serial.println(passwd);
        Serial.println("");
        Serial.println("writing eeprom ssid:");
        for (int i = 0; i < ssid.length(); ++i)
        {
          EEPROM.write(i, ssid[i]);
          Serial.print("Wrote: ");
          Serial.println(ssid[i]);
        }
        Serial.println("writing eeprom pass:");
        for (int i = 0; i < passwd.length(); ++i)
        {
          EEPROM.write(32 + i, passwd[i]);
          Serial.print("Wrote: ");
          Serial.println(passwd[i]);
        }
        EEPROM.commit();
}


class MyCallbacks: public BLECharacteristicCallbacks {
  
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      
      char message[value.length()];

      if (value.length() > 0) {
        Serial.println("*********");
        Serial.print("New value: ");
        for (int i = 0; i < value.length(); i++){
          message[i] = value[i];
            }
        }
       DynamicJsonDocument doc(100); 
       deserializeJson(doc, Serial);
       if(doc["status"] == "Ready"){
        deserializeJson(doc, message);
        eepromData(doc["wifi"], doc["passwd"]);
        Serial.println("*********");
       }
      }
    
};



class MyServerCallbacks: public BLEServerCallbacks {   
  void onConnect(BLEServer* pServer) {
//      pAdvertising->start();
    };
   void onDisconnect(BLEServer* pServer) {
      pAdvertising->start();
    }
};

String ssidread;
String passwdread = "";


void setup() {
  Serial.begin(115200);
  EEPROM.begin(512); 
  for (int i = 0; i < 32; ++i)
  {
    ssidread += char(EEPROM.read(i));
  }
  Serial.println();
  Serial.print("SSID: ");
  Serial.println(ssidread);
  Serial.println("Reading EEPROM pass");
  for (int i = 32; i < 92; ++i)
  {
    passwdread += char(EEPROM.read(i));
  }
  Serial.print("PASS: ");
  Serial.println(passwdread);
  
  Serial.println("Bluetooth Started");

  WiFi.begin(ssid, passwd);
  WifiConnect();

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


  DynamicJsonDocument doc(92);
  doc["deviceUID"] = "";
  doc["deviceID"] = "0x01";
  char message[100];
  serializeJson(doc, message);
  pCharacteristic->setValue(message);
  pService->start();
  pAdvertising = pServer->getAdvertising();
  pAdvertising->start();
}

void WifiConnect(){
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.println("Connecting to WiFi..");
    }
   Serial.println("Connected to the WiFi network");
}


void loop() {
  delay(2000);
}
