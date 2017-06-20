extern void printChar();
extern void data_copy(int SS1, int SS2, int i);
extern void sc_save();
extern void wait();

int NEW = 0;
int READY = 1;
int RUNNING = 2;
int BLOCK = 3;
int DEAD = 4;
int FREE = 0;
int USED = 1;

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
	int pid;
	int fid;
	int used;
}PCB;


PCB pcb_list[8];
int stack_select[8]={0x1000,0x1100,0x1200,0x1300,0x1400,0x1500,0x1600,0x1700};
int CurrentPCBno = 0;  /*当前进程号*/
int Program_Num = 0;  /*进程计数*/

PCB* Current_Process();
void Save_Process(int,int, int, int, int, int, int, int,
		  int,int,int,int, int,int, int,int );
void init(PCB*, int, int);
void Schedule();
void special();
int do_fork();
void memcopy(PCB* F_PCB, PCB* C_PCB);
void stackcopy(PCB* F_PCB, PCB* C_PCB);
void do_wait();
void do_exit(char ch);

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
	pcb->regImg.SP = offset - 20; 
	pcb->regImg.BX = 0;
	pcb->regImg.DX = 0;
	pcb->regImg.CX = 0;
	pcb->regImg.AX = 0;
	pcb->regImg.IP = offset;
	pcb->regImg.FLAGS = 512;
	pcb->Process_Status = NEW;
	pcb->used = USED;
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

/*保存当前PCB*/
void Save_Process2(int gs,int fs,int es,int ds,int di,int si,int bp,
		int sp,int dx,int cx,int bx,int ax,int ss,int ip,int cs,int flags)
{
	pcb_list[CurrentPCBno+1].regImg.AX = ax;
	pcb_list[CurrentPCBno+1].regImg.BX = bx;
	pcb_list[CurrentPCBno+1].regImg.CX = cx;
	pcb_list[CurrentPCBno+1].regImg.DX = dx;

	pcb_list[CurrentPCBno+1].regImg.DS = ds;
	pcb_list[CurrentPCBno+1].regImg.ES = es;
	pcb_list[CurrentPCBno+1].regImg.FS = fs;
	pcb_list[CurrentPCBno+1].regImg.GS = gs;
	pcb_list[CurrentPCBno+1].regImg.SS = ss;

	pcb_list[CurrentPCBno+1].regImg.IP = ip;
	pcb_list[CurrentPCBno+1].regImg.CS = cs;
	pcb_list[CurrentPCBno+1].regImg.FLAGS = flags;
	
	pcb_list[CurrentPCBno+1].regImg.DI = di;
	pcb_list[CurrentPCBno+1].regImg.SI = si;
	pcb_list[CurrentPCBno+1].regImg.SP = sp;
	pcb_list[CurrentPCBno+1].regImg.BP = bp;
}


void Schedule(){
	CurrentPCBno ++;
	if( CurrentPCBno > 7)
		CurrentPCBno = 0;
	while(pcb_list[CurrentPCBno].used == FREE
	|| pcb_list[CurrentPCBno].Process_Status == BLOCK 
	|| pcb_list[CurrentPCBno].Process_Status == DEAD ){
		CurrentPCBno++;
		if( CurrentPCBno > 7)
			CurrentPCBno = 0;
	}	
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
		pcb_list[CurrentPCBno].Process_Status=READY;
}

/*do_fork原语*/
int do_fork(){
	PCB* p;
	p = pcb_list + Program_Num + 1;
	if( p >= pcb_list + 8 )
		pcb_list[CurrentPCBno].regImg.AX = -1;
	else
	{
		memcopy( pcb_list + CurrentPCBno, p );
		stackcopy( pcb_list + CurrentPCBno, p );
		p -> pid = p - pcb_list;
		p -> fid = CurrentPCBno;
		p -> Process_Status = READY;
		pcb_list[CurrentPCBno].regImg.AX = p -> pid;
		p -> regImg.AX = 0;
		p ->  used = USED;
		Program_Num++;
	}
}

void memcopy( PCB* F_PCB, PCB* C_PCB )
{
	C_PCB -> regImg.SP = F_PCB -> regImg.SP;
	C_PCB -> regImg.SS = stack_select[C_PCB->pid]; 
	C_PCB -> regImg.GS = F_PCB -> regImg.GS;
	C_PCB -> regImg.ES = F_PCB -> regImg.ES;
	C_PCB -> regImg.DS = F_PCB -> regImg.DS;
	C_PCB -> regImg.CS = F_PCB -> regImg.CS;
	C_PCB -> regImg.FS = F_PCB -> regImg.FS;
	C_PCB -> regImg.IP = F_PCB -> regImg.IP;
	C_PCB -> regImg.AX = F_PCB -> regImg.AX;
	C_PCB -> regImg.BX = F_PCB -> regImg.BX;
	C_PCB -> regImg.CX = F_PCB -> regImg.CX;
	C_PCB -> regImg.DX = F_PCB -> regImg.DX;
	C_PCB -> regImg.DI = F_PCB -> regImg.DI;
	C_PCB -> regImg.SI = F_PCB -> regImg.SI;
	C_PCB -> regImg.BP = F_PCB -> regImg.BP;
	C_PCB -> regImg.FLAGS = F_PCB -> regImg.FLAGS;
}

/*栈拷贝函数*/
void stackcopy(PCB* F_PCB, PCB* C_PCB){
	int i;
	for(i=F_PCB->regImg.SP;i<=0x100;i=i+2){
		data_copy(F_PCB->regImg.SS, C_PCB->regImg.SS, i);
	}
}

/*do_wait原语*/
void do_wait() {
       pcb_list[CurrentPCBno].Process_Status=BLOCK;
}

/*do_exit原语*/
void do_exit(char ch) {
       pcb_list[CurrentPCBno].Process_Status=DEAD;
       pcb_list[CurrentPCBno].used=FREE; 
       pcb_list[pcb_list[CurrentPCBno].fid].Process_Status=READY;
       pcb_list[pcb_list[CurrentPCBno].pid].regImg.AX=ch;
}
