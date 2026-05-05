// server.js
const express = require('express');
const { initializeDB } = require('./config/db');
require('dotenv').config();

const app = express();
app.use(express.json());

// Start DB, then start server
initializeDB().then(() => {
    app.listen(process.env.PORT, () => {
        console.log(`🚀 Server running on port ${process.env.PORT}`);
    });
});