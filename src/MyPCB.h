extern void printChar();

int NEW = 0;
int READY = 1;
int RUNNING = 2;
int EXIT = 3;

typedef struct RegisterImage{
	int SS;
	int GS;
	int FS;
	int ES;
	int DS;
	int DI;
	int SI;
	int BP;
	int SP;
	int BX;
	int DX;
	int CX;
	int AX;
	int IP;
	int CS;
	int FLAGS;
}RegisterImage;

typedef struct PCB{
	RegisterImage regImg;
	int Process_Status;
}PCB;


PCB pcb_list[8];
int CurrentPCBno = 0;  /*当前进程号*/
int Program_Num = 0;  /*进程计数*/

PCB* Current_Process();
void Save_Process(int,int, int, int, int, int, int, int,
		  int,int,int,int, int,int, int,int );
void init(PCB*, int, int);
void Schedule();
void special();

void init(PCB* pcb,int segement, int offset)
{
	pcb->regImg.SS = segement;
	pcb->regImg.GS = 0xb800;
	pcb->regImg.FS = segement;
	pcb->regImg.ES = segement;
	pcb->regImg.DS = segement;
	pcb->regImg.CS = segement;
	pcb->regImg.DI = 0;
	pcb->regImg.SI = 0;
	pcb->regImg.BP = 0;
	pcb->regImg.SP = offset - 20;  /**/
	pcb->regImg.BX = 0;
	pcb->regImg.DX = 0;
	pcb->regImg.CX = 0;
	pcb->regImg.AX = 0;
	pcb->regImg.IP = offset;
	pcb->regImg.FLAGS = 512;
	pcb->Process_Status = NEW;
}

/*保存当前PCB*/
void Save_Process(int gs,int fs,int es,int ds,int di,int si,int bp,
		int sp,int dx,int cx,int bx,int ax,int ss,int ip,int cs,int flags)
{
	pcb_list[CurrentPCBno].regImg.AX = ax;
	pcb_list[CurrentPCBno].regImg.BX = bx;
	pcb_list[CurrentPCBno].regImg.CX = cx;
	pcb_list[CurrentPCBno].regImg.DX = dx;

	pcb_list[CurrentPCBno].regImg.DS = ds;
	pcb_list[CurrentPCBno].regImg.ES = es;
	pcb_list[CurrentPCBno].regImg.FS = fs;
	pcb_list[CurrentPCBno].regImg.GS = gs;
	pcb_list[CurrentPCBno].regImg.SS = ss;

	pcb_list[CurrentPCBno].regImg.IP = ip;
	pcb_list[CurrentPCBno].regImg.CS = cs;
	pcb_list[CurrentPCBno].regImg.FLAGS = flags;
	
	pcb_list[CurrentPCBno].regImg.DI = di;
	pcb_list[CurrentPCBno].regImg.SI = si;
	pcb_list[CurrentPCBno].regImg.SP = sp;
	pcb_list[CurrentPCBno].regImg.BP = bp;
}

void Schedule(){
	pcb_list[CurrentPCBno].Process_Status = READY;

	CurrentPCBno ++;
	if( CurrentPCBno > Program_Num)
		CurrentPCBno = 1;
	if(Program_Num==0)
		CurrentPCBno = 0;
	if( pcb_list[CurrentPCBno].Process_Status != NEW )
		pcb_list[CurrentPCBno].Process_Status = RUNNING;
	return;
}


PCB* Current_Process(){
	return &pcb_list[CurrentPCBno];
}


void special()
{
	if(pcb_list[CurrentPCBno].Process_Status==NEW)
		pcb_list[CurrentPCBno].Process_Status=RUNNING;
}
