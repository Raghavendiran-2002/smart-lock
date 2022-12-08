// fetch("http://13.235.244.236:3000/lock/updateLockStatus", {
//   method: "POST",
//   headers: {
//     Accept: "application/json",
//     "Content-Type": "application/json",
//   },
//   body: JSON.stringify({ deviceID: "0x01", deviceState: false }),
// })
//   .then((response) => response.json())

//   .then((response) => console.log(JSON.stringify(response)));

async function doRequest() {
    var req = new Request("http://13.235.244.236:3000/lock/updateLockStatus", {method: "POST",headers :{
        'Content-Type': 'application/json'}, body: JSON.stringify(data),
    }, );
}

doRequest().then(data => {
    console.log(data);
});

var request = require("request");
let url = "http://13.235.244.236:3000/lock/updateLockStatus";
async function smartlock(state){
    let data ={ "deviceID": "0x01", "deviceState": true };
    let k = JSON.stringify(data)
    var req = new Request("http://13.235.244.236:3000/lock/updateLockStatus", {method: "POST",headers :{
        'Content-Type': 'application/json'}, body: JSON.stringify(data),
    }, );
    req.
    req.post(
        "http://13.235.244.236:3000/lock/updateLockStatus",
        { json: { "deviceID": "0x01", "deviceState": state } },
        function (error, response, body) {
          if (!error && response.statusCode == 200) {
            console.log(body);
          }
        }
      ); 
}

smartlock(True);


request.post(
  "http://13.235.244.236:3000/lock/updateLockStatus",
  { json: { deviceID: "0x01", deviceState: true } },
  function (error, response, body) {
    if (!error && response.statusCode == 200) {
      console.log(body);
    }
  }
);

<script>
    async function doRequest() {

        let url = 'http://13.235.244.236:3000/lock/updateLockStatus';
        

        let res = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
        });

        if (res.ok) {

            // let text = await res.text();
            // return text;

            let ret = await res.json();
            return JSON.parse(ret.data);

        } else {
            return `HTTP error: ${res.status}`;
        }
    }

    doRequest().then(data => {
        console.log(data);
    });

</script>
