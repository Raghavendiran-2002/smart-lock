

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>
#include <ArduinoJson.h>

int led[4] = {2, 4, 18, 19};
bool deviceState[4] = {false, false, false ,false};

#define SERVICE_UUID        "28406d0e-73e1-11ed-a1eb-0242ac120002"
#define CHARACTERISTIC_UUID "beb5483e-36e1-4688-b7f5-ea07361b26a8"

BLEAdvertising *pAdvertising ;

class MyCallbacks: public BLECharacteristicCallbacks {
  
    void onWrite(BLECharacteristic *pCharacteristic) {
      std::string value = pCharacteristic->getValue();
      
      char message[value.length()];
      Serial.println("Receiving message!!!");

      if (value.length() > 0) {
        Serial.print("New value: ");
        for (int i = 0; i < value.length(); i++){
          Serial.print(value[i]);
          message[i] = value[i];
            }
        }
       DynamicJsonDocument doc(1024);
       deserializeJson(doc, message);
       bool state = doc["deviceState"]; 
       int deviceUID = doc["deviceID"];
       if(doc["deviceID"] == 0){
            if(state){
              Serial.println("d0 ON");
              digitalWrite(2, LOW);
            }
            else{
              Serial.println("d0 OFF");
              digitalWrite(2, HIGH);
            }
        }
        if(doc["deviceID"] == 1){
            if(state){
              Serial.println("d1 ON");
              digitalWrite(4, LOW);
            }
            else{
              Serial.println("d1 OFF");
              digitalWrite(4, HIGH);
            }
        }
        if(doc["deviceID"] == 2){
            if(state){
              Serial.println("d2 ON");
              digitalWrite(18, LOW);
            }
            else{
              Serial.println("d2 OFF");
              digitalWrite(18, HIGH);
            }
        }
        if(doc["deviceID"] == 3){
            if(state){
              Serial.println("d3 ON");
              digitalWrite(19, LOW);
            }
            else{
              Serial.println("d3 OFF");
              digitalWrite(19, HIGH);
            }
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
void reset(){
  digitalWrite(2, HIGH);
  digitalWrite(4, HIGH);
  digitalWrite(18, HIGH);
  digitalWrite(19, HIGH);
}

void setup() {
  pinMode(2, OUTPUT);
  pinMode(4, OUTPUT);
  pinMode(18, OUTPUT);
  pinMode(19, OUTPUT);
  Serial.begin(115200);
  reset();

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


  
  char messages[25] = "Connected";

  pCharacteristic->setValue(messages);
  pService->start();
  pAdvertising = pServer->getAdvertising();
  pAdvertising->start();
}


void loop() {
  delay(2000);
}
