
In order for Homer3 to recognize and import correctly a user function 
into it's registry of available processing stream functions, the help 
text of that function, should follow the format described below:

Here's a formal description of a user functions help section format:
---------------------------------------------------------------------
SYNTAX:
[r1,...,rN] = <funcname>(a1,...,aM,p1,...,pL)
            
UI NAME:
<User Interface Function Name>
            
DESCRIPTION:
<General function description spanning from one to multiple lines>

            
INPUT:
a1: <Description of a1 spanning from one to multiple lines>
    <Description of a1 spanning from one to multiple lines continued>
  . . . . . . . . . .
aM: <Description of am spanning from one to multiple lines>
p1: <Description of am spanning from one to multiple lines>
  . . . . . . . . . .
pL: <Description of am spanning from one to multiple lines>
            
OUPUT:
r1: <Description of r1 spanning from one to multiple lines>
  . . . . . . . . . .
rN: <Description of rN spanning from one to multiple lines>
            
USAGE OPTIONS:
<User-friendly name for option 1>: [r11,...,r1N] = <funcname>(a11,...,a1M,p1,...,pL)
  . . . . . . . . . .
<User-friendly name for option K>: [rK1,...,rKN] = <funcname>(aK1,...,aKM,p1,...,pL)
            
PARAMETERS:
p1: [v11, ..., v1S1]
  . . . . . . . . 
pj: [vj1, ..., vjSj], maxnum: Sj+k
  . . . . . . . . 
pL: [vL1, ..., vLSL]
---------------------------------------------------------------------

For examples of a Homer3-readable help section please see the help of any one of the 
hmr*_*.m user functions already provided in the homer3/FuncRegistry/UserFunctions folder. 



