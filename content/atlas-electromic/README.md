# ATLAS-Electromic

## Data

```sh
cd /save_projet/electromic
mkdir goodData
cd /save_projet/electromic/goodData
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0001_1.fq.gz R1J142A_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0001_2.fq.gz R1J142A_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0002_1.fq.gz R2J142A_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0002_2.fq.gz R2J142A_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0003_1.fq.gz R3J142A_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0003_2.fq.gz R3J142A_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0004_1.fq.gz R4J147A_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0004_2.fq.gz R4J147A_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0005_1.fq.gz R5J141A_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0005_2.fq.gz R5J141A_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0006_1.fq.gz R6J143A_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0006_2.fq.gz R6J143A_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0007_1.fq.gz R4J147C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0007_2.fq.gz R4J147C_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0008_1.fq.gz R5J141C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0008_2.fq.gz R5J141C_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0009_1.fq.gz R6J143C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0009_2.fq.gz R6J143C_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0010_1.fq.gz Sg1AJ36C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0010_2.fq.gz Sg1AJ36C_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0011_1.fq.gz Sg1BJ36C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0011_2.fq.gz Sg1BJ36C_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0012_1.fq.gz Sg1CJ36C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0012_2.fq.gz Sg1CJ36C_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0013_1.fq.gz NSg1AJ41C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0013_2.fq.gz NSg1AJ41C_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0014_1.fq.gz NSg1BJ41C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0014_2.fq.gz NSg1BJ41C_2.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0015_1.fq.gz NSg1CJ41C_1.fastq.gz
ln -s /save_projet/electromic/Data/Unknown_CK389-002R0015_2.fq.gz NSg1CJ41C_2.fastq.gz
```

## atlas init

```sh
cd /work_projet/electromic/atlas-electromic/
conda activate metagenome-atlas-2.19.0
atlas init --db-dir /work_home/cmidoux/atlas-databases --working-dir /work_projet/electromic/atlas-results --assembler spades --data-type metagenome --threads 8 /save_projet/electromic/goodData/

# [Atlas] INFO: I inferred that _1 and _2 distinguish paired end reads.
# [Atlas] INFO: Found 15 samples
# [Atlas] INFO: Configuration file written to /work_projet/electromic/atlas-results/config.yaml
#         You may want to edit it using any text editor.
```

- See [`samples.tsv`](samples.tsv) (BinGroup by `Reactor_type;Compartment;Community`)
- See [`config.yaml`](config.yaml) (`final_binner: metabat`)

## atlas run

We use [`migale/atlas-cluster-profiles`](https://forgemia.inra.fr/migale/atlas-cluster-profiles).

```sh
mkdir  logs/atlas/ -p
qsub -cwd -V -N atlasElectromic -o logs/atlas/ -e logs/atlas/  -pe thread 8 -q infinit.q -b y "conda activate metagenome-atlas-2.19.0 && atlas run all genecatalog combine_gene_coverages --profile /save_home/cmidoux/ATLAS/atlas-cluster-profiles/sge --working-dir /work_projet/electromic/atlas-results && conda deactivate"
```
