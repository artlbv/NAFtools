#!/bin/sh

function overview {
    echo -n $(echo "$x" | egrep $1 | grep -c " r ") "running, "
    echo -n $(echo "$x" | egrep $1 | grep -c " qw ") "queuing, "
    echo $(echo "$x" | egrep -c $1) "total."
}
#$tmp = $real{$user} if $real{$user};
x=`qstat -g d -u '*'`
echo -n "All users: "
overview "."
echo -n "You:       "
overview "$USER"
perl -le'print "*"x50'
r=`echo "$x" | grep " r " | awk '{print $4}' | sort | uniq -c | sort -rn`
w=`echo "$x" | egrep " h?qw " | awk '{print $4}' | sort | uniq -c | sort -rn`
perl -le'
    use Term::ReadKey;
    ($width, $height) = GetTerminalSize();
    $width = int($width/2-6);
    $height-=8;
    print sprintf "      %-${width}s      %s", "RUNNING JOBS", "WAITING JOBS";

    for $c(@ARGV) {
        for $i (0..$height) {
            (undef,$n,$user) = split/\s+/, (split/\n/,$c)[$i];
            $real{$user} = $user;
        }
    }

    for (do{open $x, "<", "/etc/passwd"; <$x>}) {
        ($user,undef,undef,undef,$nameAndUni) = split /:/;
        ($name,undef,undef,$uni) = split /,/, $nameAndUni;
        $name.=", $uni" if $uni;

          $real{$user}.=" $name";

    }

    for $c(@ARGV) {
        for $i (0..$height) {
            (undef,$n,$user) = split/\s+/, (split/\n/,$c)[$i];
            $out[$i].=sprintf "%5s %-${width}.${width}s", $n, $real{$user} if $user;
        }
    }
    print for @out' "$r" "$ru" "$w"
