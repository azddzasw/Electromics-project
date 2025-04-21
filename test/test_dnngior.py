import os, sys
# set the gurobi license
os.environ['GRB_LICENSE_FILE'] = '/Users/azddza/Electromics-project/content/licenses/gurobi.lic'

import cobra

import dnngior

# set to the location of the DNNGIOR repository
models_path = "/Users/azddza/Electromics-project/external/DNNGIOR/docs/models"
path_to_blautia_model = os.path.join(models_path, "bh_ungapfilled_model.sbml")

draft_reconstruction = cobra.io.read_sbml_model(path_to_blautia_model)

print(f"The solution of the draft reconstruction is:\n\n{draft_reconstruction.optimize()}",  "\U0001F63F", "\n")

gapfill = dnngior.Gapfill(draftModel = path_to_blautia_model,
                                          medium = None,
                                          objectiveName = 'bio1')

print("Number of reactions added:", len(gapfill.added_reactions))
print("~~")
for reaction in gapfill.added_reactions:
    print(f"Name: {gapfill.gapfilledModel.reactions.get_by_id(reaction).name}", "\n", f"Equation: {gapfill.gapfilledModel.reactions.get_by_id(reaction).build_reaction_string(use_metabolite_names=True)}")


gf_model = gapfill.gapfilledModel.copy()

print(f"The solution of the gapfilled reconstruction is:\n\n{gf_model.optimize()}",  "\U0001F63A", "\n")