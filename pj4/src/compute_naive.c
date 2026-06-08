#include "compute.h"

// Computes the convolution of two matrices
int convolve(matrix_t *a_matrix, matrix_t *b_matrix, matrix_t **output_matrix) {
  // TODO: convolve matrix a and matrix b, and store the resulting matrix in
  // output_matrix
  uint32_t a_rows = a_matrix->rows;
  uint32_t a_cols = a_matrix->cols;
  int32_t * a_data = a_matrix->data;
  uint32_t b_rows = b_matrix->rows;
  uint32_t b_cols = b_matrix->cols;
  int32_t * b_data = b_matrix->data;

  if (a_rows <= 0 || a_cols <= 0 || b_rows <= 0 || b_cols <= 0) {
    return -1;
  }

  if (b_rows > a_rows || b_cols > a_cols) {
    return -1;
  }

  // allocate memory for result matrix

  uint32_t result_rows = a_rows - b_rows + 1;
  uint32_t result_cols = a_cols - b_cols + 1;
  int32_t * result_data = (int32_t *)malloc(result_rows * result_cols * (sizeof(int32_t)));
  if (result_data == NULL) {
    printf("Memory allocation failed.");
    return -1;
  }

  matrix_t * result = (matrix_t *)malloc(sizeof(matrix_t));
  if (result == NULL) {
    printf("Memory allocation failed.");
    return -1;
  }

  result->rows = result_rows;
  result->cols = result_cols;
  result->data = result_data;

  // filp matrix_b
  int32_t *flipped_b = (int32_t *)malloc(b_rows * b_cols * sizeof(int32_t));
  if (flipped_b == NULL) {
    printf("Memory allocation failed.");
    free(result_data);
    free(result);
    return -1;
  }

  for (uint32_t i = 0; i < b_rows; i++) {
    for (uint32_t j = 0; j < b_cols; j++) {
      flipped_b[i * b_cols + j] = b_data[(b_rows - 1 - i) * b_cols + (b_cols - 1 - j)];
    }
  }

  // convolution

  for (uint32_t i = 0; i < result_rows; i++) {
    for (uint32_t j = 0; j < result_cols; j++) {
      uint32_t sum = 0;
      for (uint32_t c = 0; c < b_rows; c++) {
        for (uint32_t d = 0; d < b_cols; d++) {
          sum += b_data[c * b_cols + d] * a_data[(i + c) * a_cols + j + d];
        }
      }
      result_data[i * result_cols + j] = sum;
    }
  }

  * output_matrix = result;
  free(flipped_b);
  return 0;
}

// Executes a task
int execute_task(task_t *task) {
  matrix_t *a_matrix, *b_matrix, *output_matrix;

  char *a_matrix_path = get_a_matrix_path(task);
  if (read_matrix(a_matrix_path, &a_matrix)) {
    printf("Error reading matrix from %s\n", a_matrix_path);
    return -1;
  }
  free(a_matrix_path);

  char *b_matrix_path = get_b_matrix_path(task);
  if (read_matrix(b_matrix_path, &b_matrix)) {
    printf("Error reading matrix from %s\n", b_matrix_path);
    return -1;
  }
  free(b_matrix_path);

  if (convolve(a_matrix, b_matrix, &output_matrix)) {
    printf("convolve returned a non-zero integer\n");
    return -1;
  }

  char *output_matrix_path = get_output_matrix_path(task);
  if (write_matrix(output_matrix_path, output_matrix)) {
    printf("Error writing matrix to %s\n", output_matrix_path);
    return -1;
  }
  free(output_matrix_path);

  free(a_matrix->data);
  free(b_matrix->data);
  free(output_matrix->data);
  free(a_matrix);
  free(b_matrix);
  free(output_matrix);
  return 0;
}
