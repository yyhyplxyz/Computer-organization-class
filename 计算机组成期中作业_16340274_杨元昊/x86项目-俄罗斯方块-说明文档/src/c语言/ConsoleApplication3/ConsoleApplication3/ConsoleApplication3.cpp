// ConsoleApplication3.cpp: 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <graphics.h>
#include <stdio.h>
#include <stdlib.h>


int main()
{
	initgraph(WINDOW_WIDTH, WINDOW_HIGH);

	DrawGameWindow();
	//使用 API 函数修改窗口名称  
	HWND hWnd = GetHWnd();
	SetWindowText(hWnd, _T("俄罗斯方块"));
	InitGame();
	PlayGame();
	getchar();
	closegraph();
	system("pause");
	return	0;
}
