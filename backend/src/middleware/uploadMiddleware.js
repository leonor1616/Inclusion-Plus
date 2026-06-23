const multer = require('multer');
const path = require('path');

// Multer stores user-uploaded images on local disk. The generated filename
// avoids collisions while preserving the original file extension.
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },

  filename: (req, file, cb) => {
    const uniqueName =
      Date.now() + '-' + Math.round(Math.random() * 1e9);

    cb(
      null,
      uniqueName + path.extname(file.originalname)
    );
  }
});

const upload = multer({ storage });

module.exports = upload;
