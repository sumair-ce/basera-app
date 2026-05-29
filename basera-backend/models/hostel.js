const mongoose = require('mongoose');

const hostelSchema = new mongoose.Schema({
    name: { type: String, required: true },
    city: { type: String, required: true },
    address: { type: String, required: true },
    description: { type: String },
    contactEmail: { type: String },
    contactPhone: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Hostel', hostelSchema);
