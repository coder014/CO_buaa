#include<stdio.h>

int visit[8][8];
int n,m;
int ans;

void dfs(int x, int y)
{
	if(x<0) goto FOUT;
	if(x>=n) goto FOUT;
	if(y<0) goto FOUT;
	if(y>=m) goto FOUT;
	if(visit[x][y]==2)
	{
		++ans;
		goto FOUT;
	}
	if(visit[x][y]==1) goto FOUT;
	visit[x][y]=1;
	dfs(x+1,y);
	dfs(x-1,y);
	dfs(x,y+1);
	dfs(x,y-1);
	visit[x][y]=0;
FOUT:
	return;
}

int main()
{
	scanf("%d",&n);
	scanf("%d",&m);
	for(int i=0;i<n;i++)
		for(int j=0;j<m;j++)
			scanf("%d",&visit[i][j]);
	int x1,y1,x2,y2;
	scanf("%d",&x1);
	scanf("%d",&y1);
	scanf("%d",&x2);
	scanf("%d",&y2);
	--x1,--y1,--x2,--y2;
	visit[x2][y2]=2;
	dfs(x1,y1);
	printf("%d",ans);
	return 0;
}