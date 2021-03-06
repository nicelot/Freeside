package FS::NetworkMonitoringSystem::Torrus_Internal;

use strict;
#use vars qw( $DEBUG $me );
use Fcntl qw(:flock);
use IO::File;
use File::Slurp qw(slurp);
use IPC::Run qw(run);
use Date::Format;
use XML::Simple;
use FS::Record qw(qsearch qsearchs dbh);
use FS::svc_port;
use FS::torrus_srvderive;
use FS::torrus_srvderive_component;
#use Torrus::ConfigTree;

#$DEBUG = 0;
#$me = '[FS::NetworkMonitoringSystem::Torrus_Internal]';

our $lock;
our $lockfile = '/usr/local/etc/torrus/discovery/FSLOCK';
our $ddxfile  = '/usr/local/etc/torrus/discovery/routers.ddx';

sub new {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    return $self;
}

sub ddx2hash {
    my $self = shift;
    my $ddx_xml = slurp($ddxfile);
    my $xs = new XML::Simple(RootName=> undef, SuppressEmpty => '', 
                                ForceArray => 1, );
    return $xs->XMLin($ddx_xml);
}

sub get_router_serviceids {
  my $self = shift;
  my $router = shift;
  my $find_serviceid = shift;
  my $found_serviceid = 0;
  my $ddx_hash = $self->ddx2hash;
  return '' unless $ddx_hash->{'host'};

  my @hosts = @{$ddx_hash->{host}};
  foreach my $host ( @hosts ) {
    my $param = $host->{param};
    if($param && $param->{'snmp-host'} 
              && (!$router || $param->{'snmp-host'}->{'value'} eq $router)
              && $param->{'RFC2863_IF_MIB::external-serviceid'}) {
      my $serviceids =
        $param->{'RFC2863_IF_MIB::external-serviceid'}->{'content'};
      my %hash = ();
      if ($serviceids) {
        my @serviceids = split(',',$serviceids);
        foreach my $serviceid ( @serviceids ) {
          $serviceid =~ s/^\s+|\s+$//g;
          my @s = split(':',$serviceid);
          next unless scalar(@s) == 4;
          $hash{$s[1]} = $s[0] if $router;
          if ($find_serviceid && $find_serviceid eq $s[0]) {
            $hash{$param->{'snmp-host'}->{'value'}} = $s[1];
            $found_serviceid = 1;
          }
        }
      }
      return \%hash if ($router || $found_serviceid);
    }
  }
  '';
}

#false laziness and probably should be merged w/above, but didn't want to mess
# that up
sub all_router_serviceids {
  my $self = shift;
  my $ddx_hash = $self->ddx2hash;
  return () unless $ddx_hash->{'host'};

  my %hash = ();
  my @hosts = @{$ddx_hash->{host}};
  foreach my $host ( @hosts ) {
    my $param = $host->{param};
    if($param && $param->{'snmp-host'} 
              && $param->{'RFC2863_IF_MIB::external-serviceid'}) {
      my $serviceids =
        $param->{'RFC2863_IF_MIB::external-serviceid'}->{'content'};
      if ($serviceids) {
        my @serviceids = split(',',$serviceids);
        foreach my $serviceid ( @serviceids ) {
          $serviceid =~ s/^\s+|\s+$//g;
          my @s = split(':',$serviceid);
          next unless scalar(@s) == 4;
          $hash{$s[0]}=1;
        }
      }
    }
  }
  return sort keys %hash;
}

sub port_graphs_link {
    # hardcoded for 'main' tree for now 
    my $self = shift;
    my $serviceid = shift;
    my $hash = $self->get_router_serviceids(undef,$serviceid) or return '';
    my @keys = keys %$hash; # yeah this is weird...
    my $host = $keys[0];
    my $iface = $hash->{$keys[0]};

    #Torrus::ConfigTree is only available when running under the web UI
    eval 'use Torrus::ConfigTree;';
    die $@ if $@;

    my $config_tree = new Torrus::ConfigTree( -TreeName => 'main' );
    my $token = $config_tree->token("/Routers/$host/Interface_Counters/$iface/InOut_bps");
    return $Torrus::Freeside::FSURL."/torrus/main?token=$token";
}

sub find_svc {
    my $self = shift;
    my $serviceid = shift;
    return '' unless $serviceid =~ /^[0-9A-Za-z_\-.\\\/ ]+$/;
  
    my @svc_port = qsearch('svc_port', { 'serviceid' => $serviceid });
    return '' unless scalar(@svc_port);

    # for now it's like this, later on just change to qsearchs

    return $svc_port[0];
}

sub find_torrus_srvderive_component {
    my $self = shift;
    my $serviceid = shift;
    return '' unless $serviceid =~ /^[0-9A-Za-z_\-.\\\/ ]+$/;
  
    qsearchs('torrus_srvderive_component', { 'serviceid' => $serviceid });
}

