---
name: meeting-summary
description: Chuyển file ghi âm/video cuộc họp tiếng Việt thành transcript local bằng faster-whisper và tạo bản tổng hợp nội dung, các kết luận đã chốt, các việc cần làm, vấn đề chưa chốt, chỉ đạo và thông tin kỹ thuật quan trọng. Tự tái sử dụng transcript đã có để không chạy Whisper lại khi chỉ cần tạo lại summary.
argument-hint: '"<input-path>" "<output-directory>"'
arguments:
  - input_path
  - output_dir
disable-model-invocation: true
shell: powershell
---

# Meeting Summary

Skill này chỉ chạy khi người dùng gọi `/meeting-summary`.

## Tham số

- Input đã truyền: `$input_path`
- Output đã truyền: `$output_dir`

Quy tắc nhận tham số:

1. Nếu `input_path` trống, hỏi người dùng đường dẫn tuyệt đối tới file video/audio.
2. Nếu `output_dir` trống, hỏi người dùng thư mục gốc muốn lưu kết quả.
3. Chỉ bắt đầu xử lý khi có đủ cả hai giá trị.
4. Hỗ trợ: `.mp4`, `.mkv`, `.mov`, `.webm`, `.mp3`, `.wav`, `.m4a`.
5. Không phụ thuộc thư mục hiện tại của Claude Code.
6. Không copy, sửa hoặc xóa file nguồn.
7. Không tạo file trong repository hiện tại; mọi output phải nằm dưới `output_dir`.

## Bước 1: Lấy transcript

Chạy script PowerShell của skill:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_SKILL_DIR}\scripts\transcribe.ps1" -InputPath "<INPUT>" -OutputRoot "<OUTPUT>"
```

Thay `<INPUT>` và `<OUTPUT>` bằng hai đường dẫn đã xác định ở trên.

Script sẽ ưu tiên **tái sử dụng transcript đã có**:

1. Từ tên file nguồn, tìm các thư mục kết quả tương ứng dưới `output_dir`.
2. Nếu tìm thấy `transcript.txt`, chọn transcript mới nhất.
3. Trả về ngay `OUTPUT_DIR` và `TRANSCRIPT_PATH`.
4. **Không chạy Whisper lại.**
5. Nếu chưa có transcript phù hợp thì mới chạy transcription local như bình thường.

Khi tái sử dụng transcript, output sẽ có:

```text
REUSED_TRANSCRIPT=1
OUTPUT_DIR=...
TRANSCRIPT_PATH=...
```

Khi chưa có transcript, script sẽ:

- kiểm tra file đầu vào;
- tạo thư mục kết quả theo tên file nguồn;
- nếu thư mục kết quả đã tồn tại thì tạo thư mục mới có timestamp để không ghi đè;
- dùng `faster-whisper` với model `large-v3`;
- ép ngôn ngữ `vi`;
- ưu tiên CUDA nếu dùng được, tự fallback CPU `int8` nếu CUDA lỗi;
- tạo `transcript.txt` trong thư mục kết quả;
- in ra các dòng `OUTPUT_DIR=...` và `TRANSCRIPT_PATH=...` khi thành công.

Chỉ khi người dùng **chủ động yêu cầu nhận diện lại từ recording**, mới gọi script với `-ForceTranscribe`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_SKILL_DIR}\scripts\transcribe.ps1" -InputPath "<INPUT>" -OutputRoot "<OUTPUT>" -ForceTranscribe
```

Nếu script thất bại: dừng, báo ngắn gọn lỗi thực tế. Không tạo summary từ transcript thiếu hoặc lỗi.

## Bước 2: Đọc transcript

Lấy chính xác `TRANSCRIPT_PATH` từ output của script.

Đọc TOÀN BỘ transcript trước khi viết summary. Nếu file dài, đọc tuần tự theo nhiều phần cho đến hết. Không chỉ dựa trên đoạn đầu hoặc một vài đoạn tìm kiếm.

Không cần phân tích ai nói câu nào. Tập trung vào:

