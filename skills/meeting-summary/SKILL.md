---
name: meeting-summary
description: Chuyển file ghi âm/video cuộc họp tiếng Việt thành transcript local bằng faster-whisper và tạo bản tổng hợp nội dung, các kết luận đã chốt, các việc cần làm, vấn đề chưa chốt, chỉ đạo và thông tin kỹ thuật quan trọng.
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
5. Khi chạy lại cùng file nguồn và cùng `output_dir`, phải ưu tiên tái sử dụng `transcript.txt` đã có thay vì transcribe lại.
6. Không phụ thuộc thư mục hiện tại của Claude Code.
7. Không copy, sửa hoặc xóa file nguồn.
8. Không tạo file trong repository hiện tại; mọi output phải nằm dưới `output_dir`.

## Bước 1: Tái sử dụng transcript hoặc transcribe local

Chạy script PowerShell của skill:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_SKILL_DIR}\scripts\transcribe.ps1" -InputPath "<INPUT>" -OutputRoot "<OUTPUT>"
```

Thay `<INPUT>` và `<OUTPUT>` bằng hai đường dẫn đã xác định ở trên.

Script sẽ:

- kiểm tra file đầu vào;
- tìm transcript đã có của cùng file nguồn trong `output_dir`;
- ưu tiên đúng thư mục `<output_dir>\<tên-file>\transcript.txt`;
- nếu không có thư mục đúng tên thì tìm bản kết quả có timestamp mới nhất chứa `transcript.txt`;
- nếu tìm thấy transcript hợp lệ: tái sử dụng ngay, không chạy Whisper lại và trả `REUSED_TRANSCRIPT=true`;
- nếu chưa có transcript: tạo thư mục kết quả theo tên file nguồn;
- nếu cần tạo mới nhưng thư mục kết quả đã tồn tại thì tạo thư mục mới có timestamp để không ghi đè;
- dùng `faster-whisper` với model `large-v3`;
- ép ngôn ngữ `vi`;
- ưu tiên CUDA nếu dùng được, tự fallback CPU `int8` nếu CUDA lỗi;
- tạo `transcript.txt` trong thư mục kết quả;
- in ra các dòng `OUTPUT_DIR=...`, `TRANSCRIPT_PATH=...` và `REUSED_TRANSCRIPT=...` khi thành công.

Mặc định khi người dùng chỉ muốn tạo lại summary hoặc format summary thay đổi, phải dùng transcript sẵn có.
Chỉ khi người dùng nói rõ muốn nhận diện lại recording/transcribe lại từ đầu mới chạy script với thêm `-ForceTranscribe`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "${CLAUDE_SKILL_DIR}\scripts\transcribe.ps1" -InputPath "<INPUT>" -OutputRoot "<OUTPUT>" -ForceTranscribe
```

Nếu script thất bại: dừng, báo ngắn gọn lỗi thực tế. Không tạo summary từ transcript thiếu hoặc lỗi.

## Bước 2: Đọc transcript

Lấy chính xác `TRANSCRIPT_PATH` từ output của script, bất kể transcript vừa được tạo hay được tái sử dụng.

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

## Bước 3: Tạo `summary.md`

Tạo file `summary.md` trong chính `OUTPUT_DIR` mà script trả về.

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
- Đường dẫn `transcript.txt`.
- Đường dẫn `summary.md`.
