#pragma once

#include "types.h"

typedef enum {
    BENCODE_STR,
    BENCODE_INT,
} BencodeType;

typedef union {
    i32 num;
    char *str;
} BencodeElement;

typedef struct {
    BencodeElement val;
    BencodeType type;
} BencodeValue;

void
bencode_print(BencodeValue const* const val);
