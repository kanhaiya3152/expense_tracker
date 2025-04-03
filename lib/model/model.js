const mongoose = require('mongoose');

const ExpenseSchema = new mongoose.Schema({
  amount: { type: Number, required: true },
  category: { type: String, required: true },
  subcategory: { type: String, required: false }, // Optional subcategory field
  date: { type: Date, required: true },
});

module.exports = mongoose.model('Expense', ExpenseSchema);