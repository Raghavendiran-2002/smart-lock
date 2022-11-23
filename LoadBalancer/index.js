const express = require("express");

const app = express();
const appId = process.env.APPID;

app.get("/", (req, res) => res.send("opening app : ${appId}"));

app.listen(appId, () => console.log("App on port no. ${appId}"));
