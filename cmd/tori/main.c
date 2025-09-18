#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stddef.h>

#include "../../src/decoder.h"

void
print_help() {
    printf("Usage: tori <COMMAND>\n");
    printf("\n");
    printf("Commands:\n");
    printf("help                prints this message\n");
    printf("decode              decodes a bencoded string\n");
}

int
main(int argc, char** argv) {
    if (argc < 2) {
        print_help();
        return EXIT_FAILURE;
    }

    char const *const cmd = argv[1];
    if (strcmp("help", cmd) == 0) {
        print_help();
    } else if (strcmp("decode", cmd) == 0) {
        if (argc < 3) {
            printf("Expected bencoded string!\n");
            printf("Use: tori decode [bencoded string]\n");
            printf("i.e. 'tori decode i42e\n");
            return EXIT_FAILURE;
        }

        char const *const blob = argv[2];
        BencodeValue* res = calloc(1, sizeof(BencodeValue));
        Decoder dec = decoder_init(blob);
        DecoderErr err = decoder_run(&dec, res);
        if (err != DECODER_NULL) {
            printf("%s\n", decoder_err_msg(err));
            bencode_free(res);
            return EXIT_FAILURE;
        }

        bencode_print(res);
        bencode_free(res);
    } else {
        printf("Invalid command!\n");
        printf("Use: tori 'help'\n");
    }

    return EXIT_SUCCESS;
}
