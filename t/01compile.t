#!/usr/bin/perl

use strict;
use warnings;

use English qw(-no_match_vars);
use Test::More;
use UNIVERSAL::require;

use lib 't';

plan(skip_all => 'Test::Compile required')
    unless Test::Compile->require();
Test::Compile->import();

# exclude linked modules
my @files = all_pm_files('lib');

all_pm_files_ok(@files);

