# 🎨 StickerStudio — WhatsApp & Telegram Sticker Hub

![PHP](https://img.shields.io/badge/PHP-8.x-777BB4?style=for-the-badge&logo=php&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-Database-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-Mobile_App-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![TailwindCSS](https://img.shields.io/badge/Tailwind_CSS-Admin_UI-38B2AC?style=for-the-badge&logo=tailwind-css&logoColor=white)
![Telegram API](https://img.shields.io/badge/Telegram-Bot_API-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)

**StickerStudio** is a complete, full-stack sticker pack management system and REST API built with Core PHP & MySQL, paired with a Flutter mobile client. Upload any standard image (PNG/JPG) through the web admin dashboard—the backend automatically converts it into WhatsApp & Telegram-compliant **$512 \times 512$ transparent WebP** stickers, generates **$96 \times 96$ tray icons**, syncs packs directly to Telegram Cloud via Bot API, and serves clean JSON endpoints for mobile apps.

---

## 📸 Screenshots

| Pack Manager | Pack Details & Whatsapp, Telegram Sync |
| :---: | :---: |
| <img src="https://github.com/user-attachments/assets/b2b34d92-bbe5-4e3f-b68e-ccf62da07961" alt="Admin Dashboard" width="30%"/> | <img src="https://github.com/user-attachments/assets/61c0a26d-53b3-4022-8951-7f2dabc28bec" alt="Pack Details & Telegram Sync" width="30%"/> |


> **Note:** Create a `screenshots/` folder in your repository root and upload your two screenshots as `admin-dashboard.png` and `pack-details.png` (or update the filenames in the table above).

---

## ✨ Key Features

- **🔄 Automated Image Conversion Engine:** Converts uploaded PNG/JPG/WebP images into $512 \times 512$ transparent `.webp` stickers while preserving aspect ratios and alpha transparency via PHP GD.
- **🖼️ Auto Tray Icon Generator:** Generates $96 \times 96$ tray icons from any sticker inside a pack with a single click.
- **📦 Bulk Multi-File Uploader:** Drag-and-drop batch upload support with client-side previews and WhatsApp 3–30 sticker count validation (`Ready`, `Incomplete`, `Overflow`).
- **✈️ One-Click Telegram Cloud Sync:** Integrates directly with the **Telegram Bot API** (`uploadStickerFile`, `createNewStickerSet`, `addStickerToSet`) to publish sticker sets to Telegram Cloud and generate instant `t.me/addstickers/...` links.
- **📱 Flutter-Ready REST API:** Clean JSON endpoints (`api/packs.php` & `api/pack.php`) serving ready-to-import sticker packs for Android and iOS Flutter apps.
- **🌐 Responsive Bengali Landing Page:** Included emerald-green, mobile-responsive front page for end users.

---

## 🏗️ System Architecture

```text
[Web Admin Panel (PHP + Tailwind)]
        │
        ├── Bulk Upload (PNG/JPG) ──► Auto 512x512 WebP + 96x96 Tray Icon
        ├── Sync Telegram         ──► Telegram Bot API (Cloud Sticker Set)
        │
        ▼
[MySQL Database & File Storage]
        │
        ▼
[REST API (JSON Endpoints)]
        │
        ▼
[Flutter Mobile App] ──► Direct Export to WhatsApp & Telegram
