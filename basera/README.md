# Basera - Hotel & Guest House Booking UI

A modern and highly dynamic mobile application built using Flutter to facilitate seamless bookings for hotel rooms and guest houses across Kaghan and Shogran.

## Architecture

This project strictly follows the **MVVM (Model-View-ViewModel)** architecture via the `provider` state management pattern, ensuring clear separation of concerns.

### Folder Structure
- `lib/core/` - Global constants like colors and theme.
- `lib/models/` - Data definitions representing the business logic mappings.
- `lib/services/` - Network requests to interact with the Node.js backend.
- `lib/viewmodels/` - State management bridging views and services.
- `lib/views/` - Stateful and stateless UI components.

## Application Flow

1. **Authentication:** 
    - Users can Login or Sign Up.
    - Added a **"Continue as Guest"** option which directly routes to Dashboard.
2. **Dashboard (City Selection Map):**
    - Users select their destination (Kaghan or Shogran).
3. **Room Listing & Dates:**
    - Displays all rooms based on selected city.
    - User selects `start` and `end` dates. Rooms visually change based on availability (Smart Availability prompts).
4. **Checkout:**
    - Confirmation of dates and duration.
    - Add discount promo codes dynamically adjusting the cart total.
5. **Payment Upload:**
    - Simulation of standard manual banking (IBFT).
    - Captures the receipt base64 and ships it to backend for manager verification.

## Connecting UI with Backend

The ViewModels interact with classes inside `services/` (`RoomService`, `BookingService`, `PaymentService`).
When a network hit is required:
1. `View` accesses the `ViewModel` (e.g. `vm.bookRoom()`).
2. The `ViewModel` performs loading adjustments and forwards data to the `Service`.
3. `Service` parses JSON from the respective Node.js `/api/...` endpoints and returns Dart `Model` objects.
