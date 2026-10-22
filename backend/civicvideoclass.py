# =========================================================
# CIVIC ISSUE ANALYZER + SELF-LEARNING PIPELINE
# Enhanced Preprocessing + Video Support
# =========================================================

import tensorflow as tf
import numpy as np
import cv2
import os
import json
from PIL import Image, ImageEnhance
from collections import defaultdict
from tensorflow.keras.applications.mobilenet_v2 import preprocess_input
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint

# =========================================================
# CONFIGURATION
# =========================================================
IMG_SIZE = (224, 224)
FRAME_INTERVAL = 10
MAX_FRAMES = 20
TOP_K_AGREEMENT = 3
UNKNOWN_REJECT_THRESHOLD = 0.60

CLASS_NAMES = [
    "garbage",
    "open_drain",
    "public_toilet_issue",
    "damaged_property",
    "water_leakage",
    "overgrown_vegetation"
]

CLASS_THRESHOLDS = {
    "garbage": 0.75,
    "open_drain": 0.85,
    "public_toilet_issue": 0.80,
    "damaged_property": 0.80,
    "water_leakage": 0.80,
    "overgrown_vegetation": 0.75
}

EVIDENCE_DIR = "evidence"
SELF_LEARNING_DIR = "self_learning_data"
os.makedirs(EVIDENCE_DIR, exist_ok=True)
os.makedirs(SELF_LEARNING_DIR, exist_ok=True)

OLD_MODEL_PATH = "civic_image_classifier"
NEW_MODEL_PATH = "civic_image_classifier_v2"

# =========================================================
# LOAD MODEL
# =========================================================
def load_model(path=OLD_MODEL_PATH):
    return tf.keras.models.load_model(path)

model = load_model()

# =========================================================
# IMAGE PREPROCESSING FUNCTION
# =========================================================
def preprocess_image(image: Image.Image, augment=False):
    """
    Preprocesses image for prediction:
    1. Resize
    2. Blur check
    3. Denoising
    4. Brightness/contrast enhancement
    5. Safe augmentation (flip/rotation)
    6. Normalization for MobileNetV2
    7. Convert to batch numpy array
    """
    # 1. Resize
    image = image.resize(IMG_SIZE)

    # 2. Safe augmentation (only if augment=True)
    if augment:
        if np.random.rand() < 0.5:
            image = image.transpose(Image.FLIP_LEFT_RIGHT)
        angle = np.random.randint(-15, 16)
        image = image.rotate(angle)

    # 3. Brightness & Contrast enhancement
    enhancer = ImageEnhance.Contrast(image)
    image = enhancer.enhance(1.2)
    enhancer_b = ImageEnhance.Brightness(image)
    image = enhancer_b.enhance(1.1)

    # Convert to numpy array
    img_array = np.array(image)

    # 4. Denoising
    img_array = cv2.fastNlMeansDenoisingColored(img_array, None, 10, 10, 7, 21)

    # 5. Normalization
    img_array = preprocess_input(img_array)

    # 6. Expand dims for batch
    return np.expand_dims(img_array, axis=0)

# =========================================================
# BLUR CHECK
# =========================================================
def is_blurry(image: Image.Image, threshold=100):
    gray = cv2.cvtColor(np.array(image), cv2.COLOR_RGB2GRAY)
    return cv2.Laplacian(gray, cv2.CV_64F).var() < threshold

# =========================================================
# IMAGE PREDICTION
# =========================================================
def predict_image(image: Image.Image):
    processed = preprocess_image(image)
    preds = model.predict(processed, verbose=0)[0]
    cls_idx = np.argmax(preds)
    return CLASS_NAMES[cls_idx], preds[cls_idx]

# =========================================================
# VIDEO FRAME EXTRACTION
# =========================================================
def extract_frames(video_path):
    cap = cv2.VideoCapture(video_path)
    frames = []
    count = 0
    while cap.isOpened() and len(frames) < MAX_FRAMES:
        ret, frame = cap.read()
        if not ret:
            break
        if count % FRAME_INTERVAL == 0:
            frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            frame_img = Image.fromarray(cv2.resize(frame, IMG_SIZE))
            if not is_blurry(frame_img):
                frames.append(frame_img)
        count += 1
    cap.release()
    return frames

