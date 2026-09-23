# AI-SKILLS

Kho skill AI có thể tái sử dụng, hiện tập trung vào **Claude Code**.

Repository này là **source of truth** cho các skill. Skill được quản lý trong Git, cài vào user scope và có thể dùng ở nhiều project mà không phải copy thủ công từng repo.

## Skill hiện có

| Skill | Mục đích | Target |
|---|---|---|
| `meeting-summary` | Chuyển recording cuộc họp tiếng Việt thành transcript local và tổng hợp nội dung, quyết định, việc cần làm | Claude Code |

## Cài nhanh

### 1. Clone repository

```powershell
git clone https://github.com/ngduydu/AI-SKILLS.git
cd AI-SKILLS
```

### 2. Chuẩn bị dependency

Hiện `meeting-summary` cần `uv`.

Kiểm tra:

```powershell
uv --version
```

Nếu chưa có `uv`, cài theo hướng dẫn chính thức của Astral rồi chạy lại installer.

### 3. Cài toàn bộ skill

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install.ps1
```

Skill được cài vào user scope:

```text
%USERPROFILE%\.claude\skills\
```

Vì vậy Claude Code có thể gọi skill ở bất kỳ project/folder nào.

## Cài một skill

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install.ps1 -Skill meeting-summary
```

## Update

Sau khi pull source mới:

```powershell
git pull
powershell -ExecutionPolicy Bypass -File .\tools\update.ps1
```

Update một skill:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\update.ps1 -Skill meeting-summary
```

## Gỡ skill

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\uninstall.ps1 -Skill meeting-summary
```

Nếu không truyền `-Skill`, script sẽ gỡ toàn bộ skill được khai báo trong `manifest.json`.

## Ví dụ: meeting-summary

```text
/meeting-summary "D:\Record\NPC Rent.mp4" "D:\Meeting-Summary"
```

Kết quả:

```text
D:\Meeting-Summary\NPC Rent\
├── transcript.txt
└── summary.md
```

Nếu transcript của recording đó đã tồn tại, skill sẽ **tái sử dụng transcript** và chỉ tạo lại `summary.md`; không chạy Whisper lại trừ khi người dùng chủ động yêu cầu transcribe lại.

Chi tiết: `skills/meeting-summary/README.md`.

## Cấu trúc repository

```text
AI-SKILLS/
├── skills/                 # Source của từng skill
├── tools/                  # Install / update / uninstall
│   ├── installers/         # Dependency installer riêng từng skill
│   └── uninstallers/       # Cleanup riêng từng skill
├── docs/                   # Quy chuẩn phát triển skill
├── manifest.json           # Danh mục skill
├── CHANGELOG.md
├── CONTRIBUTING.md
├── SECURITY.md
└── LICENSE
```

## Thêm skill mới

Đọc trước:

```text
docs/creating-skills.md
docs/conventions.md
```

Quy chuẩn:

```text
Nội dung skill       -> skills/<skill-name>/
Dependency riêng     -> tools/installers/<skill-name>.ps1
Cleanup riêng        -> tools/uninstallers/<skill-name>.ps1
Danh mục skill       -> manifest.json
```

Không tạo nested folder kiểu:

```text
skills/<skill-name>/skill/<skill-name>/
```

## Nguyên tắc

- Mỗi skill giải quyết một workflow lặp lại có giá trị tái sử dụng.
- Ưu tiên input/output đơn giản; ẩn complexity kỹ thuật phía dưới.
- Không phụ thuộc project hiện tại nếu skill được thiết kế cho user scope.
- Không commit runtime, model cache, log, transcript, recording hoặc output của người dùng.
- Không commit secret, token, credential hoặc dữ liệu nội bộ.
- Thay đổi đi qua branch và Pull Request.

## Bảo mật và quyền riêng tư

Một số skill có thể xử lý dữ liệu local. Ví dụ `meeting-summary` chạy speech-to-text bằng `faster-whisper` local trước khi Claude đọc transcript để tạo summary.

Người dùng cần tự đánh giá dữ liệu nào phù hợp để đưa cho AI agent theo chính sách của tổ chức mình.

Xem thêm: `SECURITY.md`.

## Đóng góp

Pull Request và issue được hoan nghênh.

Xem: `CONTRIBUTING.md`.

## License

MIT — xem `LICENSE`.
