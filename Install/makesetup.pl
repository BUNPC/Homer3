use strict; 
use warnings;

# NOTE: In perl argument 0 is the actual argument NOT the script name like in C
my $filesrc = $ARGV[0];
my $filedst = $ARGV[1];
my $mcrver = $ARGV[2];

open(hInput,  '<', $filesrc) or die "Could not open $filesrc: $!";
open(hOutput, '>', $filedst) or die "Could not open $filedst: $!";

while( my $line = <hInput>)  
{
    my @chars = split("", $line);

    # Write each line to output file
    print hOutput "$line\n";

    last if $chars[0] ne '#';
}


# If not running setup script from ~/Downloads/homer3_install then 
# copy current homer3_install folder to ~/Downloads  
print hOutput "currpath=\$(dirname \"\$0\")\n";
print hOutput "exe_dir=~/Downloads/homer3_install\n";
print hOutput "cd ~/Downloads\n\n";
print hOutput "if [ -d \"\$exe_dir\" ]; then\n";
print hOutput "     echo TARGET DIR EXISTS\n";
print hOutput "else\n";
print hOutput "     echo TARGET DIR DOES NOT EXIST...Creating TARGET DIR\n";
print hOutput "     mkdir \"\$exe_dir\"\n";
print hOutput "fi\n";
print hOutput "cd \"\$exe_dir\"\n";
print hOutput "targetpath=\$(pwd);\n";
print hOutput "echo\n";
print hOutput "echo \"CURRENT DIR: \" \"\$currpath\"\n";
print hOutput "echo \"TARGET  DIR: \" \"\$exe_dir\"\n";
print hOutput "echo\n";
print hOutput "if [ \"\$currpath\" != \"\$exe_dir\" ]; then\n";
print hOutput "     echo rm -rf \$exe_dir\n";
print hOutput "     rm -rf \$exe_dir\n";
print hOutput "	\n";
print hOutput "     echo cp -r \"\$currpath\" \"\$exe_dir\"\n";
print hOutput "     cp -r \"\$currpath\" \"\$exe_dir\"\n";
print hOutput "	\n";
print hOutput "     echo\n";
print hOutput "fi\n\n";
print hOutput "cd \"\$exe_dir\"\n";
print hOutput "currpath=\$(pwd)\n\n";
print hOutput "echo \"NEW CURRENT PATH: \" \"\$currpath\"\n\n";


# Create link to MATLAB Runtime Libraries
print hOutput "rm -rf ~/libs; mkdir ~/libs\n";
print hOutput "if [ ! -L \"~/libs/mcr\" ]; then ln -s /Applications/MATLAB/MATLAB_Runtime/$mcrver ~/libs/mcr; fi\n";
print hOutput "libsdir=~/libs/mcr\n";


my $find    = '\$1';
my $replace = '$libsdir';

# Complete copying rest of the lines
while(my $line = <hInput>)  
{
    # Write each line to output file
    my $linenew = $line;

    if (index($linenew, "exe_dir=") != -1) 
    {
    	$linenew = "exe_dir=~/Downloads/homer3_install\n";
    } 
    elsif (index($linenew, "exit") != -1) 
    {
        $linenew = "osascript -e \'tell application \"Terminal\" to quit\' &\n"       
    }
    else
    {
        $linenew =~ s/$find/$replace/g;
    }
    print hOutput "$linenew";
}
print hOutput "exit\n";

close hInput;
close hOutput;

chmod 0755, $filedst

