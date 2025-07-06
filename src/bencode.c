#include <string.h>
#include <stdint.h>
#include <stdbool.h>

#include "include/bencode.h"

BencodeDecoder bencode_init(const char* const blob) {
    return (BencodeDecoder) {
        .pos = 0,
        .blob = blob,
    };
}

BencodeType decode_number(BencodeDecoder* self) {
    // skip i
    self->pos++;

    bool is_negative = false;
    if (self->blob[self->pos] == '-') {
        is_negative = true;
        self->pos++;
    }

    int64_t num = 0;
    while (self->pos < strlen(self->blob) && self->blob[self->pos] != 'e') {
        num = num * 10 + (int64_t)(self->blob[self->pos] - '0');
        self->pos++;
    }

    if (is_negative) num = -num;

    return (BencodeType) {
        .data = num,
        .tag = BENTAG_NUMBER,
    };
}

BencodeType bencode_decode(BencodeDecoder* self) {
    if (self->blob[self->pos] == 'i') {
        return decode_number(self);
    }
}
