const Term = require('../models/term');

exports.getTerms = async (req, res) => {
    try {
        const terms = await Term.find().sort({ order: 1 });
        res.status(200).json(terms);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching terms' });
    }
};

exports.createTerm = async (req, res) => {
    try {
        const term = new Term(req.body);
        await term.save();
        res.status(201).json(term);
    } catch (error) {
        res.status(400).json({ message: 'Error creating term' });
    }
};

exports.updateTerm = async (req, res) => {
    try {
        const term = await Term.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.status(200).json(term);
    } catch (error) {
        res.status(400).json({ message: 'Error updating term' });
    }
};

exports.deleteTerm = async (req, res) => {
    try {
        await Term.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'Term deleted' });
    } catch (error) {
        res.status(400).json({ message: 'Error deleting term' });
    }
};
