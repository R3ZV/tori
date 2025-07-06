#ifndef BENCODE_H
#define BENCODE_H

#include <stdint.h>

typedef struct {
    size_t pos;
    const char* const blob;
} BencodeDecoder; 

typedef enum {
    BENTAG_NUMBER,
    BENTAG_STR,
} BencodeTag;

typedef union {
    int64_t number;
    const char* const str;
} BencodeData;

typedef struct {
    BencodeTag tag;
    BencodeData data;
} BencodeType;

BencodeDecoder bencode_init(const char* const blob);
BencodeType bencode_decode(BencodeDecoder* self);

#endif
