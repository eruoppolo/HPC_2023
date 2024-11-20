# HPC Final Project: Exercise 1

## Table of contents
- [Project structure](#project-structure)
- [Data gathering](#data-gathering)

## Project structure

```
📂 ex1/
│ 
├── 📂 scripts/
│   │
│   ├── 📂 bcast/
│   │   │
│   │   ├── 📂 fixed/
│   │   │   ├── ⚙️ bcast0_fixed_core_epyc.sh
│   │   │   └── ⚙️ ...
│   │   │
│   │   └── 📂 varied/
│   │        └── ⚙️ ...
│   │
│   └── 📂 scatter/
│       │
│       ├── 📂 fixed/
│       │   └── ⚙️ ...
│       │
│       └── 📂 varied/
│            └── ⚙️ ...
│
├── 📂 results/
│   │
│   ├── 📂 bcast/
│   │   │
│   │   ├── 📂 fixed_size/
│   │   │   ├── 📊 bcast0_fixed_core.csv
│   │   │   ├── 📊 bcast1_fixed_core.csv	
│   │   │   ├── 📊 bcast3_fixed_core.csv	
│   │   │   └── 📊 bcast5_fixed_core.csv
│   │   │
│   │   ├── 📂 map-by-sock/
│   │   │   ├── 📊 bcast3_fixed_socket.csv
│   │   │   └── 📊 bcast5_fixed_socket.csv
│   │   │
│   │   └── 📂 var_size/
│   │       ├── 📊 bcast0_core_mapping_epyc.csv
│   │       ├── 📊 bcast1_core_mapping_epyc.csv
│   │       ├── 📊 bcast3_core_mapping_epyc.csv
│   │       └── 📊 bcast5_core_mapping_epyc.csv
│   │
│   └── 📂 scatter/
│       │
│       ├── 📂 fixed_size/
│       │   ├── 📊 scatter0_fixed_core.csv
│       │   ├── 📊 scatter1_fixed_core.csv	
│       │   ├── 📊 scatter2_fixed_core.csv	
│       │   └── 📊 scatter_fixed_core.csv
│       │
│       └── 📂 var_size/
│           ├── 📊 scatter0_core_mapping_epyc.csv
│           ├── 📊 scatter_core_mapping_epyc.csv
│           ├── 📊 scatter3_core_mapping_epyc.csv
│           └── 📊 scatter5_core_mapping_epyc.csv
│ 
├── 📂 analysis/
│   └──🔎 analysis.ipynb
│
├── 📂 plots/...  
│
├── 📝 RUOPPOLO_ex1_report.pdf
│
├── 🗒️ slides.pdf
│   
└── 📰 README.md

```


# Data gathering

The entire data gathering process was automated by using some bash scripts, which were then submitted to the cluster using the **SLURM** workload manager, utilizing the *sbatch* command for streamlined execution.

