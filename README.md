# High Performance Computing - UniTS
## Exam project - Class 2023/2024 - Emanuele Ruoppolo

### Performance Evaluation of OpenMPI collective operations
The aim of this project is to assess the performances of the OpenMPI library's **collective operations** on the EPYC partition of the ORFEO cluster. Many optimizations options have been tested for two specific collective algorithms: broadcast and scatter. Particularly the results presented evaluate the performance of a four of their possible implementations.
### Mandelbrot Set Computation - Hybrid Implementation
The aim of this project is to implement a **hybrid MPI+OpenMP** version of the Mandelbrot set computation algorithm, leveraging MPI for distributed memory parallelism and OpenMP for shared memory parallelism, and verifying the scaling performances of the code on the ORFEO cluster. The code was implemented using the C programming language and the MPI and OpenMP libraries. The performances were evaluated by measuring the speedup and efficiency of the code for different numbers of processes and threads. Both strong and weak scaling tests were conducted, either by fixing the MPI tasks and increasing the OMP threads or running a single OMP thread per MPI task and increasing the number of MPI tasks.
