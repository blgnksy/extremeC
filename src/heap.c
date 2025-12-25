/** \file heap.c
 *
 * No auto allocation/deallocation
 *
 * Process starts filling the stack from top to bottom
 *
 * It has large memory size
 *
 * No scope for heap allocated variables (actually pointers)
 *
 */

#include <stdio.h>  // For printf function
#include <stdlib.h> // For C library's heap memory functions
#include <string.h>


void print_mem_maps() {
#ifdef __linux__
    FILE* fd = fopen("/proc/self/maps", "r");
    if (!fd) {
        printf("Could not open maps file.\n");
        exit(1);
    }
    char line[1024];
    while (!feof(fd)) {
        fgets(line, 1024, fd);
        printf("> %s", line);
    }
    fclose(fd);
#endif
}
int main(int argc, char** argv) {
    // Allocate 10 bytes without initialization
    char* ptr1 = (char*)malloc(10 * sizeof(char));
    printf("Address of ptr1: %p\n", (void*)&ptr1);
    printf("Memory allocated by malloc at %p: ", (void*)ptr1);
    for (int i = 0; i < 10; i++) {
        printf("0x%02x ", (unsigned char)ptr1[i]);
    }
    printf("\n");
    // Allocation 10 bytes all initialized to zero
    char* ptr2 = (char*)calloc(10, sizeof(char));
    printf("Address of ptr2: %p\n", (void*)&ptr2);
    printf("Memory allocated by calloc at %p: ", (void*)ptr2);
    for (int i = 0; i < 10; i++) {
        printf("0x%02x ", (unsigned char)ptr2[i]);
    }
    printf("\n");
    print_mem_maps();
    free(ptr1);
    free(ptr2);

    char* ptr = (char*)malloc(16 * sizeof(char));
    // memset fills memory addresses
    memset(ptr, 0, 16 * sizeof(char));    // Fill with 0
    memset(ptr, 0xff, 16 * sizeof(char)); // Fill with 0xff
    printf("Address of ptr: %p\n", (void*)&ptr);
    printf("Memory allocated by malloc at %p: \n", (void*)ptr);

    /*
     * The realloc function does not change the data in the old block and only expands an already allocated block to
     * a new one. If it cannot expand the currently allocated block because of fragmentation, it will find another
     * block that's large enough and copy the data from the old block to the new one.
     *
     */
    ptr = (char*)realloc(ptr, 32 * sizeof(char));
    printf("Address of ptr: %p\n", (void*)&ptr);
    printf("Memory allocated by remalloc at %p: \n", (void*)ptr);
    free(ptr);
    return 0;
}