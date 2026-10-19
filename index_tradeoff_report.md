# Báo cáo đánh đổi chỉ mục

Kiểm thử ngày 19/10/2026 trên MySQL 9.4 với 100.000 bản ghi giả lập. Chỉ mục phủ năm cột chiếm 4.734.976 byte (4,52 MiB). Sau thay bằng idx_lean_search(sensor_id, recorded_at), dung lượng secondary index còn 2.637.824 byte (2,52 MiB), giảm khoảng 44,3%. Data_length giữ 5.783.552 byte. Đây là số liệu fixture, không phải kết quả của nhà máy thật.

EXPLAIN truy vấn sensor_id=105 và recorded_at từ 20/06/2026 chọn idx_lean_search, kiểu range; Extra là Using index condition. Chỉ mục mới đáp ứng điều kiện equality trước và range sau, nhưng không còn chứa temperature, humidity, status. MySQL cần truy cập clustered row qua khóa chính để lấy các giá trị này; chấp nhận thêm đọc để giảm kích thước cây và chi phí ghi.

Covering index vẫn phù hợp nếu truy vấn đọc áp đảo, latency nghiêm ngặt và bộ nhớ đủ lớn. Với luồng ghi liên tục, đưa mọi trường đo vào index làm tăng chi phí bảo trì, đặc biệt khi sửa giá trị. Không suy ra INSERT nhanh gấp năm từ thống kê dung lượng: cần benchmark cùng dữ liệu, batch, transaction và hardware.

Log ghi cả EXPLAIN trước/sau và snapshot storage bằng kết nối mới để tránh cache thống kê DDL. Chỉ mục mới giữ khóa chính tự mang theo của InnoDB; không ép UNIQUE lên cảm biến và thời gian.
