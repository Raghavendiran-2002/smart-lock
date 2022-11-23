const express = require("express");
const router = express.Router();

const lockstatus = require("../models/lockstatus");

router.use(express.json());
router.use(express.urlencoded({ extended: true }));

router.post("/postLockStatus", (req, res) => {
  lockstatus
    .create({
      nodeId: req.body.nodeId,
      status: req.body.status,
      motion: req.body.motion,
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
