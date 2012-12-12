use inc::Module::Install;
use English qw(-no_match_vars);

name 'Net-NUT';
include 'Net::NUT';
abstract 'Network UPS Tools (NUT) client';
license 'perl';
version_from 'lib/Net/NUT.pm';
perl_version '5.008';

requires 'IO::Socket::INET'        => undef;

WriteAll;
