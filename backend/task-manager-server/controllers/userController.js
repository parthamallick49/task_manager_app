// controllers/userController.js
const User = require('../models/userModel');
const jwt = require('jsonwebtoken');

// Register a new user
const registerUser = async (req, res) => {
  const { name, email, password } = req.body;

  const userExists = await User.findOne({ email });
  if (userExists) {
    return res.status(400).json({ message: 'User already exists' });
  }

  const user = await User.create({ name, email, password });
  if (user) {
    res.status(201).json({
      _id: user._id,
      name: user.name,
      email: user.email,
      token: generateToken(user._id),
    });
  } else {
    res.status(400).json({ message: 'Invalid user data' });
  }
};

// Login an existing user
const loginUser = async (req, res) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email });
  if (user && (await user.matchPassword(password))) {
    res.json({
      _id: user._id,
      name: user.name,
      email: user.email,
      token: generateToken(user._id),
    });
  } else {
    res.status(401).json({ message: 'Invalid email or password' });
  }
};

// Generate JWT token
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN,
  });
};


const getCurrentUser = async (req, res) => {
  try {
    //console.log("🔍 req.userId =", req.userId); // Debug log

    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      console.log("❌ No user found with ID:", req.userId); // More debug info
      return res.status(404).json({ message: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    console.error('[ERROR] Failed to get current user:', error.message);
    res.status(500).json({ message: 'Server error' });
  }
};


module.exports = { registerUser, loginUser, getCurrentUser };