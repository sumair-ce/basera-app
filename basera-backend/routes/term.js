const express = require('express');
const router = express.Router();
const termController = require('../controllers/term');
const { verifyToken, isAdmin } = require('../middleware/auth');

router.get('/', termController.getTerms);
router.post('/', verifyToken, isAdmin, termController.createTerm);
router.put('/:id', verifyToken, isAdmin, termController.updateTerm);
router.delete('/:id', verifyToken, isAdmin, termController.deleteTerm);

module.exports = router;
