# meeting-summary

Skill dùng cho Claude Code trên Windows để xử lý recording cuộc họp tiếng Việt.

Skill transcribe audio/video bằng `faster-whisper` chạy local, sau đó Claude Code đọc toàn bộ transcript và tạo bản tổng hợp cuộc họp.

## Chức năng

- Nhận file audio/video cuộc họp.
- Transcribe tiếng Việt bằng `faster-whisper` với model `large-v3`.
- Ưu tiên CUDA và fallback CPU `int8` khi cần.
- **Tự tái sử dụng `transcript.txt` đã có**, không chạy Whisper lại khi chỉ cần cập nhật/tạo lại summary.
- Có tùy chọn `-ForceTranscribe` khi thực sự muốn nhận diện lại recording.
- Không ghi đè transcript khi tái sử dụng.
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

### Chạy lại sau khi đổi format summary

Cứ gọi lại cùng command:

```text
/meeting-summary "D:\Record\NPC Rent.mp4" "D:\Meeting-Summary"
```

Nếu đã có transcript phù hợp, skill sẽ:

```text
MP4
→ tìm transcript.txt đã có
→ bỏ qua Whisper
→ đọc lại transcript
→ tạo lại summary.md
```

Vì vậy thay đổi format summary không làm mất thêm thời gian transcription.

Nếu có nhiều thư mục kết quả cùng meeting, skill chọn transcript có thời gian sửa mới nhất.

### Muốn bắt buộc transcribe lại

Chỉ dùng khi recording thay đổi hoặc transcript cũ không đạt chất lượng. Skill sẽ gọi script với:

```powershell
-ForceTranscribe
```

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