# =========================================================
# VIDEO PREDICTION (CONFIDENCE-WEIGHTED VOTING)
# =========================================================
def predict_video(video_path):
    frames = extract_frames(video_path)
    if len(frames) == 0:
        return None, 0.0, None
    score_map = defaultdict(float)
    count_map = defaultdict(int)
    best_frame = None
    best_conf = 0
    for frame in frames:
        cls, conf = predict_image(frame)
        if conf < UNKNOWN_REJECT_THRESHOLD:
            continue
        score_map[cls] += conf
        count_map[cls] += 1
        if conf > best_conf:
            best_conf = conf
            best_frame = frame
    if not score_map:
        return None, 0.0, None
    final_class = max(score_map, key=score_map.get)
    avg_conf = score_map[final_class] / count_map[final_class]
    if count_map[final_class] < TOP_K_AGREEMENT or avg_conf < CLASS_THRESHOLDS[final_class]:
        return None, avg_conf, None
    return final_class, avg_conf, best_frame

# =========================================================
# SAVE EVIDENCE + SELF-LEARNING
# =========================================================
def save_evidence(cls, confidence, image):
    filename = f"{EVIDENCE_DIR}/{cls}_{int(confidence*100)}.jpg"
    image.save(filename)
    meta = {"issue": cls, "confidence": confidence}
    with open(filename.replace(".jpg", ".json"), "w") as f:
        json.dump(meta, f, indent=2)
    # Add to self-learning data
    cls_dir = os.path.join(SELF_LEARNING_DIR, cls)
    os.makedirs(cls_dir, exist_ok=True)
    image.save(os.path.join(cls_dir, os.path.basename(filename)))

# =========================================================
# PREDICT FILE (IMAGE OR VIDEO)
# =========================================================
def analyze_file(file_path, file_type="image"):
    if "image" in file_type.lower():
        image = Image.open(file_path).convert("RGB")
        cls, conf = predict_image(image)
        if conf >= CLASS_THRESHOLDS.get(cls, 0.8):
            save_evidence(cls, conf, image)
            return cls, conf
        else:
            return None, conf
    else:
        cls, conf, frame = predict_video(file_path)
        if cls:
            save_evidence(cls, conf, frame)
            return cls, conf
        else:
            return None, conf

# =========================================================
# SELF-LEARNING RETRAINING
# =========================================================
def retrain_self_learning_model():
    print("⚙ Retraining model with confirmed evidence...")
    datagen = ImageDataGenerator(
        preprocessing_function=preprocess_input,
        rotation_range=15,
        zoom_range=0.1,
        horizontal_flip=True,
        validation_split=0.2
    )
    train_gen = datagen.flow_from_directory(
        SELF_LEARNING_DIR,
        target_size=IMG_SIZE,
        batch_size=16,
        class_mode="categorical",
        subset="training",
        shuffle=True
    )
    val_gen = datagen.flow_from_directory(
        SELF_LEARNING_DIR,
        target_size=IMG_SIZE,
        batch_size=16,
        class_mode="categorical",
        subset="validation"
    )
    model = tf.keras.models.load_model(OLD_MODEL_PATH)
    for layer in model.layers[:-4]:
        layer.trainable = False
    model.compile(
        optimizer=tf.keras.optimizers.Adam(1e-4),
        loss="categorical_crossentropy",
        metrics=["accuracy"]
    )
    callbacks = [
        EarlyStopping(monitor="val_loss", patience=3, restore_best_weights=True),
        ModelCheckpoint(NEW_MODEL_PATH, monitor="val_accuracy", save_best_only=True)
    ]
    model.fit(train_gen, validation_data=val_gen, epochs=10, callbacks=callbacks)
    print("✅ Retraining complete!")
    print(f"🔥 New model saved as: {NEW_MODEL_PATH}")

# =========================================================
# EXAMPLE USAGE
# =========================================================
if __name__ == "__main__":
    # Image prediction example:
    # cls, conf = analyze_file("test_images/garbage1.jpg", "image")
    # Video prediction example:
    # cls, conf = analyze_file("test_videos/garbage_video.mp4", "video")
    # Retrain after collecting evidence:
    # retrain_self_learning_model()
    pass
