const multer = require("multer");
const path = require("path");
const fs = require("fs");

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, "../uploads");
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    // Generate unique filename: timestamp_randomnumber_originalname
    const uniqueSuffix = Date.now() + "_" + Math.round(Math.random() * 1E9);
    const extension = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, extension);
    cb(null, `${uniqueSuffix}_${baseName}${extension}`);
  }
});

// File filter to accept only images
const fileFilter = (req, file, cb) => {
  const allowedMimeTypes = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/gif',
    'image/webp',
    'application/octet-stream' // Allow generic binary streams (often happens with Flutter/Android raw files)
  ];

  console.log(`[Multer] Processing upload: ${file.originalname} (Mime: ${file.mimetype})`);

  if (allowedMimeTypes.includes(file.mimetype)) {
    cb(null, true);
  } else {
    console.error(`[Multer] Rejected file type: ${file.mimetype}`);
    cb(new Error(`Invalid file type: ${file.mimetype}. Only JPEG, PNG, GIF, WebP are allowed.`), false);
  }
};

// Configure multer
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
    files: 1 // Only one file per request
  }
});

module.exports = upload;
