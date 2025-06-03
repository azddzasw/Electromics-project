from cobra import Reaction, Metabolite
import cobra
import os

def makeMissingReaction(model, met_in, met_out):
    new_reaction_1 = Reaction('EX_' + met_out.id)
    new_reaction_1.name = met_out.name + ' exchange'
    new_reaction_1.lower_bound = -1000
    new_reaction_1.upper_bound = 1000
    new_reaction_1.add_metabolites({met_out: -1.0})

    new_reaction_2 = Reaction('TR_' + met_in.id)
    new_reaction_2.name = met_in.name + ' transport'
    new_reaction_2.lower_bound = -1000
    new_reaction_2.upper_bound = 1000
    new_reaction_2.add_metabolites({met_out: -1.0, met_in: 1.0})

    model.add_reactions([new_reaction_1, new_reaction_2])
    return model

def fix_exchange_reactions(model_in, list_of_metabolites):
    for met in list_of_metabolites:
        if model_in.metabolites.has_id(met):
            met_in = model_in.metabolites.get_by_id(met)
            met_out = Metabolite(met_in.id.replace("_c0", "_e0"),
                                 formula = met_in.formula,
                                 name= met_in.name.replace("_c0", "_e0"),
                                 compartment='e0')
            makeMissingReaction(model_in, met_in, met_out)
            print(f"Added exchange reaction for {met} in {model_in.id}")
    return model_in.copy()

def add_exchange_reactions(model_in, list_of_metabolites):
    for met_id in list_of_metabolites:
        if model_in.metabolites.has_id(met_id):
            met_in = model_in.metabolites.get_by_id(met_id)
        else:
            met_in = Metabolite(met_id,
                                name=met_id,
                                compartment='c0')
            model_in.add_metabolites([met_in])

        met_out_id = met_id.replace('_c0', '_e0')
        met_out = Metabolite(met_out_id,
                             name=met_out_id,
                             formula=met_in.formula,
                             compartment='e0')

        makeMissingReaction(model_in, met_in, met_out)
        print(f"add exchange & transport for {met_id} in {model_in.id}")

    return model_in.copy()