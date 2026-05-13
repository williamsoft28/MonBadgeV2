const express = require('express');
const router = express.Router();
const coursController = require('../controllers/coursController');
const auth = require('../middleware/authMiddleware');
const role = require('../middleware/roleMiddleware');

const reportController = require('../controllers/reportController');

router.get('/', auth, coursController.getAllCours);
router.get('/jour', auth, coursController.getCoursDuJour);
router.get('/:id', auth, coursController.getCoursById);
router.get('/:id/report', auth, role('admin', 'enseignant'), reportController.getPresencesReport);
router.post('/', auth, role('admin'), coursController.createCours);
router.put('/:id', auth, role('admin'), coursController.updateCours);
router.delete('/:id', auth, role('admin'), coursController.deleteCours);

module.exports = router;