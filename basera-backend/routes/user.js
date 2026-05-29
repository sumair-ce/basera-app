const express = require('express');
const router = express.Router();
const userController = require('../controllers/user');
const { verifyToken } = require('../middleware/auth');

router.put('/profile', verifyToken, userController.updateProfile);
router.put('/payment', verifyToken, userController.updatePayment);

module.exports = router;
