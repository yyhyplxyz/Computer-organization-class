// stdafx.cpp : 只包括标准包含文件的源文件
// ConsoleApplication3.pch 将作为预编译标头
// stdafx.obj 将包含预编译类型信息

#include "stdafx.h"

#include <stdio.h>
#include <tchar.h>
#include<graphics.h>
#include<stdio.h>
#include<conio.h>
#include<stdlib.h>
#include<time.h>
#include<string.h>



//全局变量-游戏板的状态描述(即表示当前界面哪些位置有方块)  
//0表示没有，1表示有(多加了两行和两列，形成一个围墙，便于判断方块是否能够移动)  
int game_board[yROCK_SQUARE_NUM + 2][xROCK_SQUARE_NUM + 2] = { 0 };
//int game_socres = 0; //全局分数

					 // 把俄罗斯方块的19种类放到数组中
int rockTypeNum = 19;
RockType RockArray[19] = { (0, 0) };

//预览区的方块的位置
RockLocation_t preRockLocation = { GAME_WALL_WIDTH + 70,70 };
//每次生成初始化方块的位置
RockLocation_t initRockLocation = { (WALL_SQUARE_WIDTH + 100), WALL_SQUARE_WIDTH };
//分数显示的位置


//画出游戏界面
void DrawGameWindow()
{
	//先画出围墙
	setcolor(BLUE);
	setlinestyle(PS_SOLID, NULL, 0);
	setfillcolor(BLUE);
	//画出上下围墙
	for (int x = WALL_SQUARE_WIDTH; x <= GAME_WALL_WIDTH; x += WALL_SQUARE_WIDTH)
	{
		fillrectangle(x - WALL_SQUARE_WIDTH, 0, x, WALL_SQUARE_WIDTH); //上
		fillrectangle(x - WALL_SQUARE_WIDTH, GAME_WALL_HTGH - WALL_SQUARE_WIDTH, x, GAME_WALL_HTGH);//下
	}
	//画出左右围墙
	for (int y = WALL_SQUARE_WIDTH; y <= GAME_WALL_HTGH; y += WALL_SQUARE_WIDTH)
	{
		fillrectangle(0, y, WALL_SQUARE_WIDTH, y + WALL_SQUARE_WIDTH);//左
		fillrectangle(GAME_WALL_WIDTH - WALL_SQUARE_WIDTH, y, GAME_WALL_WIDTH, y + WALL_SQUARE_WIDTH);//右
	}
	
}