- cuộc họp đang bàn nội dung gì;
- các vấn đề chính;
- phương án/hướng xử lý được bàn;
- nội dung nào thực sự đã chốt;
- các công việc/việc cần làm được nêu ra hoặc thống nhất từ cuộc họp;
- nội dung nào vẫn chưa chốt;
- yêu cầu/chỉ đạo quan trọng;
- thông tin kỹ thuật quan trọng nếu có.

## Bước 3: Tạo hoặc cập nhật `summary.md`

Tạo hoặc ghi lại file `summary.md` trong chính `OUTPUT_DIR` mà script trả về.

Nếu đang tái sử dụng transcript thì **chỉ tạo lại summary**, không đụng vào `transcript.txt`.

Nội dung phải hoàn toàn bằng tiếng Việt và dùng đúng cấu trúc sau:

```markdown
# TỔNG HỢP CUỘC HỌP

## 1. Thông tin cuộc họp

- File nguồn: `<tên file>`
- Thời lượng: `<thời lượng nếu xác định được>`
- Ngôn ngữ: Tiếng Việt

## 2. Tóm tắt cuộc họp

Tóm tắt ngắn gọn toàn bộ cuộc họp trong khoảng 5-10 dòng, tập trung vào nội dung chính, vấn đề chính, hướng xử lý và kết quả quan trọng.

## 3. Nội dung trao đổi chi tiết

Chia theo các chủ đề thực tế xuất hiện trong cuộc họp.

### 3.1. <Tên chủ đề>

**Vấn đề**

- ...

**Nội dung trao đổi**

- ...

**Phương án / đề xuất**

- ...

**Kết luận**

- ...

## 4. Nội dung đã thống nhất / quyết định

- ...

Chỉ ghi những nội dung thực sự đã được chốt trong transcript.

## 5. Các việc cần làm

- ...

Chỉ liệt kê các công việc/việc cần thực hiện được nêu ra hoặc có thể xác định rõ từ kết luận của cuộc họp.
Không ghi người phụ trách, deadline hoặc phân rã chi tiết cách thực hiện ở mục này.
Không tự suy diễn thêm công việc không có căn cứ trong transcript.

## 6. Vấn đề chưa chốt / cần trao đổi tiếp

- ...

## 7. Yêu cầu / chỉ đạo quan trọng

- ...

## 8. Thông tin kỹ thuật quan trọng

Chỉ tạo các mục con thực sự có nội dung, ví dụ:

### Hệ thống / Project
- ...

### Module / Chức năng
- ...

### API
- ...

### Database / SQL / Stored Procedure
- ...

### Task / Bug
- ...

### Số liệu / Mốc thời gian
- ...

## 9. Điểm cần lưu ý

- ...
```

## Nguyên tắc tổng hợp bắt buộc

- Mục tiêu là biết cuộc họp đã nói gì và chốt gì; không viết thành bản chép lời.
- Không tách nội dung theo từng người nói nếu không thực sự cần thiết để hiểu kết luận.
- Không tự bịa hoặc suy diễn thông tin không có trong transcript.
- Không biến đề xuất thành quyết định.
- Không biến câu hỏi thành kết luận.
- Phân biệt rõ nội dung đang thảo luận và nội dung đã thống nhất.
- Nếu một chủ đề được nhắc ngắn nhưng có ý nghĩa thì vẫn phải ghi nhận.
- Nếu mục nào không có dữ liệu thì ghi ngắn gọn `Không có nội dung được xác định rõ.` hoặc bỏ các mục con tùy chọn ở phần 8; không tự bổ sung.
- Ở mục "Các việc cần làm", chỉ ghi tên/nội dung công việc ở mức đủ để biết cần làm gì; không ghi người phụ trách, deadline, phân công hoặc phân rã chi tiết.
- Không tạo mục "Tóm tắt báo cáo cấp trên".
- Không tạo mục "Nội dung cần kiểm tra lại từ recording".

## Hoàn tất

Sau khi ghi `summary.md`, chỉ báo ngắn gọn:

- Đã hoàn tất.
- Transcript được tạo mới hay tái sử dụng.
- Đường dẫn `transcript.txt`.
- Đường dẫn `summary.md`.
