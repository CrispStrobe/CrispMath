import torch
import torch.nn as nn

# A simple mock "transformer" that takes an integer sequence and outputs an integer sequence
class DummyMathNLP(nn.Module):
    def __init__(self):
        super(DummyMathNLP, self).__init__()
        self.linear = nn.Linear(10, 10)

    def forward(self, x):
        # x is [batch_size, 10]
        return self.linear(x)

model = DummyMathNLP()
model.eval()

dummy_input = torch.randn(1, 10)

torch.onnx.export(model, dummy_input, "assets/models/math_nlp.onnx", 
                  export_params=True, opset_version=14, 
                  do_constant_folding=True, 
                  input_names = ['input'], output_names = ['output'])
print("Created dummy assets/models/math_nlp.onnx")
