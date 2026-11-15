# Attendance: Employee Attendance Mobile App

A Flutter mobile app that lets employees **check in and check out**, and gives them a complete, transparent view of their attendance: daily records, working hours, deductions, and requests. It is connected to a companion **desktop management application** where HR and managers administer attendance, review requests, and generate reports.

---

## ✨ Features

### Employee app (mobile)
- **Secure sign-up and sign-in** with an onboarding flow for new users
- **Check-in / check-out** with automatic recording of arrival and departure times
- **Daily attendance view:** every day shows arrival time, departure time, and total time worked
- **Deductions:** a full breakdown of all deductions with the details behind each one
- **Statistics:** an overview of attendance performance (days attended, lateness, absences)
- **Activity log:** a complete history of attendance activity
- **Requests:** submit vacation, holiday, day-off, delay, and emergency requests directly from the app
- **Notifications** to keep employees informed
- **Profile** management

### Management desktop application
- Central management of employees and attendance rules
- Monitoring of attendance across all employees
- Review and handling of employee requests
- **Reports** on attendance, lateness, absence, and deductions

Both applications work on the same shared data: every check-in recorded on the mobile app is available to management, and every rule or deduction defined on the desktop side is reflected in the employee's view.

---

## 🧱 Tech Stack

| Layer | Technology |
|---|---|
| Mobile app | Flutter (Dart) |
| Platforms | Android, iOS |
| Management system | Desktop application connected to the same backend |

---

## 🏗 Architecture

```
Employee Mobile App (Flutter)          Management Desktop App
          │                                      │
          └──────────────┬───────────────────────┘
                         ▼
                  Backend / Database
   (attendance records · deductions · requests · reports)
```

---

## 🗂 Project Structure

```
lib/
├── main.dart
└── pages/
    ├── splashscreen.dart   # App launch screen
    ├── onboarding.dart     # First-run onboarding
    ├── signin.dart         # Authentication
    ├── signup.dart
    ├── home.dart           # Main shell and navigation
    ├── homebody.dart       # Home content (check-in / check-out)
    ├── activity.dart       # Attendance activity and daily records
    ├── stat.dart           # Statistics overview
    ├── location.dart       # Location screen
    ├── notification.dart   # Notifications
    ├── profile.dart        # Employee profile
    ├── vacation.dart       # Vacations overview
    ├── addvac.dart         # Vacation request
    ├── addholi.dart        # Holiday request
    ├── addoff.dart         # Day-off request
    ├── adddelay.dart       # Delay request
    └── emergency.dart      # Emergency request
android/ · ios/ · web/ · windows/ · linux/ · macos/   # Platform targets
images/                                               # App assets
```

---

## 🚀 Getting Started

**Requirements:** Flutter SDK 3.x, Android Studio or Xcode, and a running instance of the backend API

```bash
# 1. Clone
git clone https://github.com/ahmedmamdoh3142/attendance.git
cd attendance

# 2. Install dependencies
flutter pub get

# 3. Run on a connected device or emulator
flutter run

# Build a release APK
flutter build apk --release
```

The app communicates with the backend API, so the API endpoint must be configured for your own environment. **No real credentials, server addresses, or employee data are included in this repository.**

---

## 👤 My Role

I designed and built the mobile application, including its screens, attendance flow, and its integration with the management system.

