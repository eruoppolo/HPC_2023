#!/bin/bash
#SBATCH --job-name=bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=01:59:59
#SBATCH --partition EPYC
#SBATCH --exclusive


module load openMPI/4.1.6/gnu/14.2.1

echo "Processes,Size,Latency" > bcast0_fixed_core.csv

# Repetitions to get an average result
repetitions=10000

# Fixed message size
size=4

for processes in {2..256}
do


    # Perform osu_bcast with current processors, fixed message size and fixed number of repetitions
    result_bcast=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_bcast_algorithm 0 ../osu_bcast -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

    echo "$processes, $size, $result_bcast"
    # Write results on CSV
    echo "$processes,$size,$result_bcast" >> bcast0_fixed_core.csv

done
