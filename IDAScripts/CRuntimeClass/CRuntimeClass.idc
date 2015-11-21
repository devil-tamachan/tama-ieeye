#include <idc.idc>

// CRuntimeClass.idc 0.1 by tamachan
// https://github.com/devil-tamachan/tama-ieeye/tree/master/IDAScripts
//

static findIsKindOf(void)
{ 
	auto funcAddr;
	
	funcAddr = LocByName("?IsKindOf@CObject@@QBEHPBUCRuntimeClass@@@Z");
	if(funcAddr == BADADDR)
	{
  	funcAddr = LocByName("CObject::IsKindOf");
  	if(funcAddr == BADADDR)
  	{
    	funcAddr = LocByName("CObject__IsKindOf");
    	if(funcAddr == BADADDR)
    	{
				Warning("Err: CObject::IsKindOf not found!");
				return BADADDR;
			}
		}
	}
  Message("CObject::IsKindOf 0x%08X\n", funcAddr);
	return funcAddr;
}

static findReadObject(void)
{ 
	auto funcAddr;
	
	funcAddr = LocByName("?ReadObject@CArchive@@QAEPAVCObject@@PBUCRuntimeClass@@@Z");
	if(funcAddr == BADADDR)
	{
  	funcAddr = LocByName("CArchive::ReadObject");
  	if(funcAddr == BADADDR)
  	{
    	funcAddr = LocByName("CArchive__ReadObject");
    	if(funcAddr == BADADDR)
    	{
				Warning("Err: CArchive::ReadObject not found!");
				return BADADDR;
			}
		}
	}
  Message("CArchive::ReadObject 0x%08X\n", funcAddr);
	return funcAddr;
}

static GetNextLabelAddr(a)
{
	auto a2, limit, cmin, cmax;
  
  cmin = SegByName(".text");
  cmax = SegEnd(cmin);
	
	limit = 40;
	a2 = a;
	a2 = NextHead(a2, cmax);
	while(a2 != BADADDR && a2 > a && a2 - a < limit)
	{
		if(Name(a2)!="")return a2;
		a2 = NextHead(a2, cmax);
	}
	if(a2 > a)return a2;
	else return BADADDR;
}

static AddAddr(a)
{
  auto arr, i, k;
  arr = GetArrayId("AddrList");
  if(arr==-1)
  {
    arr = CreateArray("AddrList");
  }
  
  for(i = GetFirstIndex(AR_LONG, arr); i!=-1; i = GetNextIndex(AR_LONG, arr, i))
  {
    k = GetArrayElement(AR_LONG, arr, i);
    if(k == a)return;
    if(k>a)
    {
      for(;i!=-1;i = GetNextIndex(AR_LONG, arr, i))
      {
        k = GetArrayElement(AR_LONG, arr, i);
        SetArrayLong(arr, i, a);
        a = k;
      }
    }
  }
  SetArrayLong(arr, GetLastIndex(AR_LONG, arr)+1, a);
}

static regPushOffset(pushaddr)
{
	auto rc1;
	Message("0x%08X: %s, %d Flag%08X %d\n", pushaddr, GetMnem(pushaddr), GetOpType(pushaddr, 0), GetFlags(pushaddr), isStkvar0(GetFlags(pushaddr)));
	if(GetOpType(pushaddr, 0)!=1 && GetOpType(pushaddr, 0)!=5)
	{
		//Jump(pushaddr);
		//Warning("newtype %08X, %s\n", pushaddr, GetOpnd(pushaddr, 0));
	}
	rc1 = Dfirst(pushaddr);
	if(rc1!=BADADDR)
	{
    AddAddr(rc1);
		Message("Offset -> 0x%08X-0x%08X %s\n", rc1, GetNextLabelAddr(rc1), Name(rc1));
	//	rc1 = Dnext(pushaddr, rc1);
	} else {
    //Message("Op == %s\n", GetOpnd(pushaddr, 0));
		//Jump(pushaddr);
		//Warning("newtype %08X, %s %d\n", pushaddr, GetOpnd(pushaddr, 0), GetOpType(pushaddr, 0));
  }
}
static _findPush2(a, numSkipPush, limitJump)
{
	auto a2, limit, cmin;
  
  cmin = SegByName(".text");
	limit = 40;
	a2 = a;
  while(a2 != BADADDR)
  {
		if(GetMnem(a2)=="push")
		{
			if(numSkipPush==0)
			{
				regPushOffset(a2);
				return;
			} else numSkipPush = numSkipPush-1;
		}
		a2 = PrevHead(a2, cmin);
	}
	return;
}
static findPush(a, numSkipPush)
{
	auto a2, cmin;
  
  cmin = SegByName(".text");
	a2 = a;
	a2 = PrevHead(a2, cmin);
	if(a2!=BADADDR)
	{
		_findPush2(a2, numSkipPush, 3);
	}
}

static scanCallArg(calladdr)
{
	auto a1, a1t, a2, cmin, cmax;
  
  cmin = SegByName(".text");
  cmax = SegEnd(cmin);
  
	a1 = RfirstB(calladdr);
  while(a1!=BADADDR)
  {
		a1t = XrefType();
		if(a1t == fl_CF || a1t == fl_CN)
		{
			findPush(a1, 0);
		}
		Message("xref: %08X %d\n", a1, XrefType());
		a1 = RnextB(calladdr, a1);
	}
}

static scanall(void)
{
	auto faddr,arr;
	
  arr = GetArrayId("AddrList");
  if(arr!=-1)DeleteArray(arr);
  
	faddr = findIsKindOf();
	scanCallArg(faddr);
  
	faddr = findReadObject();
	scanCallArg(faddr);
}

static dumpCRuntimeClass(fp, a)
{
  auto stra, s, b, limit;
  limit = 40;
  b = GetNextLabelAddr(a);
  fprintf(fp, "0x%08X ", a);
  stra = Dword(a);
  s = GetString(stra, -1, GetStringType(stra));
  if(s!="")fprintf(fp, "%s, ", s);
  else fprintf(fp, "0x%08X, ", stra);
  while(a+4 <= b && limit > 0)
  {
    a = a+4;
    fprintf(fp, "0x%08X,  ", Dword(a));
    limit = limit-1;
  }
  fprintf(fp, "\n");
}

static dumpall(void)
{
  auto p, fp, i, k, arr, rc1;
  p = AskFile(1, "*.txt", "");
  if(p==0)return;
  fp = fopen(p, "w");
  arr = GetArrayId("AddrList");
  if(fp!=0 && arr!=-1)
  {
    fprintf(fp, "// CRuntimeClass.idc by tamachan\n\n");
    for(i = GetFirstIndex(AR_LONG, arr); i!=-1; i = GetNextIndex(AR_LONG, arr, i))
    {
      k = GetArrayElement(AR_LONG, arr, i);
      dumpCRuntimeClass(fp, k);
    }
    fclose(fp);
  }
}

static main (void)
{
  if(AskYN(1, "Do you wish to find CRuntimeClass?"))
  {
		scanall();
		dumpall();
  }
}
