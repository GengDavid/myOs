extern void clear();
extern void inputchar();
extern void printchar();
extern void printstring();
extern void printstring2();
extern void setcursor();
extern void load();
extern void jmp();
extern void filldata();
extern void readdata();
extern int put_color_char();
extern void setClock();
extern void another_load(int segment,int offset);
#include  "MyPCB.h"

char message1[80]="Welcome to use system of zgw and xh\n";
char message2[80]="you can input some legal instructions\n";
char message3[80]="    if you want to run the program by Batching,input \'batch\'\n";
char message4[80]="       for example: b 1 2 3 4 5 6\n";
char message7[80]="    if you want to know the information of the program,input \'show\'\n";
char message8[80]="       for example: show\n";
char message9[80]="    if you want to run the default instructions,input \'default\'\n";
char message10[80]="       for example: default\n\n";
char message11[80]="If you want to continue,input \'yes\'\n";
char message12[80]="OS will run instructions \'batch 1 2 3 4 5 6\' \n";
char message_cmd[80]="Commond> ";
char message_show0[80]="GROUP MEMBER:\n zhang_geng_wei 15352403, \n xie_hong 15352355\n";
char message_show1[80]="USER PROGRAM1:\n   Name:zgw_clinet1,Size:1024byte,Position:section 2\n";
char message_show2[80]="USER PROGRAM2:\n   Name:zgw_clinet2,Size:1024byte,Position:section 4\n";
char message_show3[80]="USER PROGRAM3:\n   Name:zgw_clinet3,Size:1024byte,Position:section 6\n";
char message_show4[80]="USER PROGRAM4:\n   Name:zgw_clinet4,Size:1024byte,Position:section 8\n";
char message_show5[80]="USER PROGRAM5:\n   Name:xh_game,Size:1024byte,Position:section 10\n";
char string[80];
char message_error[80]="INPUT ERROR!!\n";
const char default1[80]="batch 1 2 3 4 5 6";
int len=0;
int pos=0;
char ch;
int x=0;
int y=0;
int i=0;
int a=0;
int u=0;
int d=0;/*data*/
int offset_user=0xb100-0x8000;/*用户程序偏移量*/
const int offset_user1=0xb100-0x8000;
const int offset_user2=0xb500-0x8000;
const int offset_user3=0xb900-0x8000;
const int offset_user4=0xbd00-0x8000;
const int offset_user5=0xc100-0x8000;
const int offset_user6=0xc500-0x8000;
const int hex600h=1536;/*600h*/
int offset_begin=0xb100-0x8000;/*读到内存的偏移量*/
int num_shanqu=12;/*扇区数*/
int pos_shanqu=2;/*起始扇区数*/

int px,py,pcolor,pdir,pbegin,p_cnt;
char pch;
char chs[4];
c_paint()
{
	/*初始化*/
	if(pbegin!=1)
	{
		px=24;
		py=79;
		pcolor=1;
		p_cnt=0;
		chs[0]='|';chs[1]='/';chs[2]='\\';
		pch=chs[0];
		pbegin=1;
	}
	/*显示字符，更新颜色和位置*/
	put_color_char(pch,px,py,pcolor);
	pch=chs[p_cnt%3];
	pcolor=(pcolor+1)%15+1;
	p_cnt=p_cnt+1;
	p_cnt=p_cnt%3;
}

int is_ouch;
int ouch_color;
/*键盘中断显示程序*/
c_ouch()
{
	/*初始化*/
	if(is_ouch==1) {
		x=y=pos=0;
		is_ouch=0;
		ouch_color=1;
	}
	/*显示字符串Ouch!，并自动更新显示位置*/
	printstring2(ouch_color,"Ouch!");
	/*更新颜色*/
	ouch_color++;
	if(ouch_color>15) ouch_color=1;
}

int input()
{
	inputchar();/*输入字符*/
	if(ch=='\b'){/*是删除键Backspace*/
		if(y>8&&y<79){
			y--;
			cal_pos();
			printchar(' ');
			y--;
			cal_pos();
		}
		return 0;
	}
	else if(ch==13);/*是回车*/
	else printchar(ch);/*显示字符*/
	return 1;
}

