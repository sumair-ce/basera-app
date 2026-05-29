const User = require('../models/user');
const Booking = require('../models/booking');
const Hostel = require('../models/hostel');

exports.getUsers = async (req, res) => {
    try {
        const users = await User.find();
        res.status(200).json(users);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching users' });
    }
};

exports.deleteUser = async (req, res) => {
    try {
        await User.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'User deleted' });
    } catch (error) {
        res.status(400).json({ message: 'Error deleting user' });
    }
};

exports.getBookings = async (req, res) => {
    try {
        const bookings = await Booking.find().populate('userId roomId').sort({ createdAt: -1 });
        res.status(200).json(bookings);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching bookings' });
    }
};

exports.updateBookingStatus = async (req, res) => {
    try {
        const { status } = req.body;
        const booking = await Booking.findByIdAndUpdate(req.params.id, { status }, { new: true });
        res.status(200).json(booking);
    } catch (error) {
        res.status(400).json({ message: 'Error updating booking' });
    }
};

exports.deleteBooking = async (req, res) => {
    try {
        await Booking.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'Booking deleted' });
    } catch (error) {
        res.status(400).json({ message: 'Error deleting booking' });
    }
};

exports.getHostels = async (req, res) => {
    try {
        const hostels = await Hostel.find();
        res.status(200).json(hostels);
    } catch (error) {
        res.status(500).json({ message: 'Error fetching hostels' });
    }
};

exports.createHostel = async (req, res) => {
    try {
        const hostel = new Hostel(req.body);
        await hostel.save();
        res.status(201).json(hostel);
    } catch (error) {
        res.status(400).json({ message: 'Error creating hostel' });
    }
};

exports.updateHostel = async (req, res) => {
    try {
        const hostel = await Hostel.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.status(200).json(hostel);
    } catch (error) {
        res.status(400).json({ message: 'Error updating hostel' });
    }
};

exports.deleteHostel = async (req, res) => {
    try {
        await Hostel.findByIdAndDelete(req.params.id);
        res.status(200).json({ message: 'Hostel deleted' });
    } catch (error) {
        res.status(400).json({ message: 'Error deleting hostel' });
    }
};
