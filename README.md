# OriginOS 5 Hidden Features Unlock

Module KernelSU / SukiSU / APatch / Magisk siêu nhẹ giúp mở khóa các tính năng hệ thống bị ẩn trên **vivo / iQOO chạy OriginOS 5 (Android 15)** — được kiểm chứng thực tế trên **iQOO Z9 CN (`V2361A`, Locked Bootloader + Temp Root `late-load`)**.

> **An toàn tuyệt đối cho máy khóa Bootloader (Temp Root):** Không chạy tiến trình nền (zero daemon), không mount `/system` hay `/vendor`, không ghi phân vùng hệ thống, hỗ trợ đầy đủ cả `post-fs-data.sh` lẫn `late-load.sh`.

---

## Tính năng được mở khóa (đều đã kiểm chứng hoạt động thật)

| Nhóm | Tính năng | Thuộc tính / Cấu hình |
| :--- | :--- | :--- |
| **Pin & Sạc** | Giới hạn % sạc pin gốc (`80% / 85% / 90% / 95% / 100%`) trong *Cài đặt › Pin › Tình trạng pin & Sạc* (lưu bền vững qua cả reboot) | `persist.vivo.charge_capacity_up_limit_support=1`<br>`persist.vivo.battery_charge_limit=1` |
| **Pin & Sạc** | Sạc nhánh toàn cục & Ngắt sạc (Bypass / Disable Charge) | `persist.vivo.all_bypass_charge_support=1`<br>`persist.vivo.disable_charge_support=1` |
| **Màn hình AOD** | Full / Integration AOD & công tắc hiển thị nhạc trên AOD | `ro.vivo.keyguard_full_aod.enable=1`<br>`persist.vivo.phone.smart_aod=1`<br>`vivo_integration_aod_enable=1`, `aod_show_music_switch=1` |
| **Hiển thị & Âm thanh** | Full DC Dimming & Âm thanh độ trễ thấp (Low-Latency Audio) | `persist.sys.dcdiming.en.vivo=1`<br>`persist.vivo.audio.feature.uselowlatency.enable=true` |
| **Game & Đa nhiệm** | Gỡ trần FPS mặc định Android 15 (Game Override 144Hz) & Hiệu ứng chia đôi màn hình | `persist.graphics.game_default_frame_rate.disabled=true`<br>`ro.surface_flinger.game_default_frame_rate_override=144`<br>`persist.vivo.multiwindow_split_switch_anim=1`<br>`persist.vivo.multiwindow_splittofull_anim=1` |

### Tại sao KHÔNG đưa các cờ làm mờ kính (Real-time Blur) vào module này?
Trên máy OriginOS 5 chạy Temp Root (`late-load`), tiến trình `SurfaceFlinger` khởi chạy từ lúc bật nguồn trước khi nạp root và giữ cố định `ro.surface_flinger.supports_background_blur=0`, nên các cờ prop blur sẽ không có tác dụng. Module này cố tình loại bỏ mọi prop "vô nghĩa / placebo" để giữ máy sạch tuyệt đối.

---

## Cài đặt

1. Tải file `OriginOS5_Hidden_Features_v1.0.zip` tại mục **[Releases](../../releases/latest)**.
2. Mở **KernelSU / SukiSU / APatch / Magisk → Module → Cài đặt từ bộ nhớ** và chọn file `.zip`.
3. **Soft Reboot** (nếu dùng Temp Root) hoặc **Khởi động lại máy** (nếu mở khóa Bootloader).

### Gỡ cài đặt
Gỡ module trong trình quản lý root → `uninstall.sh` sẽ tự động khôi phục toàn bộ thuộc tính `persist.*` và `settings` về mặc định gốc.

---

## Tự build từ mã nguồn & kiểm thử

```bash
sh tests/test_module.sh
bash build.sh
```

File ZIP sẽ được xuất tại `dist/OriginOS5_Hidden_Features_v1.0.zip`.

## License
MIT License — xem tệp [LICENSE](LICENSE).
