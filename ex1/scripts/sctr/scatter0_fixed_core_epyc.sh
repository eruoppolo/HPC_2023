#!/bin/bash
#SBATCH --job-name=HPC
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=01:59:59
#SBATCH --partition EPYC
#SBATCH --exclusive


module load openMPI/4.1.6/gnu/14.2.1

echo "Processes,Size,Latency" > scatter0_fixed_core.csv
echo "Processes,Size,Latency" > scatter1_fixed_core.csv
echo "Processes,Size,Latency" > scatter2_fixed_core.csv
echo "Processes,Size,Latency" > scatter3_fixed_core.csv

# Repetitions to get an average result
repetitions=10000

# Fixed message size
size=4

# Cycling over different algorithms
for algoritm in {0..3}
do
    for processes in {2..256}
    do
    
        # Perform osu_scatter with current processors, fixed message size and fixed number of repetitions
        result_scatter=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm $algoritm ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')
    
        echo "$processes, $size, $result_scatter"
        # Write results on CSV
        echo "$processes,$size,$result_scatter" >> scatter0_fixed_core.csv
    
    done
done


