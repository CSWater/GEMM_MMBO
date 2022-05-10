#!/usr/bin/perl

for my $file (@ARGV) {
    my $content;

    open(in, "$file");
    $content .= $_ while <in>;
    close(in);

    if ($content =~ m/\.Lfunc_end0:/) {
        print "$`";
    }
}
