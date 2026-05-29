const mongoose = require('mongoose');

const termSchema = new mongoose.Schema({
    sectionTitle: { type: String, required: true },
    content: { type: String, required: true },
    order: { type: Number, default: 0 }
}, { timestamps: true });

module.exports = mongoose.model('Term', termSchema);
