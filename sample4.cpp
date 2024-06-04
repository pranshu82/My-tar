#include<iostream>
#include<string>
#include<cmath>
using namespace std;

int main(){
    string s;
    cin>>s;
  char curr,next;
  curr=s[0];
  next=s[1];
  int maxl=1;
  int leng=1;
  for(unsigned long long int i=2;i<s.length()+1;i++){
      if(curr==next){
          leng++;
      }else{
          if(maxl<leng){
              maxl=leng;
              leng=1;
      }
      }
      curr=next;
      if(i<s.length())
      next=s[i];   
  }
  cout<<max(maxl,leng)<<endl;
  
}