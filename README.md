# Debugger for KDB+/Q

## Description.

dbg.q is a debugger for KDB+/Q programs/functions. Unlike other debug utilities it is an interpreter of Q language and as such has full control over the program flow.
You can execute functions step by step, stop on exceptions or breakpoints, inspect the current call stack, view all local variables and arguments in all functions and etc.

The debugger resides in its own namespace that can be easily changed and doesn't alter any variables outside this namespace. Also it doesn't interfere with the normal work flow - while
one user is using it other users can continue their work and the system timer will continue to work as usual. Basically the debugger is just a set of ordinary functions, once one
of its commands is finished other functions or arbitrary expressions can be executed.

Debugger features:
* Supports all Q expressions and control structures. Any function can be executed.
* Allows you to navigate code one instruction at a time or by larger steps (line, next expression, next line, exit function, continue).
* Interprets all adverbs and also the functional amends ({x+1} each V, @[L;1 2 3;{x+1}]).
* Shows the current expression and line within the current function using the original text representation of the function.
* Supports breakpoints and allows you to ignore exception blocks to capture the handled exceptions.
* Can be used from a console or remotely.

There are also some limitations. SQL statements, eval expressions, value function are not interpreted. peach is always executed as each, obviously there will be no 'noupd exception. Sometimes the exception thrown by the debugger may differ from the native exception, this is rare and usually in such cases the exact exception doesn't matter. User exceptions are not affected.

## Starting to work.

To use the debugger you should first load it into the target Q process (hdb for example). The debugger can be put into any namespace, you can easily change its namespace by
modifying the first line of its file. The default namespace is `d2` and it will be used in examples below.
```
\l dbg.q
```

You can use it from a console or remotely. If you use it remotely it will usually return a list of strings representing its current state. Q console and many Q editors will
nicely format this list vertically like this:
```
q)h:hopen 5566
q)h ".d2.i[{x+1};1]"
"Running"
"Top of the stack:"
" fr[8]: ::"
"Current line: {x+1}"
"Current exp: x+1"
```
If you run it from a console it will print these strings. You can change `out` function if you want something else.

Suppose now you want to debug myHdbFunction with a dictionary \`date\`sym!(2016.03.03;\`IBM). First you should choose the initial function:
* `.d2.r` runs a function until an exception or breakpoint.
* `.d2.i` just initializes the debugger but doesn't start to execute the function.

Then you should run the initial function with the target function and a list of its arguments:
```
.d2.i[myHdbFunction;enlist `date`sym!(2016.03.03;`IBM)] / or
.d2.i[{myHdbFunction `date`sym!(2016.03.03;`IBM)};1] / there is no need to enlist 1 because it is an atom
```
Sometimes it is more convenient to wrap the call into an anonymous function.

Until the function is finished all debugger commands will report the current execution state:
```
q).d2.i[{myHdbFunction `date`sym!(2016.03.03;`IBM)};1]
Running
Top of the stack:
 fr[8]: ::
Current line: {myHdbFunction `date`sym!(2016.03.03;`IBM)}
Current exp: `IBM
```
The first line indicates the state of the debugger - Running, Exception or Breakpoint. Then you will see the current call stack and the full stack of the current function.
To see more stack entries use `.d2.ps[N]`. Finally the debugger prints the current line and the current expression.

There are several commands that can be used to continue:
* `.d2.cont[]` - continue the current function until it is finished (normally or via an exception or breakpoint).
* `.d2.nxt[]` - jump to the next line. Lines are expressions delimited by ";" or expressions within the control structures (do, while, if, $). `nxt` will not enter subfunctions.
* `.d2.nexp[]` - jump to the next expression. Expressions are smaller entities than lines, delimited by ";" and by square or round brackets. `nexp` also will not enter subfunctions.
* `.d2.l[]` - jump to the next line. It is like `nxt` but `l` will enter subfunctions.
* `.d2.ef[]` - exit the current function.
* `.d2.s[]` - execute one instruction.

You can always run `.d2.h[]` to see help on these functions.

While in the function you can inspect its variables using `.d2.v[]`:
```
q).d2.r[{{l:10;`a+l+x}1};1] / cause an exception
Exception: type
Top of the stack:
 Fn call, line: {l:10;`a+l+x}1
 fr[8]: 11
 fr[9]: `a
Current line: {l:10;`a+l+x}
Current exp: `a+l+x
q).d2.v[]
x| 1
l| 10
q).d2.v[1] / previous fn on the stack
x| 1
```
There are other similar functions: `.d2.f[N]` (print function), `.d2.pl[N]` (print line).

## Breakpoints.

If you want to add a breakpoint you need first to find an expression within a function where you want to stop. `.d2.pf[]` will print all expressions in the order they are evaluated
within the function. Find the required expression and add it via `.d2.ba[fn;idxs]` or `.d2.bs[fn;idxs]` (add or set breakpoint(s)). If you do not need some breakpoint anymore delete it with
`.d2.bd[fn;idxs]` or `.d2.bc[]` (delete or clear all). Example:
```
q)f:{l:x+y; l2:x*l; : l2%l}
q).d2.pf[f]
  1:  l:x+y
  2:  l2:x*l
  3:  : l2%l
q).d2.ba[f;2]
q).d2.pf[f]
  1:  l:x+y
  2:* l2:x*l <--- bp is marked with *
  3:  : l2%l
