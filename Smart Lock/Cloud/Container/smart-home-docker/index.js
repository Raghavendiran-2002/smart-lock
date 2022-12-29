const express = require("express");
const mongoose = require("mongoose");

require("dotenv").config({ path: "ENV_FILENAME" });

const app = express();
console.log("Runing SmartLock");
mongoose
  .connect("mongodb://host.docker.internal:27015/", {
    // mongodb://mongo:27017/
    // .connect("mongodb://localhost:27017/", {
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