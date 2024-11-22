#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <omp.h>
#include <string.h>
#include <unistd.h>

#define TAG_WORK_REQUEST 1
#define TAG_WORK_ASSIGNMENT 2
#define TAG_WORK_RESULT 3
#define TAG_TERMINATE 4
#define ROWS_PER_REQUEST 10

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

// Function to write PGM image using MPI I/O with error handling
int write_pgm_image(unsigned char *image, int maxval, int xsize, int ysize, const char *filename) {
    FILE *fp = fopen(filename, "wb");
    if (!fp) {
        fprintf(stderr, "Error: Unable to open file %s for writing.\n", filename);
        return 0;
    }

    fprintf(fp, "P5\n%d %d\n%d\n", xsize, ysize, maxval);
    size_t items_written = fwrite(image, sizeof(unsigned char), xsize * ysize, fp);
    if (items_written != xsize * ysize) {
        fprintf(stderr, "Error: Unable to write image data to file.\n");
        fclose(fp);
        return 0;
    }

    fclose(fp);
    return 1;
}

int main(int argc, char** argv) {
    int provided;
    int rank, size;

    MPI_Init_thread(&argc, &argv, MPI_THREAD_FUNNELED, &provided);
    if (provided < MPI_THREAD_FUNNELED) {
        fprintf(stderr, "Error: MPI does not support required threading level.\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (argc != 9) {
        if (rank == 0) {
            fprintf(stderr, "Usage: %s nx ny x_left y_left x_right y_right max_iter num_threads\n", argv[0]);
        }
        MPI_Finalize();
        return 1;
    }

    // Argument parsing and validation
    int nx = atoi(argv[1]);
    int ny = atoi(argv[2]);
    double x_left = atof(argv[3]);
    double y_left = atof(argv[4]);
    double x_right = atof(argv[5]);
    double y_right = atof(argv[6]);
    int max_iter = atoi(argv[7]);
    int num_threads = atoi(argv[8]);

    if (nx <= 0 || ny <= 0 || max_iter <= 0 || num_threads <= 0) {
        if (rank == 0) {
            fprintf(stderr, "Error: nx, ny, max_iter, and num_threads must be positive.\n");
        }
        MPI_Finalize();
        return 1;
    }
    if (x_left >= x_right || y_left >= y_right) {
        if (rank == 0) {
            fprintf(stderr, "Error: x_left must be less than x_right and y_left must be less than y_right.\n");
        }
        MPI_Finalize();
        return 1;
    }

    // disabling dynamic threads and setting the number of threads
    omp_set_dynamic(0);
    omp_set_num_threads(num_threads);

    // pixel dimesions
    double dx = (x_right - x_left) / nx;
    double dy = (y_right - y_left) / ny;

    // start the timer
    MPI_Barrier(MPI_COMM_WORLD);
    double start_total = MPI_Wtime();

    if (rank == 0) {
        // MASTER PROCESS
        int next_row = 0;
        int active_workers = size - 1;
        MPI_Status status;

        // allocate memory for the full image
        unsigned char* full_image = (unsigned char*)malloc(nx * ny);
        if (full_image == NULL) {
            fprintf(stderr, "Error: Unable to allocate memory for full image on master.\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
            return 1;
        }

        // start computation timer
        double start_compute = MPI_Wtime();

        // trace the number of pending results
        int pending_results = 0;

        while (active_workers > 0 || pending_results > 0) {
            MPI_Status recv_status;
            int flag;

            MPI_Iprobe(MPI_ANY_SOURCE, MPI_ANY_TAG, MPI_COMM_WORLD, &flag, &recv_status);
            if (flag) {
                if (recv_status.MPI_TAG == TAG_WORK_REQUEST) {
                    // receive work request
                    int worker_rank = recv_status.MPI_SOURCE;
                    int message;
                    MPI_Recv(&message, 1, MPI_INT, worker_rank, TAG_WORK_REQUEST, MPI_COMM_WORLD, &status);

                    if (next_row < ny) {
                        // assign job
                        int rows_to_assign = ROWS_PER_REQUEST;
                        if (next_row + rows_to_assign > ny) {
                            rows_to_assign = ny - next_row;
                        }
                        int start_row = next_row;
                        next_row += rows_to_assign;

                        // send job assignement
                        MPI_Send(&rows_to_assign, 1, MPI_INT, worker_rank, TAG_WORK_ASSIGNMENT, MPI_COMM_WORLD);
                        MPI_Send(&start_row, 1, MPI_INT, worker_rank, TAG_WORK_ASSIGNMENT, MPI_COMM_WORLD);

                        pending_results++;

                    } else {
                        // If no work left send message of termination
                        MPI_Send(&message, 0, MPI_INT, worker_rank, TAG_TERMINATE, MPI_COMM_WORLD);
                        active_workers--;
                    }
                } else if (recv_status.MPI_TAG == TAG_WORK_RESULT) {
                    // receive work results
                    int worker_rank = recv_status.MPI_SOURCE;
                    int rows_received;
                    MPI_Recv(&rows_received, 1, MPI_INT, worker_rank, TAG_WORK_RESULT, MPI_COMM_WORLD, &status);

                    for (int i = 0; i < rows_received; i++) {
                        int row_number;
                        MPI_Recv(&row_number, 1, MPI_INT, worker_rank, TAG_WORK_RESULT, MPI_COMM_WORLD, &status);
                        MPI_Recv(&full_image[row_number * nx], nx, MPI_UNSIGNED_CHAR, worker_rank, TAG_WORK_RESULT, MPI_COMM_WORLD, &status);
                    }
                    pending_results--;
                }
            } else {
                // if no message come, we can execute a short sleep to avoid busy waiting
                // usleep(1000); // to use this option simply remove this comment
            }
        }

        // end the computation timer and start the I/O timer, and the image writing, at the end we stop the timer and print all the results
        double end_compute = MPI_Wtime();
        double start_io = MPI_Wtime();

        int write_success = write_pgm_image(full_image, max_iter, nx, ny, "mandelbrot.pgm");

        double end_io = MPI_Wtime();

        double compute_time = end_compute - start_compute;
        double io_time = end_io - start_io;
        double total_time = end_io - start_total;

        printf("Image size: %dx%d\n", nx, ny);
        printf("Number of processes: %d\n", size);
        printf("Threads per process: %d\n", num_threads);
        printf("Compute time: %f\n", compute_time);
        printf("I/O time: %f\n", io_time);
        printf("Total time: %f\n", total_time);

        if (!write_success) {
            fprintf(stderr, "Warning: Image write operation failed\n");
        }

        free(full_image);

    } else {
        // WORKERS
        MPI_Status status;
        int message = 0;
        MPI_Request send_request;
        int rows_to_compute;
        int start_row;

        // initial work request to the master
        MPI_Isend(&message, 1, MPI_INT, 0, TAG_WORK_REQUEST, MPI_COMM_WORLD, &send_request);

        while (1) {
            // receive work from  master
            MPI_Recv(&rows_to_compute, 1, MPI_INT, 0, MPI_ANY_TAG, MPI_COMM_WORLD, &status);

            if (status.MPI_TAG == TAG_WORK_ASSIGNMENT) {
                // receive start_row
                MPI_Recv(&start_row, 1, MPI_INT, 0, TAG_WORK_ASSIGNMENT, MPI_COMM_WORLD, &status);

                // allocate memory for rows
                unsigned char* rows_data = (unsigned char*)malloc(rows_to_compute * nx);
                if (rows_data == NULL) {
                    fprintf(stderr, "Error: Unable to allocate memory for rows on rank %d.\n", rank);
                    MPI_Abort(MPI_COMM_WORLD, 1);
                    return 1;
                }

		// to avoid time wasting overlap the communication with the computing, so while the worker is still computing it sends
		// a new work request
                MPI_Isend(&message, 1, MPI_INT, 0, TAG_WORK_REQUEST, MPI_COMM_WORLD, &send_request);

                #pragma omp parallel for schedule(dynamic)
                for (int r = 0; r < rows_to_compute; r++) {
                    int row_number = start_row + r;
                    double cy = y_left + row_number * dy;

                    for (int i = 0; i < nx; i++) {
                        double cx = x_left + i * dx;
                        int iter = 255 - compute_mandelbrot(cx, cy, max_iter);
                        rows_data[r * nx + i] = (unsigned char)(iter == max_iter ? 1 : iter);
                    }
                }

		// Send computed data to master
                MPI_Send(&rows_to_compute, 1, MPI_INT, 0, TAG_WORK_RESULT, MPI_COMM_WORLD);
                for (int r = 0; r < rows_to_compute; r++) {
                    int row_number = start_row + r;
                    MPI_Send(&row_number, 1, MPI_INT, 0, TAG_WORK_RESULT, MPI_COMM_WORLD);
                    MPI_Send(&rows_data[r * nx], nx, MPI_UNSIGNED_CHAR, 0, TAG_WORK_RESULT, MPI_COMM_WORLD);
                }

                free(rows_data);

            } else if (status.MPI_TAG == TAG_TERMINATE) {
                break;
            }
        }

        MPI_Wait(&send_request, MPI_STATUS_IGNORE);
    }

    MPI_Finalize();
    return 0;
}

