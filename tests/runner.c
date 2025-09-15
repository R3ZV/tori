#include <stdio.h>
#include <time.h>

#include "../src/types.h"
#include "all_tests.h"

char const* const PASS_COLOR = "\x1b[32m";
char const* const FAIL_COLOR = "\x1b[31m";
char const* const LEAK_COLOR = "\x1b[34m";
char const* const SKIP_COLOR = "\x1b[35m";
char const* const RESET_COLOR = "\x1b[0m";
char const* const CLEAN_START = "\r\x1b[0K";
char const* const FILLER = "................................................";


#define run_test(test_fn) do { \
    err_msg = test_fn(); \
    clock_gettime(CLOCK_MONOTONIC, &end); \
    elapsed = (end.tv_sec - start.tv_sec) + \
                     (end.tv_nsec - start.tv_nsec) / 1e9; \
    total_elapsed += elapsed;\
    \
    if (err_msg != NULL) { \
        failed++; \
        printf("%s%s%sFAIL%s in %.6fs\nERR: %s\n", \
               #test_fn, FILLER, FAIL_COLOR, RESET_COLOR, elapsed, err_msg); \
    } else { \
        passed++; \
        printf("%s%s%sPASS%s in %.6fs\n", \
               #test_fn, FILLER, PASS_COLOR, RESET_COLOR, elapsed); \
    } \
} while (0)



int
main(void) {
    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);

    u32 passed = 0, failed = 0;
    char *err_msg = NULL;
    double elapsed = 0.0, total_elapsed = 0.0;

    run_test(decoder_number_decoding_test);

    u32 total_tests = passed + failed;
    printf("%s%d%s passed; %s%d%s failed; %d completed in %fs\n",
        PASS_COLOR,  passed, RESET_COLOR,
        FAIL_COLOR,  failed, RESET_COLOR,
        total_tests, total_elapsed
    );
    return 0;
}
