#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "include/bencode.h"

const char *const usage =
    "Usage: tori <COMMAND> [args]\n"
    "\n"
    "Commands:\n"
    "  decode        decodes a bencoded value\n"
    "  help          display this message"
;

int main(int argc, char** argv) {
    if (argc < 2) {
        printf("%s\n", usage);
        return EXIT_FAILURE;
    }

    const char* const cmd = argv[1];
    if (strcmp(cmd, "decode") == 0) {
        if (argc < 3) {
            printf("Invalid number of arguments!\n");
            printf("Expected bencoded value!\n");
            return EXIT_FAILURE;
        }

        const char* const blob = argv[2];
        BencodeDecoder decoder = bencode_init(blob);
        BencodeType elem = bencode_decode(&decoder);
        switch(elem.tag) {
            case BENTAG_NUMBER:
                printf("%ld\n", elem.data.number);
                break;
            case BENTAG_STR:
                printf("%s\n", elem.data.str);
                break;
            default:
                printf("Unsupported type!\n");
        }
    } else if (strcmp(cmd, "help") == 0) {
        printf("%s\n", usage);
    } else {
        printf("Invalid command!\n");
        printf("Use 'tori help' for all available commands!\n");
        return EXIT_FAILURE;
    }
   
    return EXIT_SUCCESS;
};
