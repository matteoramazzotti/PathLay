#!/usr/bin/perl
use strict;
use warnings;
use CGI;

our $CGI;
our %form;
our $base;
our $localhost;

sub CheckUploadedFile {

	my %args = (
		@_
	);

	my $parameters = $args{Parameters};
	my $filename = $args{File};
	my $base = $parameters -> {_base};
	my $home = $parameters -> {_home};


	my $safe_filename_characters = "a-zA-Z0-9_.-";

	if (!$filename) {
		print "Content-type: text/html\n\n";
		print "There was a problem uploading your file: maybe size exceeds 2 MBytes.";
		exit;
	} else {
		if ($filename !~ /\.zip/) {
			print "Content-type: text/html\n\n";
			print "There was a problem uploading your file: only zip files accepted.";
			exit;
		}
		my @tmp = split(/[\\\/]/,$filename);
		$filename = shift @tmp;
		$filename =~ tr/ /_/;
		$filename =~ s/[^$safe_filename_characters]//g;
		if ( $filename =~ /^([$safe_filename_characters]+)$/ ) {
			$filename = $1;
		} else {
			print "Content-type: text/html\n\n";
			print "There was a problem uploading your file: characters other than $safe_filename_characters are not accepted.";
			exit;
		}
		my $upload_filehandle = $CGI->upload("file");
		open(UP,">$base/pathlay_users/$home/tmpfile.zip") or die "$!";
		binmode(UP);
		while(<$upload_filehandle>) {
			print UP;
		}
		close(UP);
		if (!-e "$base/pathlay_users/$home/tmpfile.zip") {
			print "Content-type: text/html\n\n";
			print "There was a problem uploading your file: transfer failed.";
			#print LOG "$timestamp $remoteurl ",$form{'username'}," upload failed: not completed\n";
			exit;
		}
	}

}
sub ExtractZip {

	use Archive::Zip;

	my %args = (
		@_
	);

	my $parameters = $args{Parameters};
	my $zip = $args{File};
	my $base = $parameters -> {_base};
	my $home = $parameters -> {_home};
	my $userDir = $parameters->{_userdir};

	my $expn = getExpToAdd(
		userDir => $parameters->{_userdir}
	);
	$zip = Archive::Zip->new($zip);
	my @members = $zip -> memberNames();
	if (!-d "$userDir/exp$expn") {
		mkdir("$userDir/exp$expn/");
	}
	foreach my $file (@members) {
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.conf") if ($file =~ /\.conf/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.last") if ($file =~ /\.last/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.sel") if ($file =~ /\.sel/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.mirna") if ($file =~ /\.mirna/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.mrna") if ($file =~ /\.mrna/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.meta") if ($file =~ /\.meta/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.prot") if ($file =~ /\.prot/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.chroma") if ($file =~ /\.chroma/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.meth") if ($file =~ /\.meth/);
		$zip->extractMember($file,"$userDir/exp$expn/exp$expn.ont") if ($file =~ /\.ont/);
	}
	changePermissions(
		Input => "$userDir/exp$expn"
	);
}
sub DownloadZip {

	use Archive::Zip;
	use CGI qw(:standard);

	my %args = (
		@_
	);

	my $parameters = $args{Parameters};
	my $target = $args{Target};
	my $exp = $args{Exp} ? $args{Exp} : '';

	my $base = $parameters -> {_base};
	my $user = $parameters -> {_username};
	my $home = $parameters -> {_home};
	my $userDir = $parameters->{_userdir};
	print STDERR "$userDir/$exp\n";
	my $zip = Archive::Zip->new();

	if ($target eq "experiment" && $exp) {
		if (-d "$userDir/$exp") { # Check if the folder exists
			$zip->addTree("$userDir/$exp","$exp");
			print header(
				-type => 'application/zip',
				-attachment => "${user}_$exp.zip",
				-Access_Control_Allow_Origin => '*',
				-Access_Control_Expose_Headers => 'Content-Disposition',
			);
		}
	}

	if ($target eq "home") {
		opendir(DIR,$userDir);
		foreach my $id (readdir(DIR)) {
			next if (-f $id || $id !~ /^exp/);
			$zip -> addTree("$userDir/$id","$id");
		}
		closedir(DIR);
		print header(
			-type => 'application/zip',
			-attachment => "${user}_home.zip",
			-Access_Control_Allow_Origin => '*',
			-Access_Control_Expose_Headers => 'Content-Disposition',
		);
	}
	binmode(STDOUT);
	$zip->writeToFileHandle(*STDOUT);
}
sub writeExpData {
	my %args = (
		@_
	);

	my $mainBase = $args{mainBase};
	my $userHome = $args{userHome};

	my $expId = $args{expId};
	my $dataType = $args{dataType};
	my $expData = $args{expData};

	print STDERR "$base/pathlay_users/$userHome/$expId.$dataType\n";

	open(OUT, ">", "$mainBase/pathlay_users/$userHome/$expId.$dataType") or die "$mainBase/pathlay_users/$userHome/$expId.$dataType : writeExpData Failed!";
	print OUT $expData;
	close(OUT);

	return();
}
sub writeExpONT {

	my %args = (
		@_
	);

	my $mainBase = $args{mainBase};
	my $userHome = $args{userHome};
	my $expId = $args{expId};
	my $expONT = $args{expONT};
	my $expOrganism = $args{expOrganism};

	$expONT =~ s/[\x00|\x08\x0B|\x0C\x0E|\x1F\x7F|\x9F|\x87]//g;

	open(OUT,">","$mainBase/pathlay_users/$userHome/$expId.ont");
	my @array = split(/\@/,$expONT);

	foreach my $ont (sort @array) {
		#$ont =~ s/[\x00|\x08\x0B|\x0C\x0E|\x1F\x7F|\x9F|\x87]//g;
		#$ont =~ s/%(..)/pack("C", hex($1))/eg;
		$ont =~ s/\_$expOrganism//;
		print OUT "$ont\n";
	}
	close(OUT);
	return();
}
sub writeExpConf {

	my %args = (
		@_
	);

	my $mainBase = $args{mainBase};
	my $userHome = $args{userHome};
	my $expId = $args{expId};
	my $expName = $args{expName};
	my $expComments = $args{expComments};
	my $expOrganism = $args{expOrganism};
	my $form = $args{form};

	my @dataTypes = (
		"gene",
		"prot",
		"urna",
		"meth",
		"meta",
		"chroma"
	);
	print STDERR "$base/pathlay_users/$userHome/$expId.conf\n";
	open(OUT, ">" ,"$base/pathlay_users/$userHome/$expId.conf") or die "$base/pathlay_users/$userHome/$expId.conf"."writeExpData Failed!";
	print OUT "expname=$expName\n";
	print OUT "comments=$expComments\n";
	print OUT "organism=$expOrganism\n";

	foreach my $dataType (@dataTypes) {
		print OUT $dataType."IdType=".$form{$dataType."IdType"}."\n";
		print OUT $dataType."_id_column=".$form{$dataType."_id_column"}."\n";
		print OUT $dataType."_dev_column=".$form{$dataType."_dev_column"}."\n";
		print OUT $dataType."_pvalue_column=".$form{$dataType."_pvalue_column"}."\n";
	}
	close OUT;
}

