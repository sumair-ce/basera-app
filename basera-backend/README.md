# Basera - Hotel & Guest House API

RESTful API service providing full control over the Basera hotel bookings ecosystem. Built using Node.js and Express with MongoDB.

## Architecture

The backend implements the standard Controller/Route paradigm:
- `models/` - Mongoose schemas handling MongoDB schemas.
- `routes/` - Express router mappings pointing endpoints to controller execution.
- `controllers/` - Heart of the business logic including Smart Availability and booking prevention logic.

## Logic Overview

### Booking logic
- System receives `startDate` and `endDate`. It checks via `$lt` and `$gt` operators if any overlaps occur with `pending` or `confirmed` bookings for the selected `roomId`.
- Enforces strong transactional consistency visually indicating which dates are conflicted.

### Cancellation & Refund Policies
- 3 days prior: 100% refund
- 2 days prior: 50% refund
- 1 day prior: 0% refund
- Managed automatically by diffing `stayDate` versus `currentDate` in `controllers/booking.js`.

### Seed Data
Included in this repo is `seed_data.json` and a script `generate_seed.js`.
Running `npm run seed` will insert 42 realistic rooms, admin profiles, manager profiles, and dummy users into the database.

## Endpoints

### Auth
- `POST /api/auth/login` - Retrieve token map.
- `POST /api/auth/signup` - Register a new role (user, manager, admin).

### Rooms
- `GET /api/rooms` - Query params `city`, `category`, `startDate`, `endDate`.

### Bookings
- `POST /api/bookings` - Submit a booking request. Needs `roomId`, `userId`, `startDate`, `endDate`, `totalPrice`.
- `PUT /api/bookings/:id/cancel` - Request refund matrix based on elapsed days.

### Payment
- `POST /api/payments` - Upload receipt images. Re-tags booking to `paid`.
- `PUT /api/payments/:id/verify` - Manager endpoint to officially `confirm` a booking.

### Discounts
- `POST /api/discounts/apply` - Submit a `code` and checks `isActive` boolean. Validates `validUntil` TTL.

## How to Run

1. `npm install`
2. Ensure MongoDB is running `mongodb://localhost:27017`
3. Generate and push seed data: `node generate_seed.js` && `node seed_db.js`
4. Run server: `npm run start` (uses nodemon, points to `server.js`)
