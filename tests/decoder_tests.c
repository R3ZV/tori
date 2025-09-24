#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "all_tests.h"
#include "../lib/macros.h"
#include "../src/decoder.h"

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

char*
decoder_str_decoding_test() {
    char* blobs[3] = {
        "0:",
        "4:test",
        "9:cmuratori",
    };

    char* expected[3] = {"", "test", "cmuratori" };
    for (size_t i = 0; i < 3; i++) {
        Decoder dec = decoder_init(blobs[i]);
        BencodeValue res = {};
        DecoderErr err = decoder_run(&dec, &res);
        if (err != DECODER_NULL) {
            return decoder_err_msg(err);
        }

        if (res.type != BENCODE_STR) {
            return "Expected result to be of type STR!";
        }

        if (strcmp(res.val.str, expected[i]) != 0) {
            char* err_msg = calloc(1024, sizeof(char));
            sprintf(err_msg, "Expected result to be '%s' but found '%s'\n", expected[i], res.val.str);
            return err_msg;
        }
    }

    return NULL;
}

char*
decoder_str_decoding_errs() {
    char* blobs[3] = {
        "4test",
        "4f:test",
        "9:test",
    };

    DecoderErr expected[3] = { DECODER_MISSING_COLUMN, DECODER_MISSING_COLUMN, DECODER_UNEXPECTED_EOF };
    for (size_t i = 0; i < 3; i++) {
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
decoder_list_decoding_test() {
    char* blobs[3] = {
        "le",
        "l4:teste",
        "li420eli69e5:jblowee",
    };


    ArrayList list0 = arrayl_init();

    ArrayList list1 = arrayl_init();
    BencodeValue val11 = {
        .val.str = "test",
        .type = BENCODE_STR,
    };
    arrayl_append(&list1, &val11);

    ArrayList list2 = arrayl_init();
    BencodeValue val21 = {
        .val.num = 420,
        .type = BENCODE_INT,
    };

    ArrayList list3 = arrayl_init();
    BencodeValue val31 = {
        .val.num = 69,
        .type = BENCODE_INT,
    };
    BencodeValue val32 = {
        .val.str = "jblow",
        .type = BENCODE_STR,
    };
    arrayl_append(&list3, &val31);
    arrayl_append(&list3, &val32);
    BencodeValue val22 = {
        .val.list = &list3,
        .type = BENCODE_LIST,
    };

    arrayl_append(&list2, &val21);
    arrayl_append(&list2, &val22);

    ArrayList expected[3] = { list0, list1, list2 };
    for (size_t i = 0; i < 3; i++) {
        Decoder dec = decoder_init(blobs[i]);
        BencodeValue res = {};
        DecoderErr err = decoder_run(&dec, &res);
        if (err != DECODER_NULL) {
            return decoder_err_msg(err);
        }

        if (res.type != BENCODE_LIST) {
            return "Expected result to be of type STR!";
        }

        ArrayList* res_arr = (ArrayList*) res.val.list;
        if (res_arr->len != expected[i].len) {
            char* err_msg = calloc(1024, sizeof(char));
            sprintf(err_msg, "[%ld]: Expected list len to be '%ld' but found '%ld'\n", i, expected[i].len, res_arr->len);
            return err_msg;
        }

        char* err_eql = arrayl_eql(&expected[i], res_arr);
        if (err_eql != NULL) {
            return err_eql;
        }
    }

    return NULL;
}