//在游戏区显示编号为rockIdx的方块
void DisplayRock(int rockIdx, RockLocation_t*  LocatePtr, bool displayed)
{
	int color;//方块的填充颜色
	int lineColor = WHITE;//线的颜色
	int boardFalg = 0;
	int xRock = 0;
	int yRock = 0;       
	unsigned short rockCode = RockArray[rockIdx].rockShapeBits;
	//如果displayed为true的话，将方块块颜色设置为white，game_board对应的位置设置为1；
	//如果displayed为false的话，将方块块颜色设置为black，game_board对应的位置设置为0；
	displayed ? (color = GREEN, boardFalg = 1) : (color = BLACK, lineColor = BLACK, boardFalg = 0);

	setcolor(lineColor);
	setfillcolor(color);

	setlinestyle(PS_SOLID);//设置为实线，
	xRock = LocatePtr->left;
	yRock = LocatePtr->top;

	int count = 0;//每4个换行，记录坐标偏移量
	unsigned short mask = 1;
	for (int i = 1; i <= 16; ++i)
	{

		mask = 1 << (16 - i);
		if ((rockCode & mask) != 0) //如果不为0的话，就画出小方块
		{
			fillrectangle(xRock, yRock, xRock + ROCK_SQUARE_WIDTH, yRock + ROCK_SQUARE_WIDTH);
		}
		if (i % 4 == 0) //换行
		{
			yRock = yRock + ROCK_SQUARE_WIDTH;
			xRock = xRock = LocatePtr->left;
		}
		else
		{
			xRock += ROCK_SQUARE_WIDTH;
		}
	}
}
void changecolor(int rockIdx, RockLocation_t*  LocatePtr, bool displayed)
{
	int color;//方块的填充颜色
	int lineColor = WHITE;//线的颜色
	int boardFalg = 0;
	int xRock = 0;
	int yRock = 0;
	unsigned short rockCode = RockArray[rockIdx].rockShapeBits;

	setcolor(lineColor);
	setfillcolor(RED);

	setlinestyle(PS_SOLID);//设置为实线，
	xRock = LocatePtr->left;
	yRock = LocatePtr->top;

	int count = 0;//每4个换行，记录坐标偏移量
	unsigned short mask = 1;
	for (int i = 1; i <= 16; ++i)
	{

		mask = 1 << (16 - i);
		if ((rockCode & mask) != 0) //如果不为0的话，就画出小方块
		{
			fillrectangle(xRock, yRock, xRock + ROCK_SQUARE_WIDTH, yRock + ROCK_SQUARE_WIDTH);
		}
		if (i % 4 == 0) //换行
		{
			yRock = yRock + ROCK_SQUARE_WIDTH;
			xRock = xRock = LocatePtr->left;
		}
		else
		{
			xRock += ROCK_SQUARE_WIDTH;
		}
	}
}
void InitGame()
{
	//把全局游戏游戏版初始化，边界初始化为1
	for (int i = 0; i < xROCK_SQUARE_NUM + 2; i++)
	{
		game_board[0][i] = 1;  //上边界
		game_board[yROCK_SQUARE_NUM + 1][i] = 1; //下边界
	}
	for (int i = 0; i < yROCK_SQUARE_NUM + 2; i++)
	{
		game_board[i][0] = 1; //左边界
		game_board[i][xROCK_SQUARE_NUM + 1] = 1; //右边界
	}
	//读取俄罗斯方块 
	ReadRcok();

}

//从文件中读取方块的形状存储到rockArray中
void ReadRcok()
{
	errno_t err;
	FILE* fp = NULL;
	err = fopen_s(&fp, "RockShape.ini", "r");
	if (NULL == fp)
	{
		printf("打开文件失败\n");
		return;
	}
	unsigned char readBuf[1024]; //fp读取到字符串readbuf中
	unsigned short rockShapeBit = 0;//存放方块形状，占16比特位
	unsigned char rockShapeStr[16];//存放方块字符串
	int ShapeStrIdx = 0;
	int rockNum = 0;//统计方块的个数以及存放方块数组RockArray的下标
	int rocknext = 0;//方块数组中下一个形状
	int rockShapeStart = 0;//同一类型的形状
	while (true)
	{
		size_t readSize = fread(readBuf, 1, 1024, fp);
		if (readSize == 0)
			break;
		//处理readbuf
		for (size_t idx = 0; idx < readSize; ++idx)
		{
			//将字符存放到rockShapeStr中
			while (ShapeStrIdx < 16 && idx < readSize)
			{
				if (readBuf[idx] == '@' || readBuf[idx] == '#')
				{
					rockShapeStr[ShapeStrIdx] = (unsigned char)readBuf[idx];
					++ShapeStrIdx;
				}
				++idx; //可能idx == readSize了 
				if (readBuf[idx] == '*')//修改上一次方块的next值
				{
					idx += 5;
					RockArray[--rockNum].nextRockIndex = rockShapeStart;
					rockNum++;
					rockShapeStart = rockNum;
					rocknext = rockShapeStart;
				}
			}
			//可能没有填满
			if (ShapeStrIdx < 16)
			{
				break;
			}
			else //填满shapestr
			{
				ShapeStrIdx = 0;//置0
								//将rockShapeStr 转为rockShapeBit
				ShapeStrToBit(rockShapeStr, rockShapeBit);
				rocknext++;
				RockArray[rockNum].rockShapeBits = rockShapeBit;
				RockArray[rockNum].nextRockIndex = rocknext;
				rockNum++;
			}
		}
	}
	fclose(fp);
}
//将从文件中读取的字符串(长度默认为16)转换成 unsigned short
void ShapeStrToBit(unsigned char *rockShapeStr, unsigned short& rockShapeBit)
{
	rockShapeBit = 0;
	for (size_t idx = 0; idx < 16; ++idx)
	{
		if (rockShapeStr[idx] == '@') //1
		{
			rockShapeBit |= (1 << (16 - idx - 1));
		}
		// #为0 不需要处理
	}
}
#define _CRT_SECURE_NO_WARNINGS 1




