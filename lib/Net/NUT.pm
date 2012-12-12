package Net::NUT;

use Net::NUT::UPS;

use warnings;
use strict;
use IO::Socket::INET;

sub new {
    my $class = shift;
    my %params = (
            PeerAddr => 'localhost',
            PeerPort => 3493,
            Timeout => 10,
            @_);

    my $self = {
        sock => IO::Socket::INET->new(%params)
    };

    die unless $self->{sock};

    bless $self, $class;

    return $self; 
}


sub _pushCommand {
    my ($self, $cmd) = @_;

    my $fd = $self->{sock};

    $fd->send($cmd."\n");

}

sub _readListResult {
    my ($self) = @_;

    my @result;
    do {
        push @result, $self->{sock}->getline();
        chomp($result[-1]);
    } while ($result[-1] && $result[-1] !~ /^END\s/);

    return @result;
}

sub listDevices {
    my ($self) = @_;

    $self->_pushCommand("LIST UPS");
    my @result = $self->_readListResult();

    my @ups;

    foreach my $line (@result) {
        next unless $line =~ /^UPS\s(\S+)\s+"(.*)"/;
        push @ups, Net::NUT::UPS->new(
            name => $1,
            desc => $2,
            nut => $self
        );
    }

    return @ups;
}

sub getDevice {
    my ($self, $name) = @_;

    my $cmd = sprintf("GET UPSDESC %s", $name);
    $self->_pushCommand($cmd);
    my $line = $self->{sock}->getline();

    my $ups;

    if ($line =~ /^UPSDESC\s(\S+)\s+"(.*)"/) {
        $ups = Net::NUT::UPS->new(
            name => $1,
            desc => $2,
            nut => $self
        );
    }

    return $ups;
}
1;


__END__

=head1 NAME

Net::NUT - Network UPS Tools (NUT) client

=head1 METHODS

=head2 new(%params)

Use IO::Socket::INET params. Default is to connect on a local NUT server.

=head2 listDevices()

Returns a list of Net::NUT::UPS object.

=head2 getDevice($name)

Returns a Net::NUT::UPS object named $name or undef.
