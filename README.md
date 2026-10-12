<<<<<<< HEAD
# AI Fitness Coach

![Flutter](https://img.shields.io/badge/Flutter-3.44%2B-02569B?logo=flutter&logoColor=white)
![Android](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)
![ML Kit](https://img.shields.io/badge/Pose%20Detection-ML%20Kit-4285F4?logo=google&logoColor=white)
![Language](https://img.shields.io/badge/ภาษา-ไทย-DB2777)

> โค้ช Squat แบบเรียลไทม์: ตรวจจับท่าทาง นับ rep และดูสรุปการฝึกจาก Android

แอป Flutter สำหรับฝึก Squat โดยใช้กล้องและ ML Kit Pose Detection ตรวจจับท่าทาง
คำนวณมุม Hip-Knee-Ankle นับ rep และบันทึกประวัติการฝึกไว้ในเครื่อง

## สารบัญ

- [สิ่งที่ต้องมี](#สิ่งที่ต้องมี)
- [เริ่มใช้งาน](#เริ่มใช้งาน)
- [วิธีฝึก Squat](#วิธีฝึก-squat)
- [ทดสอบและ Build](#ทดสอบและ-build)
- [วิเคราะห์ผลด้วย Gemini](#วิเคราะห์ผลด้วย-gemini-ไม่บังคับ)
- [โครงสร้างโปรเจกต์](#โครงสร้างโปรเจกต์)
- [แก้ปัญหาเบื้องต้น](#แก้ปัญหาเบื้องต้น)

## สิ่งที่ต้องมี

- Flutter 3.44 ขึ้นไป และ Dart 3.12 ขึ้นไป
- Android Studio พร้อม Android SDK, Platform Tools และ Build Tools
- อุปกรณ์ Android หรือ Android emulator เช่น MuMu

ตรวจสอบเครื่องมือก่อนเริ่ม:

```powershell
flutter doctor -v
```

## เริ่มด่วนด้วย MuMu

เปิด MuMu แล้วรันคำสั่งต่อไปนี้จาก PowerShell ที่โฟลเดอร์โปรเจกต์:

```powershell
flutter pub get
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb connect 127.0.0.1:16384
flutter run -d 127.0.0.1:16384
```

> หาก ADB แสดงสถานะ `device` แล้ว ก็พร้อมเปิดแอปบน MuMu

โปรเจกต์มี Android host อยู่ใน `android/` แล้ว ไม่ต้องรัน `flutter create` ซ้ำ
แพ็กเกจหลักประกอบด้วย `camera`, `google_mlkit_pose_detection`,
`permission_handler`, `shared_preferences` และ `http` ดูเวอร์ชันที่ล็อกไว้ใน
`pubspec.lock`

## เริ่มใช้งาน

เปิด PowerShell ที่โฟลเดอร์โปรเจกต์ แล้วติดตั้ง dependencies:

```powershell
flutter pub get
```

### ใช้ MuMu

1. เปิด MuMu และรอให้ Android เริ่มทำงาน
2. เชื่อม ADB ของ Android SDK เข้ากับ MuMu (พอร์ตที่ใช้กับ MuMu เครื่องนี้คือ `16384`):

  ```powershell
  $adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
  & $adb connect 127.0.0.1:16384
  & $adb devices -l
  ```

  ตรวจว่ามีอุปกรณ์ `127.0.0.1:16384` และสถานะเป็น `device`
3. ตรวจว่า Flutter เห็นอุปกรณ์ แล้วเปิดแอป:

  ```powershell
  flutter devices
  flutter run -d 127.0.0.1:16384
  ```

  หากมีอุปกรณ์ Android เพียงเครื่องเดียว ใช้ `flutter run` ได้เช่นกัน
  กด `q` ใน terminal เพื่อหยุด debug session; กด `d` เพื่อ detach โดยปล่อยแอป
  ทำงานบน emulator ต่อ

### ใช้โทรศัพท์ Android

เปิด Developer options และ USB debugging บนโทรศัพท์ เชื่อม USB แล้วกดยอมรับ
ข้อความอนุญาต USB debugging บนเครื่อง จากนั้นใช้คำสั่ง:

```powershell
flutter devices
flutter run -d <device-id>
```

แทน `<device-id>` ด้วย ID ที่แสดงจาก `flutter devices`

## วิธีฝึก Squat

1. จากหน้า Home กด **Start Workout** และอนุญาตให้แอปใช้กล้อง
2. วางอุปกรณ์ให้กล้องเห็นร่างกาย โดยเฉพาะไหล่ สะโพก เข่า และข้อเท้าทั้งสองข้าง
3. เริ่มจากยืนตรง ย่อตัวลง แล้วกลับมายืนตรง
4. ระบบนับ rep เมื่อเห็นการย่อลงและกลับขึ้นครบหนึ่งรอบ จำนวนครั้งและ feedback
   จะแสดงบนหน้า Workout
5. กด **Finish** เพื่อหยุดกล้อง บันทึก session และเปิดหน้าผลการฝึก
6. เปิด **History** จากหน้า Home เพื่อดู session ที่บันทึกไว้

ระบบเฉลี่ยมุมเข่าซ้ายและขวา: มุมน้อยกว่า 110° ถือว่าอยู่ช่วงลง (`DOWN`),
มุมมากกว่า 160° ถือว่ากลับมายืน (`UP`) และ rep ถูกต้องเมื่อมุมต่ำสุดอยู่ในช่วง
70° ถึงต่ำกว่า 110° การค้างอยู่ในท่าเดิมไม่นับซ้ำ; หากตรวจไม่พบ pose ระหว่าง
รอบ ระบบจะยกเลิกรอบที่ขาดช่วงนั้น

การประเมินนี้เป็นเพียง feedback จาก landmarks และมุมเข่า ไม่ใช่การวินิจฉัยทาง
การแพทย์ มุมกล้อง แสง การบังร่างกาย และทิศทางที่หันเข้ากล้องมีผลต่อความแม่นยำ

## ทดสอบและ Build

| งาน | คำสั่ง |
| --- | --- |
| รัน unit tests | `flutter test` |
| สร้าง Debug APK | `flutter build apk --debug` |

หลัง build สำเร็จ ไฟล์ APK อยู่ที่ `build/app/outputs/flutter-apk/app-debug.apk`
ติดตั้ง APK ลง MuMu ที่เชื่อมต่อผ่าน ADB:

```powershell
$adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe"
& $adb -s 127.0.0.1:16384 install -r build/app/outputs/flutter-apk/app-debug.apk
```

## วิเคราะห์ผลด้วย Gemini (ไม่บังคับ)

การนับ rep และบันทึกประวัติใช้ได้โดยไม่ต้องเชื่อมต่อ AI หากต้องการขอคำแนะนำ
หลังจบ workout ให้กำหนด Gemini API key สำหรับการรันในเครื่อง:

```powershell
$env:GEMINI_API_KEY = 'YOUR_API_KEY'
flutter run -d 127.0.0.1:16384 --dart-define=GEMINI_API_KEY=$env:GEMINI_API_KEY
```

ค่าเริ่มต้นใช้โมเดล `gemini-2.5-flash`; เปลี่ยนได้ด้วย
`--dart-define=GEMINI_MODEL=MODEL_NAME` แอปส่งข้อมูลสรุปจำนวน rep/ความถูกต้อง
ไปยัง Gemini ไม่ได้ส่งภาพกล้อง

> **ความปลอดภัย:** API key ที่ส่งด้วย `--dart-define` ถูกฝังในแอปและอาจถูกดึงจาก
> APK ได้ ใช้สำหรับทดสอบในเครื่องเท่านั้น; สำหรับเผยแพร่แอปควรเก็บ key ไว้บน
> backend และห้าม commit key จริงลง Git

## โครงสร้างโปรเจกต์

- `lib/pose/`: แปลงภาพจากกล้องเป็น ML Kit input และวาด skeleton
- `lib/workout/`: คำนวณมุม วิเคราะห์ Squat นับ rep และควบคุม session
- `lib/models/`: โมเดลสรุปผลการฝึก
- `lib/data/`: ประวัติในเครื่อง (เก็บล่าสุดไม่เกิน 50 sessions)
- `lib/ai/`: ขอคำแนะนำสรุปผลจาก Gemini
- `lib/ui/`: หน้า Home, Workout, Result และ History
- `android/`: Android host project ที่ Flutter ใช้ build แอป
- `test/`: unit tests ของ Squat rep counter

ไฟล์ `main.dart`, `main2.dart` และ `main3.dart` ที่ root เป็น prototype รุ่นเก่า
entry point ของแอปปัจจุบันคือ `lib/main.dart`

## แก้ปัญหาเบื้องต้น

- **Flutter ไม่เห็น MuMu:** เปิด MuMu ก่อน แล้วรัน `adb connect 127.0.0.1:16384`
  จากนั้นตรวจด้วย `adb devices -l`; พอร์ตอาจต่างกันตามการตั้งค่า MuMu
- **Finish กดไม่ได้:** รอจนกล้องเริ่มทำงานและปุ่มเปลี่ยนเป็นสถานะพร้อมกด หากยังไม่ได้
  ให้ปิด/เปิด workout ใหม่
- **ไม่ได้รับภาพ pose หรือมุมเข่า:** อนุญาต Camera ใน Android app settings,
  เพิ่มแสง และจัดกล้องให้เห็นไหล่ สะโพก เข่า และข้อเท้า
- **Build แจ้ง Android SDK/License:** เปิด `flutter doctor -v` ตรวจ SDK และรัน
  `flutter doctor --android-licenses` เพื่อทบทวน/ยอมรับ Android SDK licenses
- **Gemini วิเคราะห์ไม่ได้:** ตรวจ API key, อินเทอร์เน็ต, model และ quota; ฟีเจอร์ AI
  เป็นส่วนเสริม จึงยังฝึกและนับ rep แบบออฟไลน์ได้
=======
# AI-Fitness-Coach
>>>>>>> origin/main
