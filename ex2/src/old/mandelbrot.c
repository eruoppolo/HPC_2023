#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <omp.h>
#include <string.h>
#include <time.h>

// Function to write PGM image
void write_pgm_image( void *image, int maxval, int xsize, int ysize, const char *image_name){
  FILE* image_file;
  image_file = fopen(image_name, "w");

  // Writing the header of the PGM file
  fprintf(image_file, "P5\n# generated by\n# Emanuele Ruoppolo\n%d %d\n%d\n", xsize, ysize, maxval);

  // If the maximum value is less than 256, use char data type for the image
  // Otherwise, use short int data type for the image
  int color_depth = 1 + ( maxval > 255 );
  // Writing file
  fwrite( image, 1, xsize * ysize * color_depth, image_file);

  fclose(image_file);
}

// Function to compute iterations for a single point
int compute_mandelbrot(double cx, double cy, int max_iter) {
    double x = 0, y = 0;
    double x2 = 0, y2 = 0;
    int iter = 0;
    
    while (x2 + y2 <= 4 && iter < max_iter) {
        y = 2 * x * y + cy;
        x = x2 - y2 + cx;
        x2 = x * x;
        y2 = y * y;
        iter++;
    }
    
    return iter;
}

int main(int argc, char** argv) {
  
    int provided;
    int rank, size;
  
    MPI_Init_thread(&argc, &argv, MPI_THREAD_FUNNELED, &provided);
    if (provided < MPI_THREAD_FUNNELED) {
        printf("Error: MPI implementation does not support MPI_THREAD_FUNNELED\n");
        MPI_Finalize();
        exit(1);
    }
    
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);
    
    // Parse command line arguments
    if (argc != 9) {
        if (rank == 0) {
            fprintf(stderr, "Usage: %s nx ny x_left y_left x_right y_right max_iter\n", argv[0]);
        }
        MPI_Finalize();
        exit(1);
    }
    
    int nx = atoi(argv[1]);
    int ny = atoi(argv[2]);
    double x_left = atof(argv[3]);
    double y_left = atof(argv[4]);
    double x_right = atof(argv[5]);
    double y_right = atof(argv[6]);
    int max_iter = atoi(argv[7]);
    int num_threads = atoi(argv[8]);

    double start_time, end_time;

    omp_set_dynamic(0);
    omp_set_num_threads(num_threads);

    // Validate arguments
    if (nx <= 0 || ny <= 0 || max_iter <= 0) {
        if (rank == 0) {
            fprintf(stderr, "Error: nx, ny, and max_iter must all be positive integers.\n");
        }
        MPI_Finalize();
        exit(1);
    }
    if (x_left >= x_right || y_left >= y_right) {
        if (rank == 0) {
            fprintf(stderr, "Error: x_left must be less than x_right and y_left must be less than y_right.\n");
        }
        MPI_Finalize();
        exit(1);
    }

    start_time = MPI_Wtime();
    
    // Calculate delta values
    double dx = (x_right - x_left) / nx;
    double dy = (y_right - y_left) / ny;
    
    // Allocate local portion of the image
    int rows_per_process = ny / size;
    int remainder = ny % size;
    int start_row = rank * rows_per_process + (rank < remainder ? rank : remainder);
    int local_rows = rows_per_process + (rank < remainder ? 1 : 0);
    unsigned char* local_image = (unsigned char*)malloc(local_rows * nx);
    
    if (local_image == NULL) {
        fprintf(stderr, "Error: Unable to allocate memory for local image on rank %d.\n", rank);
        MPI_Finalize();
        exit(1);
    }
    
    // OpenMP parallel region for computing Mandelbrot set
    #pragma omp parallel for
    for (int j = 0; j < local_rows; j++) {
        for (int i = 0; i < nx; i++) {
            double cx = x_left + i * dx;
            double cy = y_left + (start_row + j) * dy;
            int iter = compute_mandelbrot(cx, cy, max_iter);
            local_image[j * nx + i] = (unsigned char)(iter == max_iter ? 0 : iter);
        }
    }
    
    // Gather results to rank 0
    unsigned char* final_image = NULL;
    if (rank == 0) {
        final_image = (unsigned char*)malloc(nx * ny);
        if (final_image == NULL) {
            fprintf(stderr, "Error: Unable to allocate memory for final image on rank 0.\n");
            MPI_Finalize();
            exit(1);
        }
    }
    
    // Calculate send counts and displacements for MPI_Gatherv
    int* sendcounts = (int*)malloc(size * sizeof(int));
    int* displs = (int*)malloc(size * sizeof(int));
    
    if (sendcounts == NULL || displs == NULL) {
        fprintf(stderr, "Error: Unable to allocate memory for sendcounts or displs on rank %d.\n", rank);
        MPI_Finalize();
        exit(1);
    }
    
    for (int i = 0; i < size; i++) {
        int rows_for_process = (i < remainder) ? (rows_per_process + 1) : rows_per_process;
        sendcounts[i] = rows_for_process * nx;
        displs[i] = (i == 0) ? 0 : displs[i - 1] + sendcounts[i - 1];
    }

    // Synchronize and gather
    MPI_Barrier(MPI_COMM_WORLD);
  
    MPI_Gatherv(local_image, local_rows * nx, MPI_UNSIGNED_CHAR,
                final_image, sendcounts, displs, MPI_UNSIGNED_CHAR,
                0, MPI_COMM_WORLD);

    end_time = MPI_Wtime();
    
    if (rank == 0) {
        printf("Total time (s): %f\n", end_time - start_time);
    }

    // Write the image file from rank 0
    if (rank == 0) {
        write_pgm_image(final_image, max_iter, nx, ny, "../plots/mandelbrot.pgm");
        free(final_image);
    }

    // Cleanup
    free(local_image);
    free(sendcounts);
    free(displs);
    
    MPI_Finalize();
    return 0;
}

