#include <string.h>

#include "decoder.h"
#include "../lib/macros.h"

Decoder
decoder_init(char const *const blob) {
    return (Decoder) {
        .blob = blob,
        .it = 0,
    };
}

internal bool
is_digit(char ch) {
    return '0' <= ch && ch <= '9';
}

[[nodiscard]] internal DecoderErr
decode_str(Decoder *const self, char** res) {
    size_t len = 0;
    while (self->it < strlen(self->blob) && self->blob[self->it] != ':') {
        char curr = self->blob[self->it];
        if (!is_digit(curr)) {
            return DECODER_MISSING_COLUMN;
        }
        len = len * 10 + (size_t)(curr - '0');
        self->it++;
    }

    if (self->it >= strlen(self->blob)) {
        return DECODER_UNEXPECTED_EOF;
    }

    // skip ':'
    self->it++;
    if (self->it + len - 1 > strlen(self->blob)) {
        return DECODER_UNEXPECTED_EOF;
    }

    *res = calloc(len + 1, sizeof(char));
    strncpy(*res, &self->blob[self->it], len);
    (*res)[len] = '\0';
    self->it += len;
    return DECODER_NULL;
}

[[nodiscard]] internal DecoderErr
decode_number(Decoder *const self, i32* res) {
    *res = 0;
    // skip 'i'
    self->it++;

    char curr = self->blob[self->it];
    bool is_negative = false;
    if (self->it < strlen(self->blob) && curr == '-') {
        is_negative = true;
        self->it++;
    }

    while (self->it < strlen(self->blob)) {
        curr = self->blob[self->it];
        if (curr == 'e') {
            break;
        }

        if (!is_digit(curr)) {
            *res = 0;
            return DECODER_NON_DIGIT;
        }
        *res = *res * 10 + (curr - '0');
        self->it++;
    }

    if (self->it >= strlen(self->blob)) {
        return DECODER_MISSING_TERMINATOR;
    }

    curr = self->blob[self->it];
    if (curr != 'e') {
        return DECODER_MISSING_TERMINATOR;
    }

    // skip 'e'
    self->it++;
    if (is_negative) {
        *res *= -1;
    }

    return DECODER_NULL;
}

[[nodiscard]] DecoderErr
decoder_run(Decoder *const self, BencodeValue* res) {
    if (strlen(self->blob) == 0 || strlen(self->blob) <= self->it) {
        return DECODER_NULL_ROOT;
    }

    char const curr = self->blob[self->it];
    if (curr == 'i') {
        res->type = BENCODE_INT;
        return decode_number(self, &res->val.num);
    } else if (curr == 'l') {
        res->type = BENCODE_LIST;

        // skip 'l'
        self->it++;

        ArrayList* elems = calloc(1, sizeof(ArrayList));
        *elems = arrayl_init();
        while (self->it < strlen(self->blob) && self->blob[self->it] != 'e') {
            BencodeValue* elem = calloc(1, sizeof(BencodeValue));
            DecoderErr err = decoder_run(self, elem);
            if (err != DECODER_NULL) {
                free(elem);
                res->val.list = elems;
                return err;
            }
            arrayl_append(elems, elem);
        }
        res->type = BENCODE_LIST;
        res->val.list = elems;
        return DECODER_NULL;
    } else if (curr == 'd') {
        todo("dict decoding");
    } else if (is_digit(curr)) {
        res->type = BENCODE_STR;
        DecoderErr err = decode_str(self, &(res->val.str));
        return err;
    }

    return DECODER_INVALID_TYPE;
}

char *
decoder_err_msg(DecoderErr const err) {
    switch(err) {
        case DECODER_UNEXPECTED_EOF:
            return "Bencoded string ended earlier!";
        case DECODER_MISSING_COLUMN:
            return "Bencoded string misses ':' separator!";
        case DECODER_MISSING_TERMINATOR:
            return "Found bencoded value with missing 'e' terminator!";
        case DECODER_NULL_ROOT:
            return "Empty bencode string found!";
        case DECODER_INVALID_TYPE:
            return "Given bencode contains invalid type!";
        case DECODER_NON_DIGIT:
            return "Found bencode int that contains non digits!";
        case DECODER_NULL:
            return "NO ERROR";
    }
    unreachable();
}

char *
decoder_enum_str(DecoderErr const err) {
    switch(err) {
        case DECODER_UNEXPECTED_EOF:
            return "DECODER_UNEXPECTED_EOF";
        case DECODER_MISSING_COLUMN:
            return "DECODER_MISSING_COLUMN";
        case DECODER_MISSING_TERMINATOR:
            return "DECODER_MISSING_TERMINATOR";
        case DECODER_NULL_ROOT:
            return "DECODER_NULL_ROOT";
        case DECODER_INVALID_TYPE:
            return "DECODER_INVALID_TYPE";
        case DECODER_NON_DIGIT:
            return "DECODER_NON_DIGIT";
        case DECODER_NULL:
            return "DECODER_NULL";
    }
    unreachable();
}
