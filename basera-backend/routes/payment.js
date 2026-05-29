const express = require('express');
const router = express.Router();
const { uploadPayment, verifyPayment, getPayments } = require('../controllers/payment');

router.post('/', uploadPayment);
router.put('/:id/verify', verifyPayment);
router.get('/', getPayments);

module.exports = router;
