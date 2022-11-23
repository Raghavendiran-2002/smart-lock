const express = require("express");
const mongoose = require("mongoose");
const mqtt = require("mqtt");

require("dotenv").config({ path: "ENV_FILENAME" });

const host = "localhost";
const port = "1883";
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;

const connectUrl = `mqtt://${host}:${port}`;

const client = mqtt.connect(connectUrl, {
  clientId,
  username: "elab",
  password: "2024",
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
});

const app = express();
mongoose
  .connect("mongodb://mongo:27017/", {
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
