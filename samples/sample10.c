#include <stdio.h>

int f(int x){
    if(x<=1){
        return 1;
    }
    return f(x-1) + f(x-2);
}

int main(){
    printf("%d ", f(30));
    return 0;
}