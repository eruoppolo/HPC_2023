#!/bin/bash
#SBATCH --job-name=HPC
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=02:00:00
#SBATCH --partition EPYC
#SBATCH --exclusive

module load openMPI/4.1.6/gnu/14.2.1

echo "Nodi utilizzati: $SLURM_NODELIST"
echo "BROADCAST 3-5"
echo "Processes,Size,Latency" > bcast3_core_mapping_epyc.csv
echo "Processes,Size,Latency" > bcast5_core_mapping_epyc.csv

# Number of repetitions to get an average result
repetitions=10000
#------------BCAST3--------------
# Cycle over processors
for processes_size in {1..8}
do
    # Set number of processors from 2^1 to 2^8
    processes=$((2**processes_size))
    # Set message size from 2^1 to 2^18
    for size_power in {1..18}
    do
        # Calcola la dimensione come 2 elevato alla potenza corrente
        size=$((2**size_power))

        # Perform osu_bcast3
        result_bcast=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_bcast_algorithm 3 ../osu_bcast -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

        echo "$processes, $size, $result_bcast"
        # Write results on CSV
        echo "$processes,$size,$result_bcast" >> bcast3_core_mapping_epyc.csv
    done
done
#------------BCAST5--------------
# Ciclo esterno per il numero di processori
for processes_size in {1..8}
do
    # Set number of processors from 2^1 to 2^8
    processes=$((2**processes_size))
    # Set message size from 2^1 to 2^18
    for size_power in {1..18}
    do
        # Compute message size
        size=$((2**size_power))

        # Perform osu_bcast5
        result_bcast=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_bcast_algorithm 5 ../osu_bcast -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

        echo "$processes, $size, $result_bcast"
        # Write results on CSV
        echo "$processes,$size,$result_bcast" >> bcast5_core_mapping_epyc.csv
    done
done
