const Map<String, String> headers = {'Content-Type': 'application/json'};

// host và port của server
const String host = '0.0.0.0';
const int port = 8080;

// Cấu hình kết nối PostgreSQL
const String dbHost = 'localhost';
const int dbPort = 5432;
const String dbName = 'db_ordering_app';
const String dbUsername = 'postgres';
const String dbPassword = 'Danit@123';

const String secretKey = 'MY_SECRET_KEY';

// Đường dẫn lưu trữ file upload
const String uploadDirectory = r'D:\food_ordering_app\backend\public\image_foods';
