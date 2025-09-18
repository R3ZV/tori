#pragma once

#include "../lib/types.h"

typedef enum {
    BENCODE_STR,
    BENCODE_INT,
    BENCODE_LIST,
} BencodeType;

typedef union {
    i32 num;
    char* str;
    void* list;
} BencodeElement;

typedef struct {
    BencodeElement val;
    BencodeType type;
} BencodeValue;

typedef struct {
    BencodeValue** items;
    size_t len;
    size_t capacity;
} ArrayList;

ArrayList
arrayl_init();

void
arrayl_append(ArrayList* const self, BencodeValue* elem);

[[nodiscard]] BencodeValue*
arrayl_get(ArrayList const *const self, size_t pos);

void
bencode_print(BencodeValue const *const val);

void
bencode_free(BencodeValue* self);
