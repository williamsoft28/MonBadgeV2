const express = require('express');
const router = express.Router();
const presenceController = require('../controllers/presenceController');
const auth = require('../middleware/authMiddleware');
const role = require('../middleware/roleMiddleware');

router.post('/pointer', auth, role('etudiant'), presenceController.pointerPresence);
router.get('/historique', auth, presenceController.getHistorique);
router.get('/cours/:cours_id', auth, role('enseignant', 'admin'), presenceController.getPresencesCours);
router.post('/sync', auth, presenceController.syncOffline);

module.exports = router;