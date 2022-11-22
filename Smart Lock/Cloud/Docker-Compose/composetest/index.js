
const express = require('express');
const bodyParser = require('body-parser');
const app = express();
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json())

app.get('/', (req, res) => {
    console.log(req.body)
        res.send('Hello World!');
});


app.get('/api', (req, res) => {
        res.send({status: true, username: "Raghav", lockID : 1});
});

app.post('/test', (req, res) => {
    console.log(req.body);

    console.log(req.body['status']);
    if(req.body['status'] == true){
        res.send({status : 200});
    }
    else if(req.body['status'] == false){
            res.send({status :101});
    }
    else{
        res.send({status :500});
    }
});



app.listen(3022, ()=> console.log('Listening on port 3000...'));





