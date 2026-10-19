# 🔬 Spermoscope — Project Documentation

> **An AI-powered clinical mobile application for automated semen analysis**

---

## 📌 What is Spermoscope?

**Spermoscope** is a clinical-grade mobile application that assists doctors and andrologists in performing **automated semen analysis**. It digitizes and automates the traditional **sperm quality test (spermiogram)** — a procedure typically performed manually under a microscope in diagnostic laboratories.

By combining a **Flutter mobile frontend**, a **Python Flask backend**, and an **AI-based detection algorithm**, Spermoscope brings fast, accurate, and standardized fertility diagnostics to any clinical setting.

---

## 🏥 Where Can It Be Used?

| Setting | Use Case |
|---|---|
| **Fertility Clinics** | Rapid semen analysis for infertility diagnosis |
| **Urology / Andrology Departments** | Quantitative sperm health assessment |
| **IVF Centers** | Pre-treatment male fertility screening |
| **Rural / Resource-Limited Labs** | Replace manual microscopy with AI-assisted mobile analysis |
| **Research Institutions** | Standardized data collection for andrology studies |

---

## ⚙️ How Does the App Work?

`
Doctor logs in
      ↓
Registers patient (age, BMI, lifestyle factors)
      ↓
Uploads semen sample image (via camera or gallery)
      ↓
Image is sent to the AI backend for analysis
      ↓
AI detects & counts sperm cells, measures motility & morphology
      ↓
Results displayed: Count, Motility %, Morphology %, Diagnosis
      ↓
Doctor views charts, saves report, manages patient history
`

---

## 👥 User Roles

| Role | Capabilities |
|---|---|
| **Doctor** | Login, register patients, upload samples, view results & trend charts |
| **Admin** | All doctor capabilities + add/delete doctors, manage users system-wide |

---

## 📊 Key Medical Parameters Tracked

| Parameter | Description |
|---|---|
| **Sperm Count** | Total number of sperm cells per mL of semen |
| **Motility** | Percentage of sperm cells that are actively moving |
| **Morphology** | Percentage of sperm with a normal shape and structure |
| **Diagnosis** | Clinical verdict: e.g., Normal, Oligospermia (low count), etc. |
| **Lifestyle Factors** | BMI, smoking, alcohol consumption, drug use — correlated with results |

> Diagnosis thresholds are based on **WHO semen analysis reference criteria**.

---

## 🛠️ Full Technology Stack

### 📱 Frontend — Flutter Mobile App

