#include <stdio.h>
#include <time.h>
#include <string.h>

#include "../lib/types.h"
#include "all_tests.h"

char const *const PASS_COLOR = "\x1b[32m";
char const *const FAIL_COLOR = "\x1b[31m";
char const *const SKIP_COLOR = "\x1b[35m";
char const *const RESET_COLOR = "\x1b[0m";
char const *const CLEAN_START = "\r\x1b[0K";
char const *const FILLER = "................................................";

#define MAX_NAME_LEN 80

#define run_test(test_fn) do { \
    err_msg = test_fn(); \
    clock_gettime(CLOCK_MONOTONIC, &end); \
    elapsed = (end.tv_sec - start.tv_sec) + \
                     (end.tv_nsec - start.tv_nsec) / 1e9; \
    total_elapsed += elapsed;\
    int name_len = strlen(#test_fn); \
    int dots = MAX_NAME_LEN - name_len; \
    if (dots < 0) dots = 0; \
    \
    printf("%s", #test_fn); \
    for (int i = 0; i < dots; i++) putchar('.'); \
    \
    if (err_msg != NULL) { \
        failed++; \
        printf("%sFAIL%s in %.6fs\nERR: %s\n", \
               FAIL_COLOR, RESET_COLOR, elapsed, err_msg); \
    } else { \
        passed++; \
        printf("%sPASS%s in %.6fs\n", \
               PASS_COLOR, RESET_COLOR, elapsed); \
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
    run_test(decoder_number_decoding_errs);
    run_test(decoder_misc_errs);
    run_test(decoder_str_decoding_test);
    run_test(decoder_str_decoding_errs);

    u32 total_tests = passed + failed;
    printf("%s%d%s passed; %s%d%s failed; %d completed in %fs\n",
        PASS_COLOR,  passed, RESET_COLOR,
        FAIL_COLOR,  failed, RESET_COLOR,
        total_tests, total_elapsed
    );
    return 0;
}
