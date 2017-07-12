// Set explicit namespace

d: 1_ read0 `:../dbg/dbg.q

ns:".d2."

d[where d like "ns:*"]:enlist "ns:`",(-1_1_ns),";"
d:{ssr[x;"?",y,"?";{$[(y[0]in x)&last[y]in x;y[0],ns,(-1_1_y),last y;y]}["\n[]{};\\/#$%&:()!, @=-+~*'?_<>|^"]]}/["\n" sv d;("cm";"cm1";"sTop";"sT";"pc"),string ({`$$[count[x]=l:x?":";"";$[all(x:l#x)in .Q.nA,.Q.a;x;""]]} each d)except`]
d:ssr[d;"1+",ns,"i";"1+i"]
d,:"\n",ns,"intfns:({x y . z};{y};{x,enlist y};(value ",ns,"appg)[4]),raze ",(-1_ns),"`adv`appg`appN`nargs;\n",ns,"ifn:{",ns,"noDbg&any ",ns,"fr[6;0]~/:",ns,"intfns};"
`:../dbg/dbg_ns.q 0: enlist d;
