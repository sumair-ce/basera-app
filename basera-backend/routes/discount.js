const express = require('express');
const router = express.Router();
const { applyDiscount } = require('../controllers/discount');

router.post('/apply', applyDiscount);

module.exports = router;
