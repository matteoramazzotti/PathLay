#!/usr/bin/perl
START:
if (!$ARGV[0]) {
	print "\nChoose an option:\n";
	print "  1. Create pack\n";
	print "  2. Upload\n";
	print "  3. Install (mine)\n";
	print "  4. Install (general)\n";
	print "  5. Uninstall\n";
	print "  6. Help\n\n > ";
	$what = <STDIN>;
	chomp $what;
} else {
	$what = shift @ARGV;
}

#last version
if ($what =~ 1) {
	$files[0] = '/var/www/kegglay_data/ ';
	$files[1] .= '/var/www/kegglay_users/ ';
	$files[2] .= '/var/www/kegglay_home3.html '; 
	$files[3] .= '/usr/lib/cgi-bin/kegglay_home3.pl '; 
	$files[4] .= '/usr/lib/cgi-bin/kegglay5.pl ';
	mkdir("tmp");
	$files[5] .= '/usr/lib/cgi-bin/kegglayplot3alt.pl ';
	`rsync -a /var/www/kegglay_data/ tmp/kegglay_data`;
	`rsync -a /var/www/kegglay_users/ tmp/kegglay_users`;
	mkdir("tmp/html");
	mkdir("tmp/cgi");
	`cp /var/www/kegglay_home3.html tmp/html/kegglay_home.html`;
	`cp /usr/lib/cgi-bin/kegglay_home3.pl tmp/cgi/kegglay_home.pl`;
	`cp /usr/lib/cgi-bin/kegglay5.pl tmp/cgi/kegglay.pl`;
	`cp /usr/lib/cgi-bin/kegglayplot3alt.pl tmp/cgi/kegglayplot.pl`;
	`rm tmp/kegglay_data/kegglay_proto*`;
	`rm tmp/kegglay_data/kegglay_user_proto*`;
	`cp /var/www/kegglay_data/kegglay_proto3.html tmp/kegglay_data/kegglay_proto.html`;
	`cp /var/www/kegglay_data/kegglay_user_proto2.html tmp/kegglay_data/kegglay_user_proto.html`;

	`sed -i 's/kegglay_home3.pl/kegglay_home.pl/g' tmp/kegglay_data/*.html`;
	`sed -i 's/kegglay_home3.pl/kegglay_home.pl/g' tmp/cgi/*`;
	`sed -i 's/kegglay_home3.pl/kegglay_home.pl/g' tmp/html/*.html`;

	`sed -i 's/kegglay_home3.html/kegglay_home.html/g' tmp/kegglay_data/*.html`;
	`sed -i 's/kegglay_home3.html/kegglay_home.html/g' tmp/cgi/*`;
	`sed -i 's/kegglay_home3.html/kegglay_home.html/g' tmp/html/*`;

	`sed -i 's/kegglay5.pl/kegglay.pl/g' tmp/kegglay_data/*.html`;
	`sed -i 's/kegglay5.pl/kegglay.pl/g' tmp/cgi/*`;
	`sed -i 's/kegglay5.pl/kegglay.pl/g' tmp/html/*`;

	`sed -i 's/kegglayplot3alt.pl/kegglayplot.pl/g' tmp/kegglay_data/*.html`;
	`sed -i 's/kegglayplot3alt.pl/kegglayplot.pl/g' tmp/cgi/*`;
	`sed -i 's/kegglayplot3alt.pl/kegglayplot.pl/g' tmp/html/*`;

	`sed -i 's/kegglay_proto3.html/kegglay_proto.html/g' tmp/kegglay_data/*.html`;
	`sed -i 's/kegglay_proto3.html/kegglay_proto.html/g' tmp/cgi/*`;
	`sed -i 's/kegglay_proto3.html/kegglay_proto.html/g' tmp/html/*`;

	`sed -i 's/kegglay_user_proto2.html/kegglay_user_proto.html/g' tmp/kegglay_data/*.html`;
	`sed -i 's/kegglay_user_proto2.html/kegglay_user_proto.html/g' tmp/cgi/*`;
	`sed -i 's/kegglay_user_proto2.html/kegglay_user_proto.html/g' tmp/html/*`;

	`tar -czf KEGGlay.tar.gz tmp`;
	`rm -r tmp`;
}

