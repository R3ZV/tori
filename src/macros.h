#pragma once

#include <stdlib.h>
#include <stdio.h>

#define todo(fmt, ...) \
    do { \
        fprintf(stderr, "TODO: " fmt " [%s:%d]\n", \
            ##__VA_ARGS__, __FILE__, __LINE__); \
        exit(0); \
    } while (0)

