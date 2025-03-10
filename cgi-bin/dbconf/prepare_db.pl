#!/usr/bin/perl

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use FindBin;
use File::Basename;
use Data::Dumper;
use JSON;
use File::Slurp;

use lib "$FindBin::Bin/../modules/dbconf/";
use DBMaintainer "qw( HomoSapiensDB MusMusculusDB)";
my $query = CGI->new;




my $db = {
  homo_sapiens => new HomoSapiensDB(),
  mus_musculus => new MusMusculusDB()
};


print $query->header('text/plain');
my $organism = $query->param('organism');
my $dbType = $query->param('dbType');
my $basename = $db->{$organism}->{fileNames}->{$dbType};
my $type = $query->param('type');


# Process the uploaded file as tmp
if (my $upload_filehandle = $query->upload('file')) {
  #my $filename = $query->param('file');
  my $upload_path = "../../pathlay_data/$db->{$organism}->{code}/db/$basename.tmp";

  open my $out, '>', $upload_path or die "Cannot open $upload_path: $!";
  binmode $out;

  while (my $chunk = <$upload_filehandle>) {
    print $out $chunk;
  }

  close $out;

  print "File uploaded successfully.\n";
} else {
  print "No file uploaded.\n";
}
if (my $url = $query->param('url')) {
  print STDERR "Requesting tmp file from $url\n";
  my $response = {
    status => "downloading",
    statusFile => "$basename.status.json",
    file => "$basename",
    filePath => "$db->{$organism}->{interactionDBPath}",
    pid => $$
  };
  my $json_response = to_json($response, { pretty => 1 });


  write_file("$db->{$organism}->{interactionDBPath}$response->{statusFile}", $json_response);
  $db -> {$organism}->requestTmpFile(
    fileName => $basename,
    fileType => $type,
    url => $url
  );
  $response = {
    status => "processing",
    statusFile => "$basename.status.json",
    file => "$basename",
    filePath => "$db->{$organism}->{interactionDBPath}"
  };
  $json_response = to_json($response, { pretty => 1 });
  write_file("$db->{$organism}->{interactionDBPath}$response->{statusFile}", $json_response);
}


# Check if all file are present (either tmp or standard) and delete tmp
my $score = 0;
foreach my $dbType (sort keys %{$db->{$organism}->{fileNames}}) {
  if (-e "../../pathlay_data/$db->{$organism}->{code}/db/$db->{$organism}->{fileNames}->{$dbType}" || -e "../../pathlay_data/$db->{$organism}->{code}/db/$db->{$organism}->{fileNames}->{$dbType}.tmp") {
    $score++;
  }
}

exit if ($score != (scalar keys %{$db->{$organism}->{fileNames}}));


$db -> {$organism} -> checkTmpFiles();
$db -> {$organism} -> checkReadyFiles();


