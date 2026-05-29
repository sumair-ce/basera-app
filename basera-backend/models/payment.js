const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
    bookingId: { type: mongoose.Schema.Types.ObjectId, ref: 'Booking', required: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    amount: { type: Number, required: true },
    screenshotUrl: { type: String, required: true }, // Store base64 or a path to image
    accountNumber: { type: String },
    status: { type: String, enum: ['pending', 'verified', 'rejected'], default: 'pending' },
    verifiedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' } // Manager/Admin
}, { timestamps: true });

module.exports = mongoose.model('Payment', paymentSchema);
