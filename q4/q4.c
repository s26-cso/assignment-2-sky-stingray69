#include<stdio.h>
#include<dlfcn.h>

int main() {
    char op[6];
    int a, b;

    while(1) {
        scanf("%5s %d %d", op, &a, &b);
        char path[20];

        snprintf(path, sizeof(path), "./lib%s.so", op);
        // ref: https://mprtmma.medium.com/c-shared-library-dynamic-loading-eps-2-28f0a109250a
        void *handle;
        handle = dlopen(path, RTLD_NOW);
        if(!handle) {
            printf("Error\n");
            return -1;  
        }

        dlerror();

        int(*operation) (int, int);
        operation = (int (*)(int, int)) dlsym(handle, op);

        char *error = dlerror();

        if(error == NULL) {
            int result = operation(a, b);
            printf("%d\n", result);
        }

        dlclose(handle);
    }
    return 0;   
}