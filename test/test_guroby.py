#set up the gurobi license
import os
os.environ['GRB_LICENSE_FILE'] = '../content/licenses/gurobi.lic'

import gurobipy
from gurobipy import Model
model = Model("test")
print("Gurobi is working!", "\U0001F600")