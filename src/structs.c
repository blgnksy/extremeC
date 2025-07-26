/** \file structs.c
 *
 *  Among many efforts to move away from machine-level programming languages, introducing structures was a great step
 * toward having encapsulation in a programming language.
 *
 *
 */

#include <stdio.h>

/**
 * \struct color_t
 * \brief As we said before, structures do encapsulation. Encapsulation is one of the most fundamental concepts in
 * software design. It is about grouping and encapsulating related fields under a new type.
 *
 * \note Note that we use an _t suffix for naming new data types
 */
struct color_t {
    int red;
    int green;
    int blue;
};

/**
 * \struct sample_t
 * \brief it is usually important to C programmers to know exactly the memory layout of a structure variable. Having a
bad layout in memory could cause performance degradations in certain architectures.
 \code{.bash}
Size: 6 bytes
65 66 67 127 253 2
 \endcode
 * As you see in the preceding shell box, sizeof(sample_t) has returned 6 bytes. The memory layout of a structure
variable is very similar to an array. In an array, all elements are adjacent to each other in the memory, and this is
the same for a structure variable and its field. The difference is that, in an array, all elements have the same type
and therefore the same size, but this is not the case regarding a structure variable. Each field can have a different
type, and hence, it can have a different size. Unlike an array, the memory size of which is easily calculated, the size
of a structure variable in the memory depends on a few factors and cannot be easily determined.
 *
* first, second, and third, are 1 byte each, and they reside in the first word of the structure's layout, and they all
can be read by just one memory access. About the fourth field, fourth occupies 2 bytes. If we forget about the memory
alignment, its first byte will be the last byte of the first word, which makes it unaligned.

If this was the case, the CPU would be required to make two memory accesses together with shifting some bits in order to
retrieve the value of the field. That is why we see an extra zero after byte 67.
 */
struct sample_t {
    char first;
    char second;
    char third;
    short fourth;
};
void print_size(struct sample_t* var) {
    printf("Size: %lu bytes\n", sizeof(*var));
}
void print_bytes(struct sample_t* var) {
    unsigned char* ptr = (unsigned char*)var;
    for (int i = 0; i < sizeof(*var); i++, ptr++) {
        printf("%d ", (unsigned int)*ptr);
    }
    printf("\n");
}

/**
 * \struct sample1_t
 * \brief It is possible to turn off the alignment. In C terminology, we use a more specific term for aligned structures. We say that the structure is not packed.
\code{.bash}
Size: 6 bytes
65 66 67 253 2 65
\endcode
 */
struct __attribute__((__packed__)) sample1_t {
    char first;
    char second;
    char third;
    short fourth;
} ;

int main(int argc, char** argv) {
    struct sample_t var;
    var.first = 'A';
    var.second = 'B';
    var.third = 'C';
    var.fourth = 765;
    print_size(&var);
    print_bytes(&var);

    struct sample1_t var1;
    var1.first = 'A';
    var1.second = 'B';
    var1.third = 'C';
    var1.fourth = 765;
    print_size(&var1);
    print_bytes(&var1);

    return 0;
}
