const express = require('express');
const router = express.Router();
const coursController = require('../controllers/coursController');
const auth = require('../middleware/authMiddleware');
const role = require('../middleware/roleMiddleware');

router.get('/', auth, coursController.getAllCours);
router.get('/jour', auth, coursController.getCoursDuJour);
router.get('/:id', auth, coursController.getCoursById);
router.post('/', auth, role('admin'), coursController.createCours);

module.exports = router;