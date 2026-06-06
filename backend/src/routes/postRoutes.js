const express = require('express');
const router = express.Router();

const postController = require('../controllers/postController');
const authMiddleware = require('../middleware/authMiddleware');

router.post('/', authMiddleware, postController.createPost);
router.get('/', authMiddleware, postController.getPosts);
router.delete('/:id', authMiddleware, postController.deletePost);

router.post('/:id/comments', authMiddleware, postController.createComment);
router.get('/:id/comments', authMiddleware, postController.getComments);

router.delete('/comments/:id', authMiddleware, postController.deleteComment);

module.exports = router;