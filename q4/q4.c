#include<stdio.h>
#include<dlfcn.h>

int main(int argc, char* argv[]) {
    char op[6];
    int num1, num2;

    while(scanf("%5s %d %d", op, &num1, &num2) == 3) {
        char lib_path[20];

        snprintf(lib_path, sizeof(lib_path), "./lib%s.so", op);
        // ref: https://mprtmma.medium.com/c-shared-library-dynamic-loading-eps-2-28f0a109250a
        void *handle = dlopen(lib_path, RTLD_NOW);
        if(!handle) {
            continue;
        }

        dlerror();

        int(*operation) (int, int);
        operation = (int (*)(int, int)) dlsym(handle, op);

        char *error = dlerror();

        if(error == NULL) {
            int result = operation(num1, num2);
            printf("%d\n", result);
            fflush(stdout);
        }

        dlclose(handle);
    }
    return 0;   
}