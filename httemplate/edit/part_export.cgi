<!-- mason kludge -->
<%

#if ( $cgi->param('clone') && $cgi->param('clone') =~ /^(\d+)$/ ) {
#  $cgi->param('clone', $1);
#} else {
#  $cgi->param('clone', '');
#}

my($query) = $cgi->keywords;
my $action = '';
my $part_export = '';
if ( $cgi->param('error') ) {
  $part_export = new FS::part_export ( {
    map { $_, scalar($cgi->param($_)) } fields('part_export')
  } );
} elsif ( $query =~ /^(\d+)$/ ) {
  $part_export = qsearchs('part_export', { 'exportnum' => $1 } );
} else {
  $part_export = new FS::part_export;
}
$action ||= $part_export->exportnum ? 'Edit' : 'Add';

my %exports = (
  'svc_acct' => {
    'sysvshell' => {
      'desc' =>
        'Batch export of /etc/passwd and /etc/shadow files (Linux/SysV)',
      'options' => {},
    },
    'bsdshell' => {
      'desc' =>
        'Batch export of /etc/passwd and /etc/master.passwd files (BSD)',
      'options' => {},
    },
#    'nis' => {
#      'desc' =>
#        'Batch export of /etc/global/passwd and /etc/global/shadow for NIS ',
#      'options' => {},
#    },
    'bsdshell' => {
      'desc' =>
        'Batch export of /etc/passwd and /etc/master.passwd files (BSD)',
      'options' => {},
    },
    'textradius' => {
      'desc' => 'Batch export of a text /etc/raddb/users file (Livingston, Cistron)',
    },
    'sqlradius' => {
      'desc' => 'Real-time export to SQL-backed RADIUS (ICRADIUS, FreeRADIUS)',
      'options' => {
        'datasrc'  => { label=>'DBI data source' },
        'username' => { label=>'Database username' },
        'password' => { label=>'Database password' },
      },
      'nodomain' => 'Y',
      'notes' => 'Not specifying datasrc will export to the freeside database? (no...  notes on MySQL replication, DBI::Proxy, etc., from Conf.pm && export.html etc., reset with bin/sqlradius_reset',
    },
    'cyrus' => {
      'desc' => 'Real-time export to Cyrus IMAP server',
    },
    'cp' => {
      'desc' => 'Real-time export to Critical Path Account Provisioning Protocol',
    },
    'infostreet' => {
      'desc' => 'Real-time export to InfoStreet streetSmartAPI',
      'options' => {
        'url'      => { label=>'XML-RPC Access URL', },
        'login'    => { label=>'InfoStreet login', },
        'password' => { label=>'InfoStreet password', },
        'groupID'  => { label=>'InfoStreet groupID', },
      },
      'nodomain' => 'Y',
      'notes' => 'Real-time export to <a href="http://www.infostreet.com/">InfoStreet</a> streetSmartAPI.  Requires installation of <a href="http://search.cpan.org/search?dist=Frontier-Client">Frontier::Client</a> from CPAN.',
    }
  },

  'svc_domain' => {},

  'svc_acct_sm' => {},

  'svc_forward' => {},

  'svc_www' => {},

);

#my $svcdb = $part_export->part_svc->svcdb;
#YUCK
my $svcdb = 'svc_acct';

my %layers = map { $_ => "$_ - ". $exports{$svcdb}{$_}{desc} }
               keys %{$exports{$svcdb}};
$layers{''}='';

my $widget = new HTML::Widgets::SelectLayers(
  'selected_layer' => $part_export->exporttype,
  'options'        => \%layers,
  'form_name'      => 'dummy',
  'form_action'    => 'process/part_export.cgi',
  'form_text'      => [qw( exportnum machine )],
#  'form_checkbox'  => [qw()],
  'html_between'    => "</TD></TR></TABLE>\n",
  'layer_callback'  => sub {
    my $layer = shift;
    my $html = qq!<INPUT TYPE="hidden" NAME="exporttype" VALUE="$layer">!.
               ntable("#cccccc",2);
    foreach my $option ( keys %{$exports{$svcdb}->{$layer}{options}} ) {
#    foreach my $option ( qw(url login password groupID ) ) {
      my $optinfo = $exports{$svcdb}->{$layer}{options}{$option};
      my $label = $optinfo->{label};
      my $value = $cgi->param($option) || $part_export->option($option);
      $html .= qq!<TR><TD ALIGN="right">$label</TD><TD>!.
               qq!<TD><INPUT TYPE="text" NAME="$option" VALUE="$value"></TD>!.
               '</TR>';
    }
    $html .= '</TABLE>';

    $html .= '<INPUT TYPE="hidden" NAME="options" VALUE="'.
             join(',', keys %{$exports{$svcdb}->{$layer}{options}} ). '">';

    $html .= '<INPUT TYPE="hidden" NAME="nodomain" VALUE="'.
             $exports{$svcdb}->{$layer}{nodomain}. '">';

    $html .= '<INPUT TYPE="submit" VALUE="'.
             ( $part_export->exportnum ? "Apply changes" : "Add export" ).
             '">';

    $html;
  },
);

%>
<%= header("$action Export", menubar(
  'Main Menu' => popurl(2),
), ' onLoad="visualize()"')
%>

<% if ( $cgi->param('error') ) { %>
  <FONT SIZE="+1" COLOR="#ff0000">Error: <%= $cgi->param('error') %></FONT>
  <BR><BR>
<% } %>

<FORM NAME="dummy">
<INPUT TYPE="hidden" NAME="exportnum" VALUE="<%= $part_export->exportnum %>">

<%= ntable("#cccccc",2) %>
<TR>
  <TD ALIGN="right">Export host</TD>
  <TD>
    <INPUT TYPE="text" NAME="machine" VALUE="<%= $part_export->machine %>">
  </TD>
</TR>
<TR>
  <TD ALIGN="right">Export</TD>
  <TD><%= $widget->html %>
</BODY>
</HTML>

