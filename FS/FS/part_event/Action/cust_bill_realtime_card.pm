package FS::part_event::Action::cust_bill_realtime_card;

use strict;
use base qw( FS::part_event::Action );

sub description {
  #'Run card with a <a href="http://420.am/business-onlinepayment/">Business::OnlinePayment</a> realtime gateway';
  'Run card with a Business::OnlinePayment realtime gateway';
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

  my %opt = ('cc_surcharge_from_event' => 1);
  $cust_bill->realtime_card(%opt);
}

1;