sub report {
  my $self = shift;

  my @ls = localtime(time);
  my ($d,$m,$y) = ($ls[3], $ls[4]+1, $ls[5]+1900);
  if ( $ls[3] == 1 ) {
    $m--;
    if ($m == 0) { $m=12; $y-- }
    #i should have better error checking
    system('torrus', 'report', '--report=MonthlyUsage', "--date=$y-$m-01");
    system('torrus', 'report', '--genhtml', '--all2tree=main');
  }

}

sub queued_add_router {
  my $self = shift;
  my $error = $self->add_router(@_);
  die $error if $error;
}

sub add_router {
  my($self, $ip, $community) = @_;

  $community = (defined($community) && length($community) > 1)
                 ? qq!<param name="snmp-community" value="$community"/>\n !
                 : '';

  my $newhost = 
    qq(  <host>\n).
    qq(    <param name="snmp-host" value="$ip"/>\n).$community.
    qq(  </host>\n);

  my $ddx = $self->_torrus_loadddx;

  $ddx =~ s{(</snmp-discovery>)}{$newhost$1};

  $self->_torrus_newddx($ddx);

}

sub add_interface {
  my($self, $router_ip, $interface, $serviceid ) = @_;

  #false laziness w/torrus/perllib/Torrus/Renderer.pm iface_underscore, update both
  $interface =~ s(\/)(_)g; #slashes become underscores
  $interface =~ s(\.)(_)g; #periods too, huh
  $interface =~ s(\-)(_)g; #yup, and dashes

  #should just use a proper XML parser huh

  my @ddx = split(/\n/, $self->_torrus_loadddx);

  die "Torrus Service ID $serviceid in use\n"
    if grep /^\s*$serviceid:/, @ddx;

  my $newline = "     $serviceid:$interface:Both:main,";

  my $new = '';

  my $added = 0;

  while ( my $line = shift(@ddx) ) {
    $new .= "$line\n";
    next unless $line =~ /^\s*<param\s+name="snmp-host"\s+value="$router_ip"\/?>/i;

    while ( my $hostline = shift(@ddx) ) {
      $new .= "$hostline\n" unless $hostline =~ /^\s+<\/host>\s*/i;
      if ( $hostline =~ /^\s*<param name="RFC2863_IF_MIB::external-serviceid"\/?>/i ) {

        while ( my $paramline = shift(@ddx) ) {
          if ( $paramline =~ /^\s*<\/param>/ ) {
            $new .= "$newline\n$paramline\n";
            last; #paramline
          } else {
            $new .= "$paramline\n";
          }
        }

        $added++;

      } elsif ( $hostline =~ /^\s+<\/host>\s*/i ) {
        unless ( $added ) {
          $new .= 
            qq(   <param name="RFC2863_IF_MIB::external-serviceid">\n).
            qq(     $newline\n).
            qq(   </param>\n);
        }
        $new .= "$hostline\n";
        last; #hostline
      }
 
    }

  }

  $self->_torrus_newddx($new);

}

sub _torrus_lock {
  $lock = new IO::File ">>$lockfile" or die $!;
  flock($lock, LOCK_EX);
}

sub _torrus_unlock {
  flock($lock, LOCK_UN);
  close $lock;
}

sub _torrus_loadddx {
  my($self) = @_;
  $self->_torrus_lock;
  return slurp($ddxfile);
}

sub _torrus_newddx {
  my($self, $ddx) = @_;

  my $new = new IO::File ">$ddxfile.new"
    or die "can't write to $ddxfile.new: $!";
  print $new $ddx;
  close $new;

  my $tmpname = $ddxfile . Date::Format::time2str('%Y%m%d%H%M%S',time);
  rename($ddxfile, $tmpname) or die $!;
  rename("$ddxfile.new", $ddxfile) or die $!;

  my $error = $self->_torrus_reload;
  if ( $error ) { #revert routers.ddx
    rename($ddxfile, "$tmpname.FAILED") or die $!;
    rename($tmpname, $ddxfile) or die $!;
  }
  
  $self->_torrus_unlock;

  return $error;
}

sub _torrus_reload {
  my($self) = @_;

  my $stderr = '';
  run( ['torrus', 'devdiscover', "--in=$ddxfile"], '2>'=>\$stderr );
  return $stderr if $stderr;

  run( ['torrus', 'compile', '--tree=main'] ); # , '--verbose'
  #typically the errors happen at the discover stage...

  '';

}

#sub torrus_serviceids {
#  my $self = shift;
#
#  #is this going to get too slow or will the index make it okay?
#  my $sth = dbh->prepare("SELECT DISTINCT(serviceid) FROM srvexport")
#    or die dbh->errstr;
#  $sth->execute or die $sth->errstr;
#  my %serviceid = ();
#  while ( my $row = $sth->fetchrow_arrayref ) {
#    my $serviceid = $row->[0];
#    $serviceid =~ s/_(IN|OUT)$//;
#    $serviceid{$serviceid}=1;
#  }
#  my @serviceids = sort keys %serviceid;
#
#  @serviceids;
#
#}

sub torrus_serviceids {
  my $self = shift;
  my @serviceids = $self->all_router_serviceids;
  push @serviceids, map $_->serviceid, qsearch('torrus_srvderive', {});
  return sort @serviceids;
}

1;
