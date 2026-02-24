import tflite

with open('assets/plant_model_quantized.tflite', 'rb') as f:
    buf = f.read()
    model = tflite.Model.GetRootAsModel(buf, 0)
    subgraph = model.Subgraphs(0)
    
    print("--- INPUTS ---")
    for i in range(subgraph.InputsLength()):
        tensor = subgraph.Tensors(subgraph.Inputs(i))
        print(f"Input {i}: Name={tensor.Name().decode('utf-8')}, Shape={tensor.ShapeAsNumpy()}, Type={tensor.Type()}")
        
    print("--- OUTPUTS ---")
    for i in range(subgraph.OutputsLength()):
        tensor = subgraph.Tensors(subgraph.Outputs(i))
        print(f"Output {i}: Name={tensor.Name().decode('utf-8')}, Shape={tensor.ShapeAsNumpy()}, Type={tensor.Type()}")