my @types = ("gene","prot","urna","meta","ont","tf");
my $dispatch = {
  homo_sapiens => {
    gene => sub { 
      my %args = (
        @_
      );
      $db->{homo_sapiens}->extractGeneDB(
        inputFile => $args{inputFile},
        outputFile => $args{outputFile}
      );
      $db->{homo_sapiens}->parseGeneDB(
        inputFile => $args{inputFile}
      );
    },
    prot => sub { 
      my %args = (
        @_
      );
      $db->{homo_sapiens}->extractProtDB(
        inputFile => $args{inputFile},
        outputFile => $args{outputFile}
      );
    },
    urna => sub { 
      my %args = (
        @_
      );

      if (my $pid = fork) {
        # Parent process
        exit(0);
      } elsif (defined $pid) {
        # Child process
        
        $db->{homo_sapiens}->parsemiRNADB(
          inputFile=>$args{inputFile},
          outputFile => $args{outputFile}
        );
        my $response = {
          status => "complete",
          statusFile => "hsa_mirtarbase.tsv.status.json",
          file => "hsa_mirtarbase.tsv",
          filePath => "$db->{homo_sapiens}->{interactionDBPath}",
          pid => $$
        };
        my $json_response = to_json($response, { pretty => 1 });
        write_file("$db->{homo_sapiens}->{interactionDBPath}$response->{statusFile}", $json_response);
        print $query->header('application/json');
        print $json_response;
      } else {
        die "Failed to fork: $!";
      }
    },
    meta => sub {
      my %args = (
        @_
      );
      $db->{homo_sapiens}->parseMetaListFromKEGG(
        inputFile => $args{inputFile}
      );
      $db->{homo_sapiens}->parseXRefMeta(
      );
      $db->{homo_sapiens}->savemetaDB(
        outputFile => $args{outputFile}
      );

    },
    ont => sub {
      my %args = (
        @_
      );
      # $db->{homo_sapiens}->parseOntDBJson(
      #   inputFile => $args{inputFile}
      # );
      $db->{homo_sapiens}->extractProtDB(
        inputFile => $args{inputFile},
        outputFile => $args{outputFile}
      );
      $db->{homo_sapiens}->parseOntDBTsvUP(
        inputFile => $args{outputFile}
      );
      $db->{homo_sapiens}->saveOntDB(
        outputFile => $args{outputFile}
      );
    },
    tf => sub {
      my %args = (
        @_
      );
      $db->{homo_sapiens}->parseTFDB(
        inputFile => $args{inputFile}
      );
      $db->{homo_sapiens}->saveTFDB(
        inputFile => $args{inputFile},
        outputFile => $args{outputFile}
      ) 
    }
  },
  mus_musculus => {
    gene => sub { 
      my %args = (
        @_
      );
      $db->{mus_musculus}->extractGeneDB(
        inputFile => $args{inputFile},
        outputFile => $args{outputFile}
      );
      $db->{mus_musculus}->parseGeneDB(
        inputFile => $args{inputFile}
      );
    },
    prot => sub { 
      my %args = (
        @_
      );
      $db->{mus_musculus}->extractProtDB(
        inputFile => $args{inputFile},
        outputFile => $args{outputFile}
      );
    },
    urna => sub { 
      my %args = (
        @_
      );

      if (my $pid = fork) {
        # Parent process
        exit(0);
      } elsif (defined $pid) {
        # Child process
        
        $db->{mus_musculus}->parsemiRNADB(
          inputFile=>$args{inputFile},
          outputFile => $args{outputFile}
        );
        my $response = {
            status => "complete",
            statusFile => "mmu_mirtarbase.tsv.status.json",
            file => "mmu_mirtarbase.tsv",
            filePath => "$db->{mus_musculus}->{interactionDBPath}",
            pid => $$
        };
        my $json_response = to_json($response, { pretty => 1 });
        write_file("$db->{mus_musculus}->{interactionDBPath}$response->{statusFile}", $json_response);
        print $query->header('application/json');
        print $json_response;
      } else {
        die "Failed to fork: $!";
      }
    },
    meta => sub {
      my %args = (
        @_
      );
      $db->{mus_musculus}->parseMetaListFromKEGG(
        inputFile => $args{inputFile}
      );
      $db->{mus_musculus}->parseXRefMeta(
      );
      $db->{mus_musculus}->savemetaDB(
        outputFile => $args{outputFile}
      );

    },
    ont => sub {
      my %args = (
        @_
      );
      # $db->{mus_musculus}->parseOntDBJson(
      #   inputFile => $args{inputFile}
      # );
      $db->{mus_musculus}->extractProtDB(
        inputFile => $args{inputFile},
        outputFile => $args{outputFile}
      );
      $db->{mus_musculus}->parseOntDBTsvUP(
        inputFile => $args{outputFile}
      );
      $db->{mus_musculus}->saveOntDB(
        outputFile => $args{outputFile}
      );
    },
    tf => sub {
      my %args = (
        @_
      );
      $db->{mus_musculus}->parseTFDB(
        inputFile => $args{inputFile}
      );
      $db->{mus_musculus}->saveTFDB(
        inputFile => $args{inputFile},
        outputFile => $args{outputFile}
      ) 
    }
  }
};



foreach my $dbType (@types) {
  next if (!$db->{$organism}->{tmpFiles}->{$dbType});
  $dispatch -> {$organism} -> {$dbType} -> (
    inputFile => "$db->{$organism}->{tmpFiles}->{$dbType}.tmp",
    outputFile => $db->{$organism}->{fileNames}->{$dbType},
  );
}

print STDERR "Cleaning tmp files\n";
foreach my $dbType (sort keys %{$db->{$organism}->{fileNames}}) {
  if (-e "$db->{$organism}->{interactionDBPath}$db->{$organism}->{fileNames}->{$dbType}" && -e "$db->{$organism}->{interactionDBPath}$db->{$organism}->{fileNames}->{$dbType}.tmp") {
    unlink("$db->{$organism}->{interactionDBPath}$db->{$organism}->{fileNames}->{$dbType}.tmp");
  }
}
print STDERR "Cleaning status files\n";
foreach my $dbType (sort keys %{$db->{$organism}->{fileNames}}) {
  if (-e "$db->{$organism}->{interactionDBPath}$db->{$organism}->{fileNames}->{$dbType}" && -e "$db->{$organism}->{interactionDBPath}$db->{$organism}->{fileNames}->{$dbType}.status.json") {
    unlink("$db->{$organism}->{interactionDBPath}$db->{$organism}->{fileNames}->{$dbType}.status.json");
  }
}
