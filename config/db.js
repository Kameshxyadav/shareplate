// config/db.js
const oracledb = require('oracledb');
require('dotenv').config();

// Oracle recommends setting autoCommit to true for basic web apps, 
// but since we are handling transactions inside PL/SQL, we can leave it default.
oracledb.autoCommit = true; 

async function initializeDB() {
    try {
        await oracledb.createPool({
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            connectionString: process.env.DB_CONNECTION_STRING,
            poolMin: 2,
            poolMax: 10,
            poolIncrement: 2
        });
        console.log("✅ Oracle DB pool started successfully!");
    } catch (err) {
        console.error("❌ Error starting Oracle pool: ", err.message);
        process.exit(1);
    }
}

function getPool() {
    return oracledb.getPool();
}

module.exports = { initializeDB, getPool };