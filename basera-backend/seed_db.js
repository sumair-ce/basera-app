const mongoose = require('mongoose');
const fs = require('fs');
const bcrypt = require('bcryptjs');

const Room = require('./models/room');
const User = require('./models/user');
const Discount = require('./models/discount');
const FAQ = require('./models/faq');
const Term = require('./models/term');
const Hostel = require('./models/hostel');

mongoose.connect('mongodb://localhost:27017/hotel_booking', {})
  .then(async () => {
      console.log('MongoDB Connected for seeding');
      
      const seedData = JSON.parse(fs.readFileSync('seed_data.json', 'utf-8'));
      
      // Clear existing
      await Room.deleteMany({});
      await User.deleteMany({});
      await Discount.deleteMany({});
      await FAQ.deleteMany({});
      await Term.deleteMany({});
      await Hostel.deleteMany({});
      
      // Seed Hostels
      const createdHostels = await Hostel.insertMany(seedData.hostels);
      const hostelMap = {};
      createdHostels.forEach(h => hostelMap[h.city] = h._id);

      // Seed users
      for (let user of seedData.users) {
          const salt = await bcrypt.genSalt(10);
          user.password = await bcrypt.hash('password123', salt);
          await User.create(user);
      }
      
      // Seed rooms
      const roomsToCreate = seedData.rooms.map(room => ({
          ...room,
          hostelId: hostelMap[room.city] || null
      }));
      const createdRooms = await Room.insertMany(roomsToCreate);
      
      // Seed discounts
      await Discount.insertMany(seedData.discounts);

      // Seed FAQs and Terms
      await FAQ.insertMany(seedData.faqs);
      await Term.insertMany(seedData.terms);
      
      // Seed Bookings and Payments for John Doe
      const Booking = require('./models/booking');
      const Payment = require('./models/payment');
      
      await Booking.deleteMany({});
      await Payment.deleteMany({});
      
      const userJohn = await User.findOne({ email: "john@example.com" });
      const room1 = createdRooms[0];
      const room2 = createdRooms[1];
      
      const booking1 = await Booking.create({
          userId: userJohn._id,
          roomId: room1._id,
          startDate: new Date(),
          endDate: new Date(new Date().setDate(new Date().getDate() + 3)),
          status: 'confirmed',
          totalPrice: room1.pricePerNight * 3,
          paymentStatus: 'paid'
      });
      
      const booking2 = await Booking.create({
          userId: userJohn._id,
          roomId: room2._id,
          startDate: new Date(new Date().setDate(new Date().getDate() - 10)),
          endDate: new Date(new Date().setDate(new Date().getDate() - 8)),
          status: 'completed',
          totalPrice: room2.pricePerNight * 2,
          paymentStatus: 'paid'
      });
      
      await Payment.create({
          bookingId: booking1._id,
          userId: userJohn._id,
          amount: room1.pricePerNight * 3,
          screenshotUrl: 'https://via.placeholder.com/300x500?text=Payment+Proof',
          accountNumber: '12345678',
          status: 'verified'
      });
      
      await Payment.create({
          bookingId: booking2._id,
          userId: userJohn._id,
          amount: room2.pricePerNight * 2,
          screenshotUrl: 'https://via.placeholder.com/300x500?text=Payment+Proof',
          accountNumber: '12345678',
          status: 'verified'
      });
      
      console.log('Seeding completed successfully with Bookings and Payments!');
      process.exit();
  })
  .catch(err => {
      console.log(err);
      process.exit(1);
  });
