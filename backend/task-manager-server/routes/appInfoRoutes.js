// routes/appInfoRoutes.js
const express = require('express');
const router = express.Router();

router.get('/version', (req, res) => {
  res.json({
    version: '1.1.0', // Put your current latest version here
    apkUrl: 'https://task-manager-backend-4g65.onrender.com/apk/task_manager_latest.apk',
    //apkUrl: 'http://10.0.2.2:5000/apk/task_manager_latest.apk',
    releaseNotes: 'Bug fixes and performance improvements.',
    mandatory: true  // Set true if this update is mandatory, else false
  });
});

module.exports = router;
