const express = require('express');
const router = express.Router();
const { createBooking, getBookings, cancelBooking, getBookedDatesForRoom } = require('../controllers/booking');

router.post('/', createBooking);
router.get('/', getBookings);
router.put('/:id/cancel', cancelBooking);
router.get('/room/:roomId/dates', getBookedDatesForRoom);

module.exports = router;
