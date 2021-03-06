package FS::part_event::Action::cust_bill_realtime_check;

use strict;
use base qw( FS::part_event::Action );

sub description {
  #'Run check with a <a href="http://420.am/business-onlinepayment/">Business::OnlinePayment</a> realtime gateway';
  'Run check with a Business::OnlinePayment realtime gateway';
}

sub deprecated { 1; }

sub eventtable_hashref {
  { 'cust_bill' => 1 };
}

sub default_weight { 30; }

sub do_action {
  my( $self, $cust_bill ) = @_;

  #my $cust_main = $self->cust_main($cust_bill);
  my $cust_main = $cust_bill->cust_main;

  $cust_bill->realtime_ach;
}

1;
