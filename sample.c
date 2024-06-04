#include<stdio.h>

void mirror1(char a[][50],int x){
    int row=50;
    int col=50;
    char res[row][col];
    if(x==1){
        for(int i=0;i<row;i++){
            for(int j=0;j<col;j++){
                res[row-1-i][j]=a[i][j];
            }
        }
    }
    if(x==2){
        for(int i=0;i<row;i++){
            for(int j=0;j<col;j++){
                res[i][col-1-j]=a[i][j];
            }
        }
    }
    if(x==3){
        for(int i=0;i<row;i++){
            for(int j=0;j<col;j++){
                res[row-1-i][j]=a[i][j];
            }
        }
    }
    if(x==4){
        for(int i=0;i<row;i++){
            for(int j=0;j<col;j++){
                res[i][col-1-j]=a[i][j];
            }
        }
    }
    for(int i=0;i<row;i++){
        for(int j=0;j<col;j++){
            printf("%d",res[i][j]);
        }
        printf("\n");
    }
}

int main(){
    int row,col;
    scanf("%d %d",&row,&col);
    int num;
    scanf("%d",&num);
    char arr[row][col];
    for(int i=0;i<row;i++){
        for(int j=0;j<col;j++){
            scanf("%d",&arr[i][j]);
        }
    }
    mirror1(arr,num);
}