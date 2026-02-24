import tflite
import numpy as np
from PIL import Image

def preprocess_image(image_path):
    img = Image.open(image_path).resize((224, 224))
    img_array = np.array(img, dtype=np.float32)
    # the Dart code divides by 255.0 and assumes [1, 224, 224, 3] layout
    # PIL loads as [H, W, Channels].
    # But wait, does PIL loaded PNG have an alpha channel?
    if img_array.shape[2] == 4:
        img_array = img_array[:, :, :3] # drop alpha
    img_array = img_array / 255.0
    img_array = np.expand_dims(img_array, axis=0) # [1, 224, 224, 3]
    return img_array

def main():
    try:
        # Load tflite model using tensorflow.lite because raw tflite library only allows parsing flats, not interpreting.
        import tensorflow as tf
        interpreter = tf.lite.Interpreter(model_path='assets/plant_model_quantized.tflite')
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()

        apple_path = r'C:\Users\arkot\.gemini\antigravity\brain\5ef44983-8f28-469e-8197-76ce4e4dea21\healthy_apple_leaf_1771856756284.png'
        potato_path = r'C:\Users\arkot\.gemini\antigravity\brain\5ef44983-8f28-469e-8197-76ce4e4dea21\potato_blight_1771856901765.png'

        apple_input = preprocess_image(apple_path)
        potato_input = preprocess_image(potato_path)

        interpreter.set_tensor(input_details[0]['index'], apple_input)
        interpreter.invoke()
        apple_output = interpreter.get_tensor(output_details[0]['index'])[0]
        
        interpreter.set_tensor(input_details[0]['index'], potato_input)
        interpreter.invoke()
        potato_output = interpreter.get_tensor(output_details[0]['index'])[0]

        print("Apple Predicted Class:", np.argmax(apple_output), "Confidence:", np.max(apple_output))
        print("Potato Predicted Class:", np.argmax(potato_output), "Confidence:", np.max(potato_output))
    except Exception as e:
        print("Error:", e)

main()
