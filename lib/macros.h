#pragma once

#include <stdlib.h>
#include <stdio.h>

#include "types.h"

internal char const *const YELLOW = "\x1b[33m";
internal char const *const RESET = "\x1b[0m";

#define todo(...) \
    do { \
        fprintf(stderr, "%sTODO:%s ", YELLOW, RESET); \
        fprintf(stderr, __VA_ARGS__); \
        fprintf(stderr, " [%s:%d]\n", __FILE__, __LINE__); \
        exit(0); \
    } while (0)
