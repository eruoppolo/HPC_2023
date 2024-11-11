#!/bin/bash
#SBATCH --job-name=bash
#SBATCH --nodes=1                 
#SBATCH --ntasks=1                
#SBATCH --output=output_epyc.%j.out     
#SBATCH --error=error_epyc.%j.err   
#SBATCH --cpus-per-task=128
#SBATCH --time=00:40:00
#SBATCH --partition=EPYC
#SBATCH --exclusive

module load openMPI/4.1.6/gnu/14.2.1

# Executable
executable="../src/mandelbrot"

# Output directory
output_dir="../results/"

# Output file 
output_file="${output_dir}weak_scaling_OMP_EPYC.csv"

# Image parameters
X_LEFT=-2.0
Y_LOWER=-2.0
X_RIGHT=1.0
Y_UPPER=1.0
MAX_ITERATIONS=255

# CSV header
echo "Workers,Size,Time(s)" >> ${output_file}

# Fixed number of processes to use for MPI parallelism with OpenMP threads 
processes=1

# Constant amout of work per worker: C = problem size / number of workers
# Therefore, problem size = C * number of workers
C=1000000

# Scaling the number of threads
for THREADS in {1..128}; do
  threads=$THREADS
  n=$(echo "sqrt($THREADS * $C)" | bc -l | xargs printf "%.0f")
  export OMP_PLACES=threads
  export OMP_PROC_BIND=close
  EXEC_TIME=$(mpirun -np $processes \
    --map-by socket --bind-to socket \
    ${executable} \
    $n $n $X_LEFT $Y_LOWER $X_RIGHT $Y_UPPER $MAX_ITERATIONS $THREADS)
  tail -n 1 <<< "$EXEC_TIME" | awk "{print \"${THREADS},${n},\" \$4}" >> ${output_file}
done

# Store the job ID
job_id=$SLURM_JOB_ID

# sacct to retrieve job statistics and print to standard output
echo "Job Statistics for Job ID $job_id:"
sacct -j $job_id --format=JobID,JobName,Partition,MaxRSS,MaxVMSize,Elapsed,State
