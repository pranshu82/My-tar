#include<iostream>
using namespace std;

int main(){
    int n;
    cin>>n;
    int b[n]={0};
    for(int i=0;i<n-1;i++){
      int x;
      cin>>x;
      b[x-1]++;
    }
    for(int i=0;i<n;i++){
        if(b[i]==0){
            cout<<i+1;
            break;
        }
    }
}