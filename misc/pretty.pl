#!/usr/bin/perl

# :: ��������� ���� ������ � ������ '-h' ��� ������� ::

$stopat = 5;
N: foreach (@ARGV) {
    help() if (/^-h$/);
    $df=$1, next N if (/^-desc(.+)/);
    $ds=1,  next N if (/^-set$/);
    $na=1,  next N if (/^-na$/);
    $dl=1,  next N if (/^-d$/);
    $bk=1,  next N if (/^-b$/);
    $ns=1,  next N if (/^-ns$/);
    $nf=1,  next N if (/^-nf$/);
    $stopat=3, next N if (/^-nfa$/);
    $no=1,  next N if (/^-no$/);
    $nl=1,  next N if (/^-nl$/);
    $alst=$_ if (-f $_);
}
help() unless ($alst);

$aold='areas.old';
$anew='areas.l$$';

open LIST, "<$alst" or die "Error open $alst";
open LOUT, ">$anew" or die "Error open temporary file";
readna() if ($df);

%echooptions = (
'-lr' => '\d+',
'-lw' => '\d+',
'-p' => '\d+',
'-mandatory' => '',
'-ccoff' => '',
'-$m' => '\d+',
'-nopack' => '',
'-killRead' => '',
'-keepUnread' => '',
'-a' => '\S+',
'-b' => '\S+',
'-g' => '\S+',
'-keepsb' => '',
'-tinysb' => '',
'-killsb' => '',
'-manual' => '',
'-dosfile' => '',
'-h' => '',
'-d' => '\".+\"',
'-nopause' => '',
'-DupeCheck' => '(off|move|del)',
'-DupeHistory' => '\d+',
'-nolink' => '',
'-debug' => '',
'-sbadd' => '',
'-sbign' => ''
);

print ":: �������� ����������. �������� ��� ������ ����� �������.\n";
my @ml;

