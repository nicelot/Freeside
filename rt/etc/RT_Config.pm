#
# RT was configured with:
#
#   $ ./configure --enable-layout=Freeside --with-db-type=Pg --with-db-dba=freeside --with-db-database=freeside --with-db-rt-user=freeside --with-db-rt-pass= --with-web-user=freeside --with-web-group=freeside --with-rt-group=freeside --with-web-handler=modperl2
#

package RT;

#############################  WARNING  #############################
#                                                                   #
#                     NEVER EDIT RT_Config.pm !                     #
#                                                                   #
#         Instead, copy any sections you want to change to          #
#         RT_SiteConfig.pm and edit them there.  Otherwise,         #
#         your changes will be lost when you upgrade RT.            #
#                                                                   #
#############################  WARNING  #############################

=head1 NAME

RT::Config

=head1 Base configuration

=over 4

=item C<$rtname>

C<$rtname> is the string that RT will look for in mail messages to
figure out what ticket a new piece of mail belongs to.

Your domain name is recommended, so as not to pollute the namespace.
Once you start using a given tag, you should probably never change it;
otherwise, mail for existing tickets won't get put in the right place.

=cut

Set($rtname, "example.com");

=item C<$Organization>

You should set this to your organization's DNS domain. For example,
I<fsck.com> or I<asylum.arkham.ma.us>. It is used by the linking
interface to guarantee that ticket URIs are unique and easy to
construct.  Changing it after you have created tickets in the system
will B<break> all existing ticket links!

=cut

Set($Organization, "example.com");

=item C<$CorrespondAddress>, C<$CommentAddress>

RT is designed such that any mail which already has a ticket-id
associated with it will get to the right place automatically.

C<$CorrespondAddress> and C<$CommentAddress> are the default addresses
that will be listed in From: and Reply-To: headers of correspondence
and comment mail tracked by RT, unless overridden by a queue-specific
address.  They should be set to email addresses which have been
configured as aliases for F<rt-mailgate>.

=cut

Set($CorrespondAddress, '');

Set($CommentAddress, '');

=item C<$WebDomain>

Domain name of the RT server, e.g. 'www.example.com'. It should not
contain anything except the server name.

=cut

Set($WebDomain, "localhost");

=item C<$WebPort>

If we're running as a superuser, run on port 80.  Otherwise, pick a
high port for this user.

443 is default port for https protocol.

=cut

Set($WebPort, 80);

=item C<$WebPath>

If you're putting the web UI somewhere other than at the root of your
server, you should set C<$WebPath> to the path you'll be serving RT
at.

C<$WebPath> requires a leading / but no trailing /, or it can be
blank.

In most cases, you should leave C<$WebPath> set to "" (an empty
value).

=cut

Set($WebPath, "");

=item C<$Timezone>

C<$Timezone> is the default timezone, used to convert times entered by
users into GMT, as they are stored in the database, and back again;
users can override this.  It should be set to a timezone recognized by
your server.

=cut

Set($Timezone, "US/Eastern");

=item C<@Plugins>

Set C<@Plugins> to a list of external RT plugins that should be
enabled (those plugins have to be previously downloaded and
installed).

Example:

C<Set(@Plugins, (qw(Extension::QuickDelete RT::Extension::CommandByMail)));>

=cut

Set(@Plugins, (qw(RTx::Calendar
                  RT::Extension::MobileUI))); #RTx::Checklist ));

=back




=head1 Database connection

=over 4

=item C<$DatabaseType>

Database driver being used; case matters.  Valid types are "mysql",
"Oracle" and "Pg".

=cut

Set($DatabaseType, "Pg");

=item C<$DatabaseHost>, C<$DatabaseRTHost>

The domain name of your database server.  If you're running MySQL and
on localhost, leave it blank for enhanced performance.

C<DatabaseRTHost> is the fully-qualified hostname of your RT server,
for use in granting ACL rights on MySQL.

=cut

Set($DatabaseHost,   "localhost");
Set($DatabaseRTHost, "localhost");

=item C<$DatabasePort>

The port that your database server is running on.  Ignored unless it's
a positive integer. It's usually safe to leave this blank; RT will
choose the correct default.

=cut

Set($DatabasePort, "");

=item C<$DatabaseUser>

The name of the user to connect to the database as.

=cut

Set($DatabaseUser, "freeside");

=item C<$DatabasePassword>

The password the C<$DatabaseUser> should use to access the database.

=cut

Set($DatabasePassword, q{});

=item C<$DatabaseName>

The name of the RT database on your database server. For Oracle, the
SID and database objects are created in C<$DatabaseUser>'s schema.

=cut

Set($DatabaseName, q{freeside});

=item C<$DatabaseRequireSSL>

If you're using PostgreSQL and have compiled in SSL support, set
C<$DatabaseRequireSSL> to 1 to turn on SSL communication with the
database.

=cut

Set($DatabaseRequireSSL, undef);

=back




=head1 Logging

The default is to log anything except debugging information to syslog.
Check the L<Log::Dispatch> POD for information about how to get things
by syslog, mail or anything else, get debugging info in the log, etc.

It might generally make sense to send error and higher by email to
some administrator.  If you do this, be careful that this email isn't
sent to this RT instance.  Mail loops will generate a critical log
message.

=over 4

=item C<$LogToSyslog>, C<$LogToScreen>

The minimum level error that will be logged to the specific device.
From lowest to highest priority, the levels are:

    debug info notice warning error critical alert emergency

Many syslogds are configured to discard or file debug messages away, so
if you're attempting to debug RT you may need to reconfigure your
syslogd or use one of the other logging options.

