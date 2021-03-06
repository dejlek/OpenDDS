eval '(exit $?0)' && eval 'exec perl -S $0 ${1+"$@"}'
    & eval 'exec perl -S $0 $argv:q'
    if 0;

# $Id$
# -*- perl -*-

use Env (DDS_ROOT);
use lib "$DDS_ROOT/bin";
use Env (ACE_ROOT);
use lib "$ACE_ROOT/bin";
use PerlDDS::Run_Test;
use strict;

my $test = new PerlDDS::TestFramework();

# Run at high debug level for additional function coverage.
$test->{dcps_debug_level} = 8;
# give each process 300 seconds to complete
$test->{wait_after_first_proc} = 300;
$test->{add_pending_timeout} = 0;
$test->{add_transport_config} = 0;

$test->report_unused_flags(1);
$test->setup_discovery();

my ($rtps_cfg, $rtps_mon) = ($test->{info_repo}->{state} eq 'none') ?
    ('-DCPSConfigFile rtps_disc.ini', '-t 0') : ('', '');

$test->process("subscriber", "subscriber", $rtps_cfg);
$test->process("publisher", "publisher", $rtps_cfg);
$test->process("monitor1", "monitor", "-l 7 $rtps_mon $rtps_cfg");
$test->process("monitor2", "monitor", "-u $rtps_mon $rtps_cfg");
my $synch_file = "monitor1_done";

unlink $synch_file;

$test->start_process("monitor1");

$test->start_process("publisher");
$test->start_process("subscriber");

sleep (15);

$test->start_process("monitor2");

my $status = $test->finish(300, "monitor1");

unlink $synch_file;

exit $status;
