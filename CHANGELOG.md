# Changelog

## 1.1.0

- `meeting-summary`: tái sử dụng transcript đã có khi chạy lại cùng recording.
- `meeting-summary`: chỉ chạy Whisper khi chưa có transcript phù hợp hoặc khi ép `-ForceTranscribe`.
- `meeting-summary`: cho phép tạo lại `summary.md` nhanh sau khi thay đổi format tổng hợp.
- Giữ mục `Các việc cần làm`: chỉ liệt kê công việc, không gán người phụ trách, deadline hoặc phân rã chi tiết.

## 1.0.0

- Khởi tạo repository `AI-SKILLS` theo mô hình multi-skill.
- Thêm manifest quản lý danh mục skill.
- Thêm installer, updater và uninstaller dùng chung.
- Chuẩn hóa `meeting-summary` vào `skills/meeting-summary`.
- Tách dependency installer và runtime cleanup khỏi source của skill.
- Thêm quy chuẩn tạo skill mới và bảo vệ dữ liệu local/nhạy cảm.
