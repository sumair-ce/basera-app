const express = require('express');
const authrouter = express.Router();
const {login, signup} = require('../controllers/auth');

authrouter.post('/login', login);

authrouter.post('/signup', signup);

module.exports = authrouter;