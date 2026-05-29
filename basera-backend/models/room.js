const mongoose = require('mongoose');

const roomSchema = new mongoose.Schema({
    title: { type: String, required: true },
    city: { type: String, required: true },
    hostelId: { type: mongoose.Schema.Types.ObjectId, ref: 'Hostel' },
    category: { type: String, enum: ['Basic', 'Deluxe', 'VIP'], required: true },
    config: { type: String, required: true, default: '1-bed' },
    beds: { type: Number, required: true },
    pricePerNight: { type: Number, required: true },
    isAvailable: { type: Boolean, default: true },
    imageUrl: { type: String, default: 'https://via.placeholder.com/400x250?text=Room+Image' },
    description: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Room', roomSchema);