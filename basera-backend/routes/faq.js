const express = require('express');
const router = express.Router();
const faqController = require('../controllers/faq');
const { verifyToken, isAdmin } = require('../middleware/auth');

router.get('/', faqController.getFAQs);
router.post('/', verifyToken, isAdmin, faqController.createFAQ);
router.put('/:id', verifyToken, isAdmin, faqController.updateFAQ);
router.delete('/:id', verifyToken, isAdmin, faqController.deleteFAQ);

module.exports = router;