q).d2.r[{f'[1 2 3;10]};1]
Breakpoint
Top of the stack:
 Fn call, line: f'[1 2 3;10]
 Fn call, line: r[i]:x . y i+:1
 fr[8]: 11
Current line: {l:x+y; l2:x*l; : l2%l}
Current exp: l2:x*l
q).d2.cont[] // next bp
Breakpoint
Top of the stack:
 Fn call, line: f'[1 2 3;10]
 Fn call, line: r[i]:x . y i+:1
 fr[8]: 12
Current line: {l:x+y; l2:x*l; : l2%l}
Current exp: l2:x*l
q).d2.bd[::;2] / remove bp from the curr func
q).d2.cont[]
1 2 3f
```

## Functions.

### .d2.r

Runs a function within the debugger. Examples:
```
.d2.r[{x+1};1] / no need to enlist an atom arg
.d2.r[{x+y};1 2]
.d2.r[{x[`a]:10;x};enlist `a`b!20 30] / dicts must be enlisted
.d2.r[{x+y}[1];1]  / if fn's type is not 100 it will be automatically wrapped
```

### .d2.i

Initializes the debugger with a function. Usage is similar to .d2.r.
```
.d2.i[{x+1};1] / init
.d2.l[] / execute 1 line
```

### .d2.h

Prints help on the debugger functions and variables.
```
.d2.h[]
```

### .d2.cont

Continue the execution, the debugger should be in Running or Breakpoint state. If it is in Exception state the offending command will be reexecuted and you'll likely get the same exception again.
```
.d2.cont[]
```

### .d2.nxt

Execute one line, do not enter functions. `.d2.cont` rules apply to this function too. One line is an expression delimited by ";" and Q control structures do, while, if, $.
It is like one line in an imperative language (Java).
```
.d2.nxt[]
```

### .d2.nexp

Execute one expression, do not enter functions. `.d2.cont` rules apply to this function too. One expression is an expression delimited by (), [] or ";".
```
.d2.nexp[]
```

### .d2.ef

Exit the current function. `.d2.cont` rules apply to this function too.
```
.d2.ef[]
```

### .d2.l

Execute one line, enter functions. `.d2.cont` rules apply to this function too. This function is like `.d2.nxt` but it will enter subfunctions.
```
.d2.l[]
```

### .d2.s[]

Execute one instruction. `.d2.cont` rules apply to this function too.
```
.d2.s[]
```

### .d2.f

Show the current function or a function up the stack.
```
.d2.f[] / show the current function
.d2.f[2] / show the function 2 calls up the stack
.d2.f[0] / the same as .d2.f[]
```

### .d2.v

Show the current (or up N calls) local variables and args.
```
.d2.v[] / curr args
.d2.v[1] / args of the caller fn
.d2.v[0] / the same as .d2.v[]
```

### .d2.ps

Print stack entries.
```
.d2.ps[] / last 10 entries
.d2.ps[20] / last 20 entries
```

### .d2.pl

Print the current (or up N calls) line.
```
.d2.pl[] / current line
.d2.pl[1] / line in the caller
.d2.pl[0] / the same as .d2.l[]
```

### .d2.pf

Print possible breakpoints for a function. Existing breakpoints are marked with *
```
.d2.pf[]; .d2.pf[`]; .d2.pf[::] / current function
.d2.pf[1]; .d2.pf[5] / the caller up N calls
.d2.pf[{some fn}] / raw fn
```

### .d2.ba

Add breakpoints to a function.
```
.d2.ba[::;1]; .d2.ba[`;1 2]; .d2.ba[0;1 2 3] / add a bp to the curr func
.d2.ba[10;1] / add a bp to a func up N calls
.d2.ba[{some fn};1 2 3] / add a bp to an arbitrary fn
```

### .d2.bs

Set breakpoints for a function.
```
.d2.bs[::;1]; .d2.bs[`;1 2]; .d2.bs[0;1 2 3] / set a bp in the curr func
.d2.bs[10;1] / set a bp in a func up N calls
.d2.bs[{some fn};1 2 3] / set a bp in an arbitrary fn
```

### .d2.bd

Delete breakpoints from a function.
```
.d2.bd[::;1]; .d2.bd[`;1 2]; .d2.bd[0;1 2 3] / delete a bp from the curr func
.d2.bd[10;1] / delete a bp from a func up N calls
.d2.bd[{some fn};1 2 3] / delete a bp from an arbitrary fn
```

### .d2.bc

Clear all breakpoints.
```
.d2.bc[]
```

## Variables.

### .d2.e

Exception counter, can be used to ignore catch blocks. It gets decreased on every exception. If this counter becomes 0 catch blocks will stop to work.

### .d2.tm

Debugger timeout. If some command (`.d2.r`, `.d2.cont` and etc) takes too much time the debugger will automatically stop after this time (0D00:05 by default).
This timeout doesn't affect your program, you will be able to continue if you wish.

### .d2.na

Set this variable to 1b if you wish to not debug some subfunction. In this mode all subfunctions are executed as is, natively (this means breakpoints do not work and exceptions are not captured). This may be useful if some subfunction is too slow for the debugger. Do not forget to set it back to 0b.

### .d2.noDbg

Set this variable to 0b if you wish `.d2.l` to enter the internal debugger functions that realize adverb, general apply and some other functionality. The debugger by default will hide
these functions and stop only when a user function is called.

### .d2.skpns

System namespaces. Functions from these namespaces are executed natively. You may remove Q namespace for example if you want to interpret some Q function:
```
.d2.skpns:`q`h`o; / remove Q namespace
```

### .d2.fr

The current frame. It has the following structure: (code;instruction number in the code;current state;parent frame;exception/register;args;locals;id;stack....).

## Tips.

If you are inside an adverb and want to know its state then request its variables via `.d2.v[N]`.
`i` - how many items left to process (except the current one), `r` - vector of processed items.

If you got an exception that seems easy to fix you can change the stack directly and continue. To change the stack assign the correct value like `.d2.fr[8]: 100`.
