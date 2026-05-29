const Payment = require('../models/payment');
const Booking = require('../models/booking');

exports.uploadPayment = async (req, res) => {
    try {
        const { bookingId, userId, amount, screenshotUrl, accountNumber } = req.body;
        
        const payment = new Payment({
            bookingId, userId, amount, screenshotUrl, accountNumber, status: 'pending'
        });
        
        await payment.save();
        
        // update booking payment status
        await Booking.findByIdAndUpdate(bookingId, { paymentStatus: 'paid' });
        
        res.status(201).json(payment);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.verifyPayment = async (req, res) => {
    try {
        const { id } = req.params;
        const { status, verifiedBy } = req.body; // 'verified' or 'rejected'
        
        const payment = await Payment.findByIdAndUpdate(id, { status, verifiedBy }, { new: true });
        if(status === 'verified') {
            await Booking.findByIdAndUpdate(payment.bookingId, { status: 'confirmed' });
        }
        res.json(payment);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

exports.getPayments = async (req, res) => {
    try {
        const { userId } = req.query;
        let filter = {};
        if (userId) filter.userId = userId;

        const payments = await Payment.find(filter)
                                      .populate({
                                          path: 'bookingId',
                                          populate: { path: 'roomId' }
                                      })
                                      .sort({ createdAt: -1 });
        res.json(payments);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};

