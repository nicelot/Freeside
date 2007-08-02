#!/usr/bin/perl -w

use Test::More tests => 30;
use strict;
use RT;

# Load the config file
RT::LoadConfig();

#Connect to the database and get RT::SystemUser and RT::Nobody loaded
RT::Init();

#Get the current user all loaded
my $CurrentUser = $RT::SystemUser;

my $queue = new RT::Queue($CurrentUser);
$queue->Load('General') || Abort(loc("Queue could not be loaded."));

my $child_ticket = new RT::Ticket( $CurrentUser );
my ($childid) = $child_ticket->Create(
    Subject => 'test child',
    Queue => $queue->Id,
);
ok($childid, "We created a child ticket");

my $parent_ticket = new RT::Ticket( $CurrentUser );
my ($parentid) = $parent_ticket->Create(
    Subject => 'test parent',
    Children => [ $childid ],
    Queue => $queue->Id,
);
ok($parentid, "We created a parent ticket");


my $Collection = RT::Tickets->new($CurrentUser);
$Collection->LimitMemberOf( $parentid );
is($Collection->Count,1, "We found only one result");
ok($Collection->First);
is($Collection->First->id, $childid, "We found the collection of all children of $parentid with Limit");

$Collection = RT::Tickets->new($CurrentUser);
$Collection->FromSQL("MemberOf = $parentid");
is($Collection->Count, 1, "We found only one result");
ok($Collection->First);
is($Collection->First->id, $childid, "We found the collection of all children of $parentid with TicketSQL");


$Collection = RT::Tickets->new($CurrentUser);
$Collection->LimitHasMember ($childid);
is($Collection->Count,1, "We found only one result");
ok($Collection->First);
is($Collection->First->id, $parentid, "We found the collection of all parents of $childid with Limit");


$Collection = RT::Tickets->new($CurrentUser);
$Collection->FromSQL("HasMember = $childid");
is($Collection->Count,1, "We found only one result");
ok($Collection->First);
is($Collection->First->id, $parentid, "We found the collection of all parents of $childid with TicketSQL");


# Now we find a collection of all the tickets which have no members. they should have no children.
$Collection = RT::Tickets->new($CurrentUser);
$Collection->LimitHasMember('');
# must contain child; must not contain parent
my %has;
while (my $t = $Collection->Next) {
    ++$has{$t->id};
}
ok( $has{$childid}, "The collection has our child - $childid");
ok( !$has{$parentid}, "The collection doesn't have our parent - $parentid");


# Now we find a collection of all the tickets which are not members of anything. they should have no parents.
$Collection = RT::Tickets->new($CurrentUser);
$Collection->LimitMemberOf('');
# must contain parent; must not contain child
%has = ();
while (my $t = $Collection->Next) {
    ++$has{$t->id};
}
ok ($has{$parentid} , "The collection has our parent - $parentid");
ok( !$has{$childid}, "The collection doesn't have our child - $childid");


#  Do it all over with TicketSQL
#



# Now we find a collection of all the tickets which have no members. they should have no children.
$Collection = RT::Tickets->new($CurrentUser);
$Collection->FromSQL ("HasMember IS NULL");
# must contain parent; must not contain child
%has = ();
while (my $t = $Collection->Next) {
    ++$has{$t->id};
}
ok( !$has{$parentid}, "The collection doesn't have our parent - $parentid");
ok( $has{$childid}, "The collection has our child - $childid");


# Now we find a collection of all the tickets which have no members. they should have no children.
# Alternate syntax
$Collection = RT::Tickets->new($CurrentUser);
$Collection->FromSQL("HasMember = ''");
# must contain parent; must not contain child
%has = ();
while (my $t = $Collection->Next) {
    ++$has{$t->id};
}
ok( !$has{$parentid}, "The collection doesn't have our parent - $parentid");
ok( $has{$childid}, "The collection has our child - $childid");


# Now we find a collection of all the tickets which are not members of anything. they should have no parents.
$Collection = RT::Tickets->new($CurrentUser);
$Collection->FromSQL("MemberOf IS NULL");
# must not  contain parent; must contain parent
%has = ();
while (my $t = $Collection->Next) {
    ++$has{$t->id};
}
ok( $has{$parentid}, "The collection has our parent - $parentid");
ok( !$has{$childid}, "The collection doesn't have our child - $childid");


# Now we find a collection of all the tickets which are not members of anything. they should have no parents.
$Collection = RT::Tickets->new($CurrentUser);
$Collection->FromSQL("MemberOf = ''");
# must not  contain parent; must contain parent
%has = ();
while (my $t = $Collection->Next) {
    ++$has{$t->id};
}
ok( $has{$parentid}, "The collection has our parent - $parentid");
ok( !$has{$childid}, "The collection doesn't have our child - $childid");


# Now we find a collection of all the tickets which are not members of the parent ticket
$Collection = RT::Tickets->new($CurrentUser);
$Collection->FromSQL("MemberOf != $parentid");
%has = ();
while (my $t = $Collection->Next) {
    ++$has{$t->id};
}
ok( $has{$parentid}, "The collection has our parent - $parentid");
ok( !$has{$childid}, "The collection doesn't have our child - $childid");

$Collection = RT::Tickets->new($CurrentUser);
$Collection->LimitMemberOf($parentid, OPERATOR => '!=');
%has = ();
while (my $t = $Collection->Next) {
    ++$has{$t->id};
}
ok( $has{$parentid}, "The collection has our parent - $parentid");
ok( !$has{$childid}, "The collection doesn't have our child - $childid");

1;
