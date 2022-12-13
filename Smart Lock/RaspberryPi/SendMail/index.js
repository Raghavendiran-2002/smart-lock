const chokidar = require("chokidar");
const nodemailer = require("nodemailer");

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "raghavendiran222222@gmail.com",
    pass: "nikgkgvjjzlnwkrs",
  },
});

async function sendMain() {
  transporter
    .sendMail({
      from: "raghavendiran222222@gmail.com", // sender address
      to: "124158084@sastra.ac.in", // list of receivers
      subject: "Intruder Alert!!!", // Subject line
      text: "Visit your House as soon as possible", // plain text body
      attachments: [
        {
          path: "/Users/raghavendiran/Desktop/Smart-Lock/Intrusion-Detection/intruder/unknown1.png",
          filename: "Intruder!!.png",
          content: "Intruder On Alert!",
        },
      ],
    })
    .then((info) => {
      console.log({ info });
    })
    .catch(console.error);
}

chokidar
  .watch(
    "/Users/raghavendiran/Desktop/Smart-Lock/Intrusion-Detection/intruder",
    { ignoreInitial: true }
  )
  .on("add", (event, path) => {
    console.log("Sendinggg.....Mail");
    sendMain();
  });