| Technology | Role |
|---|---|
| **Flutter (Dart)** | Cross-platform mobile UI for Android & iOS |
| **Material Design 3** | Clinical design system (deep navy #0F274A theme) |
| **fl_chart** | Sperm count graphs and multi-sample trend charts |
| **image_picker** | Camera / gallery access for sample image upload |
| **permission_handler** | Runtime camera and storage permission management |
| **flutter_spinkit** | Animated loading indicators |
| **page_transition** | Smooth screen navigation animations |
| **http** | REST API communication with the backend |

#### Application Screens (18 Total)

| Screen | Purpose |
|---|---|
| splash_screen.dart | Animated app launch screen |
| login_screen.dart | Doctor authentication |
| signup_screen.dart | New doctor registration |
| home_screen.dart | Main doctor dashboard |
| patient_details_form.dart | Register & capture patient information |
| patient_details_screen.dart | View full patient profile |
| all_patients_screen.dart | List all registered patients |
| edit_patient_screen.dart | Edit existing patient records |
| upload_sample_screen.dart | Upload microscope image of sperm sample |
| result_screen.dart | Primary analysis results display |
| view_result_screen.dart | Detailed result breakdown with processed image |
| graph_screen.dart | Multi-sample sperm count trend charts |
| admin_screen.dart | Admin panel — manage doctors and users |
| change_password_screen.dart | Secure password update flow |
| profile_screen.dart | Doctor profile view |
| main_screen.dart | Bottom navigation shell |
| about.dart | App information screen |

---

### 🖥️ Backend — Python Flask API

| Technology | Role |
|---|---|
| **Python Flask** | Lightweight REST API server (runs on port 8080) |
| **flask-cors** | Enables cross-origin requests from the Flutter app |
| **UUID** | Generates unique IDs for patients and samples |

#### REST API Endpoints

| Endpoint | Method | Description |
|---|---|---|
| /login | POST | Doctor authentication |
| /Admin | POST | Admin login / registration |
| /change_password | POST | Update user password |
| /get_profile | GET | Fetch doctor profile info |
| /patient | POST | Add a new patient |
| /get_patient/<id> | GET | Retrieve a specific patient |
| /recent_patients | GET | List recent patients |
| /update_patient/<id> | PUT | Edit patient information |
| /doctors | GET | List all doctors (Admin) |
| /add_doctor | POST | Register a new doctor (Admin) |
| /delete_doctor/<id> | DELETE | Remove a doctor (Admin) |
| /upload_sample/<uid>/<type> | POST | Upload a sperm sample |
| /get_sample_status/<uid> | GET | Check sample processing status |
| /result | GET | Retrieve full analysis result |
| /view_result | GET | Detailed result with processed image |
| /get_sperm_count/<uid> | GET | Multi-sample count data for charts |

---

### 🤖 AI / Algorithm Layer

> The backend in this repository is a **mock server** simulating real AI responses. The actual AI detection module (excluded via .gitignore as sperm_detection.zip) powers the core analysis engine.

| Technology | Role |
|---|---|
| **Computer Vision (CV)** | Detect and segment sperm cells in microscope images |
| **YOLO / CNN (Deep Learning)** | Object detection model for automated sperm counting |
| **Python (Inference Server)** | Runs model predictions and returns structured results |
| **WHO Criteria Engine** | Maps raw metrics to clinical diagnoses |

**What the AI does:**
1. Accepts a microscope image of a semen sample
2. Detects individual sperm cells using object detection
3. Classifies motility (moving vs. non-moving)
4. Assesses morphology (normal vs. abnormal shape)
5. Returns count, motility %, morphology %, and a clinical status

---

### 🎨 Figma Prototype

An interactive HTML/JS prototype of the full app UI is included for design validation.

| File | Purpose |
|---|---|
| index.html | Interactive prototype entry point |
| screens.js | All screen definitions and navigation logic |
| style.css | Prototype styling |
| generate_svgs.py | Auto-generates SVG artboards from Figma exports |

---

## 📁 Repository Structure

`
Spermoscope/
├── sperm_detection/          # Flutter Mobile App
│   ├── lib/
│   │   ├── main.dart         # App entry point & theme
│   │   └── screens/          # 18 application screens
│   ├── assets/               # Images and app icon
│   ├── android/              # Android-specific config
│   ├── ios/                  # iOS-specific config
│   └── pubspec.yaml          # Flutter dependencies
│
├── mock_backend/             # Python Flask REST API
│   ├── app.py                # All API routes and mock data
│   └── requirements.txt      # Python dependencies (Flask, flask-cors)
│
├── figma_prototype/          # Interactive UI Prototype
│   ├── index.html
│   ├── screens.js
│   ├── style.css
│   └── generate_svgs.py
│
└── ABOUT.md                  # This document
`

---

## 🚀 Getting Started

### Running the Mock Backend

`ash
cd mock_backend
pip install -r requirements.txt
python app.py
# Server starts at http://localhost:8080
`

**Demo credentials:**
- Doctor: doctor@demo.com / password123
- Admin:  admin@demo.com  / admin123

### Running the Flutter App

`ash
cd sperm_detection
flutter pub get
flutter run
`

> Make sure to update lib/screens/Urls.dart to point to your backend IP if running on a physical device.

---

## 📄 License

This project was developed as an academic/research prototype. Please refer to the repository owner for licensing and usage permissions.

---

*Built with love for better fertility diagnostics.*
