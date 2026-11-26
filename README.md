# OriginOS 5 Hidden Features Unlock (v2.1.0 + WebUI)

Module KernelSU / SukiSU / APatch / Magisk siêu nhẹ kèm **WebUI bật/tắt độc lập từng tính năng và chỉ dẫn vị trí menu** giúp mở khóa **19 tính năng hệ thống 100% có phần cứng hỗ trợ** bị ẩn trên **vivo / iQOO chạy OriginOS 5 (Android 15)** — đã dịch ngược và kiểm chứng phần cứng trực tiếp trên **iQOO Z9 CN (`V2361A`, Locked Bootloader + Temp Root `late-load`)**.

> **An toàn tuyệt đối cho máy khóa Bootloader (Temp Root):** Không chạy tiến trình nền (zero daemon), không mount `/system` hay `/vendor`, không ghi phân vùng hệ thống, không chứa cờ ảo/thiếu phần cứng (đã loại bỏ cờ blur `SurfaceFlinger`, chip rời MEMC, DAC Hi-Fi rời và cảm biến ẩm Type-C không có trên Z9), hỗ trợ đầy đủ `post-fs-data.sh`, `late-load.sh` và **WebUI offline**.

---

## 19 tính năng độc lập trong WebUI (kèm vị trí menu)

| Nhóm | Tính năng | Vị trí trên OriginOS 5 | Thuộc tính / Cấu hình |
| :--- | :--- | :--- | :--- |
| **Pin & Sạc** | **Giới hạn % sạc pin (80–100%)** | *Cài đặt › Pin › Tình trạng pin & Sạc › Giới hạn sạc pin* | `persist.vivo.charge_capacity_up_limit_support=1`<br>`persist.vivo.battery_charge_limit=1` |
| **Pin & Sạc** | **Sạc nhánh toàn cục (Bypass Charge)** | *Thanh bên Game › Sạc nhánh* · *Cài đặt › Pin › Tình trạng pin & Sạc* | `persist.vivo.all_bypass_charge_support=1` |
| **Pin & Sạc** | **Ngắt sạc thủ công (Disable Charge)** | *Cài đặt › Pin › Tình trạng pin & Sạc* | `persist.vivo.disable_charge_support=1` |
| **Màn hình & AOD** | **Mở trần 144Hz & Gỡ giới hạn FPS game** | *Cài đặt › Màn hình & Độ sáng › Tốc độ làm mới màn hình* | `persist.vivo.phone.fps_max=144`<br>`persist.graphics.game_default_frame_rate.disabled=true`<br>`ro.surface_flinger.game_default_frame_rate_override=144` |
| **Màn hình & AOD** | **Tùy chỉnh tần số quét (Hz) từng app** | *Cài đặt › Màn hình & Độ sáng › Tốc độ làm mới › Tùy chỉnh từng ứng dụng* | `ro.vivo.user_refresh_rate_mode=true` |
| **Màn hình & AOD** | **Full / Integration AOD** | *Cài đặt › Màn hình khóa & Hình nền › Màn hình luôn bật (AOD)* | `ro.vivo.keyguard_full_aod.enable=1`<br>`persist.vivo.phone.smart_aod=1`, `vivo_integration_aod_enable=1` |
| **Màn hình & AOD** | **Điều khiển nhạc trên AOD** | *Cài đặt › Màn hình khóa & Hình nền › AOD › Trình phát nhạc* | `settings secure aod_show_music_switch=1` |
| **Màn hình & AOD** | **Full DC Dimming** | *Cài đặt › Màn hình & Độ sáng › Bảo vệ mắt / Giảm nhấp nháy* | `persist.sys.dcdiming.en.vivo=1` |
| **Màn hình & AOD** | **5 mức Thu phóng màn hình** | *Cài đặt › Màn hình & Độ sáng › Phông chữ & Kích thước hiển thị* | `persist.vivo.support.five_level_screen_zoom=true` |
| **Game & Camera** | **Cảm ứng Game chuyên sâu** | *Thanh bên Game (vuốt cạnh khi chơi) › Cài đặt cảm ứng* | `ro.vivo.touch.game_para_adjust=1` |
| **Game & Camera** | **Ổn định khung hình / ảnh khi chơi game** | *Thanh bên Game › Cài đặt hiển thị / Ổn định khung hình* | `persist.vivo.support.picture_stability_opt=true` |
| **Game & Camera** | **Thu âm mic Bluetooth TWS trong Camera** | *Camera gốc › Video › Cài đặt › Ghi âm qua tai nghe Bluetooth* | `persist.vivo.Lea.tws_recording.enable=true` |
| **Game & Camera** | **Chụp ảnh dải màu rộng Display P3** | *Camera gốc › Cài đặt › Lưu ảnh dải màu rộng P3* | `persist.vivo.camerap3.support=1` |
| **Âm thanh** | **Âm thanh độ trễ thấp** | Tự động áp dụng lớp hệ thống (Game / Tai nghe) | `persist.vivo.audio.feature.uselowlatency.enable=true` |
| **Âm thanh** | **Hỗ trợ AirPods** | *Cài đặt › Bluetooth & Thiết bị › cài đặt cạnh AirPods* | `ro.vivo.support.airpods=true` |
| **Đa nhiệm** | **Ép chia đôi mọi app & Giữ khi xoay ngang** | *Cài đặt › Lối tắt & Trợ năng › Chia đôi màn hình thông minh* | `persist.vivo.multiwindow_force=true`<br>`persist.vivo.multiwindow_rotatevalid=true` |
| **Đa nhiệm** | **Hiệu ứng chuyển cảnh chia đôi** | Tự động khi hoán đổi / kéo chia đôi sang toàn màn hình | `persist.vivo.multiwindow_split_switch_anim=1`<br>`persist.vivo.multiwindow_splittofull_anim=1` |
| **Hệ thống** | **Chia sẻ riêng 1 ứng dụng (App Share)** | *Trung tâm điều khiển › Chiếu/Ghi màn hình* · *Phản chiếu thông minh* | `persist.vivo.support.appshare=1` |
| **Hệ thống** | **Extreme Performance Mode** | *Cài đặt › Quản lý hệ thống › Tùy chọn nhà phát triển* | `persist.vivo.feature.super_performance_support=1` |

---

## Cài đặt & Sử dụng WebUI

1. Tải file `OriginOS5_Hidden_Features_v2.1.0.zip` tại mục **[Releases](../../releases/latest)**.
2. Mở **KernelSU / SukiSU / APatch / Magisk → Module → Cài đặt từ bộ nhớ** và chọn file `.zip`.
3. **Soft Reboot** (Temp Root) hoặc **Khởi động lại máy** để áp dụng toàn bộ `ro.*` và `persist.*`.
4. Bấm nút **Mở (WebUI)** ngay trên thẻ module trong KernelSU / SukiSU / APatch / MMRL để bật/tắt riêng từng tính năng bất kỳ lúc nào (cấu hình lưu bền vững tại `/data/adb/originos5_hidden_features.conf`, tự động kế thừa cấu hình cũ khi nâng cấp từ `v2.0`).

### Gỡ cài đặt
Gỡ module trong trình quản lý root → `uninstall.sh` tự động gọi `feature_ctl.sh reset` đưa toàn bộ thuộc tính (bao gồm `persist.vivo.phone.fps_max=120`) và `settings` về mặc định gốc.

---

## Tự build & Kiểm thử

```bash
sh tests/test_module.sh
bash build.sh
```

## License
MIT License — xem tệp [LICENSE](LICENSE).
