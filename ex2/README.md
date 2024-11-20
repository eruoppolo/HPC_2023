# HPC Final Project: Exercise 2c

![Alt text](ex2/plots/mandelbrot_mpi.png "Mandelbrot set")

## Table of contents
- [Project structure](#project-structure)
- [Data gathering](#data-gathering)

## Project structure

```
📂 ex1/
│ 
├── 📂 scripts/
│   ├── ⏳ strong_scaling_MPI_EPYC.sh
│   ├── ⏳ strong_scaling_OMP_EPYC.sh
│   ├── ⏳ weak_scaling_MPI_EPYC.sh
│   └── ⏳ weak_scaling_OMP_EPYC.sh
│
├── 📂 src/
│   ├── 🔨 Makefile
│   ├── ⚙️ mandelbrot
│   └── 🧱 mandelbrot.c
│
├── 📂 results/
│   ├── 🔎 scaling_analysis.ipynb
│   ├── 📋 analysis_report_strong.md
│   ├── 📋 analysis_report_strong.md
│   ├── 📊 strong_scaling_MPI_EPYC.csv
│   ├── 📊 strong_scaling_OMP_EPYC.csv
│   ├── 📊 weak_scaling_MPI_EPYC.csv
│   └── 📊 weak_scaling_OMP_EPYC.csv
│
├── 📂 plots/...  
│
├── 📝 RUOPPOLO_ex2_report.pdf
│
├── 🗒️ slides.pdf
│   
└── 📰 README.md

```


# Data gathering

The entire data gathering process was automated by using some bash scripts, which were then submitted to the cluster using the **SLURM** workload manager, utilizing the *sbatch* command for streamlined execution.

