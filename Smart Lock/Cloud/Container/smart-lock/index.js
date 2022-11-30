const express = require("express");
const mongoose = require("mongoose");
const mqtt = require("mqtt");

require("dotenv").config({ path: "ENV_FILENAME" });

// const host = "localhost";
// const port = "1883";
// var isUpdate = true;
// const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;

// const connectUrl = `mqtt://${host}:${port}`;
// const client = mqtt.connect(connectUrl, {
//   clientId,
// });

// const topic = "/lock/status";
// client.on("connect", () => {
//   console.log("Connected");
//   client.subscribe([topic], () => {
//     console.log(`Subscribe to topic '${topic}'`);
//   });
// });

// client.on("message", (topic, payload) => {
//   console.log("Received Message:", topic, payload.toString());

//   msg = JSON.parse(payload.toString());
//   syncFirestore(msg["status"], msg["nodeId"]);
//   lockstatus
//     .find({ nodeId: msg["nodeId"] })
//     .updateOne({
//       nodeId: `${msg["nodeId"]}`,
//       status: msg["status"],
//     })
//     .then((status) => {
//       console.log(`lock status... ID updated: `);
//       return console.log({
//         success: true,
//         message: "Data Updated Successfully",
//         quality: status,
//       });
//     })
//     .catch((err) => {
//       console.log({ success: false, message: err.message });
//       return;
//     });

//   if (msg["status"] == true) {
//     console.log(`Lock ${msg["nodeId"]} is Open`);
//   } else if (msg["status"] == false) {
//     console.log(`Lock ${msg["nodeId"]}  is Close`);
//   }
// });

const app = express();
console.log("Runing SmartLock");
mongoose
  // .connect("mongodb://13.235.99.169/", {
  .connect("mongodb://mongo:27017/", {
    // .connect("mongodb://localhost:27017/", {

    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log("Connected to Mongo DB");
    app.listen(3000);
    console.log("Server is listening at ", 3000);
  })
  .catch((err) => {
    console.log("Error Caught : ", err.message);
  });

const lockstatus = require("./controller/lockstatus");
app.use("/lock", lockstatus);

const user = require("./controller/user");
app.use("/user", user);