void PlayGame()
{
	char userHit = 0;//用户敲击键盘
	int curRockIndex = 0;//当前方块的rockArray下标
	int nextRockIndex = 0;//下次
	RockLocation_t curRockLocation;
	curRockLocation.left = initRockLocation.left;
	curRockLocation.top = initRockLocation.top;
	DWORD oldtime = 0;
	srand((unsigned int)time(NULL));
	curRockIndex = rand() % rockTypeNum;
	nextRockIndex = rand() % rockTypeNum;
	//画出预览区初始化方块
	//在初始位置和预览区显示方块形状
	DisplayRock(curRockIndex, &initRockLocation, 1);
	//DisplayRock(nextRockIndex, &preRockLocation, 1);
	bool moveAbled = false;
	while (true)
	{
		//判断当前方块是否落地(判断能否再下移)：如果落地,判断是否满行,再判断是否结束游戏， 改变game_board ,画出下次初始化的方块，以及生成新的预览方块
		//
		moveAbled = MoveAble(curRockIndex, &curRockLocation, DIRECT_DOWN);
		if (!moveAbled) //判断是否落地，不能下移表示落地
		{
			//修改game_board的值
			SetGameBoardFlag(curRockIndex, &curRockLocation);
			FullLine();
			if (IsGameOver())
			{
				MessageBox(NULL, _T("游戏结束"), _T("GAME OVER"), MB_OK);
				exit(0);
			}
			//为下次生成模块开始准备
			DisplayRock(nextRockIndex, &preRockLocation, false);//擦除旧的方块
			curRockIndex = nextRockIndex;
			nextRockIndex = rand() % rockTypeNum; //生成新的预览方块
			FlushBatchDraw();
			//修改curRockLocation的值
			curRockLocation.left = initRockLocation.left;
			curRockLocation.top = initRockLocation.top;
		}
		if (_kbhit()) //如果敲击键盘了 就处理按键
		{
			userHit = _getch();
			UserHitKeyBoard(userHit, &curRockIndex, &curRockLocation);
		}

		//没有 就自动下移一个单位 :不能用else，因为可能按键不是上下左右
		DWORD newtime = GetTickCount();
		if (newtime - oldtime >= (unsigned int)(300) && moveAbled == TRUE)
		{
			oldtime = newtime;
			DisplayRock(curRockIndex, &curRockLocation, false);
			curRockLocation.top += ROCK_SQUARE_WIDTH; //下落一格  
		}
		DisplayRock(curRockIndex, &curRockLocation, 1);
		FlushBatchDraw();//刷新界面，防止出现闪屏
		Sleep(20);
	}
}


//响应键盘命令时间
void UserHitKeyBoard(char userHit, int* RockIndex, RockLocation_t* curRockLocation)
{
	switch (userHit)
	{
	case 72:
	case ' '://↑
		if (MoveAble(RockArray[*RockIndex].nextRockIndex, curRockLocation, DIRECT_UP))
		{
			DisplayRock(*RockIndex, curRockLocation, false);
			*RockIndex = RockArray[*RockIndex].nextRockIndex;
		}
		break;
	case 80:
	case 's'://↓
		if (MoveAble(*RockIndex, curRockLocation, DIRECT_DOWN))
		{
			DisplayRock(*RockIndex, curRockLocation, false);
			curRockLocation->top += 2 * (ROCK_SQUARE_WIDTH);
			if (!MoveAble(*RockIndex, curRockLocation, DIRECT_DOWN))
			{
				curRockLocation->top -= ROCK_SQUARE_WIDTH;
			}
		}
		break;
	case 75:
	case 'a': //←
		if (MoveAble(*RockIndex, curRockLocation, DIRECT_LEFT))
		{
			DisplayRock(*RockIndex, curRockLocation, false);
			curRockLocation->left -= ROCK_SQUARE_WIDTH;
		}
		break;
	case 77:
	case 'd': //→
		if (MoveAble(*RockIndex, curRockLocation, DIRECT_RIGHT))
		{
			DisplayRock(*RockIndex, curRockLocation, FALSE);
			curRockLocation->left += ROCK_SQUARE_WIDTH;
		}
		break;
	default:
		break;
	}
}

