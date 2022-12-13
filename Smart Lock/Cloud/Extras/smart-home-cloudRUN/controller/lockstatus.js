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

const host = "13.233.193.140";
const port = "1883";
var isUpdate = true;
const clientId = `mqtt_${Math.random().toString(16).slice(3)}`;

const connectUrl = `mqtt://${host}:${port}`;
const client = mqtt.connect(connectUrl, {
  clientId,
});

const jwt = require("jsonwebtoken");

const jwtKey = "my_secret_key";
const jwtExpirySeconds = 10;

const users = {
  user1: "password1",
  user2: "password2",
};

function validateToken(req, res) {
  const token = req.cookies.token;
  if (!token) {
    return res.status(401).end();
  }
  var payload;
  try {
    payload = jwt.verify(token, jwtKey);
  } catch (e) {
    if (e instanceof jwt.JsonWebTokenError) {
      return res.status(401).end();
    }
    return res.status(400).end();
  }
}

router.post("/signIn", (req, res) => {
  // Get credentials from JSON body
  const { username, password } = req.body;
  if (!username || !password || users[username] !== password) {
    // return 401 error is username or password doesn't exist, or if password does
    // not match the password in our records
    return res.status(401).end();
  }

  // Create a new token with the username in the payload
  // and which expires 300 seconds after issue
  const token = jwt.sign({ username }, jwtKey, {
    algorithm: "HS256",
    expiresIn: jwtExpirySeconds,
  });

  // set the cookie as the token string, with a similar max age as the token
  // here, the max age is in milliseconds, so we multiply by 1000
  res.cookie("token", token, { maxAge: jwtExpirySeconds * 1000 });
  res.end();
});

const topic = "/lock/status";
client.on("connect", () => {
  console.log("Connected");
  client.subscribe([topic], () => {
    console.log(`Subscribe to topic '${topic}'`);
  });
});

client.on("message", (topic, payload) => {
  msg = JSON.parse(payload.toString());
  if (msg.hasOwnProperty("status")) {
    syncFirestore(msg["status"], msg["nodeId"], msg["status"]);
    lockstatus
      .find({ deviceID: msg["nodeId"] })
      .updateOne({
        deviceState: msg["status"],
      })
      .then((status) => {
        return;
      })
      .catch((err) => {
        console.log({ success: false, message: err.message });
        return;
      });
  }
  if (msg.hasOwnProperty("wrong")) {
    if (msg["wrong"] == true) {
      WrongID();
    }
  }
  if (msg["status"] == true) {
    console.log(`Lock ${msg["nodeId"]} is Open`);
  } else if (msg["status"] == false) {
    console.log(`Lock ${msg["nodeId"]}  is Close`);
  }
});

async function syncFirestore(state, nodeID, isUpdate) {
  db = getFirestore();
  const smartlockdb = db.collection("lockRealTime").doc("0AlIjID2eJovhzl3SDRl");
  await smartlockdb.update({
    isRandom: Math.random(),
  });
}

async function WrongID() {
  db = getFirestore();
  const smartlockdb = db.collection("wrongID").doc("6tsfk3UyPScZ6DX7Qhdg");
  await smartlockdb.update({
    wrong: Math.random(),
  });
  // sendMain();
}

router.use(express.json());
router.use(express.urlencoded({ extended: true }));

router.post("/createLockStatus", (req, res) => {
  const token = req.cookies.token;
  console.log(req.cookies.token);
  if (!token) {
    return res.status(401).end();
  }
  var payload;
  try {
    payload = jwt.verify(token, jwtKey);
  } catch (e) {
    if (e instanceof jwt.JsonWebTokenError) {
      return res.status(401).end();
    }
    return res.status(400).end();
  }
  lockstatus
    .create({
      deviceID: req.body.deviceID,
      deviceState: req.body.deviceState,
      deviceName: req.body.deviceName,
      deviceType: req.body.deviceType,
    })
    .then((status) => {
      console.log(`lock status... ID : ${req.body}`);
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
  const token = req.cookies.token;
  console.log(req.cookies.token);
  if (!token) {
    return res.status(401).end();
  }
  var payload;
  try {
    payload = jwt.verify(token, jwtKey);
  } catch (e) {
    if (e instanceof jwt.JsonWebTokenError) {
      return res.status(401).end();
    }
    return res.status(400).end();
  }

  lockstatus
    .find({ deviceID: req.body.deviceID })
    .updateOne({
      deviceState: req.body.deviceState,
    })
    .then((status) => {
      console.log(`Updated Lock status: ${req.body.deviceState}`);
      msg = JSON.stringify({
        deviceID: req.body.deviceID,
        deviceState: req.body.deviceState,
      });

      client.publish("/lock/publishStatus", msg);

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
    .find({ deviceID: req.body.deviceID })
    .then((qual) => {
      console.log(`Found lock ID : ${req.body.deviceID}`);
      return res.status(200).json({ success: true, quality: qual });
    })
    .catch((err) => {
      console.log(`no such lock ID found : ${req.body.deviceID}`);
      return res.status(500).json({ success: false, message: err.message });
    });
});

router.get("/DeleteNodeID", (req, res) => {
  lockstatus
    .deleteOne({ deviceID: req.body.deviceID })
    .then((qual) => {
      console.log(`Found lock ID : ${req.body.deviceID}`);
      return res.status(200).json({ success: true, quality: qual });
    })
    .catch((err) => {
      console.log(`no such lock ID found : ${req.body.deviceID}`);
      return res.status(500).json({ success: false, message: err.message });
    });
});

router.get("/getAllNodeID", (req, res) => {
  const token = req.cookies.token;
  console.log(req.cookies.token);
  if (!token) {
    return res.status(401).end();
  }
  var payload;
  try {
    payload = jwt.verify(token, jwtKey);
  } catch (e) {
    if (e instanceof jwt.JsonWebTokenError) {
      return res.status(401).end();
    }
    return res.status(400).end();
  }

  lockstatus
    .find({}, {})
    .then((data) => {
      console.log("Retrived All Documents");
      res.send(data);
    })
    .catch((err) => {
      res.status(500).send({
        message:
          err.message || "Some error occurred while retrieving tutorials.",
      });
    });
});

router.get("/getByNode/:nodeId", (req, res) => {
  lockstatus
    .find({ deviceID: req.params.deviceID })
    .then((values) => {
      console.log(`lock ID found : ${req.body.deviceID}`);
      return res.status(200).json({ success: true, values: values });
    })
    .catch((err) => {
      console.log(`no such lock ID found : ${req.body.deviceID}`);
      return res.status(500).json({ success: false, message: err.message });
    });
});

module.exports = router;
