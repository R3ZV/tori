#include <stdlib.h>
#include <stdio.h>

#include "../src/decoder.h"
#include "all_tests.h"


char*
decoder_number_decoding_test() {
    char* blobs[3] = {
        "i42e",
        "i-42e",
        "i248832e"
    };


    int expected[3] = { 42, -42, 248832 };
    for (size_t i = 0; i < 3; i++) {
        Decoder dec = decoder_init(blobs[i]);
        BencodeValue res = {};
        DecoderErr err = decoder_run(&dec, &res);
        if (err != DECODER_NULL) {
            return decoder_err_msg(err);
        }

        if (res.type != BENCODE_INT) {
            return "Expected result to be of type int!";
        }

        if (res.val.num != expected[i]) {
            char* err_msg = calloc(1024, sizeof(char));
            sprintf(err_msg, "Expected result to be %d but found %d\n", expected[i], res.val.num);
            return err_msg;
        }
    }

    return NULL;
}

char*
decoder_number_decoding_errs() {
    char* blobs[2] = {
        "i4f2e",
        "i-42",
    };


    DecoderErr expected[2] = { DECODER_NON_DIGIT, DECODER_MISSING_TERMINATOR };
    for (size_t i = 0; i < 2; i++) {
        Decoder dec = decoder_init(blobs[i]);
        BencodeValue res = {};
        DecoderErr err = decoder_run(&dec, &res);
        if (err == DECODER_NULL) {
            return "Expected decoding to result in an error!";
        }

        if (err != expected[i]) {
            char* err_msg = calloc(1024, sizeof(char));
            sprintf(err_msg, "Expected error '%s' but got '%s'\n",
                    decoder_enum_str(expected[i]),
                    decoder_enum_str(err)
            );
            return err_msg;
        }
    }

    return NULL;
}

char*
decoder_misc_errs() {
    char* blobs[2] = {
        "",
        "u32",
    };


    DecoderErr expected[2] = { DECODER_NULL_ROOT, DECODER_INVALID_TYPE };
    for (size_t i = 0; i < 2; i++) {
        Decoder dec = decoder_init(blobs[i]);
        BencodeValue res = {};
        DecoderErr err = decoder_run(&dec, &res);
        if (err == DECODER_NULL) {
            return "Expected decoding to result in an error!";
        }

        if (err != expected[i]) {
            char* err_msg = calloc(1024, sizeof(char));
            sprintf(err_msg, "Expected error '%s' but got '%s'\n",
                    decoder_enum_str(expected[i]),
                    decoder_enum_str(err)
            );
            return err_msg;
        }
    }

    return NULL;
}