//判断是否满行，满行消除，然后计算得分
void FullLine()
{
	bool linefull = true;
	int idx = yROCK_SQUARE_NUM;//从最后一行往上查找 22
	int count = 0;
	while (count != xROCK_SQUARE_NUM) //遇到空行 14
	{
		linefull = true;
		count = 0;
		for (int i = 1; i <= xROCK_SQUARE_NUM; ++i)
		{
			if (game_board[idx][i] == 0)
			{
				linefull = false;
				count++;
			}
		}
		if (linefull) //满行，消除当前行，更新分数
		{
			DelCurLine(idx);
			//game_socres += 3;
			//UpdateSocres(game_socres);
			idx++;//因为下面要减1
		}
		idx--;
	}

}
void UpdateSocres(int scores)
{
	setcolor(RED);
	TCHAR s[10];
	_stprintf_s(s, _T("%d"), scores);
	outtextxy(GAME_WALL_WIDTH + 90, 200, s);
}
//消除当前行
void DelCurLine(int rowIdx)
{
	//擦除当前行
	setcolor(BLACK);
	setfillcolor(BLACK);
	for (int i = 1; i < xROCK_SQUARE_NUM; ++i)
	{
		fillrectangle(WALL_SQUARE_WIDTH + (i - 1)*ROCK_SQUARE_WIDTH, (rowIdx - 1)*ROCK_SQUARE_WIDTH + WALL_SQUARE_WIDTH,
			WALL_SQUARE_WIDTH + i * ROCK_SQUARE_WIDTH, rowIdx*ROCK_SQUARE_WIDTH + WALL_SQUARE_WIDTH);
	}
	//把上面的向下移
	int cnt = 0;
	while (cnt != xROCK_SQUARE_NUM) //直到遇到是空行的为止  
	{
		cnt = 0;
		for (int i = 1; i <= xROCK_SQUARE_NUM; i++)
		{
			game_board[rowIdx][i] = game_board[rowIdx - 1][i];

			//擦除上面的一行  
			setcolor(BLACK);
			setfillcolor(BLACK);
			fillrectangle(WALL_SQUARE_WIDTH + ROCK_SQUARE_WIDTH * i - ROCK_SQUARE_WIDTH,
				WALL_SQUARE_WIDTH + ROCK_SQUARE_WIDTH * (rowIdx - 1) - ROCK_SQUARE_WIDTH,
				WALL_SQUARE_WIDTH + ROCK_SQUARE_WIDTH * i,
				WALL_SQUARE_WIDTH + ROCK_SQUARE_WIDTH * (rowIdx - 1));

			//显示下面的一行  
			if (game_board[rowIdx][i] == 1)
			{
				setcolor(WHITE);
				setfillcolor(RED);
				fillrectangle(WALL_SQUARE_WIDTH + ROCK_SQUARE_WIDTH * i - ROCK_SQUARE_WIDTH,
					WALL_SQUARE_WIDTH + ROCK_SQUARE_WIDTH * rowIdx - ROCK_SQUARE_WIDTH,
					WALL_SQUARE_WIDTH + ROCK_SQUARE_WIDTH * i,
					WALL_SQUARE_WIDTH + ROCK_SQUARE_WIDTH * rowIdx);
			}

			if (game_board[rowIdx][i] == 0)
				cnt++;            //统计一行是不是 都是空格  
		}//for  
		rowIdx--;
	}
}

