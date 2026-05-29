const express = require('express');
const router = express.Router();
const adminController = require('../controllers/admin');
const { verifyToken, isAdmin } = require('../middleware/auth');

router.use(verifyToken, isAdmin);

router.get('/users', adminController.getUsers);
router.delete('/users/:id', adminController.deleteUser);

router.get('/bookings', adminController.getBookings);
router.put('/bookings/:id', adminController.updateBookingStatus);
router.delete('/bookings/:id', adminController.deleteBooking);

router.get('/hostels', adminController.getHostels);
router.post('/hostels', adminController.createHostel);
router.put('/hostels/:id', adminController.updateHostel);
router.delete('/hostels/:id', adminController.deleteHostel);

module.exports = router;
