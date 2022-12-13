const express = require("express");
const mongoose = require("mongoose");
const bodyParser = require("body-parser");
const cookieParser = require("cookie-parser");

require("dotenv").config({ path: "ENV_FILENAME" });

const app = express();
console.log("Runing SmartLock");
mongoose
  .connect("mongodb://13.233.193.140/", {
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

app.use(bodyParser.json());
app.use(cookieParser());

const lockstatus = require("./controller/lockstatus");
app.use("/lock", lockstatus);
// const { signIn } = require("./controller/lockstatus");
// app.post("/signin", signIn);

const user = require("./controller/user");
app.use("/user", user);

const port = parseInt(process.env.PORT) || 8080;
app.listen(port, () => {
  console.log(`helloworld: listening on port ${port}`);
});
