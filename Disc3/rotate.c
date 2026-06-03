#include <stdio.h>
#include <stdlib.h>
#include <string.h>
void print_int_array(int* array, int length) {
    for(int i = 0; i < length; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");
}

void rotate(void* front, void* separator, void* end) {
    size_t left_bytes = (char*)separator - (char*)front;
    size_t right_bytes = (char*)end - (char*)separator;

    char* temp = (char*)malloc(left_bytes * sizeof(char));
    memcpy(temp, front, left_bytes);
    memcpy(front, separator, right_bytes);
    memcpy((char*)front + right_bytes, temp, left_bytes);
}

int main() {
    int array[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    print_int_array(array, 10);

    rotate(array, array + 5, array + 10);
    print_int_array(array, 10);

    rotate(array, array + 1, array + 10);
    print_int_array(array, 10);

    rotate(array + 4, array + 5, array + 6);
    print_int_array(array, 10);

}