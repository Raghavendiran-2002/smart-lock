const WebSocket = require("ws");
const wss = new WebSocket.Server({ port: 7071 });

const clients = new Map();
