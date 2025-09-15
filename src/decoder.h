#pragma once

#include "types.h"
#include "bencode.h"

typedef enum {
    DECODER_NULL_ROOT,
    DECODER_INVALID_TYPE,
    DECODER_NON_DIGIT,
    DECODER_NULL,
} DecoderErr;

char *
decoder_err_msg(DecoderErr const err);

typedef struct {
    char const *const blob;
    size_t it;
} Decoder;

Decoder
decoder_init(char const *const blob);

[[nodiscard]] DecoderErr
decoder_run(Decoder *const self, BencodeValue* res);

void
bencode_print(BencodeValue const* const val);
