import numpy as np
import tensorflow as tf

def main():
    try:
        interpreter = tf.lite.Interpreter(model_path='assets/plant_model_quantized.tflite')
        interpreter.allocate_tensors()
        
        input_details = interpreter.get_input_details()
        output_details = interpreter.get_output_details()
        
        # Test 1: Zeros
        input_data_zeros = np.zeros((1, 224, 224, 3), dtype=np.float32)
        interpreter.set_tensor(input_details[0]['index'], input_data_zeros)
        interpreter.invoke()
        output_zeros = interpreter.get_tensor(output_details[0]['index'])[0]
        
        # Test 2: Ones
        input_data_ones = np.ones((1, 224, 224, 3), dtype=np.float32)
        interpreter.set_tensor(input_details[0]['index'], input_data_ones)
        interpreter.invoke()
        output_ones = interpreter.get_tensor(output_details[0]['index'])[0]

        # Test 3: Random
        input_data_rand = np.random.rand(1, 224, 224, 3).astype(np.float32)
        interpreter.set_tensor(input_details[0]['index'], input_data_rand)
        interpreter.invoke()
        output_rand = interpreter.get_tensor(output_details[0]['index'])[0]

        print("--- TFLITE MODEL DIAGNOSTICS ---")
        print(f"Zeros Output Max: {np.max(output_zeros):.5f} at Index {np.argmax(output_zeros)}")
        print(f"Ones Output Max:  {np.max(output_ones):.5f} at Index {np.argmax(output_ones)}")
        print(f"Rand Output Max:  {np.max(output_rand):.5f} at Index {np.argmax(output_rand)}")
        
        print("\nOutputs Identical Check:")
        print(f"Zeros == Ones: {np.allclose(output_zeros, output_ones)}")
        print(f"Zeros == Rand: {np.allclose(output_zeros, output_rand)}")
        
        print("\nFirst 10 of Zeros:", output_zeros[:10])
        print("First 10 of Ones: ", output_ones[:10])

    except Exception as e:
        print("Error:", e)

if __name__ == '__main__':
    main()
