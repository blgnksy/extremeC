/**
* @file 0000_1_getopt_long.c
 * @brief getopt_long() example program.
 *
 * \note
 * Not defined in POSIX!
 * \endcode
 */


#include <stdio.h>
#include <getopt.h>
#include <stdlib.h>

/**
 * \note
 * | Return                     | Meaning                                         |
 * | -------------------------- | ----------------------------------------------- |
 * | Short option character     | Matched short option                            |
 * | `val` from `struct option` | Matched long option                             |
 * | `?`                        | Unknown option or missing argument              |
 * | `:`                        | Missing argument (if optstring starts with `:`) |
 * | `-1`                       | No more options                                 |
 * The return value rule:
 * > If `flag` is **NOT NULL**, `getopt_long()`
 * >
 * > * stores `val` in `*flag`
 * > * **returns `0`**
 * >
 * > If `flag` **IS NULL**, `getopt_long()`
 * >
 * > * **returns `val`**
 * Example struct
 * \code
 *    struct option options[] = {
 *      {"help", no_argument, &h_flag, 1},
 *      {"count", required_argument, NULL, 2},
 *      {"line", optional_argument, NULL, 3},
 *      {0, 0, 0, 0 },
 *  };
 * \endcode

 * | Option    | `flag`    | `val` | Return Value | Side Effect    |
 * | --------- | --------- | ----- | ------------ | -------------- |
 * | `--help`  | `&h_flag` | `1`   | `0`          | `h_flag = 1`   |
 * | `--count` | `NULL`    | `2`   | `2`          | `optarg` set   |
 * | `--line`  | `NULL`    | `3`   | `3`          | `optarg` maybe |

 * @param argc
 * @param argv
 * @return
 */
int main(int argc, char *argv[])
{
 int a_flag, b_flag, c_flag, verbose_flag;
 int err_flag;
 char *c_arg;
 int result;

 struct option options[] = {
  {"count", required_argument, NULL, 'c'},
  {"verbose", no_argument, &verbose_flag, 1},
  {0, 0, 0, 0}
 };

 a_flag = b_flag = c_flag = verbose_flag = err_flag = 0;

 opterr = 0;
 while ((result = getopt_long(argc, argv, "abc:", options, NULL)) != -1) {
  switch (result) {
  case 'a':
   a_flag = 1;
   break;
  case 'b':
   b_flag = 1;
   break;
  case 'c':
   c_flag = 1;
   c_arg = optarg;
   break;
  case '?':
   if (optopt == 'c')
    fprintf(stderr, "option -c or --count without argument!...\n");
   else if (optopt != 0)
    fprintf(stderr, "invalid option: -%c\n", optopt);
   else
    fprintf(stderr, "invalid long option!...\n");
   err_flag = 1;
   break;
  }
 }

 if (err_flag)
  exit(EXIT_FAILURE);

 if (a_flag)
  printf("-a option given\n");
 if (b_flag)
  printf("-b option given\n");
 if (c_flag)
  printf("-c or --count option given with argument \"%s\"\n", c_arg);
 if (verbose_flag)
  printf("--verbose given\n");

 if (optind != argc) {
  printf("Arguments without options");
  for (int i = optind; i < argc; ++i)
   printf("%s\n", argv[i]);
 }

 return 0;
}
