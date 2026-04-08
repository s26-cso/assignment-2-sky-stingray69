#include <stdio.h>
#include <stdlib.h>

// Struct definition
struct Node {
    int val;
    struct Node* left;
    struct Node* right;
};

// Declare your assembly functions
extern struct Node* make_node(int val);
extern struct Node* insert(struct Node* root, int val);
extern struct Node* get(struct Node* root, int val);
extern int getAtMost(int val, struct Node* root);

int main() {
    struct Node* root = NULL;
    
    // Test insert
    root = insert(root, 50);
    insert(root, 30);
    insert(root, 70);
    insert(root, 40);
    
    // Test get
    struct Node* found = get(root, 40);
    if (found) printf("Found: %d\n", found->val);
    else printf("Not found.\n");
    
    // Test getAtMost
    int atMost = getAtMost(45, root); // Should return 40
    printf("Get At Most 45: %d\n", atMost);
    
    return 0;
}