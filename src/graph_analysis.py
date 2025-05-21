import networkx as nx

def build_flux_graph(model, solution):
    G = nx.DiGraph()
    for rxn in model.reactions:
        flux = solution.fluxes[rxn.id]
        for reactant in rxn.reactants:
            for product in rxn.products:
                G.add_edge(reactant.id, product.id, reaction=rxn.id, flux=flux)
    return G


def trace_flux_break(G, target_met, max_depth=10):
    """
    Trace the recent flux break
     """
    visited = set()
    queue = [(target_met, [])]
    print(f" Starting from: {target_met}")
    while queue:
        current, path = queue.pop(0)
        if len(path) > max_depth:
            continue
        if current in visited:
            continue
        visited.add(current)
        for pred in G.predecessors(current):
            edge = G[pred][current]
            rxn = edge['reaction']
            flux = edge['flux']
            new_path = path + [(rxn, pred, current, flux)]
            if abs(flux) < 1e-6:
                print(" Path blocked at:")
                for r, fr, to, fx in new_path:
                    print(f"  - {r}: {fr} ➝ {to} | flux={fx}")
                return
            else:
                queue.append((pred, new_path))
    print(" No blocked path found within depth limit.")
    

def find_root_blockers(model, solution, start_met_id, visited=None, depth=0, max_depth=100, root_blocks=None):
    """
    递归查找阻断根节点

    """
    if visited is None:
        visited = set()
    if root_blocks is None:
        root_blocks = set()

    if depth > max_depth:
        return root_blocks
    if start_met_id in visited:
        return root_blocks
    visited.add(start_met_id)

    met_obj = model.metabolites.get_by_id(start_met_id)
    producers = [r for r in met_obj.reactions if met_obj in r.products]

    if not producers:
        root_blocks.add(start_met_id)
        return root_blocks

    all_blocked = True
    for rxn in producers:
        flux = solution.fluxes.get(rxn.id, 0.0)
        if abs(flux) >= 1e-6:
            all_blocked = False
            break

    if all_blocked:
        for rxn in producers:
            for reactant in rxn.reactants:
                find_root_blockers(model, solution, reactant.id, visited, depth+1, max_depth, root_blocks)
    else:
        pass

    return root_blocks
