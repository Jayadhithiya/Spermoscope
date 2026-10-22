from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
from PIL import Image
import os
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

# Load the trained model (adjust the path to your model file)
model_path = 'C:/python_projects/semen_analysis/models/resnet50_model_continued.keras'
model = tf.keras.models.load_model(model_path)

# Define the target image size (should match the input size used during training)
TARGET_SIZE = (224, 224)

# ── Image Validation ──────────────────────────────────────────────────────────

def is_semen_microscopy_image(img):
    """
    Validate whether an uploaded image looks like a semen/sperm microscopy slide.

    Microscopy slides have these visual characteristics:
    - Near-grayscale coloring (very low color saturation)
    - Moderate brightness (not pitch-black or overexposed white)
    - Some texture / contrast (not a blank/solid-color image)

    Returns:
        (True, "")              if the image passes validation
        (False, reason_string)  if the image is likely NOT a microscopy slide
    """
    # Convert to RGB for consistent processing
    img_rgb = img.convert("RGB")
    img_resized = img_rgb.resize((128, 128))  # Small size is enough for heuristics

    img_array = np.array(img_resized, dtype=np.float32)  # shape (128, 128, 3)

    # ── 1. Color Saturation Check ─────────────────────────────────────────────
    # Microscopy images are essentially grayscale.
    # Saturation = (max_channel - min_channel) / max_channel per pixel.
    r, g, b = img_array[:, :, 0], img_array[:, :, 1], img_array[:, :, 2]
    channel_max = np.maximum(np.maximum(r, g), b) + 1e-6  # avoid division by zero
    channel_min = np.minimum(np.minimum(r, g), b)
    saturation = (channel_max - channel_min) / channel_max  # 0 = gray, 1 = fully saturated
    mean_saturation = float(np.mean(saturation))

    # Natural photographs / colorful images have saturation > 0.20
    SAT_THRESHOLD = 0.20
    if mean_saturation > SAT_THRESHOLD:
        return False, (
            f"Image appears to be a natural/color photograph "
            f"(color saturation {mean_saturation:.2f} exceeds threshold {SAT_THRESHOLD}). "
            "Please upload a sperm/semen microscopy slide image."
        )

    # ── 2. Brightness Check ───────────────────────────────────────────────────
    img_gray = np.mean(img_array, axis=2)  # shape (128, 128)
    mean_brightness = float(np.mean(img_gray))

    # Pitch-black image (e.g., corrupted file or blank placeholder)
    if mean_brightness < 5.0:
        return False, "Image is too dark (possibly blank or corrupted). Please upload a valid microscopy image."

    # Pure-white / fully overexposed image
    if mean_brightness > 250.0:
        return False, "Image is too bright / overexposed. Please upload a valid microscopy image."

    # ── 3. Texture / Contrast Check ───────────────────────────────────────────
    # A microscopy image has visible texture from cells & background variation.
    # A blank or solid-color image has near-zero standard deviation.
    std_brightness = float(np.std(img_gray))
    if std_brightness < 5.0:
        return False, (
            "Image has no texture (appears to be a solid color or blank). "
            "Please upload a sperm/semen microscopy slide image."
        )

    return True, ""

# ── Prediction Endpoint ───────────────────────────────────────────────────────

@app.route('/predict_sperm_count', methods=['POST'])
def predict_sperm_count():
    if 'image' not in request.files:
        return jsonify({'success': False, 'message': 'No image file provided'}), 400

    image_file = request.files['image']
    temp_img_path = 'temp_image.jpg'  # Temporary storage for the uploaded image

    try:
        # Save the image temporarily
        image_file.save(temp_img_path)

        # Open the image for validation
        img = Image.open(temp_img_path)

        # ── Validate: reject non-microscopy images ────────────────────────────
        is_valid, rejection_reason = is_semen_microscopy_image(img)
        if not is_valid:
            return jsonify({
                'success': False,
                'error': 'invalid_image',
                'message': rejection_reason
            }), 422  # 422 Unprocessable Entity

        # ── Pre-process for the model ─────────────────────────────────────────
        img_resized = img.convert("RGB").resize(TARGET_SIZE)
        img_array = np.array(img_resized) / 255.0       # Normalize to [0, 1]
        img_array = np.expand_dims(img_array, axis=0)   # Add batch dimension

        # Make a prediction
        prediction = model.predict(img_array)
        sperm_count = prediction[0][0]  # Assuming single-value regression output

        # Round off the predicted sperm count
        rounded_sperm_count = round(sperm_count)

        return jsonify({'success': True, 'sperm_count': rounded_sperm_count}), 200

    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

    finally:
        # Clean up the temporary file
        if os.path.exists(temp_img_path):
            os.remove(temp_img_path)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5011)