Logging to your screen affects scripts run from the command line as well
as the STDERR sent to your webserver (so these logs will usually show up
in your web server's error logs).

=cut

Set($LogToSyslog, "info");
Set($LogToScreen, "info");

=item C<$LogToFile>, C<$LogDir>, C<$LogToFileNamed>

Logging to a standalone file is also possible. The file needs to both
exist and be writable by all direct users of the RT API. This generally
includes the web server and whoever rt-crontool runs as. Note that
rt-mailgate and the RT CLI go through the webserver, so their users do
not need to have write permissions to this file. If you expect to have
multiple users of the direct API, Best Practical recommends using syslog
instead of direct file logging.

You should set C<$LogToFile> to one of the levels documented above.

=cut

Set($LogToFile, undef);
Set($LogDir, q{/opt/rt3/var/log});
Set($LogToFileNamed, "rt.log");    #log to rt.log

=item C<$LogStackTraces>

If set to a log level then logging will include stack traces for
messages with level equal to or greater than specified.

NOTICE: Stack traces include parameters supplied to functions or
methods. It is possible for stack trace logging to reveal sensitive
information such as passwords or ticket content in your logs.

=cut

Set($LogStackTraces, "");

=item C<@LogToSyslogConf>

On Solaris or UnixWare, set to ( socket => 'inet' ).  Options here
override any other options RT passes to L<Log::Dispatch::Syslog>.
Other interesting flags include facility and logopt.  (See the
L<Log::Dispatch::Syslog> documentation for more information.)  (Maybe
ident too, if you have multiple RT installations.)

=cut

Set(@LogToSyslogConf, ());

=back



=head1 Incoming mail gateway

=over 4

=item C<$EmailSubjectTagRegex>

This regexp controls what subject tags RT recognizes as its own.  If
you're not dealing with historical C<$rtname> values, you'll likely
never have to change this configuration.

Be B<very careful> with it. Note that it overrides C<$rtname> for
subject token matching and that you should use only "non-capturing"
parenthesis grouping. For example:

C<Set($EmailSubjectTagRegex, qr/(?:example.com|example.org)/i );>

and NOT

C<Set($EmailSubjectTagRegex, qr/(example.com|example.org)/i );>

The setting below would make RT behave exactly as it does without the
setting enabled.

=cut

# Set($EmailSubjectTagRegex, qr/\Q$rtname\E/i );

=item C<$OwnerEmail>

C<$OwnerEmail> is the address of a human who manages RT. RT will send
errors generated by the mail gateway to this address.  This address
should I<not> be an address that's managed by your RT instance.

=cut

Set($OwnerEmail, 'root');

=item C<$LoopsToRTOwner>

If C<$LoopsToRTOwner> is defined, RT will send mail that it believes
might be a loop to C<$OwnerEmail>.

=cut

Set($LoopsToRTOwner, 1);

=item C<$StoreLoops>

If C<$StoreLoops> is defined, RT will record messages that it believes
to be part of mail loops.  As it does this, it will try to be careful
not to send mail to the sender of these messages.

=cut

Set($StoreLoops, undef);

=item C<$MaxAttachmentSize>

C<$MaxAttachmentSize> sets the maximum size (in bytes) of attachments
stored in the database.

For MySQL and Oracle, we set this size to 10 megabytes.  If you're
running a PostgreSQL version earlier than 7.1, you will need to drop
this to 8192. (8k)

=cut


Set($MaxAttachmentSize, 10_000_000);

=item C<$TruncateLongAttachments>

If this is set to a non-undef value, RT will truncate attachments
longer than C<$MaxAttachmentSize>.

=cut

Set($TruncateLongAttachments, undef);

=item C<$DropLongAttachments>

If this is set to a non-undef value, RT will silently drop attachments
longer than C<MaxAttachmentSize>.  C<$TruncateLongAttachments>, above,
takes priority over this.

=cut

Set($DropLongAttachments, undef);

=item C<$RTAddressRegexp>

C<$RTAddressRegexp> is used to make sure RT doesn't add itself as a
ticket CC if C<$ParseNewMessageForTicketCcs>, above, is enabled.  It
is important that you set this to a regular expression that matches
all addresses used by your RT.  This lets RT avoid sending mail to
itself.  It will also hide RT addresses from the list of "One-time Cc"
and Bcc lists on ticket reply.

If you have a number of addresses configured in your RT database
already, you can generate a naive first pass regexp by using:

    perl etc/upgrade/generate-rtaddressregexp

If left blank, RT will generate a regexp for you, based on your
comment and correspond address settings on your queues; this comes at
a small cost in start-up speed.

=cut

Set($RTAddressRegexp, undef);

=item C<$IgnoreCcRegexp>

C<$IgnoreCcRegexp> is a regexp to exclude addresses from automatic addition 
to the Cc list.  Use this for addresses that are I<not> received by RT but
are sometimes added to Cc lists by mistake.  Unlike C<$RTAddressRegexp>, 
these addresses can still receive email from RT otherwise.

=cut

Set($IgnoreCcRegexp, undef);

=item C<$CanonicalizeEmailAddressMatch>, C<$CanonicalizeEmailAddressReplace>

RT provides functionality which allows the system to rewrite incoming
email addresses.  In its simplest form, you can substitute the value
in C<CanonicalizeEmailAddressReplace> for the value in
C<CanonicalizeEmailAddressMatch> (These values are passed to the
C<CanonicalizeEmailAddress> subroutine in F<RT/User.pm>)

By default, that routine performs a C<s/$Match/$Replace/gi> on any
address passed to it.

=cut

# Set($CanonicalizeEmailAddressMatch, '@subdomain\.example\.com$');
# Set($CanonicalizeEmailAddressReplace, '@example.com');

=item C<$CanonicalizeOnCreate>

Set this to 1 and the create new user page will use the values that
you enter in the form but use the function CanonicalizeUserInfo in
F<RT/User_Local.pm>

=cut

Set($CanonicalizeOnCreate, 0);

=item C<$ValidateUserEmailAddresses>

If C<$ValidateUserEmailAddresses> is 1, RT will refuse to create
users with an invalid email address (as specified in RFC 2822) or with
an email address made of multiple email addresses.

=cut

Set($ValidateUserEmailAddresses, undef);

=item C<$NonCustomerEmailRegexp>

Normally, when a ticket is linked to a customer, any requestors on that
ticket that didn't previously have customer memberships are linked to 
the customer also.  C<$NonCustomerEmailRegexp> is a regexp for email 
addresses that should I<not> automatically be linked to a customer in 
this way.

=cut

Set($NonCustomerEmailRegexp, undef);

=item C<@MailPlugins>

C<@MailPlugins> is a list of authentication plugins for
L<RT::Interface::Email> to use; see L<rt-mailgate>

=cut

=item C<$UnsafeEmailCommands>

C<$UnsafeEmailCommands>, if set to 1, enables 'take' and 'resolve'
as possible actions via the mail gateway.  As its name implies, this
is very unsafe, as it allows email with a forged sender to possibly
resolve arbitrary tickets!

=cut

=item C<$ExtractSubjectTagMatch>, C<$ExtractSubjectTagNoMatch>

The default "extract remote tracking tags" scrip settings; these
detect when your RT is talking to another RT, and adjust the subject
accordingly.

=cut

Set($ExtractSubjectTagMatch, qr/\[.+? #\d+\]/);
Set($ExtractSubjectTagNoMatch, ( ${RT::EmailSubjectTagRegex}
       ? qr/\[(?:${RT::EmailSubjectTagRegex}) #\d+\]/
       : qr/\[\Q$RT::rtname\E #\d+\]/));

=back



=head1 Outgoing mail

=over 4

=item C<$MailCommand>

C<$MailCommand> defines which method RT will use to try to send mail.
We know that 'sendmailpipe' works fairly well.  If 'sendmailpipe'
doesn't work well for you, try 'sendmail'.  Other options are 'smtp'
or 'qmail'.

Note that you should remove the '-t' from C<$SendmailArguments> if you
use 'sendmail' rather than 'sendmailpipe'

For testing purposes, or to simply disable sending mail out into the
world, you can set C<$MailCommand> to 'testfile' which writes all mail
to a temporary file.  RT will log the location of the temporary file
so you can extract mail from it afterward.

=cut

Set($MailCommand, "sendmailpipe");

=item C<$SetOutgoingMailFrom>

C<$SetOutgoingMailFrom> tells RT to set the sender envelope to the
Correspond mail address of the ticket's queue.

Warning: If you use this setting, bounced mails will appear to be
incoming mail to the system, thus creating new tickets.

=cut

Set($SetOutgoingMailFrom, 0);

=item C<$OverrideOutgoingMailFrom>

C<$OverrideOutgoingMailFrom> is used for overwriting the Correspond
address of the queue as it is handed to sendmail -f. This helps force
the From_ header away from www-data or other email addresses that show
up in the "Sent by" line in Outlook.

The option is a hash reference of queue name to email address.  If
there is no ticket involved, then the value of the C<Default> key will
be used.

This option is irrelevant unless C<$SetOutgoingMailFrom> is set.

=cut

Set($OverrideOutgoingMailFrom, {
#    'Default' => 'admin@rt.example.com',
#    'General' => 'general@rt.example.com',
});

=item C<$DefaultMailPrecedence>

C<$DefaultMailPrecedence> is used to control the default Precedence
level of outgoing mail where none is specified.  By default it is
C<bulk>, but if you only send mail to your staff, you may wish to
change it.

Note that you can set the precedence of individual templates by
including an explicit Precedence header.

If you set this value to C<undef> then we do not set a default
Precedence header to outgoing mail. However, if there already is a
Precedence header, it will be preserved.

=cut

Set($DefaultMailPrecedence, "bulk");

=item C<$DefaultErrorMailPrecedence>

C<$DefaultErrorMailPrecedence> is used to control the default
Precedence level of outgoing mail that indicates some kind of error
condition. By default it is C<bulk>, but if you only send mail to your
staff, you may wish to change it.

If you set this value to C<undef> then we do not add a Precedence
header to error mail.

=cut

Set($DefaultErrorMailPrecedence, "bulk");

=item C<$UseOriginatorHeader>

C<$UseOriginatorHeader> is used to control the insertion of an
RT-Originator Header in every outgoing mail, containing the mail
address of the transaction creator.

=cut

Set($UseOriginatorHeader, 1);

=item C<$UseFriendlyFromLine>

By default, RT sets the outgoing mail's "From:" header to "SenderName
via RT".  Setting C<$UseFriendlyFromLine> to 0 disables it.

=cut

Set($UseFriendlyFromLine, 1);

=item C<$FriendlyFromLineFormat>

C<sprintf()> format of the friendly 'From:' header; its arguments are
SenderName and SenderEmailAddress.

=cut

Set($FriendlyFromLineFormat, "\"%s via RT\" <%s>");

=item C<$UseFriendlyToLine>

RT can optionally set a "Friendly" 'To:' header when sending messages
to Ccs or AdminCcs (rather than having a blank 'To:' header.

This feature DOES NOT WORK WITH SENDMAIL[tm] BRAND SENDMAIL.  If you
are using sendmail, rather than postfix, qmail, exim or some other
MTA, you _must_ disable this option.

=cut

Set($UseFriendlyToLine, 0);

=item C<$FriendlyToLineFormat>

C<sprintf()> format of the friendly 'To:' header; its arguments are
WatcherType and TicketId.

=cut

Set($FriendlyToLineFormat, "\"%s of ". RT->Config->Get('rtname') ." Ticket #%s\":;");

=item C<$NotifyActor>

By default, RT doesn't notify the person who performs an update, as
they already know what they've done. If you'd like to change this
behavior, Set C<$NotifyActor> to 1

=cut

Set($NotifyActor, 0);

=item C<$RecordOutgoingEmail>

By default, RT records each message it sends out to its own internal
database.  To change this behavior, set C<$RecordOutgoingEmail> to 0

=cut

Set($RecordOutgoingEmail, 1);

=item C<$VERPPrefix>, C<$VERPDomain>

Setting these options enables VERP support
L<http://cr.yp.to/proto/verp.txt>.

Uncomment the following two directives to generate envelope senders
of the form C<${VERPPrefix}${originaladdress}@${VERPDomain}>
(i.e. rt-jesse=fsck.com@rt.example.com ).

This currently only works with sendmail and sendmailpipe.

=cut

# Set($VERPPrefix, "rt-");
# Set($VERPDomain, $RT::Organization);


=item C<$ForwardFromUser>

By default, RT forwards a message using queue's address and adds RT's
tag into subject of the outgoing message, so recipients' replies go
into RT as correspondents.

To change this behavior, set C<$ForwardFromUser> to 1 and RT
will use the address of the current user and remove RT's subject tag.

=cut

Set($ForwardFromUser, 0);

=back

=head2 Email dashboards

=over 4

=item C<$DashboardAddress>

The email address from which RT will send dashboards. If none is set,
then C<$OwnerEmail> will be used.

=cut

Set($DashboardAddress, '');

=item C<$DashboardSubject>

Lets you set the subject of dashboards. Arguments are the frequency (Daily,
Weekly, Monthly) of the dashboard and the dashboard's name.

=cut

Set($DashboardSubject, "%s Dashboard: %s");

=item C<@EmailDashboardRemove>

A list of regular expressions that will be used to remove content from
mailed dashboards.

=cut

Set(@EmailDashboardRemove, ());

=back



=head2 Sendmail configuration

These options only take effect if C<$MailCommand> is 'sendmail' or
'sendmailpipe'

=over 4

=item C<$SendmailArguments>

C<$SendmailArguments> defines what flags to pass to C<$SendmailPath>
If you picked 'sendmailpipe', you MUST add a -t flag to
C<$SendmailArguments> These options are good for most sendmail
wrappers and work-a-likes.

These arguments are good for sendmail brand sendmail 8 and newer:
C<Set($SendmailArguments,"-oi -t -ODeliveryMode=b -OErrorMode=m");>

=cut

Set($SendmailArguments, "-oi -t");


=item C<$SendmailBounceArguments>

C<$SendmailBounceArguments> defines what flags to pass to C<$Sendmail>
assuming RT needs to send an error (i.e. bounce).

=cut

Set($SendmailBounceArguments, '-f "<>"');

=item C<$SendmailPath>

If you selected 'sendmailpipe' above, you MUST specify the path to
your sendmail binary in C<$SendmailPath>.

=cut

Set($SendmailPath, "/usr/sbin/sendmail");


=back

=head2 SMTP configuration

These options only take effect if C<$MailCommand> is 'smtp'

=over 4

=item C<$SMTPServer>

C<$SMTPServer> should be set to the hostname of the SMTP server to use

=cut

Set($SMTPServer, undef);

=item C<$SMTPFrom>

C<$SMTPFrom> should be set to the 'From' address to use, if not the
email's 'From'

=cut

Set($SMTPFrom, undef);

=item C<$SMTPDebug>

C<$SMTPDebug> should be set to 1 to debug SMTP mail sending

=cut

Set($SMTPDebug, 0);

=back

=head2 Other mailers

=over 4

=item C<@MailParams>

C<@MailParams> defines a list of options passed to $MailCommand if it
is not 'sendmailpipe', 'sendmail', or 'smtp'

=cut

Set(@MailParams, ());

=back


=head1 Web interface

=over 4

=item C<$WebDefaultStylesheet>

This determines the default stylesheet the RT web interface will use.
RT ships with several themes by default:

  web2            The default layout for RT 3.8
  aileron         The default layout for RT 4.0
  ballard         Theme which doesn't rely on JavaScript for menuing

This bundled distibution of RT also includes:
  freeside3       Integration with Freeside (enabled by default)
  freeside2.1     Previous Freeside theme

This value actually specifies a directory in F<share/html/NoAuth/css/>
from which RT will try to load the file main.css (which should @import
any other files the stylesheet needs).  This allows you to easily and
cleanly create your own stylesheets to apply to RT.  This option can
be overridden by users in their preferences.

=cut

Set($WebDefaultStylesheet, "freeside3");

=item C<$DefaultQueue>

Use this to select the default queue name that will be used for
creating new tickets. You may use either the queue's name or its
ID. This only affects the queue selection boxes on the web interface.

=cut

# Set($DefaultQueue, "General");

=item C<$RememberDefaultQueue>

When a queue is selected in the new ticket dropdown, make it the new
default for the new ticket dropdown.

=cut

# Set($RememberDefaultQueue, 1);

=item C<$EnableReminders>

Hide all links and portlets related to Reminders by setting this to 0

=cut

Set($EnableReminders, 1);

=item C<@CustomFieldValuesSources>

Set C<@CustomFieldValuesSources> to a list of class names which extend
L<RT::CustomFieldValues::External>.  This can be used to pull lists of
custom field values from external sources at runtime.

=cut

Set(@CustomFieldValuesSources, ('RT::CustomFieldValues::Queues'));

=item C<$CanonicalizeRedirectURLs>

Set C<$CanonicalizeRedirectURLs> to 1 to use C<$WebURL> when
redirecting rather than the one we get from C<%ENV>.

Apache's UseCanonicalName directive changes the hostname that RT
finds in C<%ENV>.  You can read more about what turning it On or Off
means in the documentation for your version of Apache.

If you use RT behind a reverse proxy, you almost certainly want to
enable this option.

=cut

Set($CanonicalizeRedirectURLs, 0);

=item C<@JSFiles>

A list of JavaScript files to be included in head.  Removing any of
the default entries is not suggested.

=cut

Set(@JSFiles, qw/
    jquery-1.4.2.min.js
    jquery_noconflict.js
    jquery-ui-1.8.4.custom.min.js
    jquery-ui-patch-datepicker.js
    ui.timepickr.js
    titlebox-state.js
    util.js
    userautocomplete.js
    jquery.event.hover-1.0.js
    superfish.js
    supersubs.js
    jquery.supposition.js
    history-folding.js
    late.js
/);

=item C<$JSMinPath>

Path to the jsmin binary; if specified, it will be used to minify
C<JSFiles>.  The default, and the fallback if the binary cannot be
found, is to simply concatenate the files.

jsmin can be installed by running 'make jsmin' from the RT install
directory, or from http://www.crockford.com/javascript/jsmin.html

=cut

# Set($JSMinPath, "/path/to/jsmin");

=item C<@CSSFiles>

A list of additional CSS files to be included in head.

=cut

Set(@CSSFiles, qw//);

=item C<$UsernameFormat>

This determines how user info is displayed. 'concise' will show one of
either NickName, RealName, Name or EmailAddress, depending on what
exists and whether the user is privileged or not. 'verbose' will show
RealName and EmailAddress.

=cut

Set($UsernameFormat, "verbose");

=item C<$WebBaseURL>, C<$WebURL>

Usually you don't want to set these options. The only obvious reason
is if RT is accessible via https protocol on a non standard port, e.g.
'https://rt.example.com:9999'. In all other cases these options are
computed using C<$WebDomain>, C<$WebPort> and C<$WebPath>.

C<$WebBaseURL> is the scheme, server and port
(e.g. 'http://rt.example.com') for constructing URLs to the web
UI. C<$WebBaseURL> doesn't need a trailing /.

C<$WebURL> is the C<$WebBaseURL>, C<$WebPath> and trailing /, for
example: 'http://www.example.com/rt/'.

=cut

my $port = RT->Config->Get('WebPort');
Set($WebBaseURL,
    ($port == 443? 'https': 'http') .'://'
    . RT->Config->Get('WebDomain')
    . ($port != 80 && $port != 443? ":$port" : '')
);

Set($WebURL, RT->Config->Get('WebBaseURL') . RT->Config->Get('WebPath') . "/");

=item C<$WebImagesURL>

C<$WebImagesURL> points to the base URL where RT can find its images.
Define the directory name to be used for images in RT web documents.

=cut

Set($WebImagesURL, RT->Config->Get('WebPath') . "/NoAuth/images/");

=item C<$LogoURL>

C<$LogoURL> points to the URL of the RT logo displayed in the web UI.
This can also be configured via the web UI.

=cut

Set($LogoURL, RT->Config->Get('WebImagesURL') . "bpslogo.png");

=item C<$LogoLinkURL>

C<$LogoLinkURL> is the URL that the RT logo hyperlinks to.

=cut

Set($LogoLinkURL, "http://bestpractical.com");

=item C<$LogoAltText>

C<$LogoAltText> is a string of text for the alt-text of the logo. It
will be passed through C<loc> for localization.

=cut

Set($LogoAltText, "Best Practical Solutions, LLC corporate logo");

=item C<$LogoImageHeight>

C<$LogoImageHeight> is the value of the C<height> attribute of the logo
C<img> tag.

=cut

Set($LogoImageHeight, 38);

=item C<$LogoImageWidth>

C<$LogoImageWidth> is the value of the C<width> attribute of the logo
C<img> tag.

=cut

Set($LogoImageWidth, 181);

=item C<$WebNoAuthRegex>

What portion of RT's URL space should not require authentication.  The
default is almost certainly correct, and should only be changed if you
are extending RT.

=cut

Set($WebNoAuthRegex, qr{^ /rt (?:/+NoAuth/ | /+REST/\d+\.\d+/NoAuth/) }x );

=item C<$SelfServiceRegex>

What portion of RT's URLspace should be accessible to Unprivileged
users This does not override the redirect from F</Ticket/Display.html>
to F</SelfService/Display.html> when Unprivileged users attempt to
access ticked displays.

=cut

Set($SelfServiceRegex, qr!^(?:/+SelfService/)!x );

=item C<$WebFlushDbCacheEveryRequest>

By default, RT clears its database cache after every page view.  This
ensures that you've always got the most current information when
working in a multi-process (mod_perl or FastCGI) Environment.  Setting
C<$WebFlushDbCacheEveryRequest> to 0 will turn this off, which will
speed RT up a bit, at the expense of a tiny bit of data accuracy.

=cut

Set($WebFlushDbCacheEveryRequest, 1);

=item C<%ChartFont>

The L<GD> module (which RT uses for graphs) ships with a built-in font
that doesn't have full Unicode support. You can use a given TrueType
font for a specific language by setting %ChartFont to (language =E<gt>
the absolute path of a font) pairs. Your GD library must have support
for TrueType fonts to use this option. If there is no entry for a
language in the hash then font with 'others' key is used.

RT comes with two TrueType fonts covering most available languages.

=cut

Set(
    %ChartFont,
    'zh-cn'  => "$RT::BasePath/share/fonts/DroidSansFallback.ttf",
    'zh-tw'  => "$RT::BasePath/share/fonts/DroidSansFallback.ttf",
    'ja'     => "$RT::BasePath/share/fonts/DroidSansFallback.ttf",
    'others' => "$RT::BasePath/share/fonts/DroidSans.ttf",
);

=item C<$ChartsTimezonesInDB>

RT stores dates using the UTC timezone in the DB, so charts grouped by
dates and time are not representative. Set C<$ChartsTimezonesInDB> to 1
to enable timezone conversions using your DB's capabilities. You may
need to do some work on the DB side to use this feature, read more in
F<docs/customizing/timezones_in_charts.pod>.

At this time, this feature only applies to MySQL and PostgreSQL.

=cut

Set($ChartsTimezonesInDB, 0);

=back



=head2 Home page

=over 4

=item C<$DefaultSummaryRows>

C<$DefaultSummaryRows> is default number of rows displayed in for
search results on the front page.

=cut

Set($DefaultSummaryRows, 10);

=item C<$HomePageRefreshInterval>

C<$HomePageRefreshInterval> is default number of seconds to refresh
the RT home page. Choose from [0, 120, 300, 600, 1200, 3600, 7200].

=cut

Set($HomePageRefreshInterval, 0);

=item C<$HomepageComponents>

C<$HomepageComponents> is an arrayref of allowed components on a
user's customized homepage ("RT at a glance").

=cut

Set($HomepageComponents, [qw(QuickCreate Quicksearch MyCalendar MyAdminQueues MySupportQueues MyReminders RefreshHomepage Dashboards SavedSearches)]);

=back




=head2 Ticket search

=over 4

=item C<$UseSQLForACLChecks>

Historically, ACLs were checked on display, which could lead to empty
search pages and wrong ticket counts.  Set C<$UseSQLForACLChecks> to 1
to limit search results in SQL instead, which eliminates these
problems.

This option is still relatively new; it may result in performance
problems in some cases, or significant speedups in others.

=cut

Set($UseSQLForACLChecks, undef);

=item C<$TicketsItemMapSize>

On the display page of a ticket from search results, RT provides links
to the first, next, previous and last ticket from the results.  In
order to build these links, RT needs to fetch the full result set from
the database, which can be resource-intensive.

Set C<$TicketsItemMapSize> to number of tickets you want RT to examine
to build these links. If the full result set is larger than this
number, RT will omit the "last" link in the menu.  Set this to zero to
always examine all results.

=cut

Set($TicketsItemMapSize, 1000);

=item C<$SearchResultsRefreshInterval>

C<$SearchResultsRefreshInterval> is default number of seconds to
refresh search results in RT. Choose from [0, 120, 300, 600, 1200,
3600, 7200].

=cut

Set($SearchResultsRefreshInterval, 0);

=item C<$DefaultSearchResultFormat>

C<$DefaultSearchResultFormat> is the default format for RT search
results

=cut

Set ($DefaultSearchResultFormat, qq{
   '<B><A HREF="__WebPath__/Ticket/Display.html?id=__id__">__id__</a></B>/TITLE:#',
   '<B><A HREF="__WebPath__/Ticket/Display.html?id=__id__">__Subject__</a></B>/TITLE:Subject',
   Customer,
   Status,
   QueueName,
   OwnerName,
   Priority,
   '__NEWLINE__',
   '',
   '<small>__Requestors__</small>',
   '<small>__CustomerTags__</small>',
   '<small>__CreatedRelative__</small>',
   '<small>__ToldRelative__</small>',
   '<small>__LastUpdatedRelative__</small>',
   '<small>__TimeLeft__</small>'});

=item C<$DefaultSelfServiceSearchResultFormat>

C<$DefaultSelfServiceSearchResultFormat> is the default format of
searches displayed in the SelfService interface.

=cut

Set($DefaultSelfServiceSearchResultFormat, qq{
   '<B><A HREF="__WebPath__/SelfService/Display.html?id=__id__">__id__</a></B>/TITLE:#',
   '<B><A HREF="__WebPath__/SelfService/Display.html?id=__id__">__Subject__</a></B>/TITLE:Subject',
   Status,
   Requestors,
   OwnerName});

=item C<%FullTextSearch>

Full text search (FTS) without database indexing is a very slow
operation, and is thus disabled by default.

Before setting C<Indexed> to 1, read F<docs/full_text_indexing.pod> for
the full details of FTS on your particular database.

It is possible to enable FTS without database indexing support, simply
by setting the C<Enable> key to 1, while leaving C<Indexed> set to 0.
This is not generally suggested, as unindexed full-text searching can
cause severe performance problems.

=cut

Set(%FullTextSearch,
    Enable  => 0,
    Indexed => 0,
);


=item C<$OnlySearchActiveTicketsInSimpleSearch>

When query in simple search doesn't have status info, use this to only
search active ones.

=cut

Set($OnlySearchActiveTicketsInSimpleSearch, 1);

=item C<$SearchResultsAutoRedirect>

When only one ticket is found in search, use this to redirect to the
ticket display page automatically.

=cut

Set($SearchResultsAutoRedirect, 0);

=back



=head2 Ticket display

=over 4

=item C<$ShowMoreAboutPrivilegedUsers>

This determines if the 'More about requestor' box on
Ticket/Display.html is shown for Privileged Users.

=cut

Set($ShowMoreAboutPrivilegedUsers, 0);

=item C<$MoreAboutRequestorTicketList>

This can be set to Active, Inactive, All or None.  It controls what
ticket list will be displayed in the 'More about requestor' box on
Ticket/Display.html.  This option can be controlled by users also.

=cut

Set($MoreAboutRequestorTicketList, "Active");

=item C<$MoreAboutRequestorExtraInfo>

By default, the 'More about requestor' box on Ticket/Display.html
shows the Requestor's name and ticket list.  If you would like to see
extra information about the user, this expects a Format string of user
attributes.  Please note that not all the attributes are supported in
this display because we're not building a table.

Example:
C<Set($MoreAboutRequestorExtraInfo,"Organization, Address1")>

=cut

Set($MoreAboutRequestorExtraInfo, "");

=item C<$MoreAboutRequestorGroupsLimit>

By default, the 'More about requestor' box on Ticket/Display.html
shows all the groups of the Requestor.  Use this to limit the number
of groups; a value of undef removes the group display entirely.

=cut

Set($MoreAboutRequestorGroupsLimit, 0);

=item C<$UseSideBySideLayout>

Should the ticket create and update forms use a more space efficient
two column layout.  This layout may not work in narrow browsers if you
set a MessageBoxWidth (below).

=cut

Set($UseSideBySideLayout, 1);

=item C<$EditCustomFieldsSingleColumn>

When displaying a list of Ticket Custom Fields for editing, RT
defaults to a 2 column list.  If you set this to 1, it will instead
display the Custom Fields in a single column.

=cut

Set($EditCustomFieldsSingleColumn, 0);

=item C<$ShowUnreadMessageNotifications>

If set to 1, RT will prompt users when there are new,
unread messages on tickets they are viewing.

=cut

Set($ShowUnreadMessageNotifications, 0);

=item C<$AutocompleteOwners>

If set to 1, the owner drop-downs for ticket update/modify and the query
builder are replaced by text fields that autocomplete.  This can
alleviate the sometimes huge owner list for installations where many
users have the OwnTicket right.

=cut

Set($AutocompleteOwners, 0);

=item C<$AutocompleteOwnersForSearch>

If set to 1, the owner drop-downs for the query builder are always
replaced by text field that autocomplete and C<$AutocompleteOwners>
is ignored. Helpful when owners list is huge in the query builder.

=cut

Set($AutocompleteOwnersForSearch, 0);

=item C<$UserAutocompleteFields>

Specifies which fields of L<RT::User> to match against and how to
match each field when autocompleting users.  Valid match methods are
LIKE, STARTSWITH, ENDSWITH, =, and !=.

=cut

Set($UserAutocompleteFields, {
    EmailAddress => 'STARTSWITH',
    Name         => 'STARTSWITH',
    RealName     => 'LIKE',
});

=item C<$AllowUserAutocompleteForUnprivileged>

Should unprivileged users be allowed to autocomplete users.  Setting
this option to 1 means unprivileged users will be able to search all
your users.

=cut

Set($AllowUserAutocompleteForUnprivileged, 0);

=item C<$DisplayTicketAfterQuickCreate>

Enable this to redirect to the created ticket display page
automatically when using QuickCreate.

=cut

Set($DisplayTicketAfterQuickCreate, 0);

=item C<$WikiImplicitLinks>

Support implicit links in WikiText custom fields?  Setting this to 1
causes InterCapped or ALLCAPS words in WikiText fields to automatically
become links to searches for those words.  If used on Articles, it links
to the Article with that name.

=cut

Set($WikiImplicitLinks, 0);

=item C<$PreviewScripMessages>

Set C<$PreviewScripMessages> to 1 if the scrips preview on the ticket
reply page should include the content of the messages to be sent.

=cut

Set($PreviewScripMessages, 0);

=item C<$SimplifiedRecipients>

If C<$SimplifiedRecipients> is set, a simple list of who will receive
B<any> kind of mail will be shown on the ticket reply page, instead of a
detailed breakdown by scrip.

=cut

Set($SimplifiedRecipients, 0);

=item C<$HideResolveActionsWithDependencies>

If set to 1, this option will skip ticket menu actions which can't be
completed successfully because of outstanding active Depends On tickets.

By default, all ticket actions are displayed in the menu even if some of
them can't be successful until all Depends On links are resolved or
transitioned to another inactive status.

=cut

Set($HideResolveActionsWithDependencies, 0);

=back



=head2 Articles

=over 4

=item C<$ArticleOnTicketCreate>

Set this to 1 to display the Articles interface on the Ticket Create
page in addition to the Reply/Comment page.

=cut

Set($ArticleOnTicketCreate, 0);

=item C<$HideArticleSearchOnReplyCreate>

Set this to 1 to hide the search and include boxes from the Article
UI.  This assumes you have enabled Article Hotlist feature, otherwise
you will have no access to Articles.

=cut

Set($HideArticleSearchOnReplyCreate, 0);

=back



=head2 Message box properties

=over 4

=item C<$MessageBoxWidth>, C<$MessageBoxHeight>

For message boxes, set the entry box width, height and what type of
wrapping to use.  These options can be overridden by users in their
preferences.

When the width is set to undef, no column count is specified and the
message box will take up 100% of the available width.  Combining this
with HARD messagebox wrapping (below) is not recommended, as it will
lead to inconsistent width in transactions between browsers.

These settings only apply to the non-RichText message box.  See below
for Rich Text settings.

=cut

Set($MessageBoxWidth, undef);
Set($MessageBoxHeight, 15);

=item C<$MessageBoxWrap>

Wrapping is disabled when using MessageBoxRichText because of a bad
interaction between IE and wrapping with the Rich Text Editor.

=cut

Set($MessageBoxWrap, "SOFT");

=item C<$MessageBoxRichText>

Should "rich text" editing be enabled? This option lets your users
send HTML email messages from the web interface.

=cut

Set($MessageBoxRichText, 1);

=item C<$MessageBoxRichTextHeight>

Height of rich text JavaScript enabled editing boxes (in pixels)

=cut

Set($MessageBoxRichTextHeight, 200);

=item C<$MessageBoxIncludeSignature>

Should your users' signatures (from their Preferences page) be
included in Comments and Replies.

=cut

Set($MessageBoxIncludeSignature, 1);

=item C<$MessageBoxIncludeSignatureOnComment>

Should your users' signatures (from their Preferences page) be
included in Comments. Setting this to false overrides
C<$MessageBoxIncludeSignature>.

=cut

Set($MessageBoxIncludeSignatureOnComment, 1);

=back


=head2 Transaction display

=over 4

=item C<$OldestTransactionsFirst>

By default, RT shows newest transactions at the bottom of the ticket
history page, if you want see them at the top set this to 0.  This
option can be overridden by users in their preferences.

=cut

Set($OldestTransactionsFirst, 1);

=item C<$DeferTransactionLoading>

When set, defers loading ticket history until the user clicks a link.
This should end up serving pages to users quicker, since generating
all the HTML for transaction history can be slow for long tickets.

=cut

# Set($DeferTransactionLoading, 1);

=item C<$ShowBccHeader>

By default, RT hides from the web UI information about blind copies
user sent on reply or comment.

=cut

Set($ShowBccHeader, 0);

=item C<$TrustHTMLAttachments>

If C<TrustHTMLAttachments> is not defined, we will display them as
text. This prevents malicious HTML and JavaScript from being sent in a
request (although there is probably more to it than that)

=cut

Set($TrustHTMLAttachments, undef);

=item C<$AlwaysDownloadAttachments>

Always download attachments, regardless of content type. If set, this
overrides C<TrustHTMLAttachments>.

=cut

Set($AlwaysDownloadAttachments, undef);

=item C<$AttachmentUnits>

Controls the units (kilobytes or bytes) that attachment sizes use for
display. The default is to display kilobytes if the attachment is
larger than 1024 bytes, bytes otherwise. If you set
C<$AttachmentUnits> to C<'k'> then attachment sizes will always be
displayed in kilobytes. If set to C<'b'>, then sizes will be bytes.

=cut

Set($AttachmentUnits, undef);

=item C<$PreferRichText>

If C<$PreferRichText> is set to 1, RT will show HTML/Rich text messages
in preference to their plain-text alternatives. RT "scrubs" the HTML to
show only a minimal subset of HTML to avoid possible contamination by
cross-site-scripting attacks.

=cut

Set($PreferRichText, undef);

=item C<$MaxInlineBody>

C<$MaxInlineBody> is the maximum attachment size that we want to see
inline when viewing a transaction.  RT will inline any text if the
value is undefined or 0.  This option can be overridden by users in
their preferences.

=cut

Set($MaxInlineBody, 12000);

=item C<$ShowTransactionImages>

By default, RT shows images attached to incoming (and outgoing) ticket
updates inline. Set this variable to 0 if you'd like to disable that
behavior.

=cut

Set($ShowTransactionImages, 1);

=item C<$PlainTextPre>

Normally plaintext attachments are displayed as HTML with line breaks
preserved.  This causes space- and tab-based formatting not to be
displayed correctly.  By setting $PlainTextPre messages will be
displayed using <pre>.

=cut

Set($PlainTextPre, 0);


=item C<$PlainTextMono>

Set C<$PlainTextMono> to 1 to use monospaced font and preserve
formatting; unlike C<$PlainTextPre>, the text will wrap to fit width
of the browser window; this option overrides C<$PlainTextPre>.

=cut

Set($PlainTextMono, 0);

=item C<$SuppressInlineTextFiles>

If C<$SuppressInlineTextFiles> is set to 1, then uploaded text files
(text-type attachments with file names) are prevented from being
displayed in-line when viewing a ticket's history.

=cut

Set($SuppressInlineTextFiles, undef);


=item C<@Active_MakeClicky>

MakeClicky detects various formats of data in headers and email
messages, and extends them with supporting links.  By default, RT
provides two formats:

* 'httpurl': detects http:// and https:// URLs and adds '[Open URL]'
  link after the URL.

* 'httpurl_overwrite': also detects URLs as 'httpurl' format, but
  replaces the URL with a link.

See F<share/html/Elements/MakeClicky> for documentation on how to add
your own styles of link detection.

=cut

Set(@Active_MakeClicky, qw());

=back



=head1 Application logic

=over 4

=item C<$ParseNewMessageForTicketCcs>

If C<$ParseNewMessageForTicketCcs> is set to 1, RT will attempt to
divine Ticket 'Cc' watchers from the To and Cc lines of incoming
messages.  Be forewarned that if you have I<any> addresses which forward
mail to RT automatically and you enable this option without modifying
C<$RTAddressRegexp> below, you will get yourself into a heap of trouble.

=cut

Set($ParseNewMessageForTicketCcs, undef);

=item C<$UseTransactionBatch>

Set C<$UseTransactionBatch> to 1 to execute transactions in batches,
such that a resolve and comment (for example) would happen
simultaneously, instead of as two transactions, unaware of each
others' existence.

=cut

Set($UseTransactionBatch, 1);

=item C<$StrictLinkACL>

When this feature is enabled a user needs I<ModifyTicket> rights on
both tickets to link them together; otherwise, I<ModifyTicket> rights
on either of them is sufficient.

=cut

Set($StrictLinkACL, 1);

=item C<$RedistributeAutoGeneratedMessages>

Should RT redistribute correspondence that it identifies as machine
generated?  A 1 will do so; setting this to 0 will cause no
such messages to be redistributed.  You can also use 'privileged' (the
default), which will redistribute only to privileged users. This helps
to protect against malformed bounces and loops caused by auto-created
requestors with bogus addresses.

=cut

Set($RedistributeAutoGeneratedMessages, "privileged");

=item C<$ApprovalRejectionNotes>

Should rejection notes from approvals be sent to the requestors?

=cut

Set($ApprovalRejectionNotes, 1);

=item C<$ForceApprovalsView>

Should approval tickets only be viewed and modified through the standard
approval interface?  Changing this setting to 1 will redirect any attempt to
use the normal ticket display and modify page for approval tickets.

For example, with this option set to 1 and an approval ticket #123:

    /Ticket/Display.html?id=123

is redirected to

    /Approval/Display.html?id=123

=back

=cut

Set($ForceApprovalsView, 0);

=head1 Extra security

=over 4

This is a list of extra security measures to enable that help keep your RT
safe.  If you don't know what these mean, you should almost certainly leave the
defaults alone.

=item C<$DisallowExecuteCode>

If set to a true value, the C<ExecuteCode> right will be removed from
all users, B<including> the superuser.  This is intended for when RT is
installed into a shared environment where even the superuser should not
be allowed to run arbitrary Perl code on the server via scrips.

=cut

Set($DisallowExecuteCode, 0);

=item C<$Framebusting>

If set to a false value, framekiller javascript will be disabled and the
X-Frame-Options: DENY header will be suppressed from all responses.
This disables RT's clickjacking protection.

=cut

Set($Framebusting, 1);

=back

=head1 Authorization and user configuration

=over 4

=item C<$WebExternalAuth>

If C<$WebExternalAuth> is defined, RT will defer to the environment's
REMOTE_USER variable.

=cut

Set($WebExternalAuth, undef);

=item C<$WebExternalAuthContinuous>

If C<$WebExternalAuthContinuous> is defined, RT will check for the
REMOTE_USER on each access.  If you would prefer this to only happen
once (at initial login) set this to a false value.  The default
setting will help ensure that if your external authentication system
deauthenticates a user, RT notices as soon as possible.

=cut

Set($WebExternalAuthContinuous, 1);

=item C<$WebFallbackToInternalAuth>

If C<$WebFallbackToInternalAuth> is defined, the user is allowed a
chance of fallback to the login screen, even if REMOTE_USER failed.

=cut

Set($WebFallbackToInternalAuth, undef);

=item C<$WebExternalGecos>

C<$WebExternalGecos> means to match 'gecos' field as the user
identity); useful with mod_auth_pwcheck and IIS Integrated Windows
logon.

=cut

Set($WebExternalGecos, undef);

=item C<$WebExternalAuto>

C<$WebExternalAuto> will create users under the same name as
REMOTE_USER upon login, if it's missing in the Users table.

=cut

Set($WebExternalAuto, undef);

=item C<$AutoCreate>

If C<$WebExternalAuto> is set to 1, C<$AutoCreate> will be passed to
User's Create method.  Use it to set defaults, such as creating
Unprivileged users with C<{ Privileged => 0 }> This must be a hashref.

=cut

Set($AutoCreate, undef);

=item C<$WebSessionClass>

C<$WebSessionClass> is the class you wish to use for managing
Sessions.  It defaults to use your SQL database, but if you are using
MySQL 3.x and plans to use non-ascii Queue names, uncomment and add
this line to F<RT_SiteConfig.pm> to prevent session corruption.

=cut

# Set($WebSessionClass, "Apache::Session::File");

=item C<$AutoLogoff>

By default, RT's user sessions persist until a user closes his or her
browser. With the C<$AutoLogoff> option you can setup session lifetime
in minutes. A user will be logged out if he or she doesn't send any
requests to RT for the defined time.

=cut

Set($AutoLogoff, 0);

=item C<$LogoutRefresh>

The number of seconds to wait after logout before sending the user to
the login page. By default, 1 second, though you may want to increase
this if you display additional information on the logout page.

=cut

Set($LogoutRefresh, 1);

=item C<$WebSecureCookies>

By default, RT's session cookie isn't marked as "secure". Some web
browsers will treat secure cookies more carefully than non-secure
ones, being careful not to write them to disk, only sending them over
an SSL secured connection, and so on. To enable this behavior, set
C<$WebSecureCookies> to 1.  NOTE: You probably don't want to turn this
on I<unless> users are only connecting via SSL encrypted HTTPS
connections.

=cut

Set($WebSecureCookies, 0);

=item C<$WebHttpOnlyCookies>

Default RT's session cookie to not being directly accessible to
javascript.  The content is still sent during regular and AJAX requests,
and other cookies are unaffected, but the session-id is less
programmatically accessible to javascript.  Turning this off should only
be necessary in situations with odd client-side authentication
requirements.

=cut

Set($WebHttpOnlyCookies, 1);

=item C<$MinimumPasswordLength>

C<$MinimumPasswordLength> defines the minimum length for user
passwords. Setting it to 0 disables this check.

=cut

Set($MinimumPasswordLength, 5);

=back


=head1 Internationalization

=over 4

=item C<@LexiconLanguages>

An array that contains languages supported by RT's
internationalization interface.  Defaults to all *.po lexicons;
setting it to C<qw(en ja)> will make RT bilingual instead of
multilingual, but will save some memory.

=cut

Set(@LexiconLanguages, qw(*));

=item C<@EmailInputEncodings>

An array that contains default encodings used to guess which charset
an attachment uses, if it does not specify one explicitly.  All
options must be recognized by L<Encode::Guess>.  The first element may
also be '*', which enables encoding detection using
L<Encode::Detect::Detector>, if installed.

=cut

Set(@EmailInputEncodings, qw(utf-8 iso-8859-1 us-ascii));

=item C<$EmailOutputEncoding>

The charset for localized email.  Must be recognized by Encode.

=cut

Set($EmailOutputEncoding, "utf-8");

=back







=head1 Date and time handling

=over 4

=item C<$DateTimeFormat>

You can choose date and time format.  See the "Output formatters"
section in perldoc F<lib/RT/Date.pm> for more options.  This option
can be overridden by users in their preferences.

Some examples:

C<Set($DateTimeFormat, "LocalizedDateTime");>
C<Set($DateTimeFormat, { Format => "ISO", Seconds => 0 });>
C<Set($DateTimeFormat, "RFC2822");>
C<Set($DateTimeFormat, { Format => "RFC2822", Seconds => 0, DayOfWeek => 0 });>

=cut

Set($DateTimeFormat, "DefaultFormat");

# Next two options are for Time::ParseDate

=item C<$DateDayBeforeMonth>

Set this to 1 if your local date convention looks like "dd/mm/yy"
instead of "mm/dd/yy". Used only for parsing, not for displaying
dates.

=cut

Set($DateDayBeforeMonth, 1);

=item C<$AmbiguousDayInPast>, C<$AmbiguousDayInFuture>

Should an unspecified day or year in a date refer to a future or a
past value? For example, should a date of "Tuesday" default to mean
the date for next Tuesday or last Tuesday? Should the date "March 1"
default to the date for next March or last March?

Set C<$AmbiguousDayInPast> for the last date, or
C<$AmbiguousDayInFuture> for the next date; the default is usually
correct.  If both are set, C<$AmbiguousDayInPast> takes precedence.

=cut

Set($AmbiguousDayInPast, 0);
Set($AmbiguousDayInFuture, 0);

=item C<$DefaultTimeUnitsToHours>

Use this to set the default units for time entry to hours instead of
minutes.  Note that this only effects entry, not display.

=cut

Set($DefaultTimeUnitsToHours, 0);

=item C<$SimpleSearchIncludeResolved>

By default, the simple ticket search in the top bar excludes "resolved" tickets
unless a status argument is specified.  Set this to a true value to include 
them.

=cut

Set($SimpleSearchIncludeResolved, 0);

=back




=head1 GnuPG integration

A full description of the (somewhat extensive) GnuPG integration can
be found by running the command `perldoc L<RT::Crypt::GnuPG>` (or
`perldoc lib/RT/Crypt/GnuPG.pm` from your RT install directory).

=over 4

=item C<%GnuPG>

Set C<OutgoingMessagesFormat> to 'inline' to use inline encryption and
signatures instead of 'RFC' (GPG/MIME: RFC3156 and RFC1847) format.

If you want to allow people to encrypt attachments inside the DB then
set C<AllowEncryptDataInDB> to 1.

Set C<RejectOnMissingPrivateKey> to false if you don't want to reject
emails encrypted for key RT doesn't have and can not decrypt.

Set C<RejectOnBadData> to false if you don't want to reject letters
with incorrect GnuPG data.

=cut

Set(%GnuPG,
    Enable => 1,
    OutgoingMessagesFormat => "RFC", # Inline
    AllowEncryptDataInDB   => 0,

    RejectOnMissingPrivateKey => 1,
    RejectOnBadData           => 1,
);

=item C<%GnuPGOptions>

Options to pass to the GnuPG program.

If you override this in your RT_SiteConfig, you should be sure to
include a homedir setting.

Note that options with '-' character MUST be quoted.

=cut

Set(%GnuPGOptions,
    homedir => q{/opt/rt3/var/data/gpg},

# URL of a keyserver
#    keyserver => 'hkp://subkeys.pgp.net',

# enables the automatic retrieving of keys when encrypting
#    'auto-key-locate' => 'keyserver',

# enables the automatic retrieving of keys when verifying signatures
#    'auto-key-retrieve' => undef,
);

=back



=head1 Lifecycles

=head2 Lifecycle definitions

Each lifecycle is a list of possible statuses split into three logic
sets: B<initial>, B<active> and B<inactive>. Each status in a
lifecycle must be unique. (Statuses may not be repeated across sets.)
Each set may have any number of statuses.

For example:

    default => {
        initial  => ['new'],
        active   => ['open', 'stalled'],
        inactive => ['resolved', 'rejected', 'deleted'],
        ...
    },

Status names can be from 1 to 64 ASCII characters.  Statuses are
localized using RT's standard internationalization and localization
system.

=over 4

=item initial

You can define multiple B<initial> statuses for tickets in a given
lifecycle.

RT will automatically set its B<Started> date when you change a
ticket's status from an B<initial> state to an B<active> or
B<inactive> status.

=item active

B<Active> tickets are "currently in play" - they're things that are
being worked on and not yet complete.

=item inactive

B<Inactive> tickets are typically in their "final resting state".

While you're free to implement a workflow that ignores that
description, typically once a ticket enters an inactive state, it will
never again enter an active state.

RT will automatically set the B<Resolved> date when a ticket's status
is changed from an B<Initial> or B<Active> status to an B<Inactive>
status.

B<deleted> is still a special status and protected by the
B<DeleteTicket> right, unless you re-defined rights (read below). If
you don't want to allow ticket deletion at any time simply don't
include it in your lifecycle.

=back

Statuses in each set are ordered and listed in the UI in the defined
order.

Changes between statuses are constrained by transition rules, as
described below.

=head2 Default values

In some cases a default value is used to display in UI or in API when
value is not provided. You can configure defaults using the following
syntax:

    default => {
        ...
        defaults => {
            on_create => 'new',
            on_resolve => 'resolved',
            ...
        },
    },

The following defaults are used.

=over 4

=item on_create

If you (or your code) doesn't specify a status when creating a ticket,
RT will use the this status. See also L</Statuses available during
ticket creation>.

=item on_merge

When tickets are merged, the status of the ticket that was merged
away is forced to this value.  It should be one of inactive statuses;
'resolved' or its equivalent is most probably the best candidate.

=item approved

When an approval is accepted, the status of depending tickets will
be changed to this value.

=item denied

When an approval is denied, the status of depending tickets will
be changed to this value.

=back

=head2 Transitions between statuses and UI actions

A B<Transition> is a change of status from A to B. You should define
all possible transitions in each lifecycle using the following format:

    default => {
        ...
        transitions => {
            ''       => [qw(new open resolved)],
            new      => [qw(open resolved rejected deleted)],
            open     => [qw(stalled resolved rejected deleted)],
            stalled  => [qw(open)],
            resolved => [qw(open)],
            rejected => [qw(open)],
            deleted  => [qw(open)],
        },
        ...
    },

=head3 Statuses available during ticket creation

By default users can create tickets with any status, except
deleted. If you want to restrict statuses available during creation
then describe transition from '' (empty string), like in the example
above.

=head3 Protecting status changes with rights

A transition or group of transitions can be protected by a specific
right.  Additionally, you can name new right names, which will be added
to the system to control that transition.  For example, if you wished to
create a lesser right than ModifyTicket for rejecting tickets, you could
write:

    default => {
        ...
        rights => {
            '* -> deleted'  => 'DeleteTicket',
            '* -> rejected' => 'RejectTicket',
            '* -> *'        => 'ModifyTicket',
        },
        ...
    },

This would create a new C<RejectTicket> right in the system which you
could assign to whatever groups you choose.

On the left hand side you can have the following variants:

    '<from> -> <to>'
    '* -> <to>'
    '<from> -> *'
    '* -> *'

Valid transitions are listed in order of priority. If a user attempts
to change a ticket's status from B<new> to B<open> then the lifecycle
is checked for presence of an exact match, then for 'any to B<open>',
'B<new> to any' and finally 'any to any'.

If you don't define any rights, or there is no match for a transition,
RT will use the B<DeleteTicket> or B<ModifyTicket> as appropriate.

=head3 Labeling and defining actions

For each transition you can define an action that will be shown in the
UI; each action annotated with a label and an update type.

Each action may provide a default update type, which can be
B<Comment>, B<Respond>, or absent. For example, you may want your
staff to write a reply to the end user when they change status from
B<new> to B<open>, and thus set the update to B<Respond>.  Neither
B<Comment> nor B<Respond> are mandatory, and user may leave the
message empty, regardless of the update type.

This configuration can be used to accomplish what
$ResolveDefaultUpdateType was used for in RT 3.8.

Use the following format to define labels and actions of transitions:

    default => {
        ...
        actions => [
            'new -> open'     => { label => 'Open it', update => 'Respond' },
            'new -> resolved' => { label => 'Resolve', update => 'Comment' },
            'new -> rejected' => { label => 'Reject',  update => 'Respond' },
            'new -> deleted'  => { label => 'Delete' },

            'open -> stalled'  => { label => 'Stall',   update => 'Comment' },
            'open -> resolved' => { label => 'Resolve', update => 'Comment' },
            'open -> rejected' => { label => 'Reject',  update => 'Respond' },

            'stalled -> open'  => { label => 'Open it' },
            'resolved -> open' => { label => 'Re-open', update => 'Comment' },
            'rejected -> open' => { label => 'Re-open', update => 'Comment' },
            'deleted -> open'  => { label => 'Undelete' },
        ],
        ...
    },

In addition, you may define multiple actions for the same transition.
Alternately, you may use '* -> x' to match more than one transition.
For example:

    default => {
        ...
        actions => [
            ...
            'new -> rejected' => { label => 'Reject', update => 'Respond' },
            'new -> rejected' => { label => 'Quick Reject' },
            ...
            '* -> deleted' => { label => 'Delete' },
            ...
        ],
        ...
    },

=head2 Moving tickets between queues with different lifecycles

Unless there is an explicit mapping between statuses in two different
lifecycles, you can not move tickets between queues with these
lifecycles.  This is true even if the different lifecycles use the exact
same set of statuses.  Such a mapping is defined as follows:

    __maps__ => {
        'from lifecycle -> to lifecycle' => {
            'status in left lifecycle' => 'status in right lifecycle',
            ...
        },
        ...
    },

=cut

Set(%Lifecycles,
    default => {
        initial         => [ 'new' ],
        active          => [ 'open', 'stalled' ],
        inactive        => [ 'resolved', 'rejected', 'deleted' ],

        defaults => {
            on_create => 'new',
            on_merge  => 'resolved',
            approved  => 'open',
            denied    => 'rejected',
        },

        transitions => {
            ''       => [qw(new open resolved)],

            # from   => [ to list ],
            new      => [qw(open stalled resolved rejected deleted)],
            open     => [qw(new stalled resolved rejected deleted)],
            stalled  => [qw(new open rejected resolved deleted)],
            resolved => [qw(new open stalled rejected deleted)],
            rejected => [qw(new open stalled resolved deleted)],
            deleted  => [qw(new open stalled rejected resolved)],
        },
        rights => {
            '* -> deleted'  => 'DeleteTicket',
            '* -> *'        => 'ModifyTicket',
        },
        actions => [
            'new -> open'      => {
                label  => 'Open It', # loc
                update => 'Respond',
            },
            'new -> resolved'  => {
                label  => 'Resolve', # loc
                update => 'Comment',
            },
            'new -> rejected'  => {
                label  => 'Reject', # loc
                update => 'Respond',
            },
            'new -> deleted'   => {
                label  => 'Delete', # loc
            },

            'open -> stalled'  => {
                label  => 'Stall', # loc
                update => 'Comment',
            },
            'open -> resolved' => {
                label  => 'Resolve', # loc
                update => 'Comment',
            },
            'open -> rejected' => {
                label  => 'Reject', # loc
                update => 'Respond',
            },

            'stalled -> open'  => {
                label  => 'Open It', # loc
            },
            'resolved -> open' => {
                label  => 'Re-open', # loc
                update => 'Comment',
            },
            'rejected -> open' => {
                label  => 'Re-open', # loc
                update => 'Comment',
            },
            'deleted -> open'  => {
                label  => 'Undelete', # loc
            },
        ],
    },
# don't change lifecyle of the approvals, they are not capable to deal with
# custom statuses
    approvals => {
        initial         => [ 'new' ],
        active          => [ 'open', 'stalled' ],
        inactive        => [ 'resolved', 'rejected', 'deleted' ],

        defaults => {
            on_create => 'new',
            on_merge => 'resolved',
        },

        transitions => {
            ''       => [qw(new open resolved)],

            # from   => [ to list ],
            new      => [qw(open stalled resolved rejected deleted)],
            open     => [qw(new stalled resolved rejected deleted)],
            stalled  => [qw(new open rejected resolved deleted)],
            resolved => [qw(new open stalled rejected deleted)],
            rejected => [qw(new open stalled resolved deleted)],
            deleted  => [qw(new open stalled rejected resolved)],
        },
        rights => {
            '* -> deleted'  => 'DeleteTicket',
            '* -> rejected' => 'ModifyTicket',
            '* -> *'        => 'ModifyTicket',
        },
        actions => [
            'new -> open'      => {
                label  => 'Open It', # loc
                update => 'Respond',
            },
            'new -> resolved'  => {
                label  => 'Resolve', # loc
                update => 'Comment',
            },
            'new -> rejected'  => {
                label  => 'Reject', # loc
                update => 'Respond',
            },
            'new -> deleted'   => {
                label  => 'Delete', # loc
            },

            'open -> stalled'  => {
                label  => 'Stall', # loc
                update => 'Comment',
            },
            'open -> resolved' => {
                label  => 'Resolve', # loc
                update => 'Comment',
            },
            'open -> rejected' => {
                label  => 'Reject', # loc
                update => 'Respond',
            },

            'stalled -> open'  => {
                label  => 'Open It', # loc
            },
            'resolved -> open' => {
                label  => 'Re-open', # loc
                update => 'Comment',
            },
            'rejected -> open' => {
                label  => 'Re-open', # loc
                update => 'Comment',
            },
            'deleted -> open'  => {
                label  => 'Undelete', # loc
            },
        ],
    },
);





=head1 Administrative interface

=over 4

=item C<$ShowRTPortal>

RT can show administrators a feed of recent RT releases and other
related announcements and information from Best Practical on the top
level Configuration page.  This feature helps you stay up to date on
RT security announcements and version updates.

RT provides this feature using an "iframe" on C</Admin/index.html>
which asks the administrator's browser to show an inline page from
Best Practical's website.

If you'd rather not make this feature available to your
administrators, set C<$ShowRTPortal> to a false value.

=cut

Set($ShowRTPortal, 1);

=item C<%AdminSearchResultFormat>

In the admin interface, format strings similar to tickets result
formats are used. Use C<%AdminSearchResultFormat> to define the format
strings used in the admin interface on a per-RT-class basis.

=cut

Set(%AdminSearchResultFormat,
    Queues =>
        q{'<a href="__WebPath__/Admin/Queues/Modify.html?id=__id__">__id__</a>/TITLE:#'}
        .q{,'<a href="__WebPath__/Admin/Queues/Modify.html?id=__id__">__Name__</a>/TITLE:Name'}
        .q{,__Description__,__Address__,__Priority__,__DefaultDueIn__,__Disabled__},

    Groups =>
        q{'<a href="__WebPath__/Admin/Groups/Modify.html?id=__id__">__id__</a>/TITLE:#'}
        .q{,'<a href="__WebPath__/Admin/Groups/Modify.html?id=__id__">__Name__</a>/TITLE:Name'}
        .q{,'__Description__'},

    Users =>
        q{'<a href="__WebPath__/Admin/Users/Modify.html?id=__id__">__id__</a>/TITLE:#'}
        .q{,'<a href="__WebPath__/Admin/Users/Modify.html?id=__id__">__Name__</a>/TITLE:Name'}
        .q{,__RealName__, __EmailAddress__},

    CustomFields =>
        q{'<a href="__WebPath__/Admin/CustomFields/Modify.html?id=__id__">__id__</a>/TITLE:#'}
        .q{,'<a href="__WebPath__/Admin/CustomFields/Modify.html?id=__id__">__Name__</a>/TITLE:Name'}
        .q{,__AppliedTo__, __FriendlyType__, __FriendlyPattern__},

    Scrips =>
        q{'<a href="__WebPath__/Admin/Queues/Scrip.html?id=__id__&Queue=__QueueId__">__id__</a>/TITLE:#'}
        .q{,'<a href="__WebPath__/Admin/Queues/Scrip.html?id=__id__&Queue=__QueueId__">__Description__</a>/TITLE:Description'}
        .q{,__Stage__, __Condition__, __Action__, __Template__},

    GlobalScrips =>
        q{'<a href="__WebPath__/Admin/Global/Scrip.html?id=__id__">__id__</a>/TITLE:#'}
        .q{,'<a href="__WebPath__/Admin/Global/Scrip.html?id=__id__">__Description__</a>/TITLE:Description'}
        .q{,__Stage__, __Condition__, __Action__, __Template__},

    Templates =>
        q{'<a href="__WebPath__/__WebRequestPathDir__/Template.html?Queue=__QueueId__&Template=__id__">__id__</a>/TITLE:#'}
        .q{,'<a href="__WebPath__/__WebRequestPathDir__/Template.html?Queue=__QueueId__&Template=__id__">__Name__</a>/TITLE:Name'}
        .q{,'__Description__'},
    Classes =>
        q{ '<a href="__WebPath__/Admin/Articles/Classes/Modify.html?id=__id__">__id__</a>/TITLE:#'}
        .q{,'<a href="__WebPath__/Admin/Articles/Classes/Modify.html?id=__id__">__Name__</a>/TITLE:Name'}
        .q{,__Description__},
);

=back




=head1 Development options

=over 4

=item C<$DevelMode>

RT comes with a "Development mode" setting.  This setting, as a
convenience for developers, turns on several of development options
that you most likely don't want in production:

=over 4

=item *

Disables CSS and JS minification and concatenation.  Both CSS and JS
will be instead be served as a number of individual smaller files,
unchanged from how they are stored on disk.

=item *

Uses L<Module::Refresh> to reload changed Perl modules on each
request.

=item *

Turns off Mason's C<static_source> directive; this causes Mason to
reload template files which have been modified on disk.

=item *

Turns on Mason's HTML C<error_format>; this renders compilation errors
to the browser, along with a full stack trace.  It is possible for
stack traces to reveal sensitive information such as passwords or
ticket content.

=item *

Turns off caching of callbacks; this enables additional callbacks to
be added while the server is running.

=back

=cut

Set($DevelMode, "0");


=item C<$RecordBaseClass>

What abstract base class should RT use for its records. You should
probably never change this.

Valid values are C<DBIx::SearchBuilder::Record> or
C<DBIx::SearchBuilder::Record::Cachable>

=cut

Set($RecordBaseClass, "DBIx::SearchBuilder::Record::Cachable");


=item C<@MasonParameters>

C<@MasonParameters> is the list of parameters for the constructor of
HTML::Mason's Apache or CGI Handler.  This is normally only useful for
debugging, e.g. profiling individual components with:

    use MasonX::Profiler; # available on CPAN
    Set(@MasonParameters, (preamble => 'my $p = MasonX::Profiler->new($m, $r);'));

=cut

Set(@MasonParameters, ());

=item C<$StatementLog>

RT has rudimentary SQL statement logging support; simply set
C<$StatementLog> to be the level that you wish SQL statements to be
logged at.

Enabling this option will also expose the SQL Queries page in the
Configuration -> Tools menu for SuperUsers.

=cut

Set($StatementLog, undef);

=back




=head1 Deprecated options

=over 4

=item C<$LinkTransactionsRun1Scrip>

RT-3.4 backward compatibility setting. Add/Delete Link used to record
one transaction and run one scrip. Set this value to 1 if you want
only one of the link transactions to have scrips run.

=cut

Set($LinkTransactionsRun1Scrip, 0);

=item C<$ResolveDefaultUpdateType>

This option has been deprecated.  You can configure this site-wide
with L</Lifecycles> (see L</Labeling and defining actions>).

=cut

1;
