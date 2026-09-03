# 🍔 Food Delivery App

## 📖 Giới thiệu

Food Delivery App là hệ thống đặt đồ ăn trực tuyến được xây dựng bằng **Flutter** và **Dart**, cho phép người dùng tìm kiếm món ăn, đặt hàng và theo dõi đơn hàng ngay trên thiết bị di động.

Hệ thống được thiết kế theo mô hình đa vai trò (Multi-Role System), bao gồm khách hàng và chủ nhà hàng. Mỗi vai trò được cung cấp các chức năng riêng nhằm tối ưu hóa quá trình quản lý và sử dụng dịch vụ.

Dự án được phát triển nhằm thực hành xây dựng ứng dụng di động hiện đại với Flutter, kết hợp Backend API sử dụng JWT Authentication, quản lý dữ liệu bằng PostgreSQL và triển khai các chức năng quản lý nhà hàng thực tế.

---

# 🎯 Mục tiêu dự án

- Xây dựng ứng dụng đặt đồ ăn hoàn chỉnh trên nền tảng Flutter.
- Áp dụng JWT Authentication vào hệ thống xác thực.
- Thực hành thiết kế cơ sở dữ liệu cho hệ thống thương mại điện tử.
- Xây dựng Dashboard thống kê cho chủ nhà hàng.
- Thực hành xử lý API, quản lý trạng thái và luồng dữ liệu.
- Nâng cao kỹ năng phát triển Fullstack Application.

---

# ✨ Chức năng chính

## 👤 Khách hàng

### Đăng ký và đăng nhập

- Đăng ký tài khoản.
- Đăng nhập bằng JWT Authentication.
- Quản lý phiên đăng nhập.
- Cập nhật thông tin cá nhân.

### Khám phá món ăn

- Xem danh sách món ăn.
- Tìm kiếm món ăn theo tên.
- Xem chi tiết món ăn.
- Xem thông tin nhà hàng.
- Xem đánh giá món ăn.

### Đặt hàng

- Thêm món ăn vào giỏ hàng.
- Tạo đơn hàng.
- Chọn địa chỉ giao hàng.
- Thanh toán đơn hàng.
- Theo dõi trạng thái đơn hàng.

### Quản lý đơn hàng

- Xem lịch sử đặt hàng.
- Xem chi tiết đơn hàng.
- Theo dõi trạng thái thanh toán.
- Theo dõi trạng thái giao hàng.

### Hồ sơ cá nhân

- Xem thông tin cá nhân.
- Cập nhật thông tin tài khoản.
- Quản lý địa chỉ giao hàng.

---

## 🏪 Chủ nhà hàng

### Quản lý món ăn

- Thêm món ăn mới.
- Chỉnh sửa thông tin món ăn.
- Xóa món ăn.
- Tìm kiếm món ăn.
- Quản lý tình trạng còn bán hoặc tạm ngừng bán.
- Upload hình ảnh món ăn.

### Quản lý đơn hàng

- Xem danh sách đơn hàng.
- Xem chi tiết đơn hàng.
- Cập nhật trạng thái đơn hàng.
- Cập nhật trạng thái thanh toán.
- Quản lý thông tin giao hàng.

### Quản lý nhà hàng

- Cập nhật thông tin nhà hàng.
- Quản lý địa chỉ.
- Quản lý trạng thái mở cửa.
- Quản lý vị trí địa lý (Latitude, Longitude).

### Dashboard Thống kê

Hệ thống Dashboard cung cấp các báo cáo trực quan giúp chủ nhà hàng theo dõi hoạt động kinh doanh:

#### Tổng quan doanh thu

- Tổng doanh thu.
- Tổng số sản phẩm đã bán.
- Tổng số khách hàng.
- Tổng số đơn hàng.

#### Thống kê doanh thu theo thời gian

- Theo giờ.
- Theo ngày.
- Theo tháng.

#### Thống kê đơn hàng

- Phân bố đơn hàng theo trạng thái.
- Thống kê số lượng đơn hàng theo thời gian.

#### Phân tích sản phẩm

- Top món ăn bán chạy.
- Doanh thu từng món ăn.
- Số lượng đơn hàng theo món ăn.

---

# 🔐 Xác thực và phân quyền

Hệ thống sử dụng JWT Authentication để bảo vệ API.

### Chức năng bảo mật

- Đăng nhập bằng JWT.
- Access Token.
- Refresh Token.
- Phân quyền theo vai trò.
- Bảo vệ các API quản trị.
- Kiểm tra quyền truy cập dữ liệu theo chủ sở hữu nhà hàng.

---

# 🏗 Kiến trúc hệ thống

```text
Flutter Mobile App
        │
        ▼
REST API
        │
        ▼
Authentication Layer (JWT)
        │
        ▼
Business Logic Layer
        │
        ▼
PostgreSQL Database
```

---

# 🛠 Công nghệ sử dụng

## Frontend

- Flutter
- Dart

## Backend

- Dart
- REST API
- JWT Authentication

## Database

- PostgreSQL

## Security

- JWT Access Token
- Refresh Token
- Role-Based Authorization

## Storage

- Upload và quản lý hình ảnh món ăn

---

# 📊 Các nghiệp vụ nổi bật

- Quản lý nhà hàng theo chủ sở hữu.
- Dashboard thống kê doanh thu theo thời gian.
- Thống kê đơn hàng theo trạng thái.
- Top món ăn bán chạy.
- Quản lý thanh toán.
- Quản lý lịch sử đơn hàng.
- Quản lý trạng thái giao hàng.
- Hệ thống tìm kiếm món ăn.

---

# 🚀 Hướng phát triển

- Tích hợp Google Maps.
- Tích hợp thanh toán trực tuyến.
- Gợi ý món ăn bằng AI.
- Hệ thống đánh giá và bình luận.
- Thông báo thời gian thực.
- Theo dõi đơn hàng trực tiếp.
- Chat giữa khách hàng và nhà hàng.
- Triển khai Docker và Cloud.

---