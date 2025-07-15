# Electromics-project

A computational framework for simulating and analyzing **electrogenic microbial systems**, combining metabolic modeling, environmental sampling, functional annotation, and machine learning. This project supports a full workflow from data retrieval and model construction to simulation and downstream analysis.

---
```
##  Project Structure
.
├── content/                  # Documentation and project notes
├── data/                     # Raw and processed input data
├── external/                 # External datasets or tools
├── models/                   # Metabolic model files (e.g., SBML, JSON)
├── notebooks/                # Jupyter notebooks for simulations and analysis
├── results/                  # Simulation and analysis outputs
├── scripts/                  # Shell scripts for data retrieval and preprocessing
├── src/                      # Core Python code (simulation, graph analysis)
├── test/                     # Unit and integration tests
├── README.md                 # Project overview
├── pyproject.toml            # Project configuration (Poetry)
└── poetry.lock               # Dependency lock file
```
---

## 🧪 Features

- ⚙️ **Genome-scale metabolic modeling** with thermodynamic constraints
- 🔄 **Environmental simulation** across 1000+ random media using ball sampling
- 🤖 **Neural network models** to predict biomass or metabolite flux
- 🧬 **Functional profiling** of electrogenic and homoacetogenic populations
- 🧯 **Biofilm and EPS analysis** for anode/cathode community dynamics
- 📊 **Visualization-ready outputs** for plotting with seaborn, matplotlib, or R

---

## Getting Started (with Poetry)

### 1. Clone the repository

```bash
git clone https://github.com/azddzasw/Electromics-project.git
cd Electromics-project
```

### 2. Set up the environment using Poetry
Install Poetry (if not yet installed):
```
bash
curl -sSL https://install.python-poetry.org | python3 -
```

Install dependencies and activate the virtual environment:
```
bash
poetry install
poetry shell
```
Poetry will automatically install all dependencies specified in pyproject.toml.


