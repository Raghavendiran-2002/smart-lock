const express = require("express");
const mongoose = require("mongoose");
const mqtt = require("mqtt");

require("dotenv").config({ path: "ENV_FILENAME" });

const app = express();
var client = mqtt.connect("mqtt://localhost:1883", { clientId: "c1" });
var topic = "/t/q";
options = {
  clientId: "c1",
  username: "elab",
  password: "2024",
  clean: true,
};

client.on("message", function (topic, message, packet) {
  console.log("message is " + message);
  console.log("topic is " + topic);
});

client.on("connect", function () {
  console.log("connected  " + client.connected);
});

console.log("subscribing to topics");
client.subscribe(topic);

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
