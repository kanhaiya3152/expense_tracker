const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const Expense = require('./lib/model/model');
const dotenv = require('dotenv');

dotenv.config();
const app = express();
const PORT = 5000; // Change this if needed

// Middleware
app.use(express.json());
app.use(cors());

// MongoDB Connection
const MONGO_URI = process.env.MONGO_URI
mongoose.connect(MONGO_URI)
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.error("MongoDB Connection Error:", err));

// API Routes
app.post('/addExpense', async (req, res) => {
  console.log("Received Data:", req.body);
  const { amount, category, date } = req.body;

  if (!amount || !category || !date) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const newExpense = new Expense({
      amount,
      category,
      date: new Date(date),
    });
    await newExpense.save();
    console.log("Saved Expense:", newExpense);
    res.status(201).json(newExpense);
  } catch (err) {
    console.error("Error saving expense:", err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/expenses', async (req, res) => {
  try {
    const expenses = await Expense.find();
    res.json(expenses);
  } catch (err) {
    console.error("Error fetching expenses:", err);
    res.status(500).json({ error: "Failed to fetch expenses" });
  }
});

app.get('/summary', async (req, res) => {
  try {
    console.log("Fetching summary...");
    const summary = await Expense.aggregate([
      { $group: { _id: "$category", total: { $sum: "$amount" } } }
    ]);
    console.log("Summary fetched:", summary);
    res.json(summary);
  } catch (err) {
    console.error("Error fetching summary:", err);
    res.status(500).json({ error: err.message });
  }
});

// Start Server
app.listen(PORT, () => {
  console.log(`Server running on port http://localhost:${PORT}`);
}).on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error(`Port ${PORT} is already in use. Please use a different port.`);
  } else {
    console.error('Server error:', err);
  }
});