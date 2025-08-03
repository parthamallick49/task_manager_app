// server.js
const express = require('express');
const dotenv = require('dotenv');
const mongoose = require('mongoose');
const taskRoutes = require('./routes/taskRoutes');
const userRoutes = require('./routes/userRoutes');
const { errorHandler } = require('./middleware/errorMiddleware');
const { getCurrentUser } = require('./controllers/userController');

dotenv.config();

const app = express();
app.use(express.json()); // Parse JSON bodies
app.use(express.urlencoded({ extended: true })); // Parse URL-encoded bodies

// Routes
app.use('/api/tasks', taskRoutes);
app.use('/api/users', userRoutes);
//app.get('/api/me', getCurrentUser);



// Error handling middleware
app.use(errorHandler);

// Connect to MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => {
    console.log('MongoDB connected...');
  })
  .catch((err) => {
    console.error('MongoDB connection failed:', err);
  });


const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
