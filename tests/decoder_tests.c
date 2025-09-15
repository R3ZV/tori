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
