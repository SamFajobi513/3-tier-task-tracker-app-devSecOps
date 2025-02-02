import mongoose from 'mongoose'
const ENVIRONMENT: any = process.env.ENVIRONMENT
const MONGODB_LOCAL_URL: any = process.env.MONGODB_LOCAL_URL
const MONGODB_LIVE_URL: any = process.env.MONGODB_LIVE_URL



let URL: any = '';
ENVIRONMENT === 'development' ? URL = MONGODB_LIVE_URL : URL = MONGODB_LIVE_URL;
mongoose.connect(URL)
const db = mongoose.connection;

db.on('error', console.error.bind(console, 'connection error:'));

db.once('open', function () {
    console.log("Connection Successful");
});
