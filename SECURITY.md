# Security Policy

AI-SKILLS có thể chứa script được AI agent thực thi trên máy người dùng và một số skill có thể xử lý dữ liệu local. Vì vậy thay đổi trong repository cần được xem như code thực thi, không chỉ là prompt/documentation.

## Báo cáo vấn đề bảo mật

Không đăng công khai secret, credential, dữ liệu nội bộ hoặc recording/transcript thật để minh họa lỗi.

Nếu vấn đề có thể mô tả an toàn mà không tiết lộ dữ liệu nhạy cảm, hãy tạo issue với thông tin tối thiểu cần thiết.

Nếu cần trao đổi riêng, ưu tiên GitHub Security / private vulnerability reporting khi repository đã bật tính năng này.

## Phạm vi đáng báo cáo

Ví dụ:

- Skill/script có thể đọc hoặc gửi file ngoài phạm vi người dùng yêu cầu.
- Installer thực thi command không cần thiết hoặc nguy hiểm.
- Secret/token có thể bị log hoặc commit.
- Path handling cho phép ghi đè/xóa file ngoài output được chỉ định.
- Dependency installation có hành vi supply-chain đáng ngờ.
- Skill gửi dữ liệu local ra dịch vụ bên ngoài mà không được mô tả rõ.
- Prompt/skill khiến agent bỏ qua xác nhận cho thao tác phá hoại.

## Quyền riêng tư

Không commit vào repository:

- recording cuộc họp;
- transcript;
- summary sinh từ dữ liệu thật;
- log chứa nội dung người dùng;
- credential;
- cache/model/runtime local.

Ví dụ `meeting-summary` thực hiện speech-to-text local bằng `faster-whisper`. Sau đó transcript được Claude Code đọc để tạo summary; người dùng cần áp dụng chính sách dữ liệu phù hợp với tài khoản và tổ chức của mình.

## Dependency

Repository không vendor model Whisper hoặc runtime Python vào Git.

Dependency được cài qua installer và nên được cập nhật/thẩm định định kỳ.

## Nguyên tắc contributor

- Không hard-code secret.
- Không thêm telemetry ngầm.
- Không upload dữ liệu người dùng nếu skill không mô tả rõ hành vi đó.
- Không mở rộng quyền truy cập file/network quá mức cần thiết.
- Giữ output trong phạm vi người dùng đã chỉ định.
