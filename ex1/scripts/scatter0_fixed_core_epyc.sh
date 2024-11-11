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

# Numero di ripetizioni per ottenere una media
repetitions=10000
size=4

# Ciclo esterno per il numero di processori
for processes in {2..256}
do
    # Calcola la dimensione come 2 elevato alla potenza corrente

    # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
    result_scatter=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm 0 ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

    echo "$processes, $size, $result_scatter"
    # Scrivi i risultati nel file CSV
    echo "$processes,$size,$result_scatter" >> scatter0_fixed_core.csv

done

# Ciclo esterno per il numero di processori
for processes in {2..256}
do
    # Calcola la dimensione come 2 elevato alla potenza corrente

    # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
    result_scatter=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm 1 ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

    echo "$processes, $size, $result_scatter"
    # Scrivi i risultati nel file CSV
    echo "$processes,$size,$result_scatter" >> scatter1_fixed_core.csv

done

# Ciclo esterno per il numero di processori
for processes in {2..256}
do
    # Calcola la dimensione come 2 elevato alla potenza corrente

    # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
    result_scatter=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm 2 ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

    echo "$processes, $size, $result_scatter"
    # Scrivi i risultati nel file CSV
    echo "$processes,$size,$result_scatter" >> scatter2_fixed_core.csv

done


# Ciclo esterno per il numero di processori
for processes in {2..256}
do
    # Calcola la dimensione come 2 elevato alla potenza corrente

    # Esegui osu_bcast con numero di processi, dimensione fissa e numero di ripetizioni su due nodi
    result_scatter=$(mpirun --map-by core -np $processes --mca coll_tuned_use_dynamic_rules true --mca coll_tuned_scatter_algorithm 3 ../osu_scatter -m $size -x $repetitions -i $repetitions | tail -n 1 | awk '{print $2}')

    echo "$processes, $size, $result_scatter"
    # Scrivi i risultati nel file CSV
    echo "$processes,$size,$result_scatter" >> scatter3_fixed_core.csv

done


