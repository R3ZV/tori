#include <stdio.h>
#include <memory.h>
#include <stdlib.h>

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
        case BENCODE_LIST:
            ArrayList* list = (ArrayList*)res->val.list;
            for (size_t i = 0; i < list->len; i++) {
                bencode_print(arrayl_get(list, i));
            }
            break;
    }
}


ArrayList
arrayl_init() {
    return (ArrayList) {
        .len = 0,
        .capacity = 4,
        .items = calloc(4, sizeof(BencodeValue)),
    };
}

void
arrayl_append(ArrayList* const self, BencodeValue* elem) {
    if (self->len >= self->capacity) {
        BencodeValue** old_items = self->items;
        self->capacity *= 2;

        self->items = calloc(self->capacity, sizeof(BencodeValue));
        memcpy(self->items, old_items, self->capacity / 2 * sizeof(BencodeValue));
        free(old_items);
    }
    self->items[self->len] = elem;
    self->len++;
}

[[nodiscard]] BencodeValue*
arrayl_get(ArrayList const *const self, size_t pos) {
    if (pos >= self->capacity) {
        return NULL;
    }
   return self->items[pos];
}
