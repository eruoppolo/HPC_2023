#!/bin/bash
#SBATCH --job-name=bash
#SBATCH --nodes=2                 # Usa un singolo nodo per il test OpenMP
#SBATCH --ntasks-per-node=128               # Singolo task MPI
#SBATCH --output=output_epyc.%j.out     
#SBATCH --error=error_epyc.%j.err   
#SBATCH --time=02:00:00
#SBATCH --partition=EPYC
#SBATCH --exclusive

module load openMPI/4.1.6/gnu/14.2.1

#executable
executable="../src/mandelbrot"

# Output directory
output_dir="../results/"

# Output file 
output_file="${output_dir}strong_scaling_MPI_EPYC.csv"

n=1000

# Definisci altri parametri per l'immagine
X_LEFT=-2.0
Y_LOWER=-2.0
X_RIGHT=1.0
Y_UPPER=1.0
MAX_ITERATIONS=255


# Add CSV header
echo "Workers,Size,Time(s)" >> ${output_file}

# Define the number of processes to use for MPI parallelism with OpenMP theads 
THREADS=1

# Esegui il programma per ogni numero di thread OpenMP aumentando linearmente la larghezza
for processes in {1..256}; do
  processes=$processes
  # Esegui il programma con un singolo processo MPI (-np 1) e cattura il tempo di esecuzione
  EXEC_TIME=$(mpirun -np ${processes} \
    --map-by core \
    ${executable} \
    $n $n $X_LEFT $Y_LOWER $X_RIGHT $Y_UPPER $MAX_ITERATIONS $THREADS)
  tail -n 1 <<< "$EXEC_TIME" | awk "{print \"${processes},${n},\" \$4}" >> ${output_file}
done

# Store the job ID
job_id=$SLURM_JOB_ID

# Run sacct to retrieve job statistics and print to standard output
echo "Job Statistics for Job ID $job_id:"
sacct -j $job_id --format=JobID,JobName,Partition,MaxRSS,MaxVMSize,Elapsed,State
