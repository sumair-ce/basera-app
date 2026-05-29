const Room = require('../models/room');
const Booking = require('../models/booking');

// Fetch rooms with optional filtering
exports.getRooms = async (req, res) => {
    try {
        const { search, city, category, startDate, endDate } = req.query;
        let query = {};

        // Apply filters if they are provided in the request
        if (city && city !== 'All') {
            query.city = city;
        }
        if (category && category !== 'All') {
            query.category = category;
        }
        if (search) {
            query.title = { $regex: search, $options: 'i' }; // Case-insensitive search
        }

        let rooms = await Room.find(query).lean().sort({ createdAt: -1 });

        if (startDate && endDate) {
            const requestedStart = new Date(startDate);
            const requestedEnd = new Date(endDate);
            
            // fetch all overlapping bookings
            const overlappingBookings = await Booking.find({
                status: { $in: ['pending', 'confirmed'] },
                $or: [
                    { startDate: { $lt: requestedEnd, $gte: requestedStart } },
                    { endDate: { $gt: requestedStart, $lte: requestedEnd } },
                    { startDate: { $lte: requestedStart }, endDate: { $gte: requestedEnd } }
                ]
            });
            
            const bookedRoomIds = overlappingBookings.map(b => b.roomId.toString());

            rooms = rooms.map(room => {
                if (bookedRoomIds.includes(room._id.toString())) {
                    room.isAvailableForDates = false;
                    const roomBookings = overlappingBookings.filter(b => b.roomId.toString() === room._id.toString());
                    room.conflicts = roomBookings.map(b => ({ start: b.startDate, end: b.endDate }));
                } else {
                    room.isAvailableForDates = true;
                }
                return room;
            });
        }

        res.status(200).json(rooms);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Error fetching rooms' });
    }
};

// Create a new room (For Admin/Testing purposes)
exports.createRoom = async (req, res) => {
    try {
        const newRoom = new Room(req.body);
        const savedRoom = await newRoom.save();
        res.status(201).json(savedRoom);
    } catch (error) {
        console.error(error);
        res.status(400).json({ message: 'Error creating room', error: error.message });
    }
};