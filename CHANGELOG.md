# Changelog

## 1.0.1

- `meeting-summary`: tái sử dụng transcript đã có khi chạy lại cùng recording và output, tránh chạy Whisper lại không cần thiết.
- `meeting-summary`: thêm chế độ force transcribe khi người dùng chủ động yêu cầu nhận diện lại recording.

## 1.0.0

- Khởi tạo repository `AI-SKILLS` theo mô hình multi-skill.
- Thêm manifest quản lý danh mục skill.
- Thêm installer, updater và uninstaller dùng chung.
- Chuẩn hóa `meeting-summary` vào `skills/meeting-summary`.
- Tách dependency installer và runtime cleanup khỏi source của skill.
- Thêm quy chuẩn tạo skill mới và bảo vệ dữ liệu local/nhạy cảm.
