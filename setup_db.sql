const sqlite3 = require('sqlite3').verbose();

const db = new sqlite3.Database('./restaurant.db', (err) => {
    if (err) {
        console.error('Error connecting to the database', err);
    } else {
        console.log('Connected to SQLite database');
    }
});

db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS Customers (
        customer_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        phone_number TEXT,
        email TEXT
    );`);

    db.run(`CREATE TABLE IF NOT EXISTS Reservations (
        reservation_id INTEGER PRIMARY KEY,
        customer_id INTEGER,
        table_number INTEGER,
        reservation_time TEXT,
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
    );`);

    db.run(`CREATE TABLE IF NOT EXISTS MenuItems (
        item_id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL,
        category TEXT
    );`);

    db.run(`CREATE TABLE IF NOT EXISTS Orders (
        order_id INTEGER PRIMARY KEY,
        customer_id INTEGER,
        item_id INTEGER,
        quantity INTEGER,
        order_time TEXT,
        FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
        FOREIGN KEY (item_id) REFERENCES MenuItems(item_id)
    );`);

    db.run(`INSERT INTO Customers (name, phone_number, email) VALUES
        ('John Doe', '555-1234', 'john@example.com'),
        ('Jane Smith', '555-5678', 'jane@example.com'),
        ('Alice Johnson', '555-2468', 'alice@example.com'),
        ('Bob Brown', '555-1357', 'bob@example.com'),
        ('Charlie Davis', '555-9876', 'charlie@example.com');`);

    db.run(`INSERT INTO MenuItems (name, price, category) VALUES
        ('Margherita Pizza', 10.99, 'Main Course'),
        ('Caesar Salad', 7.99, 'Appetizer'),
        ('Spaghetti Bolognese', 12.99, 'Main Course'),
        ('Garlic Bread', 4.99, 'Appetizer'),
        ('Tiramisu', 6.49, 'Dessert'),
        ('Grilled Chicken', 15.99, 'Main Course'),
        ('Minestrone Soup', 5.99, 'Appetizer'),
        ('Panna Cotta', 7.49, 'Dessert');`);

    db.run(`INSERT INTO Orders (customer_id, item_id, quantity, order_time) VALUES
        (1, 1, 2, '2023-10-01 12:00:00'),
        (2, 2, 1, '2023-10-02 13:30:00'),
        (3, 3, 1, '2023-10-03 18:45:00'),
        (4, 4, 3, '2023-10-04 19:15:00'),
        (5, 5, 2, '2023-10-05 20:00:00'),
        (1, 6, 1, '2023-10-06 12:30:00'),
        (3, 7, 1, '2023-10-07 14:00:00'),
        (4, 8, 1, '2023-10-08 15:30:00');`);

    db.run(`INSERT INTO Reservations (customer_id, table_number, reservation_time) VALUES
        (1, 5, '2023-10-05 19:00:00'),
        (2, 3, '2023-10-06 20:00:00'),
        (3, 4, '2023-10-07 18:00:00'),
        (4, 2, '2023-10-08 19:30:00'),
        (5, 6, '2023-10-09 21:00:00'),
        (1, 1, '2023-10-10 17:45:00'),
        (3, 7, '2023-10-11 18:15:00');`);

    console.log('Database setup complete with sample data.');
});

db.close();