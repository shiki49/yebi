#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <stdint.h>

union bit{
  uint32_t i32;
  float    f32;
};

void print_bit(uint32_t a,FILE *fout){
    int i=0,tmp;
    for(;i<=31;i++){
        tmp = (a >> (31 - i)) & 0x1;
        fprintf(fout,"%d",tmp);
    }
    fprintf(fout,"\n");
    return;
}

void print_bit2(uint32_t a,FILE *fout){
    fprintf(fout,"%d\n",a);
    return;
}

uint32_t float_rand(){
    int i=0,rnd;
    uint32_t tmp=0;
    for(;i<=3;i++){
        tmp <<= 8;
        rnd = rand() % 256;
        tmp += rnd;
    }

    return tmp;
}

int main(int argc,char *argv[]){
    int i;
    union bit argX,argY,ans;
    FILE *fp1,*fp2;
  
    srand((unsigned)time(NULL));

    if((fp1 = fopen("input.dat","w")) == NULL){
        return 1;
    }
    if((fp2 = fopen("answer.dat","w")) == NULL){
        return 1;
    }

    int num = atoi(argv[1]);
    int op  = atoi(argv[2]);

    for(i=0;i<num;i++){
        if((i % 1000) == 0){
            srand((unsigned)time(NULL));
        }
        argX.i32 = float_rand();
        argY.i32 = float_rand();
        print_bit(argX.i32,fp1);
        print_bit(argY.i32,fp1);
        if(op == 0){
            ans.f32 = argX.f32 + argY.f32;
        }else if(op == 1){
            ans.f32 = argX.f32 * argY.f32;
        }
        print_bit(ans.i32,fp2);
    }
    /* test1.f32 = 0.5; */
    /* test2.f32 = 2.0; */
    /* tmp.f32 = test1.f32 + test2.f32; */
    /* printf("%f %f %f\n",test1.f32,test2.f32,tmp.f32); */
    /* print_bit(test1.i32,fp2); */
    /* print_bit(test2.i32,fp2); */
    /* print_bit(tmp.i32,fp2); */

    return 0;
}
