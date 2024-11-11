#!/bin/bash
#SBATCH --job-name=bash
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --time=00:15:00
#SBATCH --partition EPYC
#SBATCH --exclusive


module load openMPI/4.1.6/gnu/14.2.1

# Ottenere i nomi dei nodi assegnati
#
echo "Test 2"
nodes=($(scontrol show hostname))
hostname1=${nodes[0]}
hostname2=${nodes[1]:-$hostname1} # Se viene assegnato un solo nodo, utilizza lo stesso nodo per hostname2

# Specificare le coppie di core per ciascun test
core_pairs=(
    "0,1"    # Same CCX
    "0,4"    # Same CCD, Different CCX
    "0,8"    # Same NUMA
    "0,16"   # Same SOCKET
    "0,32"   # Different SOCKET
    "0,0"    # Different NODE (uso di hostname1 e hostname2)
)

# Eseguire i test di latenza
echo "Running osu_latency tests across different core configurations..."

# Test Same CCX
echo "Testing Same CCX"
mpirun -np 2 --cpu-list ${core_pairs[0]} ../../../pt2pt/standard/osu_latency

# Test Same CCD, Different CCX
echo "Testing Same CCD, Different CCX"
mpirun -np 2 --cpu-list ${core_pairs[1]} ../../../pt2pt/standard/osu_latency

# Test Same NUMA
echo "Testing Same NUMA"
mpirun -np 2 --cpu-list ${core_pairs[2]} ../../../pt2pt/standard/osu_latency

# Test Same SOCKET, Different SOCKET
echo "Testing Same SOCKET"
mpirun -np 2 --cpu-list ${core_pairs[3]} ../../../pt2pt/standard/osu_latency

# Test Different SOCKET
echo "Testing Different SOCKET"
mpirun -np 2 --cpu-list ${core_pairs[4]} ../../../pt2pt/standard/osu_latency

# Test Different NODE (usando hostname1 e hostname2)
echo "Testing Different NODE"
mpirun -np 2 --host $hostname1,$hostname2 --cpu-list ${core_pairs[5]} ../../../pt2pt/standard/osu_latency

echo "All tests completed."

