#include <stdio.h>

int n;
int num[1000];
int len=1;

void carry()
{
	for(int i=0;i<len;i++)
	{
		num[i+1]=num[i+1] + (num[i]/10);
		num[i]=num[i]%10;
	}
	while(num[len]>0)
	{
		num[len+1]=num[len+1] + (num[len]/10);
		num[len]=num[len]%10;
		len++; 
	}
}

int main()
{
	scanf("%d",&n);
	num[0]=1;
	for(int i=2;i<=n;i++)
	{
		for(int j=0;j<len;j++)
			num[j]=num[j]*i;
		if(!(i%3)) carry();
	}
	carry();
	for(int i=len-1;i>=0;i--)
		printf("%d",num[i]);
	return 0;
}