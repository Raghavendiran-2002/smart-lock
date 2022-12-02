const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const homeDeviceSchema = new Schema(
  {
    deviceId: {
      type: String,
      required: true,
    },
    deviceName: {
      type: String,
      required: true,
    },
    actualState: {
      type: String,
      required: true,
    },
    previousState: {
      type: String,
      // required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("lock", lockSchema);
