# AI-SKILLS

Repository private dùng để quản lý các AI skill dùng chung của team.

Repository này là **source of truth**. Không chỉnh sửa trực tiếp skill đã được cài trong thư mục user của AI agent.

Hiện tại target được hỗ trợ là Claude Code.

## Cấu trúc

```text
AI-SKILLS/
├── skills/                 # Source của từng skill
├── tools/                  # Install / update / uninstall
│   ├── installers/         # Dependency installer riêng từng skill
│   └── uninstallers/       # Cleanup riêng từng skill
├── docs/                   # Quy chuẩn phát triển skill
├── manifest.json           # Danh mục skill
├── CHANGELOG.md
└── .gitignore
```

## Cài toàn bộ skill

Mở PowerShell tại root repository:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install.ps1
```

## Cài một skill

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\install.ps1 -Skill meeting-summary
```

## Update toàn bộ skill

Sau khi `git pull`:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\update.ps1
```

Update một skill:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\update.ps1 -Skill meeting-summary
```

## Gỡ một skill

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\uninstall.ps1 -Skill meeting-summary
```

Nếu không truyền `-Skill`, lệnh uninstall sẽ gỡ toàn bộ skill được khai báo trong `manifest.json`.

## Thêm skill mới

Bắt buộc đọc trước:

```text
docs/creating-skills.md
```

Quy chuẩn chung:

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

## Git và dữ liệu nhạy cảm

Trước khi commit luôn kiểm tra:

```powershell
git status
git add .
git status
```

Không commit secret, token, credential, `.env`, virtual environment, cache, database local, log hoặc output sinh tự động.
