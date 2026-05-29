const Booking = require('../models/booking');
const Room = require('../models/room');

exports.createBooking = async (req, res) => {
    try {
        const { userId, roomId, startDate, endDate, totalPrice } = req.body;
        
        // Prevent double booking logic here
        const existingBookings = await Booking.find({
            roomId,
            status: { $in: ['pending', 'confirmed'] },
            $or: [
                { startDate: { $lt: new Date(endDate), $gte: new Date(startDate) } },
                { endDate: { $gt: new Date(startDate), $lte: new Date(endDate) } }
            ]
        });

        if (existingBookings.length > 0) {
            return res.status(400).json({ message: 'Room is already booked for these dates' });
        }

        const booking = new Booking({ userId, roomId, startDate, endDate, totalPrice });
        await booking.save();
        res.status(201).json(booking);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.getBookings = async (req, res) => {
    try {
        // optionally filter by userId if user, else get all for manager
        const { userId } = req.query;
        let filter = {};
        if (userId) filter.userId = userId;

        const bookings = await Booking.find(filter).populate('roomId').populate('userId', 'name email');
        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.cancelBooking = async (req, res) => {
    try {
        const { id } = req.params;
        const booking = await Booking.findById(id);

        if (!booking) {
            return res.status(404).json({ message: 'Booking not found' });
        }

        // Cancellation logic
        const stayDate = new Date(booking.startDate);
        const currentDate = new Date();
        const diffTime = Math.abs(stayDate - currentDate);
        const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

        let refundPercentage = 0;
        if (diffDays >= 3) {
            refundPercentage = 100;
        } else if (diffDays === 2) {
            refundPercentage = 50;
        } else {
            refundPercentage = 0;
        }

        booking.status = 'cancelled';
        Object.assign(booking, { refundPercentage, refundedAmount: booking.totalPrice * (refundPercentage / 100) });
        await booking.save();

        res.json({ message: 'Booking cancelled', booking, refundPercentage });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

// Return all confirmed/pending date ranges for a specific room (for calendar highlighting)
exports.getBookedDatesForRoom = async (req, res) => {
    try {
        const { roomId } = req.params;
        const bookings = await Booking.find({
            roomId,
            status: { $in: ['pending', 'confirmed'] }
        }).select('startDate endDate status -_id');

        res.json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

