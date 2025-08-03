const mongoose = require('mongoose');
const Task = require('../models/taskModel');

const createTask = async (req, res) => {
  const { title, description } = req.body;
  try {
    const task = await Task.create({
      title,
      description,
      user: req.userId, // Use req.userId consistently
    });
    res.status(201).json(task);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

const getTasks = async (req, res) => {
  try {
    const tasks = await Task.find({ user: req.userId }); // Use req.userId
    res.json(tasks);
  } catch (error) {
    res.status(500).json({ message: 'Server Error' });
  }
};

const updateTask = async (req, res) => {
  const { id } = req.params;
  console.log('[DEBUG] Received task ID for update:', id);
  const { title, description, isCompleted } = req.body;

  // Validate ObjectId to prevent cast errors
  if (!mongoose.Types.ObjectId.isValid(id)) {
    console.log('[ERROR] Invalid task ID format:', id);
    return res.status(400).json({ message: 'Invalid task ID' });
  }

  try {
    const task = await Task.findOne({ _id: id, user: req.userId });

    if (!task) {
      return res.status(404).json({ message: 'Task not found or not authorized' });
    }

    // Only update fields if they're provided
    if (title !== undefined) task.title = title;
    if (description !== undefined) task.description = description;
    if (isCompleted !== undefined) task.isCompleted = isCompleted;

    await task.save();
    res.json(task);
  } catch (error) {
    console.error('[UPDATE ERROR]', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

const deleteTask = async (req, res) => {
  const { id } = req.params;
  console.log('[DEBUG] Received task ID for delete:', id);

  // Validate ObjectId to avoid cast errors
  if (!mongoose.Types.ObjectId.isValid(id)) {
    console.log('[ERROR] Invalid task ID format:', id);
    return res.status(400).json({ message: 'Invalid task ID' });
  }

  try {
    const task = await Task.findOneAndDelete({ _id: id, user: req.userId });

    if (!task) {
      return res.status(404).json({ message: 'Task not found or not authorized' });
    }

    res.json({ message: 'Task deleted successfully' });
  } catch (error) {
    console.error('[DELETE ERROR]', error);
    res.status(500).json({ message: 'Server Error' });
  }
};

module.exports = { createTask, getTasks, updateTask, deleteTask };