# Quy chuẩn thêm Skill mới

Đây là file bắt buộc phải đọc trước khi thêm hoặc sửa skill trong `AI-SKILLS`.

Mục tiêu: skill đặt đúng chỗ, cài được, test được, commit được và không mang file local/nhạy cảm lên Git.

## 1. Cấu trúc chuẩn

```text
AI-SKILLS/
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md
│       ├── README.md
│       ├── scripts/        # tùy chọn
│       ├── references/     # tùy chọn
│       └── templates/      # tùy chọn
├── tools/
│   ├── install.ps1
│   ├── update.ps1
│   ├── uninstall.ps1
│   ├── installers/
│   │   └── <skill-name>.ps1       # tùy chọn
│   └── uninstallers/
│       └── <skill-name>.ps1       # tùy chọn
└── manifest.json
```

Không tạo folder rỗng.

Không tạo nested thừa như:

```text
skills/<skill-name>/skill/<skill-name>/
```

## 2. Source of truth

Source chuẩn luôn nằm tại:

```text
skills/<skill-name>/
```

Không sửa trực tiếp:

```text
%USERPROFILE%\.claude\skills\<skill-name>\
```

Luồng đúng:

```text
Sửa trong repo
→ install/update
→ test
→ commit
```

## 3. File bắt buộc

Mỗi skill phải có:

```text
skills/<skill-name>/SKILL.md
skills/<skill-name>/README.md
```

`SKILL.md` phải đủ:

- Mục đích.
- Khi nào dùng.
- Input.
- Cách xử lý.
- Output.
- Quy tắc bắt buộc.
- Script/reference liên quan nếu có.

`README.md` chỉ mô tả skill và cách sử dụng.

## 4. Script của skill

Script skill trực tiếp gọi đặt tại:

```text
skills/<skill-name>/scripts/
```

Không đưa vào source:

```text
.venv/
venv/
__pycache__/
*.pyc
*.log
cache/
tmp/
*.db
*.sqlite
```

## 5. Dependency riêng

Nếu skill cần runtime/tool riêng, tạo:

```text
tools/installers/<skill-name>.ps1
```

File này chỉ cài/kiểm tra dependency.

Nó không copy skill vào `.claude`.

Việc copy skill thuộc:

```text
tools/install.ps1
```

Nếu không có dependency riêng thì không tạo installer riêng.

## 6. Cleanup riêng

Chỉ tạo:

```text
tools/uninstallers/<skill-name>.ps1
```

nếu skill tạo thêm runtime/data ngoài thư mục skill.

Nếu không có thì bỏ.

## 7. manifest.json

Mọi skill phải được khai báo.

Ví dụ đơn giản:

```json
{
  "name": "sql-review",
  "path": "skills/sql-review",
  "targets": ["claude"]
}
```

Có dependency riêng:

```json
{
  "name": "meeting-summary",
  "path": "skills/meeting-summary",
  "targets": ["claude"],
  "installer": "tools/installers/meeting-summary.ps1",
  "uninstaller": "tools/uninstallers/meeting-summary.ps1"
}
```

Không khai báo file không tồn tại.

## 8. Install và update

Cài:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install.ps1 -Skill <skill-name>
```

Sau khi sửa:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\update.ps1 -Skill <skill-name>
```

Kiểm tra bản cài tại:

```text
%USERPROFILE%\.claude\skills\<skill-name>\
```

Phải test chạy thực tế trước khi commit.

## 9. Security

Tuyệt đối không commit:

```text
.env
.venv/
__pycache__/
*.pyc
*.log
*.db
*.sqlite
credentials.json
auth.json
*.key
*.pem
*.pfx
secrets/
cache/
tmp/
private/
personal/
```

Không hard-code:

- API key.
- Token.
- Password.
- Connection string thật.
- Credential.
- Path cá nhân không cần thiết.

Cấu hình mẫu dùng:

```text
.env.example
```

và không chứa giá trị thật.

## 10. Skill lấy từ bên ngoài

Không copy nguyên package vào repo.

Chuẩn hóa như sau:

```text
Nội dung skill
→ skills/<skill-name>/

Dependency
→ tools/installers/<skill-name>.ps1

Cleanup riêng
→ tools/uninstallers/<skill-name>.ps1
```

Không giữ nested folder hoặc installer package cũ nếu không cần.

## 11. Checklist DONE

Trước khi commit phải PASS:

- [ ] Skill nằm đúng `skills/<skill-name>/`.
- [ ] Có `SKILL.md`.
- [ ] Có `README.md`.
- [ ] Không có folder lồng thừa.
- [ ] `manifest.json` đã cập nhật.
- [ ] Dependency riêng đặt đúng chỗ.
- [ ] Không có secret/cache/venv/log.
- [ ] Install/update chạy được.
- [ ] Skill chạy được thực tế.
- [ ] `git status` chỉ có file cần commit.

## 12. Quy tắc cho Claude/AI

Khi được yêu cầu thêm hoặc sửa skill:

1. Đọc file này.
2. Kiểm tra cấu trúc repo và `manifest.json`.
3. Đặt source vào `skills/<skill-name>/`.
4. Chỉ tạo installer/uninstaller riêng khi thật sự cần.
5. Không sửa trực tiếp `%USERPROFILE%\.claude`.
6. Không tạo kiến trúc mới nếu cấu trúc hiện tại đã đáp ứng.
7. Test bằng installer/update chung.
8. Kiểm tra `git status`.
9. Báo rõ file đã thêm/sửa.

Không tự ý:

- tạo repo riêng cho skill nhỏ
- tạo nested `skill/<skill-name>`
- commit runtime/cache/secret
- duplicate dependency dùng chung
- thay đổi kiến trúc chung chỉ để phục vụ một skill

## 13. Nhớ nhanh

```text
Skill
→ skills/<skill-name>/

Dependency
→ tools/installers/<skill-name>.ps1

Cleanup
→ tools/uninstallers/<skill-name>.ps1

Danh sách skill
→ manifest.json

Cài
→ tools/install.ps1

Update
→ tools/update.ps1
```
