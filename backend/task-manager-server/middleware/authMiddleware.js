const jwt = require('jsonwebtoken');
const User = require('../models/userModel'); // Update this path based on your structure

const protect = (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      console.log("✅ Decoded token:", decoded); // Debug
      req.userId = decoded.id; // Attach user ID from token payload
      
      if (!req.userId) {
        console.log("====");
        return res.status(401).json({ message: 'Invalid token payload' });
      }else{
        console.log(">>>>>>>>>>>>> req.userId set as:", req.userId);
      }
      return next();
    } catch (error) {
      return res.status(401).json({ message: 'Not authorized' });
    }
  } else {
    return res.status(401).json({ message: 'Not authorized, no token' });
  }
};

module.exports = { protect };
