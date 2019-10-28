use strict; 
use warnings;

# NOTE: In perl argument 0 is the actual argument NOT the script name like in C
my $filesrc = $ARGV[0];
my $filedst = $ARGV[1];

open(hInput,  '<', $filesrc) or die "Could not open $filesrc: $!";
open(hOutput, '>', $filedst) or die "Could not open $filedst: $!";

while( my $line = <hInput>)  
{
    my @chars = split("", $line);

    # Write each line to output file
    print hOutput "$line";

    last if $chars[0] ne '#';
}

# Check that link to matlab libraries exists
print hOutput "current_dir=\$(pwd)\n";
print hOutput "script_dir=\$(dirname \$0)\n";
print hOutput "if [ \$script_dir = '.' ]; then\n";
print hOutput "    script_dir=\"\$current_dir\"\n";
print hOutput "fi\n";
print hOutput "echo \"Current folder: \" \$script_dir\n";
print hOutput "err=0;\n";
print hOutput "if [ \"\$script_dir\" = \"\$HOME/Downloads/homer3_install\" ]; then\n";
print hOutput "    echo \"Installation folder is correct...\"\n";
print hOutput "else\n";
print hOutput "    echo \"Wrong installation folder...Please move homer3_install to Downloads and rerun setup from there\"\n";
print hOutput "    touch \$script_dir\.error\n";
print hOutput "    err=1;\n";
print hOutput "fi\n";
print hOutput "\n";

# If not running script from ~/Downloads/homer3_install then copy current homer3_install folder to ~/Downloads  
print hOutput "if [ \$err = 1 ]; then\n";
print hOutput "    if [ -d ~/Downloads/homer3_install ]; then\n";
print hOutput "        echo ~/Downloads/homer3_install exists .... Deleting ~/Downloads/homer3_install\n";
print hOutput "        rm -rf ~/Downloads/homer3_install;\n";
print hOutput "    else\n";
print hOutput "        echo ~/Downloads/homer3_install does not exist ... will create it\n";
print hOutput "    fi\n";
print hOutput "    echo cp -r \$script_dir ~/Downloads/homer3_install;\n";
print hOutput "    cp -r \$script_dir ~/Downloads/homer3_install;\n";
print hOutput "fi\n";

print hOutput "rm -rf ~/libs; mkdir ~/libs\n";
print hOutput "if [ ! -L \"~/libs/mcr\" ]; then ln -s /Applications/MATLAB/MATLAB_Runtime/v93 ~/libs/mcr; fi\n";
# print hOutput "if [ ! -L \"~/libs/mcr\" ]; then ln -s /Applications/MATLAB/MATLAB_Compiler_Runtime/v84 ~/libs/mcr; fi\n";
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

