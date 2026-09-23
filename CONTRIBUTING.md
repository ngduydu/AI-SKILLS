# Contributing to AI-SKILLS

Cảm ơn bạn đã quan tâm đến AI-SKILLS.

Mục tiêu của repository là xây dựng các AI skill nhỏ, rõ ràng, có thể tái sử dụng và dễ cài ở user scope.

## Nguyên tắc đóng góp

Một skill tốt nên:

- Giải quyết một workflow thực tế và lặp lại.
- Có input/output rõ ràng.
- Không bắt người dùng phải hiểu implementation bên trong.
- Không duplicate một skill đã có nếu có thể mở rộng skill hiện tại.
- Chỉ thêm dependency khi thực sự cần.
- Không hard-code path, credential hoặc dữ liệu cá nhân.
- Có README đủ để người khác cài và dùng.

## Trước khi tạo Pull Request

Hãy kiểm tra:

1. Skill này giải quyết vấn đề gì?
2. Workflow có đủ tính lặp lại để đáng đóng gói thành skill không?
3. Có skill hiện tại nào có thể mở rộng thay vì tạo mới không?
4. Dependency mới có cần thiết không?
5. Skill có chạy được ngoài repository/project đã dùng để phát triển không?
6. Có dữ liệu local, secret, cache hoặc output sinh tự động bị đưa vào commit không?

## Cấu trúc skill

Source:

```text
skills/<skill-name>/
├── SKILL.md
├── README.md
└── scripts/        # chỉ khi cần
```

Dependency installer riêng:

```text
tools/installers/<skill-name>.ps1
```

Cleanup riêng:

```text
tools/uninstallers/<skill-name>.ps1
```

Mọi skill phải được khai báo trong:

```text
manifest.json
```

Chi tiết: `docs/creating-skills.md`.

## Pull Request

PR nên:

- Tập trung vào một mục tiêu chính.
- Mô tả rõ vấn đề và hành vi mong muốn.
- Không refactor phần không liên quan.
- Cập nhật README/CHANGELOG nếu thay đổi cách dùng.
- Giữ backward compatibility khi hợp lý.
- Có bằng chứng đã chạy/test workflow thực tế nếu skill có script.

## Security

Không commit:

- API key, token, password, credential.
- Recording, transcript hoặc output chứa dữ liệu thật.
- `.env` thật.
- virtual environment/model cache.
- database/index local.
- log/debug artifact.
- path cá nhân nếu không cần thiết.

Khi cần minh họa, dùng dữ liệu giả rõ ràng.

## Code of Conduct

Trao đổi kỹ thuật thẳng thắn nhưng tôn trọng nhau.

Phản biện implementation và thiết kế — không công kích cá nhân.
