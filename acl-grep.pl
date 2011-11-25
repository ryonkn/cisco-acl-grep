#!/usr/bin/perl

#| = 1;

my $aclname = $ARGV[0];

if ( $aclname eq "" ) {
  exit 255;
}

sub get_hostname {
    my ($ip_address) = @_;
    my (@addr) = split(/\./, $ip_address);
    return $ip_address if @addr != 4;
    my ($name, $aliases, $addrtype, $length, @addrs)
        = gethostbyaddr(pack("C4", @addr), 2);
    return $name ? $name : $ip_address;
}

while ( <STDIN> ) {

    if ( $_ =~ /\%SEC-6-IPACCESSLOGP: list $aclname/ ) {
        my ( $month, $day, $time,  $router, $proto, $src, $dst ) = (split(/ /, $_))[0,1,2,3,12,13,17];

        my ( $srcip, $srcport ) = (split(/\(|\)/,$src))[0,1];
        my $srchost = get_hostname($srcip) . "($srcport)";

        my ( $dstip, $dstport ) = (split(/\(|\)|\,/,$dst))[0,1];
        my $dsthost = get_hostname($dstip) . "($dstport)";

        printf("%-60s ---(%-03s)--> %-60s on %-30s(%3s %02d %s)\n", $srchost, $proto, $dsthost, $router, $month, $day, $time);
    }
}
