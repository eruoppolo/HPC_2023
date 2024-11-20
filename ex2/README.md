# HPC Final Project: Exercise 2c

The aim of this project is to implement a hybrid MPI+OpenMP version of the Mandelbrot set computation algorithm, leveraging MPI for distributed memory parallelism and OpenMP for shared memory parallelism, and verifying the scaling performances of the code on the ORFEO cluster. The code was implemented using the C programming language and the MPI and OpenMP libraries. The performances were evaluated by measuring the speedup and efficiency of the code for different numbers of processes and threads. Both strong and weak scaling tests were conducted, either by fixing the MPI tasks and increasing the OMP threads or running a single OMP thread per MPI task and increasing the number of MPI tasks.

<div style="text-align: center;">
    <img src="plots/mandelbrot_mpi.png" alt="Alt text" width="400" height="400">
</div>

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

