<div align="center">
  <h1 style="margin-bottom:5px;">Basera</h1>
  <p style="font-size:16px; color:#555;">Hotel & Guest House Booking Mobile Application</p>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Overview</h2>
  <p><b>Basera</b> is a full-stack hotel and guest house booking application built with Flutter, Node.js, Express.js, and MongoDB. It allows users to explore rooms, check availability, book accommodations, upload payment receipts, and manage bookings. The system also includes dedicated dashboards for managers and admins to manage rooms, bookings, payments, discounts, FAQs, and platform policies.</p>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Key Features</h2>
  <ul>
    <li><b>User Authentication:</b> Secure signup and login with JWT authentication and role-based access.</li>
    <li><b>Guest Access:</b> Users can explore rooms without creating an account.</li>
    <li><b>Room Discovery:</b> Browse rooms by city, category, price, and availability.</li>
    <li><b>Smart Booking:</b> Prevents double booking using date-range conflict detection.</li>
    <li><b>Payment Upload:</b> Users can upload bank transfer receipts for verification.</li>
    <li><b>Manager Dashboard:</b> Managers can verify payments and manage bookings.</li>
    <li><b>Admin Dashboard:</b> Admins can manage users, rooms, hostels, bookings, discounts, FAQs, and terms.</li>
    <li><b>Refund Policy:</b> Automatic refund calculation based on cancellation time.</li>
  </ul>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Tech Stack</h2>
  <table>
    <tr>
      <th align="left">Layer</th>
      <th align="left">Technologies</th>
    </tr>
    <tr>
      <td><b>Frontend</b></td>
      <td>Flutter, Dart, Provider, HTTP, image_picker, table_calendar</td>
    </tr>
    <tr>
      <td><b>Backend</b></td>
      <td>Node.js, Express.js, REST API</td>
    </tr>
    <tr>
      <td><b>Database</b></td>
      <td>MongoDB, Mongoose</td>
    </tr>
    <tr>
      <td><b>Authentication</b></td>
      <td>JWT, bcryptjs, Role-Based Access Control</td>
    </tr>
  </table>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Application Modules</h2>
  <ul>
    <li><b>User Module:</b> Browse rooms, book stays, upload receipts, view booking history, and cancel bookings.</li>
    <li><b>Manager Module:</b> Verify payment receipts, confirm bookings, and manage room availability.</li>
    <li><b>Admin Module:</b> Manage users, hostels, rooms, discounts, FAQs, terms, and overall system data.</li>
    <li><b>Booking Module:</b> Handles booking creation, availability checking, cancellation, and status tracking.</li>
    <li><b>Payment Module:</b> Handles receipt uploads, payment status, and manager verification.</li>
  </ul>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Architecture</h2>
  <h3>Frontend</h3>
  <p>The Flutter frontend follows the <b>MVVM architecture</b> using Provider for state management.</p>
  <p><code>View → ViewModel → Service → Backend API</code></p>
  <h3>Backend</h3>
  <p>The backend follows an <b>MVC-based REST API structure</b> using Express.js and MongoDB.</p>
  <p><code>Routes → Controllers → Models → MongoDB</code></p>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Booking Flow</h2>
  <ol>
    <li>User selects city, room, and date range.</li>
    <li>System checks room availability.</li>
    <li>User confirms booking and proceeds to payment.</li>
    <li>User uploads payment receipt.</li>
    <li>Manager verifies the payment.</li>
    <li>Booking status is updated to confirmed.</li>
  </ol>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Refund Policy</h2>
  <table>
    <tr>
      <th align="left">Cancellation Time</th>
      <th align="left">Refund</th>
    </tr>
    <tr>
      <td>3 or more days before arrival</td>
      <td>100% Refund</td>
    </tr>
    <tr>
      <td>2 days before arrival</td>
      <td>50% Refund</td>
    </tr>
    <tr>
      <td>1 day before arrival</td>
      <td>No Refund</td>
    </tr>
  </table>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Project Structure</h2>
  <pre><code>basera/
├── lib/
│   ├── models/
│   ├── services/
│   ├── viewmodels/
│   ├── views/
│   └── core/
├── assets/
├── pubspec.yaml
└── README.md
basera-backend/
├── controllers/
├── models/
├── routes/
├── middleware/
├── server.js
└── package.json</code></pre>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Installation & Setup</h2>
  <h3>Frontend</h3>
  <pre><code>cd basera
flutter pub get
flutter run</code></pre>
  <h3>Backend</h3>
  <pre><code>cd basera-backend
npm install
npm run start</code></pre>
  <h3>Environment Variables</h3>
  <pre><code>MONGODB_URI=mongodb://localhost:27017/basera
JWT_SECRET=your_secret_key_here
PORT=5000</code></pre>
</div>
<div style="border:1px solid #ddd; border-radius:10px; padding:18px; margin-top:20px;">
  <h2>Main API Endpoints</h2>
  <table>
    <tr>
      <th align="left">Method</th>
      <th align="left">Endpoint</th>
      <th align="left">Description</th>
    </tr>
    <tr>
      <td>POST</td>
      <td><code>/api/auth/signup</code></td>
      <td>Register new user</td>
    </tr>
    <tr>
      <td>POST</td>
      <td><code>/api/auth/login</code></td>
      <td>User login</td>
    </tr>
    <tr>
      <td>GET</td>
      <td><code>/api/rooms</code></td>
      <td>Fetch rooms with filters</td>
    </tr>
    <tr>
      <td>POST</td>
      <td><code>/api/bookings</code></td>
      <td>Create new booking</td>
    </tr>
    <tr>
      <td>POST</td>
      <td><code>/api/payments</code></td>
      <td>Upload payment receipt</td>
    </tr>
    <tr>
      <td>POST</td>
      <td><code>/api/discounts/apply</code></td>
      <td>Apply discount code</td>
    </tr>
  </table>
</div>
