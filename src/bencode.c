#include <stdio.h>

#include "bencode.h"

void
bencode_print(BencodeValue const* const res) {
    switch(res->type) {
        case BENCODE_STR:
            printf("String: %s\n", res->val.str);
            break;
        case BENCODE_INT:
            printf("Int: %d\n", res->val.num);
            break;
    }
}