$ln=0;
foreach $line (<LIST>) {
   chomp $line;
   if (($type,$name,$file,$rest) = $line=~/^(\w+)\s+(\S+)\s+(\S+)\s+(.+)/i) {
      
      $rest=~s/\"(.*)\"/do{$_=$1, $_=~tr# #\x01#, '"'.$_.'"'}/eg;

      @res = (split /\s+/, $rest);
      map {tr/\x01/ /} @res;
      @opt = ();
      @lnk = ();

      for ($i=0, $rest=''; $i<=$#res; $i++){
                $ss = $res[$i];
                $ss=~s/\(.*\)//;
                ($opti) = (grep (/^\Q$ss/i, keys %echooptions));
                # check is not implemented yet
                $eo = $echooptions{$opti};
                if ($eo) {
                    push @opt, "$res[$i] $res[++$i]";
                } elsif ($opti) {
                    push @opt, $res[$i];
                } else {
                    if ($res[$i]=~/-(def|r|w|mn)/) {
                        $lnk[$#lnk].=' '.$res[$i];
                    } else {
                        push @lnk, $res[$i];
                    }
                }
      }
      # foreach (@opt) { print "$_\, " }; print "\n";

      $desc = (grep /^-d /, @opt)[0];
      @opt  = grep !/^-d /, @opt;
      if ($df and (!$desc or $ds)) {
         $ndesc = description(lc($name));
         $desc = "-d \"". $ndesc ."\"" if ($ndesc);
      }

      if ($no) {$rest = join " " ,@opt} else
               {$rest = join " " ,sort {$a cmp $b} @opt};
      if ($nl) {$links= join " " ,@lnk} else
               {$links= join " " ,sort {mysort()} @lnk};
      sub mysort {
          my ($i,$j);
          $i=$a; $j=$b;
          $i=~s/(\d+)/'0' x (5-length($1)) . $1/eg;
          $j=~s/(\d+)/'0' x (5-length($1)) . $1/eg;
          return $i cmp $j;
      }

      &max(1, $type);
      &max(2, $name);
      &max(3, $file);
      &max(4, $rest);
      &max(5, $desc);
      $lines[$ln] = [ (1, $type, $name, $file, $rest, $desc, $links) ];
   } else {
      $lines[$ln] = [ (0, $line) ];
   }
   print ".";
   $ln++;
}
print "\n";

sub max() {
        my ($i, $s);
        ($i, $s)=@_;
        if ($ml[$i]<length($s)) {
            $ml[$i]=length($s);
        }
}

if (!$ns) {
print ":: ��������� ������ ����.\n";
CN: for ($i=0; $i<=$ln; $i++) {
        if ($lines[$i][0]) {
            for ($j=$i; $j<=$ln; $j++) {
                 if (!$lines[$j][0]) {
                     @part=@lines[$i..$j-1];
                     @part = sort {${$a}[2] cmp ${$b}[2]} @part;
                     @lines[$i..$j-1]=@part;
                     $i=$j;
                     next CN;
                 }
            }
        }
}
}

if (!$nf) { print ":: ����������� ����������.\n" } else
          { print ":: ���������� ����������.\n" }
for ($i=0; $i<$ln; $i++) {
      @al = @{$lines[$i]};
      if ($al[0]) {
          $al[3] = 'passthrough' if ($al[3]=~/passthrough/i);
          if (!$nf) {
               for ($j=2; $j<=$stopat; $j++) {
                    $al[$j].=' ' x ( $ml[$j]-length($al[$j]) );
               }
          }
          # no desc
          if (($dl) and not ($al[5]=~/\w/) ) {
              $line = join ' ', (@al) [1,2,3,4,6];
          } else {
              $line = join ' ', (@al) [1,2,3,4,5,6];
          }
          $line =~ s/\s+$//;
      } else {
          $line = $al[1];
      }
      print LOUT "$line\n";
}

close LIST;
close LOUT;
rename($alst,$aold) unless ($bk);
rename($anew,$alst);
print ":: ������� ��������.\n";

sub readna() {
        open DESC, "<$df" or die "Error open $df";
        print ":: ������ ���� �������� ����.\n";
        foreach $line (<DESC>) {
           chomp $line;
           if ($na) {
                ($name,$tmp) = $line=~/(\S+)[\s\"]+(.+)/;
                $tmp=~s/[\s\"]+$//;
                $descript{lc($name)}=$tmp;
           } else {
             if ($line=~/(hold|down|),/i) {
                ($name,$tmp)=(split(/,/,$line))[1,2];
                $descript{lc($name)}=$tmp;
             }
           }
        }
}
sub description() {
    ($_)=@_;
    return $descript{$_} if ($descript{$_});
    # :: ����� �� ������ ���������� ���� ������� �� �������� ���� ::
    # return 'Some CityCat echo...' if (/^ru\.list\.citycat/);
    # return 'Some ExUSSR echo...'  if (/^su\./);
    # return 'Some Russian echo...' if (/^ru\./);
    # return 'Some private echo...' if (/^pvt\./);
    return '';
}

sub help() {
        print "Usage: pretty.pl [-d] [-b] [-ns] [-nf[a]] [-no] [-nl] <areafile>\n";
        print "                 [-desc<echodesc> [-na] [-set]]\n\n";
        print "::  ���� -d ��������� ����������� � ���� � �� �� ������� ������ �\n";
        print "::    �����������. ���� � ��� ���� ������������, �� ����� ������\n";
        print "::    (��� � 2:5080/102 ;-), �� �������������� ������ ������.\n";
        print "::  ���� -b ��������� ������ backup.\n";
        print "::  ���� -ns ��������� ����������� ����.\n";
        print "::    �� ��������� ����������� ������ ����, ������ ���� �� ������.\n";
        print "::  ���� -nf ��������� ������������ (� -nfa �� ������������� �����/�����).\n";
        print "::  ���� -no ��������� ����������� �����.\n";
        print "::  ���� -nl ��������� ����������� ������.\n";
        print "::  ���� -desc ��������� ��������� �������� ���� �� ����� ����\n";
        print "::    echo5020.lst. ���� �������� ����������� ����� -na, �� ��������\n";
        print "::    ����� ������� �� ����� ������������ ��� hpt �������.\n";
        print "::    ����� � �������������� ������� ����������� ��������, ��� �����\n";
        print "::    ����������� ���� -set.\n";
        print "::  Example 0: pretty.pl areas.lst\n";
        print "::  Example 1: pretty.pl -descD:\\files\\Xofcelist\\echo5020.lst\n";
        print "::                       -set -no -nl -ns areas.lst\n";
        print "::  ��������! ������ ������ ��������. ������ ���������.\n";
        exit;
}