sub SaveData {

	my %args = (
		@_
	);

	my $mainBase = $args{mainBase};
	my $userHome = $args{userHome};
	my $expId = $args{expId};
	my $form = %{$args{form}};

	my %dataTypes = (
		'gene' => 'mrna',
		'prot' => 'prot',
		'urna' => 'mirna',
		'chroma' => 'chroma',
		'meth' => 'meth',
		'meta' => 'meta'
	);

	foreach my $dataType (keys %dataTypes) {
		writeExpData(
			mainBase => $mainBase,
			userHome => $userHome,
			expId => $expId,
			expData => $form{$dataType."_data"},
			dataType => $dataTypes{$dataType}
		);
	}

}
sub DeleteData {

	my %args = (
		@_
	);

	my $mainBase = $args{mainBase};
	my $userHome = $args{userHome};
	my $expId = $args{expId};

	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".conf") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".conf");
	}
	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".last") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".last");
	}
	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".mrna") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".mrna");
	}
	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".mirna") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".mirna");
	}
	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".meta") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".meta");
	}
	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".meth") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".meth");
	}
	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".prot") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".prot");
	}
	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".chroma") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".chroma");
	}
	if (-e "$mainBase/pathlay_users/".$userHome."/".$expId.".sel") {
		unlink("$mainBase/pathlay_users/".$userHome."/".$expId.".sel");
	}
}
sub DeleteExp {
	my %args = (
		@_
	);
	my $userHome = $args{userHome};
	my $expId = $args{expId};
	return if (!$expId);
	opendir(DIR,"$userHome/$expId/");
	foreach my $file (readdir(DIR)){
		if ($file =~ $expId) {
			unlink("$userHome/$expId/$file");
		}
	}
	closedir(DIR);
	rmdir("$userHome/$expId");
}
sub PoolDownload {
	my %args = (
		@_
	);

	my $form = $args{form};

	print "Content-Type:application/x-download\n";
	print "Content-Disposition:attachment;filename=pathlay_data_pool.txt\n\n";
	#print "ID\tName\tType\tlogFC (Expression)\tlogFC (Methylation)\tMap\tGene/miRNA Association\n";
	print $form{'info_to_download'};
}
sub getExpToAdd {

	my %args = (
		@_
	);
	my $userDir = $args{userDir};

	my $max;

	opendir(DIR,$userDir);
	my @folderContent = readdir(DIR);
	my @expFolders;
	foreach my $folder (@folderContent) {
		next if (-f $folder || $folder !~ /^exp(.+?)$/);
		push(@expFolders,$folder);
	}
	my $limit = scalar(@expFolders) + 1;
	foreach (1..$limit) {
		next if (-d "$args{userDir}/exp$_");
		$max = $_;
		last;
	}
	closedir(DIR);
	return($max);
}



1;