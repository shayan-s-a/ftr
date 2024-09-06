const express = require('express');
const jsforce = require('jsforce');
require('dotenv').config();

const app = express();

const {SF_LOGIN_URL, SF_USERNAME, SF_PASSWORD, SF_TOKEN} = process.env;
const conn = new jsforce.Connection({
    loginUrl:SF_LOGIN_URL,
    version: '58.0'
});

if(conn)
{
    //console.log(conn.login(SF_USERNAME, SF_PASSWORD+SF_TOKEN));
    //console.log(conn.login(SF_USERNAME, SF_PASSWORD+SF_TOKEN));
    try{
        conn.login(SF_USERNAME, SF_PASSWORD+SF_TOKEN).then((userInfo,err) => {
            if(err)
            {
                console.log('Error connection',err);
            }
            else
            {
                console.log('\n********Connected to Salesforce')
                console.log(`User Id: ${userInfo.id}`);
                console.log(`Org Id: ${userInfo.organizationId}`);
            }
        });
        
    }
    catch(error)
    {
        console.error(error);
    }
}
else
{
    console.log('Unable to log in')
}

app.use(express.json());

app.get("/getResponse",(req,res) =>{
    conn.query("SELECT Id, Name FROM Account", function(err, result) {
    if (err) { return console.error(err); }
    console.log("total : " + result.totalSize);
    console.log("fetched : " + result.records.length);
    res.send(result);
    });
})



app.listen(3002, () => {
    console.log("Running on http://localhost:3002");
})