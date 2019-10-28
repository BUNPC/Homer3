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

# Insert new string into new file. Write literal $ by adding \ in front of $
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
    	$linenew = "exe_dir=~/homer3\n";
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
print hOutput "exit";

close hInput;
close hOutput;

