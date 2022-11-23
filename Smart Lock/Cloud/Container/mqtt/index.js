const mqtt = require("mqtt");

const host = "13.235.99.169";
const port = "1883";
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;

const connectUrl = `mqtt://${host}:${port}`;
const client = mqtt.connect(connectUrl, {
  clientId,
});

const topic = "/nodejs/mqtt";
client.on("connect", () => {
  console.log("Connected");
  client.subscribe([topic], () => {
    console.log(`Subscribe to topic '${topic}'`);
  });
});
client.on("message", (topic, payload) => {
  console.log("Received Message:", topic, payload.toString());
  msg = JSON.parse(payload.toString());
  if (msg["nodeID"] == "0x01") {
    if (msg["status"] == true) {
      console.log("Lock is Open");
      if (msg["motion"] == true) {
        client.publish("rpi", "{'image':0}");
        console.log("Published");
      }
    } else if (msg["status"] == false) {
      console.log("Lock is Close");
    }
  }
});
