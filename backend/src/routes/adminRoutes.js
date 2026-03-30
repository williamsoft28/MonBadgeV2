const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const auth = require('../middleware/authMiddleware');
const role = require('../middleware/roleMiddleware');

router.get('/stats', auth, role('admin'), adminController.getStats);
router.get('/users', auth, role('admin'), adminController.getAllUsers);
router.delete('/users/:id', auth, role('admin'), adminController.deleteUser);
router.get('/rapport/cours', auth, role('admin', 'enseignant'), adminController.getRapportCours);
router.get('/rapport/absences', auth, role('admin', 'enseignant'), adminController.getAbsencesEtudiant);

module.exports = router;