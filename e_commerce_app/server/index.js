// IMPORT FROM PACKAGES
const express = require('express'); 
// import 'pakage:express/express.dart'
const mongoose = require('mongoose');



// IMPORT FROM OTHER FILES
const authRouter = require('./routes/auth');
const adminRouter = require('./routes/admin');


// INIT
const PORT = 3000;
const app = express();
const DB = "mongodb+srv://HARSH:harsh12345@cluster0.yl1r5j0.mongodb.net/?retryWrites=true&w=majority";


// MIDDLEWARE
app.use(express.json());
app.use(authRouter);
app.use(adminRouter);

// CONNECTIONS
mongoose.connect(DB)
.then(() => {
    console.log("Connection Successful");
})
.catch((e) => {
    console.log(e);
});

app.listen(PORT, "0.0.0.0" , () => {
    console.log(`Connected at port ${PORT}`);
});
// localhost