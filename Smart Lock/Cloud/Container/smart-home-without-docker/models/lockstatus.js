const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const lockSchema = new Schema(
  {
    deviceID: {
      type: String,
      required: true,
    },
    state: {
      type: Boolean,
      required: true,
    },
    deviceName: {
      type: String,
      required: true,
    },
    deviceType: {
      type: String,
      required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("locks", lockSchema);
