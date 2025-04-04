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
const MONGO_URI = process.env.MONGO_URI;
mongoose.connect(MONGO_URI)
  .then(() => console.log("MongoDB Connected"))
  .catch(err => console.error("MongoDB Connection Error:", err));

// API Routes

// Add Expense
app.post('/addExpense', async (req, res) => {
  console.log("Received Data:", req.body);
  const { amount, category, subcategory, date } = req.body; // Include subcategory

  if (!amount || !category || !date) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  try {
    const newExpense = new Expense({
      amount,
      category,
      subcategory, // Save subcategory if provided
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

// Get All Expenses
app.get('/expenses', async (req, res) => {
  try {
    const expenses = await Expense.find();
    res.json(expenses);
  } catch (err) {
    console.error("Error fetching expenses:", err);
    res.status(500).json({ error: "Failed to fetch expenses" });
  }
});

// Get Summary
app.get('/summary', async (req, res) => {
  try {
    console.log("Fetching summary...");
    const summary = await Expense.aggregate([
      {
        $group: {
          _id: { category: "$category", subcategory: "$subcategory" }, // Group by category and subcategory
          total: { $sum: "$amount" },
        },
      },
      {
        $project: {
          _id: 0, // Exclude the `_id` field
          category: "$_id.category", // Flatten `category`
          subcategory: "$_id.subcategory", // Flatten `subcategory`
          total: 1, // Include the `total` field
        },
      },
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

// Delete
app.delete('/deleteExpense/:id', async (req, res) => {
  console.log("hey");
  try {
    const expenseId = req.params.id;
    console.log(expenseId)
    const result = await Expense.findByIdAndDelete(expenseId);
    console.log(result)

    if (!result) {
      return res.status(404).json({ error: "Expense not found" });
    }

    res.status(200).json({ message: "Expense deleted successfully" });
  } catch (err) {
    console.error("Error deleting expense:", err);
    res.status(500).json({ error: "Failed to delete expense" });
  }
});