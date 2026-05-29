require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const authRoutes = require('./routes/auth');
const roomRoutes = require('./routes/room');
const bookingRoutes = require('./routes/booking');
const paymentRoutes = require('./routes/payment');
const discountRoutes = require('./routes/discount');

const faqRoutes = require('./routes/faq');
const termRoutes = require('./routes/term');
const adminRoutes = require('./routes/admin');
const userRoutes = require('./routes/user');

const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

mongoose.connect('mongodb://127.0.0.1:27017/hotel_booking', {
}).then(() => console.log('MongoDB Connected'))
  .catch(err => console.log(err));

app.use('/api/auth', authRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/discounts', discountRoutes);
app.use('/api/faqs', faqRoutes);
app.use('/api/terms', termRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/users', userRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));