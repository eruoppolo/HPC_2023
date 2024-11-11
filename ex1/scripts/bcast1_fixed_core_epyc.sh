#!/bin/bash
#SBATCH --job-name=bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=01:59:59
#SBATCH --partition EPYC
#SBATCH --exclusive


module load openMPI/4.1.6/gnu/14.2.1

echo "Processes,Size,Latency" > bcast1_fixed_core.csv

# Numero di ripetizioni per ottenere una media
repetitions=10000

# Ciclo esterno per il numero di processori
for processes in {2..256}
do
    # Calcola la dimensione come 2 elevato alla potenza corrente
    size=4

    # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
    result_bcast=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_bcast_algorithm 1 ../osu_bcast -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

    echo "$processes, $size, $result_bcast"
    # Scrivi i risultati nel file CSV
    echo "$processes,$size,$result_bcast" >> bcast2_fixed_core.csv

done
