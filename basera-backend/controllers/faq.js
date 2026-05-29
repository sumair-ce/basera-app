const FAQ = require('../models/faq');

exports.getFAQs = async (req, res) => {
    try {
        const faqs = await FAQ.find({ isActive: true });
        res.status(200).json(faqs);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching FAQs' });
    }
};

exports.createFAQ = async (req, res) => {
    try {
        const faq = new FAQ(req.body);
        await faq.save();
        res.status(201).json(faq);
    } catch (error) {
        res.status(400).json({ message: 'Error creating FAQ' });
    }
};

exports.updateFAQ = async (req, res) => {
    try {
        const faq = await FAQ.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.status(200).json(faq);
    } catch (error) {
        res.status(400).json({ message: 'Error updating FAQ' });
    }
};

exports.deleteFAQ = async (req, res) => {
    try {
        await FAQ.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'FAQ deleted' });
    } catch (error) {
        res.status(400).json({ message: 'Error deleting FAQ' });
    }
};
