#!/bin/bash
#SBATCH --job-name=bash
#SBATCH --nodes=1                 # Usa un singolo nodo per il test OpenMP
#SBATCH --ntasks=1                # Singolo task MPI
#SBATCH --output=output_epyc.%j.out     
#SBATCH --error=error_epyc.%j.err   
#SBATCH --cpus-per-task=128       # Fino a 128 CPU disponibili per OpenMP
#SBATCH --time=00:40:00
#SBATCH --partition=EPYC
#SBATCH --exclusive
module load openMPI/4.1.6/gnu/14.2.1

#executable
executable="../src/mandelbrot"

# Output directory
output_dir="../results/"

# Output file 
output_file="${output_dir}weak_scaling_OMP_EPYC.csv"



# Definisci altri parametri per l'immagine
X_LEFT=-2.0
Y_LOWER=-2.0
X_RIGHT=1.0
Y_UPPER=1.0
MAX_ITERATIONS=255


# Add CSV header
echo "Workers,Size,Time(s)" >> ${output_file}

# Define the number of processes to use for MPI parallelism with OpenMP theads 
processes=1

C=1000000
# Esegui il programma per ogni numero di thread OpenMP aumentando linearmente la larghezza
for THREADS in {1..128}; do

  threads=$THREADS
  n=$(echo "sqrt($THREADS * $C)" | bc -l | xargs printf "%.0f")
  export OMP_PLACES=threads
  export OMP_PROC_BIND=close
  # Esegui il programma con un singolo processo MPI (-np 1) e cattura il tempo di esecuzione
  EXEC_TIME=$(mpirun -np 1 \
    --map-by socket --bind-to socket \
    ${executable} \
    $n $n $X_LEFT $Y_LOWER $X_RIGHT $Y_UPPER $MAX_ITERATIONS $THREADS)
  tail -n 1 <<< "$EXEC_TIME" | awk "{print \"${THREADS},${n},\" \$4}" >> ${output_file}
done

# Store the job ID
job_id=$SLURM_JOB_ID

# Run sacct to retrieve job statistics and print to standard output
echo "Job Statistics for Job ID $job_id:"
sacct -j $job_id --format=JobID,JobName,Partition,MaxRSS,MaxVMSize,Elapsed,State
