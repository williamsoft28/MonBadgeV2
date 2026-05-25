const express = require('express');
const router = express.Router();
const authController = require('../controllers/authController');
const auth = require('../middleware/authMiddleware');

router.post('/register', authController.register);
router.post('/login', authController.login);
router.post('/login-biometric', authController.loginBiometric);
router.post('/enable-biometrics', authController.enableBiometrics);
router.post('/enroll-face', auth, authController.enrollFace);
router.post('/verify-face', auth, authController.verifyFace);
router.get('/offline-users', auth, authController.getOfflineUsers);

module.exports = router;