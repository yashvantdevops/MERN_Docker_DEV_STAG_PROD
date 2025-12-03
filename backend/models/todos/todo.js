/**
 * Created by Syed Afzal
 */
const mongoose = require('mongoose');

const TodoSchema = new mongoose.Schema({
  text: {
    type: String,
    trim: true,
    required: true,
  },
}, {
  timestamps: true, // Adds createdAt and updatedAt fields
});

const Todo = mongoose.model('Todo', TodoSchema);

module.exports = { Todo };
