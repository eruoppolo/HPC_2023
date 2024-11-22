# Mandelbrot Set Scaling Analysis Report strong scaling 

## Data Validation

The following issues were detected:
- MPI has inconsistent timing (Total < Compute + I/O)

## Performance Metrics


### MPI Implementation
- Maximum Speedup: 78.34x
- Average Speedup: 39.83x
- Average Efficiency: 31.71%
- Peak Performance: 0.02 M pixels/second
- Compute Time Range: 0.172s - 13.453s
- I/O Time Range: 0.046s - 1.382s
- Average I/O Overhead: 51.45%

### OpenMP Implementation
- Maximum Speedup: 62.35x
- Average Speedup: 46.99x
- Average Efficiency: 82.90%
- Peak Performance: 0.04 M pixels/second
- Compute Time Range: 0.216s - 13.472s
- I/O Time Range: 0.033s - 0.756s
- Average I/O Overhead: 12.06%