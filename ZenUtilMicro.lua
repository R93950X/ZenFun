loadstring(([[_G.ZenFormat,_G.ZenMath,_G.ZenPic,_G.ZenTable,_G.ZenText={},{},{},{},{}
_LGI,GE,GG=term,math,string
_LGA,GB,GC,GD,GF,GH,GJ,GK,GL={"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"},
type,table,GE.log,pairs,GG.sub,GI.getCursorPos,GI.setCursorPos,"table"
function ZenFormat.decimalToBase(A,B,C)C=GB(C)==GL and C or {GC.unpack(GA)}
_LD,E=GE.floor(GD(A)/GD(B)),""for i=D,0,-1 do E,A=E..C[GE.floor(A/B^i)+1],A%(B^i)
end RTE EFZFormat.baseToDecimal(A,B,C)C=C or {GC.unpack(GA)}FPC) do C[v]=i-1
end _LD=0 for i=1,GG.len(A) do D=D+C[GH(A,i,i)]*B^(GG.len(A)-i)
end RTD EFZFormat.splitString(A,B)_LC={}repeat GC.insert(C,GH(A,1,B))A = GH(A,B+1,-1)
until A==""RTCEZM.root(A,B)RTA^(1/B)EZM.log(A,B)RTGD(A)/GD(B)EZM.areaOfCircle(A)
RTGE.pi*A*AEZM.circumferenceOfCircle(A)RTGE.pi*A*2EZM.sum(...)_LA,B={...},0
A=GB(A[1])==GL and A[1] or A FPA) do B=B+v end RTB end function ZenMath.mean(...)
_LA={...}A=GB(A[1])==GL and A[1] or A _LB=ZenMath.sum(A)RTB/#AEZM.mode(...)
_LA,B,C,D={...},{},0,{}A=GB(A[1])==GL and A[1] or A FPA) do B[v]=B[v] and B[v]+1 or 1
end FPB) do C=v>C and v or C end FPB) do if v==C then GC.insert(D,i) end end RTDEZM.median(...)
_LA={...}A=GB(A[1])==GL and A[1] or A GC.sort(A)RT#A%2==0 and (A[#A/2]+A[#A/2+1])/2 or
(A[#A/2+0.5])EZM.sec(x)RT1/GE.cos(x)EZM.csc(x)RT1/GE.sin(x)EZM.cot(x)RT1/GE.tan(x)
EZM.asec(x)RTGE.acos(1/x)EZM.acsc(x)RTGE.asin(1/x)EZM.acot(x)RTGE.atan(1/x)EZM.sech(x)
RT1/GE.cosh(x)EZM.csch(x)RT1/GE.sinh(x)EZM.coth(x)RT1/GE.tanh(x)EZM.asinh(x)RTGD(x+(x*x+1)^0.5)
EZM.acosh(x)RTGD(x+(x*x-1)^0.5)EZM.atanh(x)RTGD((1+x)/(1-x))/2EZM.acsch(x)RTasinh(1/x)
EZM.asech(x)RTacosh(1/x)EZM.acoth(x)RTatanh(1/x) EFZPic.draw(A,x,y)_LB,C=GJ()
_LD=GI.getBackgroundColor()paintutils.drawImage(A,x,y)GK(B,C)GI.setBackgroundColor(D)
EFZPic.centerImage(A)_Ll,w=GI.getSize()_LB,y=0,GE.ceil((w-#A)/2)+1 FPA) do B=GE.max(B,#v) end
_Lx=GE.ceil((l-B)/2)+1 draw(A,x,y)EFZTable.shuffle(A)for i=#A,2,-1 do _Lj=GE.random(i)A[i],
A[j]=A[j],A[i]end EFZTable.reverse(A)_LB,C=1,#A while B<C do A[B],A[C],B,C=A[C],A[B],B+1,C-1
end EFZText.writeAt(A,x,y)_LB,C=GJ()for i=0,select(2,A:gsub("\n","")) do
_LD=A:find("\n") or GG.len(A)_LE=A:sub(1,D-1)A=A:sub(D+1,-1)GK(x,y+i)GI.write(E)end GK(B,C)
EFZText.printPlus(A)_LB=GI.getTextColor()repeat _LC=A:find("&") or A:len()+2
_LD,E=GH(A,0,C-1),tonumber(GH(A,C+1,C+1),16)A=GH(A,C+2,-1)write(D)
if E and (E<=15 and E>=0) then GI.setTextColor(2^E)end until A==""GI.setTextColor(B)
GK(1,select(2,GJ())+1)RTtrue
end]]):gsub("FP","for i,v in GF("):gsub("EZM"," EFZMath"):gsub("EFZ","end function Zen")
:gsub("_L","local "):gsub("RT","return "))()