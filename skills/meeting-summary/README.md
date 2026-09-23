# meeting-summary

Skill dùng cho Claude Code trên Windows để xử lý recording cuộc họp tiếng Việt.

Skill transcribe audio/video bằng `faster-whisper` chạy local, sau đó Claude Code đọc toàn bộ transcript và tạo bản tổng hợp cuộc họp.

## Chức năng

- Nhận file audio/video cuộc họp.
- Transcribe tiếng Việt bằng `faster-whisper` với model `large-v3`.
- Ưu tiên CUDA và fallback CPU `int8` khi cần.
- Không ghi đè transcript khi phải transcribe mới.
- Khi chạy lại cùng recording + output, tự dùng lại `transcript.txt` đã có để tạo lại summary, không chạy Whisper lại.
- Có thể ép transcribe lại khi thật sự cần.
- Tạo `transcript.txt`.
- Tạo `summary.md` theo format chuẩn của skill.
- Có mục `Các việc cần làm`, chỉ ghi công việc, không gán người phụ trách hoặc tự phân rã chi tiết.

## Input

Hỗ trợ:

```text
.mp4
.mkv
.mov
.webm
.mp3
.wav
.m4a
```

Skill nhận:

```text
<input-path> <output-directory>
```

## Sử dụng

```text
/meeting-summary "D:\Record\NPC Rent.mp4" "D:\Meeting-Summary"
```

Ví dụ output:

```text
D:\Meeting-Summary\NPC Rent\
├── transcript.txt
└── summary.md
```

Nếu transcript của cùng recording đã tồn tại trong output, skill tái sử dụng transcript đó và chỉ tạo lại `summary.md`.

Nếu chưa có transcript nhưng thư mục cùng tên đã tồn tại, skill tạo thư mục mới có timestamp thay vì ghi đè.

Chỉ khi người dùng yêu cầu nhận diện lại recording từ đầu, skill mới bỏ qua transcript cũ và chạy Whisper lại.

## Dependency

Runtime của skill được quản lý bởi installer của repository `AI-SKILLS`:

- `uv`
- Python 3.12
- `faster-whisper`

Runtime local được đặt tại:

```text
%USERPROFILE%\.claude\tools\meeting-summary\
```

Không commit runtime này vào Git.

## Source of truth

Source chuẩn của skill nằm tại:

```text
AI-SKILLS\skills\meeting-summary\
```

Không chỉnh sửa trực tiếp bản đã cài trong:

```text
%USERPROFILE%\.claude\skills\meeting-summary\
```

Mọi thay đổi phải sửa trong repository `AI-SKILLS`, sau đó chạy công cụ update của repository.
