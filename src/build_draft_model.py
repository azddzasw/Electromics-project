# ---------- folder router ----------
input_folder = "data/all_faa"
output_folder = "models/Draft_models"

import os
import pandas as pd
import numpy as np

# ---------- License ----------
os.environ['GRB_LICENSE_FILE'] = 'content/licenses/gurobi.lic'
os.makedirs(output_folder, exist_ok=True)

from dnngior.gapfill_class import Gapfill
from dnngior.NN_Predictor import NN
from cobra.io import write_sbml_model
import gurobipy
from gurobipy import Model


def check_gurobi():
    try:
        model = Model("test")
        print("Gurobi is working! 😄")
    except Exception as e:
        print("Gurobi error:", e)


from modelseedpy.core.rast_client import RastClient
from modelseedpy import MSBuilder
from modelseedpy.core.msgenome import MSGenome

def reconstruct_draft_model(model_id, faa_path, sbml_path, rast):
    print(f"🔍 Processing: {faa_path}")
    try:
        genome = MSGenome.from_fasta(faa_path)
        rast.annotate_genome(genome)

        model = MSBuilder.build_metabolic_model(
            model_id=model_id,
            genome=genome,
            index="0",
            classic_biomass=True,
            gapfill_model=False,
            annotate_with_rast=True,
            allow_all_non_grp_reactions=True
        )

        write_sbml_model(model, sbml_path)
        print(f" Model saved: {sbml_path}")
    except Exception as e:
        print(f"Failed to process {model_id}: {e}")

# ---------- main ----------
def main():

    check_gurobi()

    rast = RastClient()

    for faa_file in os.listdir(input_folder):
        if faa_file.endswith(".faa"):
            faa_path = os.path.join(input_folder, faa_file)
            model_id = faa_file.replace(".faa", "")
            sbml_path = os.path.join(output_folder, model_id + ".sbml")
            reconstruct_draft_model(model_id, faa_path, sbml_path, rast)

if __name__ == "__main__":
    main()


