#!/usr/bin/env python3
"""
TensorFlow Lite Civic Image Classifier
Real implementation using TFLite model for civic issue classification
"""

import numpy as np
from PIL import Image
import tflite_runtime.interpreter as tflite
import os
from typing import Tuple, Dict

class CivicImageClassifier:
    """
    Classifier for civic issues using TensorFlow Lite model
    """
    
    # Category mapping (should match your model's output)
    CATEGORIES = [
        "pothole",
        "garbage", 
        "streetlight",
        "water",
        "traffic",
        "unknown"
    ]
    
    def __init__(self, model_path: str = None):
        """
        Initialize the classifier with a TFLite model
        
        Args:
            model_path: Path to the .tflite model file
        """
        if model_path is None:
            # Default to the model in the same directory
            model_path = os.path.join(
                os.path.dirname(__file__), 
                "civic_image_classifier_v1.tflite"
            )
        
        if not os.path.exists(model_path):
            raise FileNotFoundError(f"Model file not found: {model_path}")
        
        self.model_path = model_path
        self.interpreter = None
        self.input_details = None
        self.output_details = None
        self._load_model()
    
    def _load_model(self):
        """Load the TFLite model into memory"""
        try:
            self.interpreter = tflite.Interpreter(model_path=self.model_path)
            self.interpreter.allocate_tensors()
            
            self.input_details = self.interpreter.get_input_details()
            self.output_details = self.interpreter.get_output_details()
            
            print(f"✅ Model loaded successfully from {self.model_path}")
            print(f"   Input shape: {self.input_details[0]['shape']}")
            print(f"   Output shape: {self.output_details[0]['shape']}")
        except Exception as e:
            raise RuntimeError(f"Failed to load TFLite model: {e}")
    
    def preprocess_image(self, image_path: str) -> np.ndarray:
        """
        Preprocess an image for model input
        
        Args:
            image_path: Path to the image file
            
        Returns:
            Preprocessed image as numpy array
        """
        # Get expected input shape from the model
        input_shape = self.input_details[0]['shape']
        height, width = input_shape[1], input_shape[2]
        
        # Load and resize image
        img = Image.open(image_path)
        img = img.convert('RGB')  # Ensure RGB format
        img = img.resize((width, height))
        
        # Convert to numpy array and normalize
        img_array = np.array(img, dtype=np.float32)
        
        # Normalize to [0, 1] range
        img_array = img_array / 255.0
        
        # Add batch dimension
        img_array = np.expand_dims(img_array, axis=0)
        
        return img_array
    
    def classify(self, image_path: str) -> Tuple[str, float]:
        """
        Classify a civic issue image
        
        Args:
            image_path: Path to the image file
            
        Returns:
            Tuple of (category, confidence)
        """
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image not found: {image_path}")
        
        # Preprocess image
        input_data = self.preprocess_image(image_path)
        
        # Set input tensor
        self.interpreter.set_tensor(
            self.input_details[0]['index'], 
            input_data
        )
        
        # Run inference
        self.interpreter.invoke()
        
        # Get output tensor
        output_data = self.interpreter.get_tensor(
            self.output_details[0]['index']
        )
        
        # Get prediction
        predictions = output_data[0]
        predicted_index = np.argmax(predictions)
        confidence = float(predictions[predicted_index])
        
        # Handle case where number of outputs doesn't match categories
        if predicted_index < len(self.CATEGORIES):
            category = self.CATEGORIES[predicted_index]
        else:
            category = "unknown"
        
        return category, confidence
    
    def get_all_predictions(self, image_path: str) -> Dict[str, float]:
        """
        Get predictions for all categories
        
        Args:
            image_path: Path to the image file
            
        Returns:
            Dictionary mapping categories to confidence scores
        """
        if not os.path.exists(image_path):
            raise FileNotFoundError(f"Image not found: {image_path}")
        
        # Preprocess image
        input_data = self.preprocess_image(image_path)
        
        # Set input tensor
        self.interpreter.set_tensor(
            self.input_details[0]['index'], 
            input_data
        )
        
        # Run inference
        self.interpreter.invoke()
        
        # Get output tensor
        output_data = self.interpreter.get_tensor(
            self.output_details[0]['index']
        )
        
        # Get all predictions
        predictions = output_data[0]
        
        # Create dictionary
        results = {}
        for i, category in enumerate(self.CATEGORIES):
            if i < len(predictions):
                results[category] = float(predictions[i])
            else:
                results[category] = 0.0
        
        return results


# Example usage
if __name__ == "__main__":
    import sys
    
    # Test the classifier
    classifier = CivicImageClassifier()
    
    if len(sys.argv) > 1:
        image_path = sys.argv[1]
        
        print(f"\n🔍 Classifying image: {image_path}")
        category, confidence = classifier.classify(image_path)
        
        print(f"\n✅ Result:")
        print(f"   Category: {category}")
        print(f"   Confidence: {confidence:.2%}")
        
        print(f"\n📊 All predictions:")
        all_preds = classifier.get_all_predictions(image_path)
        for cat, conf in sorted(all_preds.items(), key=lambda x: x[1], reverse=True):
            print(f"   {cat:15s}: {conf:.2%}")
    else:
        print("✅ Classifier initialized successfully!")
        print(f"   Model: {classifier.model_path}")
        print(f"   Categories: {', '.join(classifier.CATEGORIES)}")
        print("\nUsage: python civic_image_classifier.py <image_path>")
