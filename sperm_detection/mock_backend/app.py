from flask import Flask, request, jsonify
from flask_cors import CORS
import uuid
import re

app = Flask(__name__)
CORS(app)

EMAIL_REGEX = re.compile(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$')

def validate_credentials(email, password):
    if not email or not isinstance(email, str) or not EMAIL_REGEX.match(email.strip()):
        return False, "Please enter a valid email address (e.g., doctor@hospital.com)"

    if not password or not isinstance(password, str):
        return False, "Password cannot be empty"

    if len(password) < 6:
        return False, "Password must be at least 6 characters long"

    if not re.search(r'[A-Z]', password):
        return False, "Password must contain at least 1 capital letter (A-Z)"

    if not re.search(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/]', password):
        return False, "Password must contain at least 1 special character (e.g. @, #, $, !)"

    return True, ""

# ── Mock data ──────────────────────────────────────────────────────────────────

USERS = {
    "doctor@demo.com": {"password": "Password123!", "name": "Dr. Demo", "role": "doctor", "uid": "uid-001"},
    "admin@demo.com":  {"password": "Admin123!",    "name": "Admin User", "role": "admin",  "uid": "uid-000"},
}

PATIENTS = [
    {"patient_id": "p001", "name": "Ali Raza",    "age": 32, "contact": "0300-1234567", "doctor_uid": "uid-001"},
    {"patient_id": "p002", "name": "Bilal Ahmed",  "age": 28, "contact": "0312-9876543", "doctor_uid": "uid-001"},
    {"patient_id": "p003", "name": "Sara Khan",    "age": 35, "contact": "0321-5551234", "doctor_uid": "uid-001"},
]

DOCTORS = [
    {"uid": "uid-001", "name": "Dr. Demo",   "email": "doctor@demo.com", "specialization": "Urology"},
    {"uid": "uid-002", "name": "Dr. Ayesha", "email": "ayesha@demo.com", "specialization": "Andrology"},
]

RESULTS = {
    "p001": {"sperm_count": 42000000, "motility": 65, "morphology": 12, "status": "Normal"},
    "p002": {"sperm_count": 15000000, "motility": 40, "morphology": 6,  "status": "Oligospermia"},
    "p003": {"sperm_count": 80000000, "motility": 72, "morphology": 14, "status": "Normal"},
}

SAMPLES = {}

# ── Auth ──────────────────────────────────────────────────────────────────────

@app.route("/login", methods=["POST"])
def login():
    data = request.get_json(force=True) if request.data else {}
    email = str(data.get("email", "")).strip().lower()
    password = str(data.get("password", ""))

    if email == "doctor@demo.com" and password == "password123":
        user = USERS["doctor@demo.com"]
        return jsonify({
            "status": "success", "uid": user["uid"],
            "name": user["name"], "role": user["role"], "email": email
        }), 200

    is_valid, err_msg = validate_credentials(email, password)
    if not is_valid:
        return jsonify({"status": "error", "message": err_msg}), 400

    if email in USERS:
        user = USERS[email]
        if user["password"] == password:
            return jsonify({
                "status": "success", "uid": user["uid"],
                "name": user["name"], "role": user["role"], "email": email
            }), 200
        return jsonify({"status": "error", "message": "Incorrect password for registered account"}), 401

    name_parts = email.split("@")[0].replace(".", " ").replace("_", " ").split()
    formatted_name = "Dr. " + " ".join([p.capitalize() for p in name_parts]) if name_parts else "Dr. Physician"
    uid = f"uid-{str(uuid.uuid4())[:6]}"

    USERS[email] = {
        "password": password,
        "name": formatted_name,
        "role": "doctor",
        "uid": uid
    }

    if not any(d.get("email") == email for d in DOCTORS):
        DOCTORS.append({
            "uid": uid,
            "name": formatted_name,
            "email": email,
            "specialization": "Clinical Andrology"
        })

    return jsonify({
        "status": "success",
        "uid": uid,
        "name": formatted_name,
        "role": "doctor",
        "email": email,
        "message": "Authenticated successfully"
    }), 200

@app.route("/Admin", methods=["POST"])
def signup():
    data = request.get_json(force=True)
    name = str(data.get("name") or data.get("email") or "admin").strip()
    password = str(data.get("password", "")).strip()

    # Admin Master Login
    if name.lower() in ["admin", "admin@demo.com", "admin user", "administrator", "root"]:
        if password == "admin123" or password == "admin" or not password:
            return jsonify({"status": "success", "message": "Admin authenticated", "role": "admin", "uid": "uid-000"}), 200
        else:
            return jsonify({"status": "error", "message": "Incorrect admin password"}), 401

    # Check existing user
    if name in USERS:
        if USERS[name]["password"] == password:
            return jsonify({"status": "success", "message": "Authenticated", "role": "admin", "uid": USERS[name].get("uid", "uid-000")}), 200
        return jsonify({"status": "error", "message": "Incorrect password"}), 401

    # Register new admin
    uid = str(uuid.uuid4())[:8]
    USERS[name] = {"password": password, "name": name, "role": "admin", "uid": uid}
    return jsonify({"status": "success", "uid": uid, "role": "admin"}), 200

@app.route("/change_password", methods=["POST"])
def change_password():
    data = request.get_json(force=True)
    email = data.get("email","")
    if email in USERS:
        USERS[email]["password"] = data.get("new_password","")
        return jsonify({"status":"success"})
    return jsonify({"status":"error","message":"User not found"}), 404

# ── Profile ───────────────────────────────────────────────────────────────────

@app.route("/get_profile", methods=["GET"])
def get_profile():
    email = request.args.get("email","")
    user = USERS.get(email)
    if user:
        return jsonify({"name":user["name"],"email":email,"role":user["role"]})
    return jsonify({"name":"Unknown","email":email,"role":"doctor"})

# ── Patients ──────────────────────────────────────────────────────────────────

@app.route("/recent_patients", methods=["GET"])
def recent_patients():
    return jsonify(PATIENTS[:5])

@app.route("/get_patient/<patient_id>", methods=["GET"])
def get_patient(patient_id):
    p = next((x for x in PATIENTS if x["patient_id"]==patient_id), None)
    return jsonify(p) if p else (jsonify({"error":"Not found"}), 404)

@app.route("/patient", methods=["POST"])
def add_patient():
    data = request.get_json(force=True)
    data["patient_id"] = str(uuid.uuid4())[:6]
    PATIENTS.append(data)
    return jsonify({"status":"success","patient_id":data["patient_id"]})

@app.route("/update_patient/<patient_id>", methods=["PUT"])
def update_patient(patient_id):
    data = request.get_json(force=True)
    for i,p in enumerate(PATIENTS):
        if p["patient_id"]==patient_id:
            PATIENTS[i].update(data)
            return jsonify({"status":"success"})
    return jsonify({"error":"Not found"}), 404

# ── Doctors ───────────────────────────────────────────────────────────────────

@app.route("/doctors", methods=["GET"])
def get_doctors():
    return jsonify(DOCTORS)

@app.route("/add_doctor", methods=["POST"])
def add_doctor():
    data = request.get_json(force=True)
    data["uid"] = str(uuid.uuid4())[:8]
    DOCTORS.append(data)
    return jsonify({"status":"success"})

@app.route("/delete_doctor/<doctor_id>", methods=["DELETE"])
def delete_doctor(doctor_id):
    global DOCTORS
    DOCTORS = [d for d in DOCTORS if d["uid"]!=doctor_id]
    return jsonify({"status":"success"})

# ── Samples & Results ─────────────────────────────────────────────────────────

@app.route("/upload_sample/<uid>/<sample_type>", methods=["POST"])
def upload_sample(uid, sample_type):
    sid = str(uuid.uuid4())[:8]
    SAMPLES[sid] = {"uid":uid,"type":sample_type,"status":"processed"}
    return jsonify({"status":"success","sample_id":sid})

@app.route("/result", methods=["GET"])
def result():
    uid = request.args.get("uid", "p001")
    p = next((x for x in PATIENTS if x["patient_id"] == uid or x["name"].lower() == uid.lower()), None)
    if not p and PATIENTS:
        p = PATIENTS[0]
    
    patient_dict = {
        "uid": p["patient_id"] if p else uid,
        "name": p["name"] if p else "Demo Patient",
        "age": p.get("age", 30) if p else 30,
        "occupation": p.get("occupation", "Software Engineer") if p else "Not specified",
        "height": p.get("height", 1.75) if p else 1.75,
        "weight": p.get("weight", 70.0) if p else 70.0,
        "bmi": p.get("bmi", 22.8) if p else 22.8,
        "foc": p.get("foc", 3) if p else 3,
        "sexual_dysfunction": p.get("sexual_dysfunction", "None") if p else "None",
        "alcoholic": p.get("alcoholic", "No") if p else "No",
        "smoker": p.get("smoker", "No") if p else "No",
        "drugs": p.get("drugs", "No") if p else "No",
    }
    
    r = RESULTS.get(p["patient_id"] if p else uid, {"sperm_count": 52000000, "motility": 68, "morphology": 14, "status": "Normal"})
    return jsonify({
        "status": "success",
        "patient": patient_dict,
        "current_sample": 1,
        "results": r
    })

@app.route("/get_sample_status/<uid>", methods=["GET"])
def get_sample_status(uid):
    return jsonify({"status": "processed", "uid": uid, "current_sample": 1})

@app.route("/view_result", methods=["GET"])
def view_result():
    uid = request.args.get("uid","p001")
    r = dict(RESULTS.get(uid,{"sperm_count":50000000,"motility":60,"morphology":10,"status":"Normal"}))
    r["processed_image"] = "sample_result.png"
    return jsonify(r)

@app.route("/get_sperm_count/<uid>", methods=["GET"])
def get_sperm_count(uid):
    counts = [42, 48, 55, 62, 59, 68] # in millions
    return jsonify({
        "status": "success",
        "labels": ["S1", "S2", "S3", "S4", "S5", "S6"],
        "counts": counts,
        "active_sperm1": 42,
        "active_sperm2": 48,
        "active_sperm3": 55,
        "active_sperm4": 62,
        "active_sperm5": 59,
        "active_sperm6": 68
    })

@app.route("/uploads/<filename>")
def serve_upload(filename):
    return jsonify({"url":f"/uploads/{filename}"})

# ── Start ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("\n  Mock Spermoscope Backend running at http://180.235.121.245:8080 (and http://localhost:8080)")
    print("  Login: doctor@demo.com / password123")
    print("  Admin: admin@demo.com  / admin123\n")
    app.run(host="0.0.0.0", port=8080, debug=True, use_reloader=False)
