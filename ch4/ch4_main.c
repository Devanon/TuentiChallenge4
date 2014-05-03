#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>


// Reads a line of unknown length until EOF or '\n' is found, and store it in the pointer given.
// Returns the length of the line saved.
int readline(char* input)
{
    char* buffer = malloc(32 * sizeof(char));
    unsigned int buffer_size = 32;
    unsigned int buffer_used = 0;

    char c = EOF;
    while ( (c = getchar()) != '\n' && c != EOF ) {
        if (buffer_used == buffer_size) {
            buffer_size *= 2;
            buffer = realloc(buffer, buffer_size);
        }
        buffer[buffer_used++] = (char) c;
    }
    buffer[buffer_used] = '\0'; // Add the end of the string

    if (strlen(buffer) == 0) { // No input
        free(buffer);
        return 0;

    } else { // Copy from buffer to string pointer given
        input = realloc(input, (strlen(buffer) + 1) * sizeof(char));
        strncpy(input, buffer, strlen(buffer));
        input[strlen(buffer) + 1] = '\0';

        free(buffer);
        return strlen(input);
    }
}


// Function to evaluate if two states are similar enough to permit the mutation
int mutable_to(const char* str1, const char* str2)
{
    unsigned int changes = 0;
    
    if ( strlen(str1) != strlen(str2) )
        return -1;

    int i;
    for (i = 0; i < strlen(str1); i++) {
        if (str1[i] != str2[i]) changes++;
    }

    if (changes == 1) return 1;
    else return 0;
}

// Struct to store the data of each of the nodes in the search tree
typedef struct Node {
    char* state;
    unsigned long no_of_changes;
    char* output;
    struct Node* next;
} Node;


// Function to create and traverse the search tree to find the best solution. Actually no tree is
// built, and the created nodes are pushed into a list.
resolve(char* init_state, char* end_state, char** safe_states, 
        unsigned int safes_stored)
{
    unsigned long min_changes = ULONG_MAX; // Value to avoid evaluating useless nodes
    char* best_move;

    Node* pending_nodes_first = NULL;
    Node* pending_nodes_last = NULL;

    Node* root = malloc( sizeof(Node) );
    root->state = strdup(init_state);
    root->no_of_changes = 0;
    root->output = strdup(init_state);
    root->next = NULL;
    pending_nodes_first = root;
    pending_nodes_last = root;

    while (pending_nodes_first != NULL) {
        Node* current_node = pending_nodes_first;

        if (current_node->no_of_changes < min_changes) {

            if ( strncmp(current_node->state, end_state, strlen(end_state)) == 0 ) {
                min_changes = current_node->no_of_changes;
                best_move = strdup(current_node->output);

            } else {

                int i;
                for (i = 0; i < safes_stored; i++) {
                    if( mutable_to(current_node->state, safe_states[i]) ){
                        Node* new_node = malloc( sizeof(Node) );
                        new_node->state = strdup(safe_states[i]);
                        new_node->no_of_changes = current_node->no_of_changes + 1;
                        new_node->output = strdup(current_node->output);
                        strcat(new_node->output, "->");
                        strcat(new_node->output, new_node->state);
                        new_node->next = NULL;

                        pending_nodes_last->next = new_node;
                        pending_nodes_last = new_node;
                    }
                }
            }        
        }
         
        if (pending_nodes_first == pending_nodes_last)
            pending_nodes_last = NULL;
        pending_nodes_first = pending_nodes_first->next;

        free(current_node->state);
        free(current_node->output);
        free(current_node);
    }

    printf("%s\n", best_move);

}


// MAIN
int main(int argc, char* argv)
{
    unsigned long states_length;
    char* init_state = malloc( sizeof(char) );
    char* end_state = malloc( sizeof(char) );

    states_length = readline(init_state);
    readline(end_state);

    // Get from stdin all the safe states and store them in an array
    unsigned int safes_array_size = 32;
    unsigned int safes_number = 0;
    char** safes_array = malloc(32 * sizeof(char*));

    unsigned int err;

    while ( !feof(stdin) ) {
        if ( safes_number == safes_array_size) {
            safes_array_size *= 2;
            safes_array = realloc(safes_array, safes_array_size * sizeof(char*));
        }

        safes_array[safes_number] = malloc( sizeof(char) );
        if ( readline(safes_array[safes_number]) ) {
            safes_array[safes_number][states_length] = '\0';
            safes_number++; 
        }
    }

    resolve(init_state, end_state, safes_array, safes_number);

    int i;
    for(i = 0; i < safes_number; i++)
        free(safes_array[i]);
    free(safes_array);
}