cin_cmd(){
	printstring(message_cmd);
	i=0;/*初始字符串下标*/
	while(1)
	{
		if(input()){/*不是删除键*/
			if(ch==13) break;/*是回车*/
			string[i++]=ch;
		}
		else if(i>0) i--; /*是删除键，则删除*/
	}
	/*去掉字符串前面的空格*/
	for(a=0;a<i;++a)
		if(string[0]==' '){
			for(u=1;u<i;++u) string[u-1]=string[u];
			i--;
		}
		else break;
	string[i]='\0';/*末尾加空字符*/
	len=i;/*记录字符串长度*/
	printstring("\n");
}

cal_pos()
{	
	if(y>79){
		y=0;
		x++;
	}
	if(x>24) clear();
	pos=(x*80+y)*2;
	setcursor();
}

batch()
{
	clear();/*清屏*/
	offset_begin=offset_user1;/*内存偏移量*/
	num_shanqu=12;/*扇区数目*/
	pos_shanqu=2;/*起始扇区号*/
	load(offset_begin,num_shanqu,pos_shanqu);/*装载用户程序到内存*/
	/*向600h,602h,604h,606h送0*/
	filldata(hex600h,0);
	filldata(hex600h+2,0);
	filldata(hex600h+4,0);
	filldata(hex600h+6,0);
	for(i=0;i<len;++i)/*遍历字符串*/
	{
		if(string[i]=='1')/*跳转到用户程序1*/
		{
			offset_user=offset_user1;
			jmp();
		}
		else if(string[i]=='2')/*跳转到用户程序2*/
		{
			offset_user=offset_user2;
			jmp();
		}
		else if(string[i]=='3')/*跳转到用户程序3*/
		{
			offset_user=offset_user3;
			jmp();
		}
		else if(string[i]=='4')/*跳转到用户程序4*/
		{
			offset_user=offset_user4;
			jmp();
		}
		else if(string[i]=='5'){
			offset_user=offset_user5;
			jmp();
		}
		else if(string[i]=='6'){
			offset_user=offset_user6;
			jmp();
		}
	}
}


void init_pro(){
	init(&pcb_list[0],0x800,0x100);
	init(&pcb_list[1],offset_user1,0x100);
	init(&pcb_list[2],offset_user2,0x100);
	init(&pcb_list[3],offset_user3,0x100);
	init(&pcb_list[4],offset_user4,0x100);
	init(&pcb_list[5],offset_user5,0x100);
}


void load_pro(){
	int i = 0;
	int j = 0;

	for( i=0; i<len;i++ )
	{
		if( string[i] ==' ' )
			continue;
		else if(string[i]=='1')/*跳转到用户程序1*/
		{
			offset_user=offset_user1;
		}
		else if(string[i]=='2')/*跳转到用户程序2*/
		{
			offset_user=offset_user2;
		}
		else if(string[i]=='3')/*跳转到用户程序3*/
		{
			offset_user=offset_user3;
		}
		else if(string[i]=='4')/*跳转到用户程序4*/
		{
			offset_user=offset_user4;
		}
		else if(string[i]=='5'){
			offset_user=offset_user5;
		}
		else if(string[i]=='6'){
			offset_user=offset_user6;
		}
		j = string[i] - '0';		
		another_load(offset_user,j);
		Program_Num ++;
	}
	printchar(Program_Num+'0');
	init_pro();
	setClock();
}

cmain(){

	while(1)
{
	clear();
	printstring(message1);
	printstring(message2);
	printstring(message3);
	printstring(message4);
	printstring(message7);
	printstring(message8);
	printstring(message9);
	printstring(message10);
	cin_cmd();
	if(string[0]=='b')
	{
		batch();
		printstring(message11);
		cin_cmd();
		if(string[0]=='y') continue;
	}
	else if(string[0]=='s')
	{
		printstring(message_show0);
		printstring(message_show1);
		printstring(message_show2);
		printstring(message_show3);
		printstring(message_show4);
		printstring(message_show5);
		printstring(message11);
		cin_cmd();
		if(string[0]=='y') continue;
	}
	else if(string[0]=='d')
	{
		printstring(message12);
		printstring(message11);
		cin_cmd();
		if(string[0]=='y')
		{
			for(i=0;i<80;++i){
				string[i]=default1[i];
				if(default1[i]=='\0')
				{
					len=i;
					break;
				}
			}
			batch();
			
			printstring(message11);
			cin_cmd();
		}
	}
	else if(string[0]=='r'){
		load_pro();
		printstring(message11);
		cin_cmd();
		if(string[0]=='y') continue;
	}
	else{
		printstring(message_error);
		printstring(message11);
		cin_cmd();
		if(string[0]=='y') continue;
	}
}
}

