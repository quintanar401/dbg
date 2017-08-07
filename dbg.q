\d .d2

mv:(value(1;))2; / magic value
im:@[256#0;cm+cm1:11 26 96 120 128 160;:;@[cm:til each 7 6 24 8 32 96;2;reverse]]; / var/const index
dm:@[256#3;cm+cm1;:;til 6]; / code category
cnst:(();0;1;,;`;::;::;';/;\;':;/:;\:); / basic consts
un:`::`flip`neg`first`reciprocal`where`reverse`null`group`hopen`hclose`string`enlist`count`floor`not`key`distinct`type`value`read0`read1`2::`avg`last`sum`prd`min`max`exit`getenv`abs; / unary fns
bi:(`$(),/:":+-*%&|^=<>$,#_~!?@."),`0:`1:`2:`in`within`like`bin`ss`insert`wsum`wavg`div; / binary fns
ub:value each string un,bi;
ns:`:foo^`$1_ string system "d"; / dbg namespace
nfr:` sv`,ns,`fr;

/ code parse fns: code -> (stk pos;func;arg), return has 4 elements because of the global assign
c:256#{(y+d<>1;(::;{x[1]fr x 0};g;g:{fr . x};get;::)d;(cnst;y,cnst@7+;6,;5,;x 3;4_x)[d:dm k]im k:z 0)}; / cnst0, adv, arg, loc, glob, const
c[17]:{z;1_value {y}[y+1;::;]}; / magic value
c[32+til 64]:{(y-b;{x . fr y}ub k-32;y-til 1+b:63<k:z 0)}; / unary/binary
c[0]:{z;(y;{$[(::)~fr 3;fr[2 4]:(0;fr x);[k:fr x;fr::fr 3;bset[];fr[sTop::fr 4]:k]]};y;`ret)}; / return
c[1]:{z;(y;{'fr x};y)}; / raise an exception
c[2]:{z;(y-1;::;())}; / end of stm: ;
c[3]:{(y;{gt 1;:fr[x;y]:fr z}[8-dm z;im z:96+z 1];y)}; / simple assign
c[4]:{(y-1;({.[nfr;x:x,fr y 1;y 0;fr y 2];ass[fr;x]};{.[x;y:fr y 1;y 0;fr y 2];ass[x;y]})[d=2](6,;5,;x 3)[d:-2+dm k]im k:z 1;(ub 32+z 2),y-0 1)}; / general assign
c[5 6 7 8 9]:({(y-1;gt;z 1)};{(y-1;{gt$[fr y;1;x]}z 1;y)};{(y;{gt$[0<fr y;[fr[y]-:1;2];1+x]}z 2;y)}),2#{(y-8=z 0;gt;neg (8=z 0)+z 1)}; / goto forward/condit/do/bkward
c[10 82 83]:{(y-a;{fr[4]:cc 0;if[x;gt 1];$[count k:empargs a:1_z:fr z;part[z 0;a;k];.[appf2;(y;z);{if[x&not 6=fr 2;gt -1];'y}[x]]]}[10=z 0;83=z 0];y-til 1+a:1^z 1)}; / applications

/ helpers
gt:{:fr[1]+:x}; / goto +N
cc:{fr[0;fr 1] x}; / current bytecode
ass:{gt 2;$[4=count fr[0;1+fr 1];::;$[y~();get x;x . y]]}; / assign + implicit return = null value
excp:{@[{if[e; e-:1;fr::{$[(::)~y:y 3;'x;y]}[x]/[{6<>x 2};fr];fr[2]:5;sTop::fr 4;k:$[99<type g:fr sTop;app[{x y};(g;x)];g];gt 1;bset[];:k];'x};x;{fr[2 4]:(1;x)}]}; / handle exceptions
spf:{(x~(@))|(x~(.))|(100=t)|(t:type x)within 104 111h}; / special function - worth interpreting in gen apply
nargs:{k:value x;$[0=t:-100+type x;count k 1;t in 1 9;1;t in 2 3 10 11;2;t in 7 8;$[2=n:nargs k;1;n];t=4;nargsp k;t=5;nargs last k;t=6;nargs k;'"not impl"]}; / num of args
nargsp:{(0|1+nargs[x 0]-count x)+count empargs x}; / required num of args for parted fn
empargs:{k:();j:-1;do[count x;k,:104=type(1;x j+:1)];where k}; / idx of missing args
part:{$[9>k:count y;x . y;(value "{[x;y]x[",(";"sv @["y ",/:string til k;z;:;(count z)#enlist""]),"]}")[x;y]]}; / create parted fn
tpart:{if[count b:(k:count j:empargs g:value x)#y;g[j]:b];g:g,k _ y;$[104=type g 0;.z.s;app][g 0;1_g]}; / transform part fn into app form
out:{(-1;::)[.z.w>0]};
senv:{sT::.z.P;pc::0;if[fr 2;fr[2]:5]};

/ app functions
app:{apm[abs type x][x;y]}; / general app
appf:{d:x~(.);if[(99<type y 0)&3=k:count y;fr[2]:6;:appf[x;2#y]];$[1=k;x . y;2=k;appf2[d;y];$[-11=type y 0;y[0]like":*";0b];x . y;spf y 2;app[(appN 4&0|d+2*k-3);y];x . y]}; / @ and . : in exc blk mark the frame
appf2:{if[x;if[(type y 1)within 0 98;:app . y];'`type];app[y 0;1_ y]}; / general app, x=1 - (.)[a;b]
appN:({$[0>type y;@[x;y;:;z x y];{@[y;z;:;x y z]}[z]/[x;y]]};{appg[0;x;y;z;0]};{[a;j;g;k]$[0>type j;@[a;j;:;g[a j;k]];{[g;a;j;k]@[a;j;:;g[a j;k]]}[g]/[a;j;k]]};{[a;j;g;k]appg[1;a;j;g;k]};{'`rank}); / @ and .  3/4 args + default
appg:{[ty;a;j;g;k]if[0=count j;j:(),(::)];{[ty;g;i2;a;i1;k]if[0=count i2;:.[a;(),i1;:;$[ty;g[;k];g] a .(),i1]];
    if[(::)~j:i2 0;j:til count a . i1,(::)];if[not(t:type j)within 0 98h;:.z.s[ty;g;1_i2;a;i1,enlist j;k]];
    .z.s[ty;g;1_i2]/[a;i1,/:$[98=t;enlist each j;j];k]}[ty;g;j;a;();k]};
appq:{if[4>count y;:x . y];fr[4]:y;value["{[",(";"sv string k 1),"]",$[count(k:value fr[6;0])2;";"sv string[k 2],'(":",n,"[6]"),/:string 1+til count k 2;""],";",string[x],"[",(";"sv(n:string nfr),/:"[4]",/:string til count fr 4),"]}"]. -1_fr[5]}; / qsql, create env and exec fn
/ app type map
apf:(each;over;scan;prior);
apm:128#(.); / default application
apm[11]:{$[-11h=type x;$[":"=string[x]0;x . y;app[get x;y]];x . y]}; / redirect globals
apm[100]:{$[count[y]<>count(k:value x)1;x . y;4>j:apf?x;app[cnst[7+j]y 0;1_y];na|(first k 3)in skpns;x . y;gif[x;y;fr]]}; / simple fn call
apm[101 102]:{$[x in (@;.);appf[x;y];x in (!;?);appq[x;y];x~(enlist);y;x . y]}; / special forms/selects/other fns
apm[104]:{$[nargsp x,y;x . y;tpart[x;y]]}; / parted fn
apm[105]:{$[(count y)<nargs x;x . y;app[{x y . z};value[x],enlist y]]}; / composite fn
apm[106+til 6]:{if[na|not[spf k]&$[100=type k:value x;(not k in apf)&(first value[k]3)in skpns;1b];:x . y];if[count[y]<nargs x;:x . y];app[adv t;(k;y;t:type[x]-106)]}; / adverbs
/ adverbs
adv:6#(::);
adv[0]:{z;if[98=type y;:(cols y)!.z.s[x;value each y;0]];if[any g:99=t:type each y;if[not((3>count y)&all g)|all b~\:k:distinct raze b:key each y w:where g;'`domain];y[w]:y[w]@\:k;:k!.z.s[x;$[98=type y;value flip y;y];0]];
  if[any t within 0 98h;y:flip y;j:-1;rr:(b:count y)#(::);do[b;rr[j]:x . y j+:1];:rr];x . y}; / each
adv[1 2]:{p:({y};{x,enlist y})z=2;n:nargs x;k:count y;rr:();if[(k=1)&n=1;g:m:y 0;while[1;rr:p[rr;m];if[(g~m)|(m:x m)~m;:rr]]]; / iterate on val
  if[(k=2)&n=1;rr:p[rr;m:y 1];$[-7=type a:y 0;do[a;rr:p[rr;m:x m]];while[a m;rr:p[rr;m:x m]]];:rr]; / iterate N/cond
  if[any g:99=t:type each a:(k:k<>1)_y;if[not all kk[0]~/:kk:key each a w:where g;'`domain];$[98=type y;y:value each y;y[k+w]:value each a w];:$[z=2;![kk 0](),;::].z.s[x;y;z]]; / dict case
  if[not k;$[1=k:count y:y 0;:first y;0=k;:();2=k;:p[y 0;x . y];[y:(y 0;1_ y);rr:p[rr;y 0]]]]; / adjust g[a] to g[a;b]
  if[any t within 0 98h;m:y 0;y:flip 1_y;j:-1;if[(z=1)&0=k:count y;:m];do[k;rr:p[rr;m:x[m]. y j+:1]];:rr];x . y}; / scan/over
adv[3]:{if[1=nargs x;:adv[0][x;y;0]];if[99=type m:last y;y:(-1_y),enlist value m;:(key m)!.z.s[x;y;z]]; / dict case
  if[all not(type each y)within 0 98h;:$[1=count y;y 0;x . y]]; / atom case
  y:enlist[$[1=count y;$[98=type y 0;0#m -1;m -1];y 0]],m;j:0;rr:(count m)#(::);do[count m;rr[j-1]:x[y j+:1;y j]];rr};
adv[4 5]:{p:z=4;if[99=t:type y p;k:key y p;y[p]:value y p;:k!.z.s[x;y;z]];
  if[not(t within 0 98h);:x . y];j:0;rr:(count y p)#(::);do[count y p;rr[j]:$[p;x[y 0;y[1;j]];x[y[0;j];y 1]];j+:1];rr}; / each right/left

/ frame:
/ (code;index;state;parent;exc/register;args;locals;id;stack....)
fr:7#0; / prevent exc on a spurious run
fs:(!). 2#2(,:)/(::); / processed fns
gb:{count[z]#enlist c[z 0][x;y[0;0];z]}; / calculate fn code
gc:{.[;(where k in 0x00020506070809;0);0 1!()]raze enlist[(),7]gb[x]\(where differ sums prev 0=0{$[x=0;0^0 0 0 1 2 1 1 2 1 1 1@y;x-1]}\k)cut k-(k=9)&7=k til[count k]-next k:-1_x 0}; / process fn to get its code
gf:{if[not(::)~g:fs x;:g];:fs[x]:(gc @[k;3;{$[`~first x;x;{$[y like ".*";y;` sv`,x,y]}[x 0]each x]}];-1;5;::;::),(::;x,count[k 2]#enlist()),0,#[last (k:-1_value x)0;::]}; / get fn frame
gif:{fr::@[gf x;3 5 7;:;(z;y,(::);1+z 7)];pc::();sTop::8;bset[]}; / get inited fn frame (set parent)

tm:0D00:05; / timeout
e:10000; / error count
na:0b; / 1=native execution
noDbg:1b; / do not stop in dbg funcs (adverbs and etc)
skpns:`q`h`o`Q; / ignore this ns

/ exec fns,  states: 0 - stopped; 1 - exception; 2 - brk point; 5 - running; 6 - exc block
i0:{gif .$[100=type x;[if[not(count value[x]1)=count (),y;'"rank"];(x;(),y)];({x . y};(x;(),y))],(::);gt 1}; / set initial frame
ifn:{noDbg&ns=(value fr[6;0])[3;0]}; / int fn
i:{i0[x;y];prs[]};
s0:{if[fr 2;@[{if[tm<.z.P-sT;'"Dbg timeout"];j:fr 7;k:x[1]x 2;if[j=fr 7;fr[x 0]:k];if[(0<fr 1)&count x 0;sTop::x 0];if[gt[1]in cbps;fr[2]:2]};cc[];excp]]}; / run 1 instruction
r:{i0[x;y];cont[]}; / run until stop/exc/brk
s:{senv[];s0[];prs[]}; / one step
cont:{senv[];{4<fr 2}s0/0;prs[]}; / continue
l:{senv[];{(4<fr 2)&(pc::cc 0;ifn[]|not()~pc)1}s0/0;prs[]}; / next line
nxt:{if[`ret~last cc[];:l[]];senv[];{y;(4<fr 2)&(pc::$[x=fr 7;cc 0;0];not(0<fr 1)&()~pc)1}[fr 7]s0/0;if[ifn[];l[]];prs[]}; / next line over
ef:{senv[];{y;(4<fr 2)&not (x=fr 7)&`ret~last cc[]}[fr 7]s0/0;l[]}; / end function
nexp:{senv[];s0[];{z;(4<fr 2)&(x<=fr 7)&not (x=fr 7)&fr[1]in y}[fr 7;value first each group txt0 fr[6;0]]s0/0;if[ifn[];l[]];prs[]};
/ stack/state
trace:{{$[(::)~k:x 3;x;k]}/[$[x~(::);0;x];fr]};
prs:{$[p:fr 2;out[](("";"Exception: ",fr 4;"Breakpoint";"";"";"Running") p;"Top of the stack:"),pstk[10],("Current line: ",m 0;"Current exp: ",(m:txt fr)1);fr 4]}; / print state
pstk:{reverse x sublist((" fr[",/:string[n],\:"]: "),'.Q.s1 each fr n:sTop-til sTop-7),1_ " Fn call(",/:string[`anon^fmap g[;6;0]],'"), line: ",/:last each txt each g:{x 3}\[{not(::)~x 3};fr]}; / get N stack entries
ps:{out[]pstk $[x~(::);10;x]}; / print N stack entries
pl:{out[]first txt trace x}; / print current line
f:{out[]string trace[x][6;0]}; / print current function
v:{(k[1]!-1_g 5),((k:value g[6;0])2)!1_(g:trace x)6};
fmap:enlist[::]!enlist`;
mfmap:{fmap::(!). flip raze{raze{$[99<type g:@[get;n:$[x~`;y;x:` sv `,x,y];0];enlist(g;n);99=type g;$[`~first key g;raze .z.s[x]each 1_key g;()];()]}[x]each key` sv`,x} each `,(key `)};

/ breakpoints
bps:enlist[::]!enlist(); / map for fns
cbps:`long$(); / curr bps
bset:{cbps::bps[fr[6;0];1]}; / set bps
bfn:{$[any x~/:(`;(::));trace[0][6;0];100=type x;x;trace[x][6;0]]}; / get fn
gbs:{id:-1+bps[x]0;update p:.[((-3#'"  ",/:string[1+i]),'":  ",/:p);(id;4);:;"*"]from((flip`p`c!((')[string x;key];{first each value x})@\:g)where 0<first each key g:group txt0 x)}; / get all possible bs.
pf:{out[](gbs bfn x)`p}; / print all bs.
bs:{x:bfn x;$[count y;bps[x]:(y j;b j:where not null b:(gbs x)[-1+y:(),y;`c]);bps[x]:(();())];}; / set bps.
ba:{bs[x;distinct bps[x:bfn x;0],y];}; /  add bps.
bd:{bs[x;bps[x:bfn x;0] except y];}; / delete bps.
bc:{bps::enlist[::]!enlist();}; / clear all bps.

/ map from code to txt.
tfs:(!). 2#2(,:)/(::); / processed fns
taj:{rr:@[x;(-1+count x),where prev 0{$[x;0b;y in 0x05060809]}\x:first value x;:;0x00];rr[where rr>=0x80]:0xa0;rr}; / adjust volatile code
tfl:{$["["~y 1;x sv(0,1+y?"]")_y;"{",x,1_y]}; / insert fake locals
tcmp:{$[(>).(j:count[x]-sum prds reverse[y]=count[y]#reverse x),k:sum prds y=count[y]#x;k+til j-k;0#0]}; / compare two preprocessed samples
tfc:{(union). tcmp[taj x]each(2+2*count raze value[x]1 2)_/:taj each value each y}; / find code range
tgm:{p&2>sums(0^("{}"!1 -1)x)*p:not 0(1 0 0;0 2 1;1 1 1)\"\"\\"?x}; / get mask, exclude {...} and "..."
tlvl:{rr:prev[0;a]&a:sums y*0^("[()]"!1 1 -1 -1)x;$["["~x 1;@[rr;til 1+x?"]";:;-1];rr]}; / get levels
tspl:{(where 1<deltas[-2;j])_j:(where x<=y)except(0,-1+count y),where z&x=y}; / split by level
tsmp:{tfl[(":"sv reverse string raze value[x]1 2),":0; "]each@[@[string x;y;:;" "];first y;:;]each"01"}; / prepare a pair of samples
tget:{tmin[x]reverse{$[k:count rr:.[tfc;(x;tsmp[x;y]);()];rr!k#enlist ttrm[x;y];()!()]}[x]each raze tspl[;p;m&";"=g]each desc(distinct p:tlvl[g;m:tgm g:string x])except -1}; / get txt ids for all bytecode
tmin:{rr:(til[k]!(k:count g:first w)#enlist til count last w:value x){x,inter'[(key y)#x;y]}/y;rr[j]:rr 0|-1+j:where g in "x"$til 10;rr}; / get the minimal txt range
ttrm:{(neg sum prds reverse m)_(sum prds m:(string x)[y]in " \n\t\r")_y}; / trim the txt ranges
txt0:{if[(::)~tfs x; tfs[x]:tget x]; tfs[x]}; / return exp idx
txt:{(trim p first where first[j]<sums 1+count each p:"\n"vs p;(p:string x[6;0])j:txt0[x[6;0]]x 1)}; / cmd line version

h:{out[]ssr[;".d.";".",string[ns],"."]each
  ("DEBUG commands:";
  "START";
  "  .d.r[func;args] or .d.r[monad;enlist arg] - runs fn with args until an exception or breakpoint";
  "  .d.i[func;args] or .d.r[monad;enlist arg] - prepares environment but do not start execution";
  "IN FUNCTION - EXEC";
  "  .d.cont[] - continue execution";
  "  .d.nxt[] - next line inside the current function (doesn't enter functions)";
  "  .d.nexp[] - next expression (entity smaller than line, doesn't enter functions)";
  "  .d.ef[] - finish the current function";
  "  .d.l[] - next line (enters functions)";
  "  .d.s[] - next step";
  "IN FUNCTION - INFO";
  "  .d.f[] or .d.f[N] - prints the current function or the function up N calls";
  "  .d.v[] or .d.v[N] - prints the current vars or the vars in the function up N calls";
  "  .d.ps[] or .d.ps[N] - prints top 10 or N stack entries";
  "  .d.pl[] or .d.pl[N] - prints the current code line or the line in the function up N calls";
  "BREAKPOINTS";
  "  .d.pf[` or :: or N or {fn}] - shows the function with the breakpoint line numbers, bps are marked with *";
  "  .d.ba[` or :: or N or {fn};line numbers] - add breakpoints to lines in the current/upper(+N)/specific function";
  "  .d.bd[` or :: or N or {fn};line numbers] - delete breakpoints from lines in the current/upper(+N)/specific function";
  "  .d.bs[` or :: or N or {fn};line numbers] - set breakpoints in the current/upper(+N)/specific function to these lines";
  "  .d.bc[] - clear all breakpoints";
  "USEFULL VARS";
  "  .d.e - number of exceptions to pass into protected blocks (10000 by default). Set to 0 to always fail";
  "  .d.tm - current dbg timeout, 0D00:05 by default";
  "  .d.na - 0b by default, call all functions via dbg, 1b - native calls";
  "  .d.noDbg - 1b by default, do not show internal dbg functions like adverbs when using .d.l and etc";
  "  .d.skpns - list of system namespaces, all functions will be called natively";
  "  .d.mfmap[] - create a map from fn names to fn bodies. Fn names will be displayed in the stack.";
  "  .d.fr - current frame (see code comments)")
 };