//是否可以移动方块
bool MoveAble(int rockIndex, RockLocation_t* currentLocatePtr, int f_direction)
{
	int mask;
	int rockX;
	int rockY;

	rockX = currentLocatePtr->left;
	rockY = currentLocatePtr->top;

	mask = (unsigned short)1 << 15;
	for (int i = 1; i <= 16; i++)
	{
		//与掩码相与为1的 即为方块上的点  
		if ((RockArray[rockIndex].rockShapeBits & mask) != 0)
		{
			//判断能否移动(即扫描即将移动的位置 是否与设置的围墙有重叠)  
			//若是向上(即翻滚变形)  
			if (f_direction == DIRECT_UP)
			{
				//因为此情况下传入的是下一个方块的形状，故我们直接判断此方块的位置是否已经被占 
				//判断下一个方块
				if (game_board[(rockY - WALL_SQUARE_WIDTH) / ROCK_SQUARE_WIDTH + 1]
					[(rockX - WALL_SQUARE_WIDTH) / ROCK_SQUARE_WIDTH + 1] == 1)
					return false;
			}
			//如果是向下方向移动  
			else if (f_direction == DIRECT_DOWN)
			{
				if (game_board[(rockY - WALL_SQUARE_WIDTH) / ROCK_SQUARE_WIDTH + 2]
					[(rockX - WALL_SQUARE_WIDTH) / ROCK_SQUARE_WIDTH + 1] == 1)
					return false;
			}
			else //如果是左右方向移动  
			{   //f_direction的DIRECT_LEFT为-1，DIRECT_RIGHT为1，故直接加f_direction即可判断。  
				if (game_board[(rockY - WALL_SQUARE_WIDTH) / ROCK_SQUARE_WIDTH + 1]
					[(rockX - WALL_SQUARE_WIDTH) / ROCK_SQUARE_WIDTH + 1 + f_direction] == 1)
					return false;
			}
		}

		//每4次 换行 转到下一行继续  
		i % 4 == 0 ? (rockY += ROCK_SQUARE_WIDTH, rockX = currentLocatePtr->left)
			: rockX += ROCK_SQUARE_WIDTH;

		mask >>= 1;
	}

	return true;

}
//给游戏game_board设置标记表示已经占了
void SetGameBoardFlag(int rockIdx, RockLocation_t* curRockLocation)
{
	changecolor(rockIdx, curRockLocation, 1);
	int mask;
	int rockX;
	int rockY;

	rockX = curRockLocation->left;
	rockY = curRockLocation->top;

	mask = (unsigned int)1 << 15;
	for (int i = 1; i <= 16; i++)
	{
		//与掩码相与为1的 即为方块上的点  
		if ((RockArray[rockIdx].rockShapeBits & mask) != 0)
		{
			game_board[(rockY - WALL_SQUARE_WIDTH) / ROCK_SQUARE_WIDTH + 1]
				[(rockX - WALL_SQUARE_WIDTH) / ROCK_SQUARE_WIDTH + 1] = 1;
		}

		//每4次 换行 转到下一行继续画  
		i % 4 == 0 ? (rockY += ROCK_SQUARE_WIDTH, rockX = curRockLocation->left)
			: rockX += ROCK_SQUARE_WIDTH;

		mask >>= 1;
	}
}
//判断游戏是否结束
bool IsGameOver()
{
	bool topLineHaveRock = false;//顶行是否有方块
	bool bottomLineHaveRock = false;

	for (int i = 1; i < xROCK_SQUARE_NUM; ++i)
	{
		if (game_board[1][i] == 1)
			topLineHaveRock = true;
		if (game_board[yROCK_SQUARE_NUM][i] == 1)
			bottomLineHaveRock = true;
	}
	if (topLineHaveRock)
		return true;
	else
		return false;
}

// TODO: 在 STDAFX.H 中引用任何所需的附加头文件，
//而不是在此文件中引用
