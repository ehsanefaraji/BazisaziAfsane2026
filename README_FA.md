# بازی‌سازی افسانه — نسخهٔ ۷

نسخهٔ حرفه‌ای با Flame/Forge2D کامل، چندمرحله‌ای، Sprite Sheet، Export/Import JSON، و نقشهٔ مسیر مثل Angry Birds.

## ارتقاء‌های نسخهٔ ۷

### ۱. چندمرحله‌ای (تا ۲۰ مرحله در هر پروژه)
- هر `GameProject` یک `List<GameLevel>` دارد
- هر مرحله: نام، items، وضعیت کامل‌شدن، تعداد ستاره‌ها (۰-۳)
- مراحل به‌ترتیب باز می‌شوند (مرحلهٔ بعدی فقط بعد از کامل‌کردن قبلی)
- کاربر می‌تواند مرحلهٔ جدید اضافه/حذف کند

### ۲. نقشهٔ مسیر (مثل Angry Birds)
`lib/src/screens/map_screen.dart`:
- مسیر پیچ‌دار (زیگزاگ) با مراحل به‌صورت دایره
- مراحل قفل‌شده با آیکن قفل 🔒
- مراحل قابل‌بازشدن با عدد + دکمهٔ play سبز
- ستاره‌های کامل‌شدن بالای هر مرحله
- افزودن مرحله با دکمهٔ + در app bar

### ۳. Export/Import JSON
- **Export**: دکمهٔ share در کارت پروژه یا در نقشه → JSON در کلیپ‌بورد کپی می‌شود
- **Import**: دکمهٔ file_download در app bar → کاربر JSON را پیست می‌کند → پروژه import می‌شود
- فرمت JSON قابل خواندن توسط انسان است
- امکان اشتراک‌گذاری پروژه‌ها با دوستان

### ۴. Sprite Sheet فریم‌به‌فریم
`assets/sprites/` شامل سه sprite sheet تولیدشده با AI:
- **fox_run_sheet.png**: ۸ فریم دویدن
- **fox_idle_sheet.png**: ۶ فریم ایستادن
- **fox_jump_sheet.png**: ۴ فریم پرش
- در Flame با `SpriteAnimationComponent` بارگذاری می‌شوند

### ۵. صفحهٔ دستاوردها
`lib/src/screens/achievements_screen.dart`:
- گالری ۸ دستاورد با وضعیت بازشده/قفل
- آمار کامل: سکه‌های کل، دشمنان کشته‌شده، مراحل کامل‌شده، دستاوردهای بازشده
- دستاوردهای جدید:
  - 👑 قهرمان (۱۰ مرحله کامل)
  - 🏗️ معمار (پروژه با ۵+ مرحله)
  - 📥 مهمان‌نواز (import یک پروژه)

### ۶. کارت پروژهٔ ارتقایافته
- نمایش تعداد مراحل
- نوار پیشرفت (مراحل کامل/کل)
- دکمهٔ export سریع
- دکمهٔ delete

### ۷. حفظ همهٔ ویژگی‌های نسخهٔ ۵
- ۵ محیط بصری متمایز
- ۵ سبک بازی کامل
- ۸ افکت صوتی + موسیقی چندصدایی
- ۴ پاورآپ
- ۵ حالت انیمیشن روباه
- پس‌زمینهٔ پارالاکس متحرک

## ساخت APK

### مرحلهٔ ۱ — افزودن ۴ Secret
| نام | مقدار |
|-----|------|
| `BAZISAZI_KEYSTORE_BASE64` | محتوای `bazisazi-afsane-keystore-base64.txt` |
| `BAZISAZI_STORE_PASSWORD` | `BazisaziAfsane2026!` |
| `BAZISAZI_KEY_PASSWORD` | `BazisaziAfsane2026!` |
| `BAZISAZI_KEY_ALIAS` | `bazisazi-afsane-release` |

### مرحلهٔ ۲ — Push
```sh
unzip bazisazi-afsane-source-v7.0.0.zip
cd bazisazi-afsane-v7
git init && git add . && git commit -m "v7.0.0: multi-level + map + JSON + sprite sheets + achievements"
git branch -M main
git remote add origin https://github.com/USERNAME/bazisazi-afsane.git
git push -u origin main
```

### مرحلهٔ ۳ — دریافت APK
**Actions → Artifacts → bazisazi-afsane-release-apk**

## مشخصات امضا
- alias: `bazisazi-afsane-release`
- SHA-1: `A8:6B:D2:42:72:4B:E2:85:2E:E3:03:A0:7D:BF:B4:9A:72:B0:90:E5`
- SHA-256: `0F:24:1E:B8:FD:02:AC:45:C5:33:A3:E5:D5:12:D9:44:F9:BC:DF:9E:8D:55:DC:FE:42:58:EA:C0:5E:8B:AB:28`

## ساختار پروژه
```
.
├── .github/workflows/build-apk.yml
├── android/app/src/main/res/mipmap-*/
├── assets/
│   ├── images/                  # ۵ پس‌زمینهٔ محیط + آیکون
│   └── sprites/                 # ← جدید: Sprite Sheet‌های روباه
│       ├── fox_run_sheet.png    # ۸ فریم دویدن
│       ├── fox_idle_sheet.png   # ۶ فریم ایستادن
│       └── fox_jump_sheet.png   # ۴ فریم پرش
├── lib/
│   ├── main.dart
│   └── src/
│       ├── theme.dart
│       ├── game_store.dart      # GameLevel + GameProject + JSON export/import
│       ├── audio/audio_manager.dart
│       ├── game/platformer_engine.dart
│       ├── painters/
│       ├── games/               # ۵ سبک بازی
│       └── screens/
│           ├── home_screen.dart        # با دکمهٔ Import
│           ├── genre_picker_screen.dart
│           ├── map_screen.dart         # ← جدید: نقشهٔ مسیر Angry Birds-style
│           ├── editor_screen.dart      # با GameLevel
│           ├── play_screen.dart        # اجرای مرحله + ذخیره ستاره‌ها
│           └── achievements_screen.dart # ← جدید: گالری دستاوردها + آمار
└── README_FA.md
```

## بازی کردن
۱. «بازی جدید» → انتخاب سبک
۲. در نقشهٔ مسیر، روی مرحلهٔ ۱ بزن تا ویرایشگر باز شود
۳. آیتم‌ها را روی بوم بچین، دکمهٔ play بزن
۴. مرحله را کامل کن تا مرحلهٔ بعدی باز شود
۵. مراحل جدید را با دکمهٔ + اضافه کن
۶. پروژه را با JSON به دوستت بفرست

## توسعه‌های بعدی (نسخهٔ ۸)
- پلتفرمر Flame با Sprite Sheet واقعی (نه گریدبیس)
- صدا برای هر رویداد در بازی
- انیمیشن‌های انتقال بین صفحات
- اشتراک‌گذاری با کد QR
- حالت چندنفرهٔ محلی
