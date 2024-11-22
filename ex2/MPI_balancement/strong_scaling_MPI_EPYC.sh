#!/bin/bash
#SBATCH --job-name=bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --output=output_epyc.%j.out
#SBATCH --error=error_epyc.%j.err
#SBATCH --time=02:00:00
#SBATCH --partition=EPYC
#SBATCH --exclusive

module load openMPI/4.1.6/gnu/14.2.1

# Check if module loaded successfully
if [ $? -ne 0 ]; then
    echo "Error: Failed to load OpenMPI module"
    exit 1
fi

# Create directories if they don't exist
mkdir -p ../results ../plots

executable="mandelbrot"
output_dir=""
output_file="${output_dir}strong_scaling_MPI_EPYC_ms.csv"

# Check if executable exists
if [ ! -f "$executable" ]; then
    echo "Error: Executable $executable not found!"
    exit 1
fi

# Constants
n=10000
X_LEFT=-2.0
Y_LOWER=-1.5
X_RIGHT=2.0
Y_UPPER=1.5
MAX_ITERATIONS=255
THREADS=1

# Initialize CSV with header
echo "Workers,Size,ComputeTime,IOTime,TotalTime" > ${output_file}

for processes in {2..256}; do
    
    echo "Running with $processes processes, image size ${n}x${n}"
    
    # Run with timeout to prevent hanging
    timeout 3600 mpirun -np ${processes} \
        --map-by core --bind-to core \
        ${executable} \
        $n $n $X_LEFT $Y_LOWER $X_RIGHT $Y_UPPER $MAX_ITERATIONS $THREADS || {
            echo "Error: MPI run failed for $processes processes"
            continue
        }
    
    # Extract timing information and append to CSV
    compute_time=$(grep "Compute time:" output_epyc.${SLURM_JOB_ID}.out | tail -n 1 | awk '{print $3}')
    io_time=$(grep "I/O time:" output_epyc.${SLURM_JOB_ID}.out | tail -n 1 | awk '{print $3}')
    total_time=$(grep "Total time:" output_epyc.${SLURM_JOB_ID}.out | tail -n 1 | awk '{print $3}')
    
    echo "$processes,$n,$compute_time,$io_time,$total_time" >> ${output_file}
    
    # Verify data was written
    if [ ! -s "$output_file" ]; then
        echo "Warning: No data written to CSV file for $processes processes"
    fi
    
    # Add small delay between runs
    sleep 2
done

# Print final job statistics
echo -e "\nJob Statistics for Job ID $SLURM_JOB_ID:"
sacct -j $SLURM_JOB_ID --format=JobID,JobName,Partition,MaxRSS,MaxVMSize,Elapsed,State

# Print scaling results summary
echo -e "\nScaling Results Summary:"
echo "========================="
echo "Results saved in: $output_file"
echo "Number of tests completed: $(( $(wc -l < $output_file) - 1 ))"
echo "Largest image size: $(tail -n 1 $output_file | cut -d',' -f2)x$(tail -n 1 $output_file | cut -d',' -f2)"
echo "Maximum number of processes: $processes"
