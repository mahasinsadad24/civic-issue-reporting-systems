const express = require('express');
const router = express.Router();
const storageService = require('../services/storageService');

// @route   GET /api/media/:folder/:filename
// @desc    Proxy media files from MinIO
// @access  Public
router.get('/:folder/:filename', async (req, res) => {
    try {
        const { folder, filename } = req.params;
        const objectName = `${folder}/${filename}`;

        const dataStream = await storageService.getFileStream(objectName);

        // Determine content type based on extension
        const ext = filename.split('.').pop().toLowerCase();
        let contentType = 'application/octet-stream';
        if (ext === 'jpg' || ext === 'jpeg') contentType = 'image/jpeg';
        if (ext === 'png') contentType = 'image/png';
        if (ext === 'gif') contentType = 'image/gif';

        res.setHeader('Content-Type', contentType);

        // Pipe the stream to response
        dataStream.pipe(res);
    } catch (error) {
        console.error('[Media Proxy] Error:', error.message);
        res.status(404).json({ message: 'Media not found' });
    }
});

module.exports = router;
