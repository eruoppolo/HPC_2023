#!/bin/bash
#SBATCH --job-name=bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=128
#SBATCH --time=01:59:00
#SBATCH --partition EPYC
#SBATCH --exclusive

module load openMPI/4.1.6/gnu/14.2.1

echo "Nodi utilizzati: $SLURM_NODELIST"
echo "SCATTER 2-3"
echo "Processes,Size,Latency" > scatter2_core_mapping_epyc.csv
echo "Processes,Size,Latency" > scatter3_core_mapping_epyc.csv

# Numero di ripetizioni per ottenere una media
repetitions=10000

# Ciclo esterno per il numero di processori
for processes_size in {1..8}
do
    processes=$((2**processes_size))
    # Ciclo interno per la dimensione del messaggio da 2^1 a 2^20
    for size_power in {1..18}
    do
        # Calcola la dimensione come 2 elevato alla potenza corrente
        size=$((2**size_power))

        # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
        result_bcast=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm 2 ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

        echo "$processes, $size, $result_bcast"
        # Scrivi i risultati nel file CSV
        echo "$processes,$size,$result_bcast" >> scatter2_core_mapping_epyc.csv
    done
done

# Ciclo esterno per il numero di processori
for processes_size in {1..8}
do
    processes=$((2**processes_size))
    # Ciclo interno per la dimensione del messaggio da 2^1 a 2^20
    for size_power in {1..18}
    do
        # Calcola la dimensione come 2 elevato alla potenza corrente
        size=$((2**size_power))

        # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
        result_bcast=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm 3 ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

        echo "$processes, $size, $result_bcast"
        # Scrivi i risultati nel file CSV
        echo "$processes,$size,$result_bcast" >> scatter3_core_mapping_epyc.csv
    done
done
