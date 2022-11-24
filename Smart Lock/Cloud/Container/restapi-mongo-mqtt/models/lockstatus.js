const mongoose = require("mongoose");
const Schema = mongoose.Schema;

const lockSchema = new Schema(
  {
    nodeId: {
      type: String,
      required: true,
    },
    status: {
      type: String,
      required: true,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("lock", lockSchema);
