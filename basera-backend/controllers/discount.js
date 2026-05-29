const Discount = require('../models/discount');

exports.applyDiscount = async (req, res) => {
    try {
        const { code } = req.body;
        const discount = await Discount.findOne({ code, isActive: true });
        
        if (!discount) {
            return res.status(404).json({ message: 'Invalid or expired discount code' });
        }
        
        if (new Date(discount.validUntil) < new Date()) {
            return res.status(400).json({ message: 'Discount code has expired' });
        }
        
        res.json(discount);
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
};
