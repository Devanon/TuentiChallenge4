#include <stdio.h>
#include <stdlib.h>
#include "uthash.h"

typedef unsigned long ulong;


// LINKED LIST

typedef struct LinkedListNode {
    ulong telephone;
    ulong contact_time;
    struct LinkedListNode* next;
} LinkedListNode;

int LL_add(LinkedListNode* list, ulong tel, ulong c_time) {
    LinkedListNode* current_node = list;
    while (current_node != NULL) {
        if (current_node->telephone == tel)
            return 0; // Item already in list
        current_node = current_node->next;
    }

    // Item not found in list, add it
    LinkedListNode* new_node = malloc( sizeof(LinkedListNode) );
    new_node->telephone = tel;
    new_node->contact_time = c_time;
    new_node->next = NULL;
    current_node->next = new_node;
    return 1;
}

LinkedListNode* LL_add_ordered(LinkedListNode* list, ulong tel, ulong c_time) {
    LinkedListNode* new_node = malloc( sizeof(LinkedListNode) );
    new_node->telephone = tel;
    new_node->contact_time = c_time;    

    if (c_time == list->contact_time) { // Base case only the first node added after the initial has the same time
        list->next = new_node;
        new_node->next = NULL;
        return list;
    }

    if (c_time < list->contact_time) {
        new_node->next = list;
        return new_node;
    }

    if (list->next != NULL) {
        list->next = new_node;
        new_node->next = NULL;
        return list;
    }

    LinkedListNode* previous_node = list;
    LinkedListNode* current_node = list->next;
    while (current_node->next != NULL && current_node->contact_time < c_time) {
        current_node = current_node->next;
    }
    previous_node->next = new_node;
    new_node->next = current_node;
    return list;
}

int LL_contains(LinkedListNode* list, ulong tel) {
    if (list == NULL) return 0; // return false
    while(list != NULL) {
        if (list->telephone == tel) return 1; // return true
        list = list->next;
    }
    return 0; // return false
}


// CONTACTS HASH

struct ContactsHash* contacts_hash = NULL;

typedef struct ContactsHash {
    UT_hash_handle hh;
    ulong telephone;
    LinkedListNode* contacts_list;
} ContactsHash;

int HT_add(ulong caller, ulong answer, ulong c_time) {
    ContactsHash *s;

    HASH_FIND_INT(contacts_hash, &caller, s);
    if (s == NULL) {
        //printf("Adding into HT %lu -> %lu @ %lu\n", caller, answer, c_time);
        
        s = (ContactsHash*) malloc( sizeof(ContactsHash) );
        s->telephone = caller;
        s->contacts_list = malloc( sizeof(LinkedListNode) );
            s->contacts_list->telephone = answer;
            s->contacts_list->contact_time = c_time;
            s->contacts_list->next = NULL;

        HASH_ADD_INT(contacts_hash, telephone, s );  /* telephone: name of key field */
        return 1; // Item inserted
    }

    //printf("Adding into LL %lu -> %lu @ %lu\n", caller, answer, c_time);
    return LL_add(s->contacts_list, answer, c_time);
}

ContactsHash* HT_find(ulong caller) {
    ContactsHash* s;
    HASH_FIND_INT(contacts_hash, &caller, s);
    return s;
}





int main(int argc, char* argv)
{
    FILE* ifp = fopen("phone_call.log", "r");
    ulong first, second;

    int count = 0;
    while ( count < 2 && !feof(ifp) ) {
        fscanf(ifp, "%lu %lu\n", &first, &second);
        
        if ( !HT_add(first, second, count) ) {
            printf("[ERROR] Adding %lu -> %lu @ %lu", first, second, count);
            exit(1);
        }
        if ( !HT_add(second, first, count) ) {
            printf("[ERROR] Adding %lu -> %lu @ %lu", second, first, count);
            exit(1);
        }

        count++;
    }

    //printf("Hash contacts: %d\n", HASH_COUNT(contacts_hash));

    ulong solution = 0;
    // Get terrorist numbers from input
    ulong terr1, terr2;
    scanf("%lu\n%lu\n", &terr1, &terr2);

    LinkedListNode* pending_tels = malloc( sizeof(LinkedListNode) ); // Telephones waiting for being investigated
    pending_tels->telephone = terr1;
    pending_tels->contact_time = 0;
    pending_tels->next = NULL;

    LinkedListNode* evaluated_tels = malloc( sizeof(LinkedListNode) ); // Telephones already investigated
    evaluated_tels->telephone = terr1;
    evaluated_tels->next = NULL;

    while (pending_tels != NULL) {
        
        // Second terrorist reached
        if (pending_tels->telephone == terr2) {
            if (pending_tels->contact_time > solution)
                solution = pending_tels->contact_time;
            printf("Connected at %lu\n", solution);
            exit(0);
        }

        ContactsHash* current_hash = HT_find(pending_tels->telephone);
        LinkedListNode* c_list = current_hash->contacts_list;
        while (c_list != NULL) {
            if ( !LL_contains(evaluated_tels, c_list->telephone) ) {
                pending_tels = LL_add_ordered(pending_tels, c_list->telephone, c_list->contact_time);
            }
            c_list = c_list->next;
        }

        LL_add(evaluated_tels, pending_tels->telephone, 0);
        // Free node evaluated, and jump to the next one
        LinkedListNode* temp = pending_tels;
        pending_tels =pending_tels->next;
        free(temp);
    }

    printf("Not connected");
}
