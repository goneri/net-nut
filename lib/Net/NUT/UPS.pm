package Net::NUT::UPS;

use warnings;
use strict;

sub new {

    my $class = shift;

    my %params = @_;

    my $self = {
        nut => $params{nut},
        name => $params{name},
        desc => $params{desc}
    };

    bless $self, $class;
}

sub listVars {
    my ($self, $ups) = @_;

    my $cmd = sprintf("LIST VAR %s", $self->{name});
    $self->{nut}->_pushCommand($cmd);
    my @result = $self->{nut}->_readListResult();

    my %info;

    foreach my $line (@result) {
        next unless $line =~ /^VAR\s\S+\s(\S+)\s"(.*)"/;
        $info{$1} = $2;
    }

    return %info;
}

1;

__END__

=head1 NAME

Net::NUT::UPS - a UPS object

=head1 SYNOPSIS

    use Net::NUT;
    
    my $nut = Net::NUT->new();
    
    my @devices = $nut->listDevices();
    
    foreach my $device (@devices) {
        print "name: ".$device->{name}."\n";
        print "desc: ".$device->{desc}."\n";
        print "---\n";
    }
    
    my $device = $nut->getDevice("dummy");
    
    my %info = $device->listVars();

=head1 METHODS

=head2 listVars()

Returns a hash of the internal values of the UPS.
