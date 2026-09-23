# Quy ước AI-SKILLS

## 1. Tên skill

- Dùng chữ thường và dấu `-`.
- Tên phải ngắn, rõ chức năng.
- Ví dụ: `meeting-summary`, `sql-review`, `release-note`.

## 2. Cấu trúc

Mỗi skill nằm tại:

```text
skills/<skill-name>/
```

File bắt buộc:

```text
SKILL.md
README.md
```

Chỉ tạo `scripts/`, `references/`, `templates/` khi thực sự cần.

## 3. Source of truth

Chỉ sửa source trong repository `AI-SKILLS`.

Không sửa trực tiếp bản đã được cài tại:

```text
%USERPROFILE%\.claude\skills\
```

## 4. Installer

- `tools/install.ps1`: quản lý cài skill.
- `tools/update.ps1`: cập nhật từ source trong repo.
- `tools/uninstall.ps1`: gỡ skill.
- `tools/installers/<skill-name>.ps1`: chỉ xử lý dependency riêng.
- `tools/uninstallers/<skill-name>.ps1`: chỉ cleanup tài nguyên riêng.

Không duplicate logic copy skill trong installer riêng.

## 5. Git

- Mỗi thay đổi đi qua branch và Pull Request.
- Không push trực tiếp `main`.
- Commit nhỏ, rõ nghĩa.
- Dùng `feat:`, `fix:`, `refactor:` phù hợp thay đổi.

## 6. Security

Không commit:

- API key, token, password, credential.
- `.env` thật.
- `.venv`, cache, `__pycache__`.
- database/index local.
- log, output sinh tự động.
- file cá nhân.

Trước commit phải kiểm tra `git status`.
