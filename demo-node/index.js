const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

try{
    mongoose.connect('mongodb://127.0.0.1:27017/sampledb');
    console.log('Connection successful')
}
catch(error){
    console.log(error);
}


const ProductSchema = mongoose.Schema({
    id: Number,
    title: String,
    price: Number,
    description: String,
    image: String,
    rating: Number,
    stock: Number
})

const OrderSchema = mongoose.Schema({
    orderId: Number,
    name: String,
    email: String,
    products: {
        id: Number,
        title: String,
        price: Number,
        quantity: Number
    },
    total: Number
})

const ProductModel = mongoose.model("products", ProductSchema);
const OrderModel = mongoose.model("orders", OrderSchema);

//app.use(cors());
//parses json request
app.use(express.json());


app.get("/getProducts",cors(), async(req,res) => {

    // ProductModel.find({}).then(function(products) {
    //     res.json(products);
    // }).catch(function(err) {
    //     console.error(err);
    // })
    console.log("here")

    // const products = await ProductModel.find({});

    // try {
    //     response.send(products);
    // } catch (error) {
    //     response.status(500).send(error);
    // }

    setTimeout(function(){
        const products = ProductModel.find({}).then(function(products) {
            res.send(products);
        }).catch(function(err){
            console.log(err);
        });
    },60000);
    
});

app.post("/postProducts",(req,res) =>{
    const data = req.body;

    //define the query to find the document to update. also it must be an object
    const id = {id: data.id};

    //define the update operation. also it must be an object
    const stock = {stock: data.stock};

    console.log(`Stock now: ${data.stock}`)

    //setTimeout(function(){
        ProductModel.updateOne(id, stock, (err, result) => {
            if(err){
                console.error(`Error while updating: ${err}`);
                res.status(404).send('Error: Not updated')
            }
            else{
                console.log('Data uploaded successfully');
                res.status(200).send(`Stock: ${data.stock}`);
            }
        })
    //},60000)
    
})

app.post("/createOrder", (req,res) => {
    const data = req.body;

    console.log(data);
    //res.sendStatus(201).send('Data created')

    OrderModel.create(data).then(result => {
        console.log('Order created');
        res.status(201).send(`Order Created`);
    }).catch(function(err){
        console.log(err);
    })
})

app.listen(3001, () => {
    console.log("Running on http://localhost:3001");
})