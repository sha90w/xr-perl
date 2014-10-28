#---------------------------------------------------------------------
#---------------------------------------------------------------------

$myas = 21497;

if(@ARGV < 1) {
	print "Usage: $0 <vrf NAME>\n";
	exit(1);
}

$vrf = $ARGV[0];

# sh run vrf XXX
system("nvgen -c -q gl/rsi/vrf/$vrf/");

# sh run int $int for vrf XXX
@out = `show_ip_interface -b -v $vrf`;

for (@out[2..$#out]) {
	$ifname = (split(/\s+/, $_))[0];
	$ifname =~ s,/,_,g;
	system("nvgen -c -q if/act/$ifname/");
} 

@out = `ospf_show -T + -v $vrf -l active`;
for (@out) {
	if(/^.*Routing\s+Process\s+"ospf\s+(\d+)"/) {
		$ospf_pid = $1;
		last;
	}
}

if($ospf_pid) {
	system("nvgen -c -q gl/ipv4-ospf/proc/$ospf_pid/");
}

# sh run router bgp
system("nvgen -c -q gl/ip-bgp/default/0/$myas/ord_b/$vrf/");

# sh run router static
system("nvgen -c -q gl/static/router/ord_v/$vrf/");
