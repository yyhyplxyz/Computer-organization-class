// stdafx.h : 标准系统包含文件的包含文件，
// 或是经常使用但不常更改的
// 特定于项目的包含文件
//

#pragma once

#include "targetver.h"
#define _CRT_SECURE_NO_WARNINGS 1

//界面的相关的参数
#define WALL_SQUARE_WIDTH 10 //围墙方块的宽度
#define xWALL_SQUARE_NUM 48 //x轴方向的方块的数目
#define yWALL_SQUARE_WIDTH 46 //y轴方向的方块的数目
#define GAME_WALL_WIDTH  (WALL_SQUARE_WIDTH*xWALL_SQUARE_NUM) //游戏区域的宽度 300	
#define GAME_WALL_HTGH (WALL_SQUARE_WIDTH*yWALL_SQUARE_WIDTH) //游戏区域的高度 460

#define WINDOW_WIDTH 480 // 游戏总窗口宽度 480 
#define WINDOW_HIGH 460  // 游戏总窗口高度 460

//定义俄罗斯方块的相关参数
#define ROCK_SQUARE_WIDTH (2*WALL_SQUARE_WIDTH) //俄罗斯方块的大小是围墙的两倍 20
#define xROCK_SQUARE_NUM  ((GAME_WALL_WIDTH -20)/ROCK_SQUARE_WIDTH) // 游戏区x轴放的方块数目：14 
#define yROCK_SQUARE_NUM  ((GAME_WALL_HTGH -20)/ROCK_SQUARE_WIDTH)  // 游戏区y轴放的方块数目：22


//定义移动方块的相关操作
#define DIRECT_UP    3  
#define DIRECT_DOWN  2      
#define DIRECT_LEFT  -1  
#define DIRECT_RIGHT 1 

/*数据结构-线性表(结构体数组)*/
typedef struct ROCK
{
	//用来表示方块的形状(每一个字节是8位，用每4位表示方块中的一行)  
	unsigned short rockShapeBits;
	int          nextRockIndex;  //下一个方块，在数组中的下标  
} RockType;

//方块在图形窗口中的位置(即定位4*4大块的左上角坐标)  
typedef struct LOCATE
{
	int left;
	int top;
} RockLocation_t;

bool MoveAble(int rockIndex, RockLocation_t* currentLocatePtr, int f_direction);
void SetGameBoardFlag(int rockIdx, RockLocation_t* curRockLocation);
void UserHitKeyBoard(char userHit, int* RockIndex, RockLocation_t* curRockLocation);
void FullLine();
void UpdateSocres(int scores);
void DelCurLine(int rowIdx);
bool IsGameOver();
void DrawGameWindow();
void DisplayRock(int rockIdx, RockLocation_t*  LocatePtr, bool displayed);
//初始化Init源文件
void InitGame();
//game.h
void PlayGame();
bool IsGameOver();
void ReadRcok();
void ShapeStrToBit(unsigned char *rockShapeStr, unsigned short& rockShapeBit);



// TODO: 在此处引用程序需要的其他头文件
