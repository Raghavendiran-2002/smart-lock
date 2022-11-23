const mqtt = require("mqtt");
const mongoose = require("mongoose");
const lockstatus = require("./models/lockstatus");

const host = "13.235.99.169";
const port = "1883";
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;

mongoose
  .connect("mongodb://localhost:27018/", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log("Connected to Mongo DB");
  })
  .catch((err) => {
    console.log("Error Caught : ", err.message);
  });

const connectUrl = `mqtt://${host}:${port}`;
const client = mqtt.connect(connectUrl, {
  clientId,
});

const topic = "/lock/status";
client.on("connect", () => {
  console.log("Connected");
  client.subscribe([topic], () => {
    console.log(`Subscribe to topic '${topic}'`);
  });
});
client.on("message", (topic, payload) => {
  console.log("Received Message:", topic, payload.toString());
  msg = JSON.parse(payload.toString());
  if (msg["nodeId"] == "0x01") {
    if (msg["status"] == true) {
      console.log("Lock is Open");
      lockstatus
        // .create({
        //   status: "true",
        //   nodeId: "0x01",
        // })
        .find({ nodeId: "0x01" })
        .updateOne({
          nodeId: "0x01",
          status: "poi",
        })
        .then((status) => {
          console.log(`lock status... ID updated: `);
          return console.log({
            success: true,
            message: "Data Updated Successfully",
            quality: status,
          });
        })
        .catch((err) => {
          console.log({ success: false, message: err.message });
          return;
        });
      if (msg["motion"] == true) {
        client.publish("rpi", "{'image':0}");
        console.log("Published");
      }
    } else if (msg["status"] == false) {
      console.log("Lock is Close");
    }
  }
});
