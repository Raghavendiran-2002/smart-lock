

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <ArduinoJson.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "28406d0e-73e1-11ed-a1eb-0242ac120002"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEAdvertising *pAdvertising ;

class MyCallbacks: public BLECharacteristicCallbacks {
  
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      
      char message[value.length()];
      Serial.println("Receiving message!!!");

      if (value.length() > 0) {
        Serial.println("*********");
        Serial.print("New value: ");
        for (int i = 0; i < value.length(); i++){
          Serial.print(value[i]);
          message[i] = value[i];
            }
        }
       DynamicJsonDocument doc(1024); 
       deserializeJson(doc, Serial);
       deserializeJson(doc, message);
//       char* a = doc["wifi"];
//       Serial.println(a);
       Serial.println("*********");
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


void setup() {
  Serial.begin(115200);

  Serial.println("Bluetooth Started!!!!");
  

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


  DynamicJsonDocument doc(1024);
  doc["deviceUID"] = "";
  doc["deviceID"] = "0x01";
  char message[100];
  serializeJson(doc, message);
  pCharacteristic->setValue(message);
  pService->start();
  pAdvertising = pServer->getAdvertising();
  pAdvertising->start();
}


void loop() {
  delay(2000);
}
