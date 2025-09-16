#pragma once

#include <stdlib.h>
#include <stdio.h>

#include "types.h"

internal char const *const YELLOW = "\x1b[33m";
internal char const *const RESET = "\x1b[0m";

#define todo(fmt, ...) \
    do { \
        fprintf(stderr, "%sTODO: %s" fmt " [%s:%d]\n", \
            YELLOW, RESET, ##__VA_ARGS__, __FILE__, __LINE__); \
        exit(0); \
    } while (0)

