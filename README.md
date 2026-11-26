# OriginOS 5 Hidden Features Unlock (v2.0 + WebUI)

Module KernelSU / SukiSU / APatch / Magisk siêu nhẹ kèm **WebUI bật/tắt trực tiếp từng tính năng** giúp mở khóa **12 nhóm tính năng hệ thống chạy thật** bị ẩn trên **vivo / iQOO chạy OriginOS 5 (Android 15)** — đã dịch ngược kiểm chứng trực tiếp từ mã nguồn hệ thống trên **iQOO Z9 CN (`V2361A`, Locked Bootloader + Temp Root `late-load`)**.

> **An toàn tuyệt đối cho máy khóa Bootloader (Temp Root):** Không chạy tiến trình nền (zero daemon), không mount `/system` hay `/vendor`, không ghi phân vùng hệ thống, không chứa cờ ảo/placebo (đã loại bỏ hoàn toàn cờ blur `SurfaceFlinger` và chip rời MEMC không có trên máy), hỗ trợ đầy đủ `post-fs-data.sh`, `late-load.sh` và **WebUI offline**.

---

## 12 nhóm tính năng được mở khóa (bật/tắt độc lập trong WebUI)

| Nhóm | Tính năng | Thuộc tính / Cấu hình |
| :--- | :--- | :--- |
| **Pin & Sạc** | **Giới hạn % sạc pin (80–100%)** trong *Cài đặt › Pin › Tình trạng pin & Sạc* | `persist.vivo.charge_capacity_up_limit_support=1`<br>`persist.vivo.battery_charge_limit=1` |
| **Pin & Sạc** | **Sạc nhánh toàn cục & Ngắt sạc** | `persist.vivo.all_bypass_charge_support=1`<br>`persist.vivo.disable_charge_support=1` |
| **Pin & Sạc** | **Cảnh báo bảo vệ cổng sạc USB ẩm** | `persist.vivo.usb_wet_charge_limit_support=1` |
| **Màn hình & 144Hz** | **Mở trần 144Hz thật & Tùy chỉnh Hz từng app** (`custom_app_refresh_rate` + gỡ trần FPS game A15) | `persist.vivo.phone.fps_max=144`<br>`ro.vivo.user_refresh_rate_mode=true`<br>`persist.graphics.game_default_frame_rate.disabled=true`<br>`ro.surface_flinger.game_default_frame_rate_override=144` |
| **Màn hình & 144Hz** | **Full / Integration AOD & Nhạc trên AOD** | `ro.vivo.keyguard_full_aod.enable=1`, `persist.vivo.phone.smart_aod=1`<br>`vivo_integration_aod_enable=1`, `aod_show_music_switch=1` |
| **Màn hình & 144Hz** | **Full DC Dimming** | `persist.sys.dcdiming.en.vivo=1` |
| **Màn hình & 144Hz** | **5 mức Thu phóng màn hình** (thay vì 3 mức) | `persist.vivo.support.five_level_screen_zoom=true` |
| **Game & Camera** | **Cảm ứng Game chuyên sâu, Ổn định ảnh & Game Hi-Fi** | `ro.vivo.touch.game_para_adjust=1`<br>`persist.vivo.support.picture_stability_opt=true`<br>`persist.vivo.gamecube.hifi.support=1` |
| **Game & Camera** | **Thu âm mic Bluetooth TWS & Lưu ảnh Display P3** (Camera gốc) | `persist.vivo.Lea.tws_recording.enable=true`<br>`persist.vivo.camerap3.support=1` |
| **Âm thanh** | **Âm thanh độ trễ thấp & Hỗ trợ AirPods** | `persist.vivo.audio.feature.uselowlatency.enable=true`<br>`ro.vivo.support.airpods=true` |
| **Đa nhiệm** | **Ép chia đôi mọi app, Giữ chia đôi khi xoay ngang & Hiệu ứng chia đôi** | `persist.vivo.multiwindow_force=true`<br>`persist.vivo.multiwindow_rotatevalid=true`<br>`persist.vivo.multiwindow_split_switch_anim=1`, `splittofull_anim=1` |
| **Hệ thống** | **Chia sẻ riêng 1 ứng dụng & Extreme Performance Mode** (*Tùy chọn nhà phát triển*) | `persist.vivo.support.appshare=1`<br>`persist.vivo.feature.super_performance_support=1` |

---

## Cài đặt & Sử dụng WebUI

1. Tải file `OriginOS5_Hidden_Features_v2.0.zip` tại mục **[Releases](../../releases/latest)**.
2. Mở **KernelSU / SukiSU / APatch / Magisk → Module → Cài đặt từ bộ nhớ** và chọn file `.zip`.
3. **Soft Reboot** (Temp Root) hoặc **Khởi động lại máy** để áp dụng toàn bộ `ro.*` và `persist.*`.
4. Bấm nút **Mở (WebUI)** ngay trên thẻ module trong KernelSU / SukiSU / APatch / MMRL để bật/tắt riêng từng nhóm tính năng bất kỳ lúc nào (cấu hình lưu bền vững tại `/data/adb/originos5_hidden_features.conf`).

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
