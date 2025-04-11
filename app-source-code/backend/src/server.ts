const tasks = require("./routes/tasks");
const connection = require("./db");
const cors = require("cors");
const express = require("express");
const app = express();
const mongoose = require('mongoose');

connection();

app.use(express.json());
app.use(cors());

// Health check endpoints

// Basic health check to see if the server is running
app.get('/healthz', (req, res) => {
    res.status(200).send('Healthy');
});

let lastReadyState = null;  
// Readiness check to see if the server is ready to serve requests
app.get('/ready', (req, res) => {
    // Here you can add logic to check database connection or other dependencies
    const isDbConnected = mongoose.connection.readyState === 1;
    if (isDbConnected !== lastReadyState) {
        console.log(`Database readyState: ${mongoose.connection.readyState}`);
        lastReadyState = isDbConnected;
    }
    
    if (isDbConnected) {
        res.status(200).send('Ready');
    } else {
        res.status(503).send('Not Ready');
    }
});

