const User = require('../models/user');

exports.updateProfile = async (req, res) => {
    try {
        const { userId, name, email } = req.body;
        // Mock checking user, usually you'd extract userId from JWT token.
        const user = await User.findByIdAndUpdate(userId, { name, email }, { new: true });
        res.status(200).json(user);
    } catch (error) {
        res.status(400).json({ message: 'Error updating profile' });
    }
};

exports.updatePayment = async (req, res) => {
    try {
        const { userId, paymentDetails } = req.body;
        const user = await User.findByIdAndUpdate(userId, { paymentDetails }, { new: true });
        res.status(200).json(user);
    } catch (error) {
        res.status(400).json({ message: 'Error updating payment details' });
    }
};
