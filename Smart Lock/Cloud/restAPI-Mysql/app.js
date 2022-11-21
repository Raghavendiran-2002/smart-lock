const express = require("express");
const mongoose = require("mongoose");
// require('dotenv').config();
require("dotenv").config({ path: "ENV_FILENAME" });

const app = express();

mongoose
  .connect("mongodb://localhost:27017/", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log("Connected to Mongo DB");
    app.listen(27017);
    console.log("Server is listening at ", 27017);
  })
  .catch((err) => {
    console.log("Error Caught : ", err.message);
  });

const lockstatus = require("./controller/lockstatus");
app.use("/esp32", lockstatus);

const user = require("./controller/user");
app.use("/user", user);
