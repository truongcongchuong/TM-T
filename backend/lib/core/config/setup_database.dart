import 'database.dart';
import 'package:postgres/postgres.dart';

Future<String> setupDatabase() async {
  final Connection conn = await DatabaseConfig.connection();

  try {
    /* =========================
       STATUS DOMAIN
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS status_domain (
        id SERIAL PRIMARY KEY,
        code VARCHAR(30) UNIQUE NOT NULL
      );
    ''');

    /* =========================
       STATUS
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS status (
        id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        domain_id INTEGER REFERENCES status_domain(id) ON DELETE CASCADE,
        UNIQUE(name, domain_id)
      );
    ''');

    /* =========================
       ROLE
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS role (
        id SERIAL PRIMARY KEY,
        name VARCHAR(30) UNIQUE NOT NULL,
        description TEXT
      );
    ''');

    /* =========================
       USERS
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        phonenumber VARCHAR(15) UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        role INTEGER REFERENCES role(id),
        default_address TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status_id INTEGER REFERENCES status(id)
      );
    ''');

    /* =========================
       RESTAURANTS
    ========================== */
    // await conn.execute('''
    //   CREATE TABLE IF NOT EXISTS restaurants (
    //     id SERIAL PRIMARY KEY,
    //     owner INTEGER REFERENCES users(id) ON DELETE CASCADE,
    //     name VARCHAR(100) UNIQUE NOT NULL,
    //     address TEXT,
    //     latitude DECIMAL,
    //     longitude DECIMAL,
    //     is_open BOOLEAN DEFAULT TRUE,
    //     rating_avg FLOAT DEFAULT 0,
    //     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    //   );
    // ''');

    /* =========================
       CATEGORY (DÙNG CHUNG)
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS category (
        id SERIAL PRIMARY KEY,
        name VARCHAR(50) UNIQUE NOT NULL
      );
    ''');

    /* =========================
       FOODS
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS foods (
        id SERIAL PRIMARY KEY,
        restaurant_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        category_id INTEGER REFERENCES category(id),
        name VARCHAR(100) NOT NULL,
        description TEXT,
        price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
        image_url TEXT,
        rating_avg FLOAT DEFAULT 0,
        is_available BOOLEAN DEFAULT TRUE
      );
    ''');

    /* =========================
       BILLS
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS bills (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        status_id INTEGER REFERENCES status(id),
        address TEXT NOT NULL,
        phone_number VARCHAR(15) NOT NULL
      );
    ''');

    /* =========================
       DETAIL BILL
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS detail_bill (
        bill_id INTEGER REFERENCES bills(id) ON DELETE CASCADE,
        food_id INTEGER REFERENCES foods(id),
        quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
        PRIMARY KEY (bill_id, food_id)
      );
    ''');

    /* =========================
       PAYMENT METHOD
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS method_payment (
        id SERIAL PRIMARY KEY,
        name VARCHAR(30) UNIQUE NOT NULL
      );
    ''');

    /* =========================
       PAYMENTS
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id SERIAL PRIMARY KEY,
        bill_id INTEGER REFERENCES bills(id),
        method_id INTEGER REFERENCES method_payment(id),
        status_id INTEGER REFERENCES status(id),
        paid_at TIMESTAMP
      );
    ''');

    /* =========================
       REVIEWS
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS reviews (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        food_id INTEGER REFERENCES foods(id),
        rating INTEGER CHECK (rating BETWEEN 1 AND 5),
        comment TEXT,
        create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    /* =========================
       CARTS
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS carts (
        user_id INTEGER REFERENCES users(id),
        food_id INTEGER REFERENCES foods(id),
        quantity INTEGER NOT NULL DEFAULT 1,
        PRIMARY KEY (user_id, food_id)
      );
    ''');

    /* =========================
       ACTION
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS action (
        id SERIAL PRIMARY KEY,
        name VARCHAR(30) UNIQUE NOT NULL
      );
    ''');

    /* =========================
       USER FOOD LOG
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS user_food_log (
        id SERIAL PRIMARY KEY,
        user_id INTEGER REFERENCES users(id),
        food_id INTEGER REFERENCES foods(id),
        action_id INTEGER REFERENCES action(id),
        create_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');
        /* =========================
       NOTIFICATION TYPES
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS notification_types (
        id SERIAL PRIMARY KEY,
        code VARCHAR(50) UNIQUE NOT NULL,
        name VARCHAR(100) NOT NULL,
        description TEXT,
        is_active BOOLEAN DEFAULT TRUE
      );
    ''');

    /* =========================
       NOTIFICATIONS
    ========================== */
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id BIGSERIAL PRIMARY KEY,

        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        type_id INTEGER NOT NULL REFERENCES notification_types(id),

        title VARCHAR(255),
        body TEXT,
        payload JSONB,

        is_read BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    ''');

    /* =========================
       INDEX FOR PERFORMANCE
    ========================== */
    await conn.execute('''
      CREATE INDEX IF NOT EXISTS idx_notifications_user_created
      ON notifications(user_id, created_at DESC);
    ''');

    return "Database setup completed successfully.";

  } catch (e) {
    return "Error setting up database: $e";
  }
}
