#include <stdio.h>
#include <memory.h>
#include <stdlib.h>

#include "bencode.h"
#include "../lib/macros.h"

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
        .items = calloc(4, sizeof(BencodeValue*)),
    };
}

void
arrayl_append(ArrayList* const self, BencodeValue* elem) {
    if (self->len >= self->capacity) {
        BencodeValue** old_items = self->items;
        self->capacity *= 2;

        self->items = calloc(self->capacity, sizeof(BencodeValue*));
        memcpy(self->items, old_items, self->capacity / 2 * sizeof(BencodeValue*));
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

char*
arrayl_eql(ArrayList const *const self, ArrayList const *const other) {
    if (self->len != other->len) {
        char* err_msg = calloc(1024, sizeof(char));
        sprintf(err_msg, "Self has len '%ld' but other has len '%ld'\n", self->len, other->len);
        return err_msg;
    }

    for (size_t i = 0; i < self->len; i++) {
        BencodeValue self_bv = *self->items[i];
        BencodeValue other_bv = *other->items[i];

        if (self_bv.type != other_bv.type) {
            char* err_msg = calloc(1024, sizeof(char));
            sprintf(err_msg, "[%ld]: Self has type '%d' but other has type '%d'\n", i, self_bv.type, other_bv.type);
            return err_msg;
        }

        switch(self_bv.type) {
            case BENCODE_INT:
                if (self_bv.val.num != other_bv.val.num) {
                    char* err_msg = calloc(1024, sizeof(char));
                    sprintf(err_msg, "[%ld]: Self has value '%d' but other has value '%d'\n", i, self_bv.val.num, other_bv.val.num);
                    return err_msg;
                }
                break;
            case BENCODE_STR:
                if (strcmp(self_bv.val.str, other_bv.val.str) != 0) {
                    char* err_msg = calloc(1024, sizeof(char));
                    sprintf(err_msg, "[%ld]: Self has value '%s' but other has value '%s'\n", i, self_bv.val.str, other_bv.val.str);
                    return err_msg;
                }
                break;
            case BENCODE_LIST:
                return arrayl_eql(self_bv.val.list, other_bv.val.list);
        }
    }
    return NULL;
}

void
bencode_free(BencodeValue* self) {
    switch(self->type) {
        case BENCODE_INT:
            break;
        case BENCODE_STR:
            if (self->val.str != NULL) {
                free(self->val.str);
            }
            break;
        case BENCODE_LIST:
            if (self->val.list != NULL) {
                ArrayList* list = (ArrayList*) self->val.list;
                for (size_t i = 0; i < list->len; i++) {
                    bencode_free(arrayl_get(list, i));
                }
                free(list->items);
                free(list);
            }
            break;
    }

    free(self);
}
