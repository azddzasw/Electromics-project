import cobra
from cobra.io import load_model

model = load_model("textbook")

solution = model.optimize()

print(f"flux balance analysis solution is {solution.objective_value}")

print("COBRApy is working", "\U0001F600")