const mongoose = require('mongoose');

const discountSchema = new mongoose.Schema({
    code: { type: String, required: true, unique: true },
    type: { type: String, enum: ['percentage', 'flat'], required: true },
    value: { type: Number, required: true },
    validUntil: { type: Date, required: true },
    isActive: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model('Discount', discountSchema);
