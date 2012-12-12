package Net::NUT;

use Net::NUT::UPS;

use warnings;
use strict;
use IO::Socket::INET;

our $VERSION = "0.1";

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

The primary goal of the Network UPS Tools (NUT) project is to provide support for
Power Devices, such as Uninterruptible Power Supplies, Power Distribution Units and Solar Controllers.

NUT provides many control and monitoring features, with a uniform control and management interface.

More than 100 different manufacturers, and several thousands models are compatible.

This software is the combined effort of many individuals and companies.


http://www.networkupstools.org/

Net::NUT only cover a limited subset of NUT features (read only access).

=head1 COPYRIGHT

Copyright (C) 2012 Gonéri Le Bouder. All rights reserved.

This library is free software. You can modify and/or distribute it under the same terms as Perl itself.

=head1 METHODS

=head2 new(%params)

Use IO::Socket::INET params. Default is to connect on a local NUT server.

=head2 listDevices()

Returns a list of Net::NUT::UPS object.

=head2 getDevice($name)

Returns a Net::NUT::UPS object named $name or undef.

=head1 AUTHOR

Gonéri Le Bouder <goneri@rulezlan.org>
