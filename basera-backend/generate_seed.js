const fs = require('fs');

const generateSeedData = () => {
    const data = {
        users: [
            { name: "John Doe", email: "john@example.com", password: "encrypted_pwd_here", role: "user" },
            { name: "Admin Sam", email: "admin@example.com", password: "encrypted_pwd_here", role: "admin" },
            { name: "Manager Ali", email: "ali@example.com", password: "encrypted_pwd_here", role: "manager" }
        ],
        rooms: [],
        discounts: [
            { code: "SUMMER10", type: "percentage", value: 10, validUntil: "2026-12-31T23:59:59.000Z", isActive: true },
            { code: "FLAT50", type: "flat", value: 50, validUntil: "2026-12-31T23:59:59.000Z", isActive: true },
            { code: "WINTERVIBES", type: "percentage", value: 15, validUntil: "2026-12-31T23:59:59.000Z", isActive: true }
        ],
        cities: ["Kaghan", "Shogran"]
    };

    // Generate 42 rooms
    const categories = ['Basic', 'Deluxe', 'VIP'];
    const configs = ['1-bed', '2-bed', 'Family Suite'];
    
    // We will distribute 21 in Kaghan, 21 in Shogran
    let i = 1;
    for (const city of data.cities) {
        for (let j = 0; j < 21; j++) {
            const cat = categories[j % 3];
            const conf = configs[j % 3];
            const bedsCount = conf === '1-bed' ? 1 : conf === '2-bed' ? 2 : 4;
            let price = cat === 'Basic' ? 50 : cat === 'Deluxe' ? 100 : 200;
            if(bedsCount > 1) price += (bedsCount-1)*20;

            const room = {
                title: `${city} ${cat} Room ${j + 1}`,
                city: city,
                category: cat,
                config: conf,
                beds: bedsCount,
                pricePerNight: price,
                isAvailable: true,
                description: `A lovely ${cat} room in ${city} with ${conf}.`,
                imageUrl: `https://via.placeholder.com/400x250?text=${city}+${cat}`
            };
            data.rooms.push(room);
            i++;
        }
    }

    fs.writeFileSync('seed_data.json', JSON.stringify(data, null, 2));
    console.log("Seed data generated to seed_data.json");
};

generateSeedData();