if ($what =~ 2) {
	print "Choose an option:\n\n";
	$w{1} = 'localhost';
	$w{2} = 'bioserver2.org';
	print " 1. localhost\n";
	print " 2. bioserver2.org\n\n > ";
	$where = <STDIN>;
	chomp $where;
	print "\nSpecify a user @ ",$w{$where},":\n\n > ";
	$who = <STDIN>;
	chomp $who;
	$dest = $who."\@150.217.62.250:/home/$who" if ($where == 2);
	print "\nUploading...\n";
	`scp KEGGlay.tar.gz kegglay_compile.pl $dest`;
	print STDERR "\nFiles successfully transferred\n";
	print STDERR "Log in to the remote machine and install as root\n\n";
}

if ($what =~ 3) {
	$html{1} = '/var/www';
	$cgi{1} = '/usr/lib/cgi-bin';
	$html{2} = '/var/www/html/bioserver2.org/';
	$cgi{2} = '/var/www/html/bioserver2.org/cgi-bin';
	print "Choose an option:\n\n";
	print " 1. localhost\n";
	print " 2. sbsc bioserver2.org\n\n > ";
	$where = <STDIN>;
	chomp $where;
	#catched the user name of the running httpd
	$apache = `ps aux | egrep '(apache|httpd|www-data)' | grep -v root | grep -v matteo | cut -d " " -f1 | uniq | head -n1`;
	$apache =~ s/ .+//;
#	$apache =~ s/[\n ]//g;

	print STDERR "Installing as user $apache on\n - HTML: $html{$where}\n - CGI: $cgi{$where}\n\n";
	$apache = $apache.":".$apache;

	if ($where == 2) { #the bioserver is @ 150.217.62.250
		#do this as root or sudo
		print STDERR "Installing home...\n";
		`tar xvf KEGGlay.tar.gz -C $html{2} --strip-components 2 var/www/kegglay_home.html`;

		print STDERR "Installing data...\n";
		`tar xvf KEGGlay.tar.gz -C $html{2} --strip-components 2 var/www/kegglay_data`;
		`chown -R apache:apache $html{2}/kegglay_data`;
		`chmod -R 500 $html{2}/kegglay_data`;

		print STDERR "Installing users...\n";
		`tar xvf KEGGlay.tar.gz -C $html{2} --strip-components 2 var/www/kegglay_users`;
		`chown -R apache:apache $html{2}/kegglay_users`;
		`chmod -R 700 $html{2}/kegglay_users`;

		print STDERR "Installing cgi...\n";
		`tar xvf KEGGlay.tar.gz -C $cgi{2} --strip-components 3 usr/lib/cgi-bin/kegglay*`;
		`chown -R apache:apache $cgi{2}/kegglay*`;
		`chmod -R 700 $cgi{2}/kegglay*`;

		print STDERR "Adjusting base links\n";
		#this way sed just replace the first occurrence
		`sed -i '0,/localserver/{s/localserver/bioserver/}' /var/www/cgi-bin/kegglay4.pl`;
		`sed -i '0,/localserver/{s/localserver/bioserver/}' /var/www/cgi-bin/kegglay_home.pl`;
	}
	print STDERR "\nInstallation complete.\n";
}

