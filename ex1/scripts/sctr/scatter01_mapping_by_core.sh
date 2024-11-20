#!/bin/bash
#SBATCH --job-name=HPC
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=01:59:00
#SBATCH --partition EPYC
#SBATCH --exclusive

module load openMPI/4.1.6/gnu/14.2.1

echo "Nodi utilizzati: $SLURM_NODELIST"
echo "SCATTER 0-1"
echo "Processes,Size,Latency" > scatter0_core_mapping_epyc.csv
echo "Processes,Size,Latency" > scatter1_core_mapping_epyc.csv

# Number of repetitions to get an average result
repetitions=10000
#----------------SCATTER 0---------------
# Cycle over processors
for processes_size in {1..8}
do
    # Set number of processors from 2^1 to 2^8
    processes=$((2**processes_size))
    # Set message size from 2^1 to 2^18
    for size_power in {1..18}
    do
        # Compute message size
        size=$((2**size_power))

        # Perform osu_scatter0
        result_scatter=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm 0 ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

        echo "$processes, $size, $result_scatter"
        # Write results on CSV
        echo "$processes,$size,$result_scatter" >> scatter0_core_mapping_epyc.csv
    done
done
#----------------SCATTER 1---------------
# Cycle over processors
for processes_size in {1..8}
do
    # Set number of processors from 2^1 to 2^8
    processes=$((2**processes_size))
    # Set message size from 2^1 to 2^18
    for size_power in {1..18}
    do
        # Compute message size
        size=$((2**size_power))

        # Perform osu_scatter1
        result_scatter=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm 1 ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

        echo "$processes, $size, $result_scatter"
        # Write results on CSV
        echo "$processes,$size,$result_scatter" >> scatter1_core_mapping_epyc.csv
    done
done
