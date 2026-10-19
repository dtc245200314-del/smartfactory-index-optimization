# SmartFactory — cân bằng đọc/ghi (399)

Trong schema thực hành mới, chạy `01_fixture.sql` rồi `smartfactory_reindex.sql` bằng MySQL client. Sau đó mở kết nối mới, chạy `storage_snapshot.sql`. Fixture gồm 100.000 log, 1.000 cảm biến, timestamp, nhiệt độ, độ ẩm và ba trạng thái. Không DROP schema hay dữ liệu đang có. File fixture sẽ dừng nếu bảng đã tồn tại, tránh ghi đè dữ liệu.

Chỉ mục cũ `(sensor_id, recorded_at, temperature, humidity, status)` bao phủ SELECT nhưng chứa nhiều byte và phải duy trì các giá trị đo. Chỉ mục mới `(sensor_id, recorded_at)` giữ thứ tự equality trước, range sau; MySQL cần đọc clustered rows để lấy ba trường SELECT. Đây là đánh đổi thêm đọc với giảm storage và chi phí ghi. Một secondary index InnoDB còn mang theo khóa chính log_id.

`measurement.log` lưu kết quả thực MySQL 9.4 trên fixture, gồm storage trước/sau và EXPLAIN. Cần thấy `key=idx_lean_search`; EXPLAIN mới không còn `Using index` theo nghĩa covering vì SELECT cần lấy cột ngoài index. `Using index condition` là index condition pushdown, có ý nghĩa khác.

Không khẳng định INSERT nhanh gấp 5 hoặc index giảm 70% nếu chưa đo trên workload sản xuất. Số liệu phụ thuộc charset, giá trị status, tỷ lệ ghi, buffer pool và phân bố thời gian. Để đánh giá production, lấy latency p50/p95 của cùng batch INSERT, cùng dữ liệu/hardware và đối chiếu số hàng SELECT, kết quả và kế hoạch thực thi.

Index_length là thống kê dung lượng index, không phải cam kết file .ibd sẽ thu nhỏ ngay. Giữ PK; không thêm UNIQUE vì cảm biến có thể ghi nhiều mẫu trong cùng thời điểm.

Mã tự triển khai với Codex theo yêu cầu CodeGym, không dùng dữ liệu nhà máy thật.