if ($what =~ 4) {
	$html = '/var/www/';
	print " Apache html folder\n>[$html]";
	$opt = <STDIN>;
	chomp $opt;
	if ($opt =~ /\w/) {
	 	$html = $opt;
	}
	$cgi = '/usr/lib/cgi-bin/';
	print " Apache cgi folder\n>[$cgi]";
	$opt = <STDIN>;
	chomp $opt;
	if ($opt =~ /\w/) {
	 	$cgi = $opt;
	}
	$apache = `ps aux | egrep '(apache|httpd|www-data)' | grep -v root | grep -v matteo | cut -d " " -f1 | uniq | head -n1`;
	$apache =~ s/ .+//;
	print " Apache user\n>[$apache]";
	$opt = <STDIN>;
	chomp $opt;
	if ($opt =~ /\w/) {
	 	$apache = $opt;
	}
	print "Installing as user $apache on\n - HTML: $html{$where}\n - CGI: $cgi{$where}\n\nPress [Enter] to continue or [ctrl-c] to quit\n";
	$apache = $apache.":".$apache;

	if ($where == 2) { #the bioserver is @ 150.217.62.250
		#do this as root or sudo
		print STDERR "Installing home...\n";
		`tar xvf KEGGlay.tar.gz -C $html --strip-components 2 var/www/kegglay_home.html`;

		print STDERR "Installing data...\n";
		`tar xvf KEGGlay.tar.gz -C $html --strip-components 2 var/www/kegglay_data`;
		`chown -R apache:apache $html{2}/kegglay_data`;
		`chmod -R 500 $html/kegglay_data`;

		print STDERR "Installing users...\n";
		`tar xvf KEGGlay.tar.gz -C $html --strip-components 2 var/www/kegglay_users`;
		`chown -R apache:apache $html/kegglay_users`;
		`chmod -R 700 $html/kegglay_users`;

		print STDERR "Installing cgi...\n";
		`tar xvf KEGGlay.tar.gz -C $cgi --strip-components 3 usr/lib/cgi-bin/kegglay*`;
		`chown -R apache:apache $cgi/kegglay*`;
		`chmod -R 700 $cgi/kegglay*`;

		print STDERR "Adjusting base links\n";
		
		# set html and cgi variabls according to setup instructions

		#this way sed just replace the first occurrence
		`sed -i '0,/localserver/{s/localserver/bioserver/}' /var/www/cgi-bin/kegglay.pl`;
		`sed -i '0,/localserver/{s/localserver/bioserver/}' /var/www/cgi-bin/kegglay_home.pl`;
	}
	print STDERR "\nInstallation complete.\n";
}

if ($what == 5) {
	#do this as root or sudo
	$html{1} = '/var/www';
	$cgi{1} = '/usr/lib/cgi-bin';
	$html{2} = '/var/www/html/dati_bioserver.org';
	$cgi{2} = '/var/www/cgi-bin';
	print "Choose an option:\n\n";
	print " 1. localhost\n";
	print " 2. sbsc bioserver2\n\n > ";
	$where = <STDIN>;
	chomp $where;
	`rm -vr $cgi{$where}/kegglay* $html{$where}/kegglay_data $html{$where}/kegglay_users $html{$where}/kegglay_home.html`;
}

if ($what == 6) {
print <<EOT;

The script runs in interactive mode (no arguments) 
             or in command line mode (e.g. 1, 12, or 3)

STRATEGY: 

The steps for installing the KEGGlay on a remote machine are:

- Using absolute paths, create a tar.gz with all the files needed (option 1), i.e.
  1. the scripts (.pl)
  2. the pages (.html)
  3. the whole kegglay_data folder
  4. the whole kegglay_users folder

- Upload both the tarball and this script via scp to the destination (option 2)

- Go to the destination via ssh

- As root or sudo, install files (option 3):
  1. place the files in the appropriate locations (install) via specific extraction from the tarball, plus
  2. set for all files the ownership to apache (the user:group depends on the destination server)
  3. set the permissions to 500 (data) or 700 (users and scripts)
  4. adjust the base urls inscripts when appropriate

- In case, all files can be removed with (uninstall, option 4)

EOT
;
}
