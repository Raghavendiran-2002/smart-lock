const express = require("express");
const mqtt = require("mqtt");
const router = express.Router();
const { getFirestore } = require("firebase-admin/firestore");
var admin = require("firebase-admin");

var serviceAccount = require("./smartlock.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const lockstatus = require("../models/lockstatus");

const host = "13.235.99.169";
const port = "1883";
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;

const connectUrl = `mqtt://${host}:${port}`;
const client = mqtt.connect(connectUrl, {
  clientId,
});

const topic = "/lock/status";
client.on("connect", () => {
  console.log("Connected");
  client.subscribe([topic], () => {
    // console.log(`Subscribe to topic '${topic}'`);
  });
});

client.on("message", (topic, payload) => {
  console.log("Received Message:", topic, payload.toString());

  msg = JSON.parse(payload.toString());
  syncFirestore(msg["status"], msg["nodeId"]);
  if (msg["nodeId"] == "0x01") {
    if (msg["status"] == true) {
      console.log("Lock is Open");
      lockstatus
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

async function syncFirestore(state, nodeID) {
  db = getFirestore();
  const cityRef = db.collection("lockRealTime").doc("0AlIjID2eJovhzl3SDRl");

  // Set the 'capital' field of the city
  const res = await cityRef.update({ isChanged: state, nodeID: nodeID });
}

router.use(express.json());
router.use(express.urlencoded({ extended: true }));

router.post("/createLockStatus", (req, res) => {
  lockstatus
    .create({
      nodeId: req.body.nodeId,
      status: req.body.status,
    })
    .then((status) => {
      console.log(`lock status... ID : ${req.body.nodeId}`);
      return res.status(201).json({
        success: true,
        message: "Data Added Successfully",
        quality: status,
      });
    })
    .catch((err) => {
      return res.status(500).json({ success: false, message: err.message });
    });
});

router.post("/updateLockStatus", (req, res) => {
  lockstatus
    .find({ nodeId: req.body.nodeId })
    .updateOne({
      nodeId: req.body.nodeId,
      status: req.body.status,
    })
    .then((status) => {
      console.log(`lock status... ID updated: ${req.body.nodeId}`);
      client.publish(
        "rpi",
        `{
        "nodeId": ${req.body.nodeId},
        "status": ${req.body.status},
      }`
      );
      client.publish("rpi", "{'image':0}");

      return res.status(201).json({
        success: true,
        message: "Data Updated Successfully",
        quality: status,
      });
    })
    .catch((err) => {
      return res.status(500).json({ success: false, message: err.message });
    });
});

router.get("/getNodeID", (req, res) => {
  lockstatus
    .find({ nodeId: req.body.nodeId })
    .then((qual) => {
      console.log(`Found lock ID : ${req.body.nodeId}`);
      return res.status(200).json({ success: true, quality: qual });
    })
    .catch((err) => {
      console.log(`no such lock ID found : ${req.body.nodeId}`);
      return res.status(500).json({ success: false, message: err.message });
    });
});

router.get("/getByNode/:nodeId", (req, res) => {
  lockstatus
    .find({ nodeId: req.params.nodeId })
    .then((values) => {
      console.log(`lock ID found : ${req.body.nodeId}`);
      return res.status(200).json({ success: true, values: values });
    })
    .catch((err) => {
      console.log(`no such lock ID found : ${req.body.nodeId}`);
      return res.status(500).json({ success: false, message: err.message });
    });
});

module.exports = router;
