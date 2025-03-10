use strict;
use warnings;


package HomoSapiensDB;
	sub new {
		my $class = shift;
		my $self = {
			code => "hsa",
			msigdbCode => "human",
			interactionDBPath => "../../pathlay_data/OrganismCode/db/",
			fileNames => {
				tf => "hsa_tf.gmt",
				urna => "hsa_mirtarbase.tsv",
				ont => "hsa_ont.gmt",
				gene => "hsa.gene_info",
				meta => "hsa.compound_info",
				prot => "hsa_uniprot.tsv"
			},
			omicsValid => {
				tf => 1,
				urna => 1,
				ont => 1,
				gene => 1,
				meta => 1,
				prot => 1,
				meth => 1,
				chroma => 1
			},
			idTypesValid => {
				gene => [
					{id => "entrez", name => "EntrezGeneID"},
					{id => "ensembl", name => "Ensembl"},
					{id => "symbol", name => "Gene Symbol"}
				],
				prot => [
					{id => "entry", name => "UniProt Entry"},
					{id => "entrez", name => "EntrezGeneID"},
					{id => "symbol", name => "Protein Symbol"}
				],
				urna => [
					{id => "mirbase", name => "miRBase"}
				],
				meth => [
					{id => "entrez", name => "EntrezGeneID"},
					{id => "ensembl", name => "Ensembl"},
					{id => "symbol", name => "Gene Symbol"}
				],
				chroma => [
					{id => "entrez", name => "EntrezGeneID"},
					{id => "ensembl", name => "Ensembl"},
					{id => "symbol", name => "Gene Symbol"}
				],
				meta => [
					{id => "keggcompound", name => "Kegg Compound"},
					{id => "name", name => "Compound Name"}
				]
			},
			universeFiles => {
				gene => {
					kegg => 'hsa.kegg.gene.gmt',
					wikipathways => 'hsa.wikipathways.gene.gmt'
				},
				meta => {
					kegg => 'hsa.kegg.meta.gmt',
					wikipathways => 'hsa.wikipathways.meta.gmt'
				}
			},
			tmpFiles => {},
			readyFiles => {},
			loadedDBs => {},
			conversionTables => {},
			defaultOnts => [
				'GO:0005634',
				'GO:0005737',
				'GO:0005739',
				'GO:0005764',
				'GO:0005783',
				'GO:0005794',
				'GO:0005856',
				'GO:0016020',
			],
			@_
		};
		$self -> {interactionDBPath} =~ s/OrganismCode/$self->{code}/;
		bless $self,$class;
		return($self);
	}
	sub requestTmpFile {
		use LWP::Simple;
		my $self = shift;
		my %args = (
			@_
		);
		
		my $url = $args{url};
		my $fileName = $args{fileName};
		my $fileType = $args{fileType};
		print STDERR $fileType."\n";
		my $folder = $fileType eq "interaction" ? $self->{interactionDBPath} : $self->{mapDBPath};
		print STDERR "Requesting: $url\n";
		my $genericData = get($url);
		print STDERR "Could not get $url!" unless defined $genericData;
		my $ext;
		if (!defined $genericData) {
			print STDERR "Trying github backup link\n";
			$url = "https://raw.githubusercontent.com/lorenzocasbarra/pathlay-dbs/main/${folder}${fileName}";
			$url =~ s/\.\.\///;
			$genericData = get($url);
			$ext = "";
		} else {
			$ext = ".tmp";
		}

		open(OUT,">","$folder$fileName$ext");
		print OUT $genericData;
		close(OUT);
		print STDERR "Saved: $folder$fileName$ext\n";
	}
	sub checkTmpFiles {
		my $self = shift;
		foreach my $dbType (keys %{$self -> {fileNames}}) {
		# print STDERR "$self->{interactionDBPath}"."$self->{fileNames}->{$dbType}.tmp"."\n";
			if (-e "$self->{interactionDBPath}"."$self->{fileNames}->{$dbType}.tmp") {
				$self->{tmpFiles}->{$dbType} = $self->{fileNames}->{$dbType};
			}
		}
	}
	sub checkReadyFiles {
		my $self = shift;
		foreach my $dbType (keys %{$self -> {fileNames}}) {
			if (-e "$self->{interactionDBPath}$self->{fileNames}->{$dbType}") {
				$self->{readyFiles}->{$dbType} = $self->{fileNames}->{$dbType};
			}
		}
	}
	sub extractGeneDB {
		use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
		my $self = shift;
		my %args = (
			inputFile => "$self->{fileNames}->{gene}.tmp",
			outputFile => $self->{fileNames}->{gene},
			@_
		);
		my $inputFile = $args{inputFile};
		my $outputFile = $args{outputFile};

		my $gz = IO::Uncompress::Gunzip->new("$self->{interactionDBPath}$inputFile") or die "IO::Uncompress::Gunzip failed: $GunzipError\n";

		open (OUT, '>', "$self->{interactionDBPath}$outputFile") or die "Cannot open output file $self->{interactionDBPath}$outputFile: $!\n";

		while (my $line = <$gz>) {
			print OUT $line;
		}
		close(OUT);
		$gz->close();

	}
	sub parseGeneDB {
		my $self = shift;
		my %args = (
			inputFile => "$self->{fileNames}->{gene}",
			@_
		);
		my $file = $args{inputFile};
		open(IN,"$self->{interactionDBPath}$file") or die "Error while opening \n";
    while (<IN>) {
        chomp;
        next if ($_ =~ /^#/);
				#tax_id	GeneID	Symbol	LocusTag	Synonyms	dbXrefs	chromosome	map_location	description	type_of_gene	Symbol_from_nomenclature_authority	Full_name_from_nomenclature_authority	Nomenclature_status	Other_designations	Modification_date	Feature_type
        my @tags = split("\t");
        my $entrez = $tags[1];
        my $symbol = $tags[2];
				my $aliasList = $tags[4];
        my $xRefsList  = $tags[5];
				#next if ($tags[9] ne "protein-coding" && $tags[9] ne "pseudogene" && $tags[9] ne "pseudo");
        $self -> {conversionTables} -> {gene} -> {_entrez_to_symbol} -> {$entrez} = $symbol;
        $self -> {conversionTables} -> {gene} -> {_symbol_to_entrez} -> {$symbol} = $entrez;

				foreach my $xRef (split(/\|/,$xRefsList)) {
					push(@{$self -> {conversionTables} -> {gene} -> {_entrez_to_xRef} -> {$entrez}},$xRef);
					push(@{$self -> {conversionTables} -> {gene} -> {_symbol_to_xRef} -> {$symbol}},$xRef);
					$self -> {conversionTables} -> {gene} -> {_xRef_to_symbol} -> {$xRef} = $symbol;
					$self -> {conversionTables} -> {gene} -> {_xRef_to_entrez} -> {$xRef} = $entrez;
				}


				foreach my $alias (split(/\|/,$aliasList)) {
					push(@{$self -> {conversionTables} -> {gene} -> {_entrez_to_alias} -> {$entrez}},$alias);
					push(@{$self -> {conversionTables} -> {gene} -> {_symbol_to_alias} -> {$symbol}},$alias);
					$self -> {conversionTables} -> {gene} -> {_alias_to_symbol} -> {$alias} = $symbol;
					$self -> {conversionTables} -> {gene} -> {_alias_to_entrez} -> {$alias} = $entrez;
				}

				$self -> {loadedDBs} -> {gene} -> {$entrez} = {
					taxID => $tags[0],
					geneID => $tags[1],
					symbol => $tags[2],
					locusTag => $tags[3],
					synonyms => $tags[4],
					dbXrefs => $tags[5],
					chromosome => $tags[6],
					mapLocation => $tags[7],
					description => $tags[8],
					typeOfGene => $tags[9],
					symbolFromAuth => $tags[10],
					nameFromAuth => $tags[11],
					nameStatus => $tags[12],
					otherNames => $tags[13],
					lastModified => $tags[14],
					featureType => $tags[15]
				};
    }
    close(IN);

	}
	sub saveGeneDB {
		my $self = shift;
		my %args = (
			File => "$self->{fileNames}->{gene}",
			@_
		);
		my $file = $args{File};
		return if (!$self -> {loadedDBs} -> {gene});
		open(OUT,">","$self->{interactionDBPath}$file");
		my @keys = (
			"taxID","geneID","symbol","locusTag",
			"synonyms","dbXrefs","chromosome",
			"mapLocation","description","typeOfGene",
			"symbolFromAuth","nameFromAuth","nameStatus",
			"otherNames","lastModified","featureType"
		);
		foreach my $entrez (sort keys %{$self -> {loadedDBs} -> {gene}}){
			my $line = "";
			foreach my $dbKey (@keys) {
				$line .= "$self->{loadedDBs}->{gene}->{$entrez}->{$dbKey}\t"; 
			}
			$line =~ s/\t$/\n/;
			print OUT $line;
		}
		close(OUT);
		
	}
	sub extractProtDB {
		use IO::Uncompress::Gunzip qw(gunzip $GunzipError);
		my $self = shift;
		my %args = (
			inputFile => "$self->{fileNames}->{prot}.tmp",
			outputFile => $self->{fileNames}->{prot},
			@_
		);
		my $inputFile = $args{inputFile};
		my $outputFile = $args{outputFile};

		my $gz = IO::Uncompress::Gunzip->new("$self->{interactionDBPath}$inputFile") or die "IO::Uncompress::Gunzip failed: $GunzipError\n";

		open (OUT, '>', "$self->{interactionDBPath}$outputFile") or die "Cannot open output file $self->{interactionDBPath}$outputFile: $!\n";

		while (my $line = <$gz>) {
			print OUT $line;
		}
		close(OUT);
		$gz->close();
	}
	sub parseProtDB {

		my $self = shift;
		my $file = "$self->{interactionDBPath}$self->{fileNames}->{prot}";
		
		open(IN,$file);
		while(<IN>) {
			chomp;
			next if ($_ =~ /Entry/);
			my ($entryId,$reviewed,$entryName,$geneNames,$protNames,$geneId,$org) = split("\t",$_);
			next if ($reviewed eq "unreviewed");
			$geneId =~ s/;//;
			$self->{conversionTables}->{prot}->{_entry_to_entrez}->{$entryId} = $geneId;
			push(@{$self->{conversionTables}->{prot}->{_entrez_to_entry}->{$geneId}},$entryId);
		}
		close(IN);
	}
	sub parseOntDBTsv {
		my $self = shift;
		my %args = (
			inputFile => "$self->{fileNames}->{ont}.tmp",
			@_
		);
		my $inputFile = $args{inputFile};

		open(IN,"$self->{interactionDBPath}$inputFile");
		while(<IN>){
			chomp;
			my ($name,$link,@entrezs) = split(/\t/);

			my $goInfo = $self->requestGOTerm(
				goName => $name
			);
			my $self->{loadedDBs}->{ont}->{$goInfo->{goTerm}} = {
				link => "http://amigo.geneontology.org/amigo/term/$goInfo->{goTerm}",
				name => $name,
				alias => $goInfo->{goAlias},
				genes => \@entrezs
			}
		}
		close(IN);
	}
	sub parseOntDBTsvUP {
		my $self = shift;
		my %args = (
			inputFile => "$self->{fileNames}->{ont}.tmp",
			@_
		);
		my $verbose = 0;
		my $inputFile = $args{inputFile};
		print STDERR "Opening: $self->{interactionDBPath}$inputFile\n";
		open(IN,"$self->{interactionDBPath}$inputFile");
		while(<IN>){
			next if ($_ =~ "Entry Name");
			my @columnValues = split("\t",$_);
			if (!$columnValues[4]){
				print STDERR "Skipping $columnValues[0]\n" if ($verbose);
				next;
			};
			my $entrez = ($columnValues[4] =~ s/\;//r);

			my @goLists = (
				{ type => "MF", list => $columnValues[8] },
				{ type => "CC", list => $columnValues[9] },
				{ type => "BB", list => $columnValues[10] }
			);

			foreach my $goList (@goLists) {
				next if ($goList->{type} ne "CC");
				my @gos = split("; ",$goList->{list});
				foreach my $go (@gos) {
					if ($go =~ /^(.*?)\s*\[(.*?)\]$/) {
						my $goName = ucfirst lc $1;
						my $goID = $2;
						$goName =~ s/\b(\w)/\U$1/g;

						if (!$self->{loadedDBs}->{ont}->{$goID}) {
							$self->{loadedDBs}->{ont}->{$goID} = {
								ID => $goID,
								name => $goName,
								link => "http://amigo.geneontology.org/amigo/term/$goID",
								type => $goList->{type},
							}
						}

						$self->{loadedDBs}->{ont}->{$goID}->{genes}->{$entrez} = {};

					}
				}
			}

		}
		close(IN);

		# foreach my $goID (sort { $goMap->{$a}->{Name} cmp $goMap->{$b}->{Name} } keys %$goMap) {
		# 	print STDOUT "$goID\t$goMap->{$goID}->{Name}\t$goMap->{$goID}->{Link}\t".(join(";",sort keys %{$goMap->{$goID}->{Genes}}))."\n";
		# }

		print STDERR "Done\n";
	}
	sub parseOntDBJson {
		use JSON;
		use Data::Dumper;
		my $self = shift;
		my %args = (
			inputFile => "$self->{fileNames}->{ont}.tmp",
			@_
		);
		return if (!-e "$self->{interactionDBPath}$self->{fileNames}->{gene}");

		$self -> parseGeneDB(
			inputFile => $self->{fileNames}->{gene}
		) if (!$self->{loadedDBs}->{gene});

		my $collectionsCodes = {
			"C5:GO:BP" => {
				required => 0,
				code => "GOBP"
			},
			"C5:GO:CC" => {
				required => 1,
				code => "GOCC"
			},
			"C5:GO:MF" => {
				required => 0,
				code => "GOMF"
			},
			"C5:HPO"	 => {
				required => 0,
				code => "HPO"
			}
		};

		my $inputFile = $args{inputFile};
		open JSON, "$self->{interactionDBPath}$inputFile" or die "Could not open file '$self->{interactionDBPath}$inputFile' $!";
		my $jsonData = do { local $/; <JSON> };
		close(JSON);		
		die "Could not read file $self->{interactionDBPath}$inputFile!" unless defined $jsonData;

		my $jsonDecoded = decode_json($jsonData);

		foreach my $goName (keys %$jsonDecoded) {
			next if (!$collectionsCodes -> {$jsonDecoded->{$goName}->{collection}}-> {required});
			my $goID = $jsonDecoded->{$goName}->{exactSource};
			$self->{loadedDBs}->{ont}->{$goID} = {
				link => $jsonDecoded -> {$goName} -> {externalDetailsURL},
				goName => $goName,
				collection => $jsonDecoded->{$goName}->{collection}
			};
			foreach my $symbol (@{$jsonDecoded->{$goName}->{geneSymbols}}) {
				next if (!$self->{conversionTables}->{gene}->{_symbol_to_entrez}->{$symbol});
				push(@{$self->{loadedDBs}->{ont}->{$goID}->{genes}},$self->{conversionTables}->{gene}->{_symbol_to_entrez}->{$symbol});
			}
			# if (!$self->{loadedDBs}->{ont}->{$goID}->{genes}) {
			# 	print STDERR "$goID\n";
			# }
			my $alias = $goName;
			$alias =~ s/$collectionsCodes->{$jsonDecoded->{$goName}->{collection}}->{code}//;
			$alias =~ s/_/ /;
			$self->{loadedDBs}->{ont}->{$goID}->{alias} = ucfirst(lc($alias));
		}
		
	}
	sub requestGOTerm {

		use LWP::Simple;
		use JSON;

		my $self = shift;
		my %args = (
			goName => "",
			@_
		);
		my $url = "https://www.gsea-msigdb.org/gsea/msigdb/$self->{msigdbCode}/download_geneset.jsp?geneSetName=$args{goName}&fileType=json";
		my $jsonData = get($url);
		die "Could not get $url!" unless defined $jsonData;
		print STDERR "Requesting: $url\n";
		my $jsonDecoded = decode_json($jsonData);
		return({goTerm => $jsonDecoded->{$args{goName}}->{exactSource},goAlias => $jsonDecoded->{$args{goName}}->{externalNamesForSimilarTerms}});
	}
	sub saveOntDB {
		my $self = shift;
		my %args = (
			outputFile => "$self->{fileNames}->{ont}",
			@_
		);
		print STDERR "Saving ONT DB\n";
		# print STDERR $self->{loadedDBs}->{ont};
		my $outputFile = $args{outputFile};
		return if (!$self->{loadedDBs}->{ont});
		open(OUT,">","$self->{interactionDBPath}$outputFile");
		foreach my $goTerm (sort keys %{$self->{loadedDBs}->{ont}}) {
			print OUT "$goTerm\t$self->{loadedDBs}->{ont}->{$goTerm}->{name}\t$self->{loadedDBs}->{ont}->{$goTerm}->{link}\t".(join(";",keys %{$self->{loadedDBs}->{ont}->{$goTerm}->{genes}}))."\n"; 
		}
		close(OUT);
		print STDERR "Saved: $self->{interactionDBPath}$outputFile\n";
	}
	sub parsemiRNADB {
			use JSON;
			use File::Slurp;
			my $self = shift;
			my %args = (
					inputFile => "$self->{fileNames}->{urna}.tmp",
					outputFile => $self->{fileNames}->{urna},
					@_
			);
			print STDERR "We are parsing miRNAs baby!!\n";

			my $inputFile = $args{inputFile};
			my $outputFile = $args{outputFile};

			system("ssconvert $self->{interactionDBPath}$inputFile $self->{interactionDBPath}tsv.tmp");

			print STDERR "Conversion complete: $self->{interactionDBPath}$outputFile\n";
			my $urnas = {};
			open(IN,"tsv.tmp");
			while(<IN>){
					chomp;
					next if ($_ =~ "miRTarBase ID");
					my @columns = split("\t",$_);
					next if (!$columns[0]);
					if ($urnas -> {$columns[0]} && $columns[7] eq "Functional MTI") {
							$urnas -> {$columns[0]} -> {support} = $columns[7];
					}
					next if ($urnas -> {$columns[0]});
					$urnas -> {$columns[0]} = {
							name => $columns[1]  ? $columns[1] : "",
							target => $columns[4]  ? $columns[4] : "",
							support => $columns[7] ? $columns[7] : ""
					};
			}
			close(IN);
			open(OUT,">","$self->{interactionDBPath}$outputFile");
			print OUT "miRTarBase ID\tmiRNA\tTarget Gene (Entrez Gene ID)\tSupport Type\n";
			foreach my $mirtID (sort keys %$urnas) {
					print OUT "$mirtID\t$urnas->{$mirtID}->{name}\t$urnas->{$mirtID}->{target}\t$urnas->{$mirtID}->{support}\n";
			}
			close(OUT);
	}
	sub requestXRefMeta {
		use LWP::Simple;
		my $self = shift;
		
		my $url = "https://rest.kegg.jp/conv/chebi/compound";
		print STDERR "Requesting: $url\n";
		my $tsvData = get($url);
		die "Could not get $url!" unless defined $tsvData;

		my @lines = split(/\n/,$tsvData);
		return(@lines);
	}
	sub parseXRefMeta {
		my $self = shift;
		my @lines = $self->requestXRefMeta();

		foreach (@lines) {
			my ($id,$chebi) = split("\t");
			$id =~ s/cpd://;
			push(@{$self->{conversionTables}->{meta}->{_kegg_compound_to_chebi} -> {$id}},$chebi);
			push(@{$self->{conversionTables}->{meta}->{_chebi_to_kegg_compound}->{$chebi}},$id);
			foreach my $name (@{$self->{conversionTables}->{meta}->{_kegg_compound_to_name}->{$id}}) {
				push(@{$self->{conversionTables}->{meta}->{_chebi_to_name} -> {$chebi}},lc($name));
				push(@{$self->{conversionTables}->{meta}->{_name_to_chebi} -> {lc($name)}},$chebi);
			}
		}

        
	}
	sub parseMetaListFromKEGG {
		my $self = shift;
		my %args = (
			inputFile => "$self->{fileNames}->{meta}.tmp",
			@_
		);
		my $inputFile = $args{inputFile};

		open(IN,"$self->{interactionDBPath}$inputFile");
		while (<IN>) {
			chomp;
			my ($id,$nameString) = split("\t");
			$self -> {loadedDBs} -> {meta} -> {$id} = {};
			my @names = split("; ",$nameString);
			foreach my $name (@names) {
				$self->{conversionTables}->{meta}->{_name_to_kegg_compound}->{lc($name)} = $id;
				push(@{$self->{conversionTables}->{meta}->{_kegg_compound_to_name}->{$id}},lc($name));
			}
    }
    close(IN);

	}
	sub parseMetaDB {
		my $self = shift;
		my %args = (
			inputFile => "$self->{fileNames}->{meta}.tmp",
			@_
		);
		my $inputFile = $args{inputFile};

		open(IN,"$self->{interactionDBPath}$inputFile");
		while (<IN>) {
			chomp;
			my ($id,$chebiString,$nameString) = split("\t");
			$self -> {loadedDBs} -> {meta} -> {$id} = {};
			my @names = split("; ",$nameString);
			my @chebis = split("; ",$chebiString);
			foreach my $name (@names) {
				$self->{conversionTables}->{meta}->{_name_to_kegg_compound}->{lc($name)} = $id;
				push(@{$self->{conversionTables}->{meta}->{_kegg_compound_to_name}->{$id}},lc($name));
			}
			foreach my $chebi (@chebis) {
				$self->{conversionTables}->{meta}->{_chebi_to_kegg_compound}->{$chebi} = $id;
				push(@{$self->{conversionTables}->{meta}->{_kegg_compound_to_chebi}->{$id}},$chebi);
			}
    }
    close(IN);

	}
	sub savemetaDB {
		use List::Uniq;
		my $self = shift;
		my %args = (
			outputFile => "$self->{fileNames}->{meta}",
			@_
		);

		return if (!$self->{conversionTables}->{meta} && !$self->{loadedDBs}->{meta});


		my $outputFile = $args{outputFile};

		open(OUT,">","$self->{interactionDBPath}$outputFile");
		foreach my $metaID (sort keys %{$self->{loadedDBs}->{meta}}) {
			(my $xRefs = join("; ", List::Uniq::uniq(@{$self->{conversionTables}->{meta}->{_kegg_compound_to_chebi}->{$metaID}}))) =~ s/; $//;
			(my $names = join("; ", List::Uniq::uniq(@{$self->{conversionTables}->{meta}->{_kegg_compound_to_name}->{$metaID}}))) =~ s/; $//;
			print OUT "$metaID\t$xRefs\t$names\n";
		}
		close(OUT);
	}
	sub parseTFDB {
		my $self = shift;
		my %args = (
			File => "$self->{fileNames}->{tf}.tmp",
			@_
		);
		print STDERR "Parsing TFDB\n";

		return if (!-e "$self->{interactionDBPath}$self->{fileNames}->{gene}");
		$self -> parseGeneDB(
			File => $self->{fileNames}->{gene}
		);

		open(IN,"$self->{interactionDBPath}$self->{fileNames}->{tf}.tmp");
		while(<IN>) {
			chomp;
			my ($target_genes_str,$tf_link,@tf_genes) = split(/\t/);
			my $symbol;
			if ($target_genes_str =~ /^(.+?)_TARGET_GENES$/) {
				$symbol = join("-",split(/_/,$1));
			}
			next if (!$self->{conversionTables}->{gene}->{_symbol_to_entrez}->{$symbol});
			my $entrez = $self->{conversionTables}->{gene}->{_symbol_to_entrez}->{$symbol};
			$self->{loadedDBs}->{tf}->{$entrez} = {
				symbol => $symbol,
				str => $target_genes_str,
				targets => \@tf_genes,
				link => $tf_link
			};
		}
		close(IN);


	}
	sub saveTFDB {
		my $self = shift;
		my %args = (
			File => "$self->{fileNames}->{tf}",
			@_
		);
		my $file = $args{File};
		print STDERR "Saving TFDB\n";
		return if (!$self->{loadedDBs}->{tf});
		# print STDERR "$self->{interactionDBPath}$file\n";
		open(OUT,">","$self->{interactionDBPath}$file");
		foreach my $tfEntrez (sort keys %{$self->{loadedDBs}->{tf}}) {
			print OUT "$tfEntrez\t$self->{loadedDBs}->{tf}->{$tfEntrez}->{symbol}\t$self->{loadedDBs}->{tf}->{$tfEntrez}->{str}\t$self->{loadedDBs}->{tf}->{$tfEntrez}->{link}\t@{$self->{loadedDBs}->{tf}->{$tfEntrez}->{targets}}\n";
		}
		close(OUT);

	}

package MusMusculusDB;
	our @ISA = ('HomoSapiensDB');
	sub new {
		my $class = shift;
		my $self = {
			code => "mmu",
			msigdbCode => "mouse",
			interactionDBPath => "../../pathlay_data/OrganismCode/db/",
			fileNames => {
				tf => "mmu_tf.gmt",
				urna => "mmu_mirtarbase.tsv",
				ont => "mmu_ont.gmt",
				gene => "mmu.gene_info",
				meta => "mmu.compound_info",
				prot => "mmu_uniprot.tsv"
			},
			omicsValid => {
				tf => 1,
				urna => 1,
				ont => 1,
				gene => 1,
				meta => 1,
				prot => 1,
				meth => 1,
				chroma => 1
			},
			idTypesValid => {
				gene => [
					{id => "entrez", name => "EntrezGeneID"},
					{id => "ensembl", name => "Ensembl"},
					{id => "symbol", name => "Gene Symbol"}
				],
				prot => [
					{id => "entry", name => "UniProt Entry"},
					{id => "entrez", name => "EntrezGeneID"},
					{id => "symbol", name => "Protein Symbol"}
				],
				urna => [
					{id => "mirbase", name => "miRBase"}
				],
				meth => [
					{id => "entrez", name => "EntrezGeneID"},
					{id => "ensembl", name => "Ensembl"},
					{id => "symbol", name => "Gene Symbol"}
				],
				chroma => [
					{id => "entrez", name => "EntrezGeneID"},
					{id => "ensembl", name => "Ensembl"},
					{id => "symbol", name => "Gene Symbol"}
				],
				meta => [
					{id => "keggcompound", name => "Kegg Compound"},
					{id => "name", name => "Compound Name"}
				]
			},
			universeFiles => {
				gene => {
					kegg => 'mmu.kegg.gene.gmt',
					wikipathways => 'mmu.wikipathways.gene.gmt'
				},
				meta => {
					kegg => 'mmu.kegg.meta.gmt',
					wikipathways => 'mmu.wikipathways.meta.gmt'
				}
			},
			tmpFiles => {},
			readyFiles => {},
			loadedDBs => {},
			defaultOnts => [
				'GO:0005634',
				'GO:0005737',
				'GO:0005739',
				'GO:0005764',
				'GO:0005783',
				'GO:0005794',
				'GO:0005856',
				'GO:0016020',
			],
			conversionTables => {},
			@_
		};
		$self -> {interactionDBPath} =~ s/OrganismCode/$self->{code}/;
		bless $self,$class;
		return($self);
	}


package KGML;
	sub new {
		my $class = shift;
		my $self = {
			organismCode => "hsa",
			fileExt => "kgml",
			fileName => "",
			data => {},
			@_
		};
		if (!$self->{filePath}) {
			$self->{filePath} = "../../pathlay_data/$self->{organismCode}/maps/kegg/";
		}
		
		die "ID for kgml file not provided!\n" unless $self->{fileName}; 
		
		bless $self,$class;
		return($self);
	}
	sub xmlLoader {
		my $self = shift;
		my %args = (
			@_
		);
		my $file = "$self->{filePath}/$self->{fileName}.$self->{fileExt}";
		
		open(IN,$file) or die "Error while opening $file\n";
    chomp(my @lines = <IN>);
    close(IN);
    $self -> {data} = join(";",@lines);
	}
	sub nodesPrinter {
		use Data::Dumper;
		my $self = shift;
		my %args = (
			conversionTables => {},
			@_
		);
		my $conversionTables = $args{conversionTables};


		my $entry_tag;
    my %counter;

		my $pathwayTag;
		if ($self -> {data} =~ /<(pathway.+?)>/) {
			$pathwayTag = $1;
    }

    while ($pathwayTag =~ /([^ +]+?)=\"(.+?)\"/g) {
			my $tag = $1;
			my $info = $2;
			$tag =~ s/^ +//;
			$self->{pathwayInfo}->{$tag} = $info;
    }


    while ($self -> {data} =~ /<entry(.+?)<\/entry>/g) {
			$entry_tag = $1;
			my $entryObj = {};
			while ($entry_tag =~ /([^ +]+?)=\"(.+?)\"/g) {
					my $tag = $1;
					my $info = $2;
					$tag =~ s/^ +//;
					#print STDERR $tag."\t".$info."\n";
					if (!$entryObj -> {$tag}) {
							$entryObj -> {$tag} = $info;
							$counter{$tag} = 2;
					} else {
							$entryObj->{$tag."_".$counter{$tag}} = $info;
							$counter{$tag}++;
					}
			}
			%counter = ();
			if ($entryObj->{coords}) {
					my ($x1,$y1,$x2,$y2) = split(",",$entryObj -> {coords});
					$entryObj->{x} = ($x1+$x2)/2;
					$entryObj->{y} = ($y1+$y2)/2;
			}
			push(@{$self -> {entries}},$entryObj);
    }
		open(OUT,">","$self->{filePath}/$self->{fileName}.nodes");
    print OUT "TEXT	TYPE	DB	ID	X	Y\n";
		print OUT "$self->{pathwayInfo}->{title}\t$self->{organismCode}\tkegg\t$self->{fileName}\n";
		foreach my $entry (@{$self -> {entries}}) {
			next if ($entry->{type} ne "gene" && $entry->{type} ne "compound");
			if ($entry->{type} eq "gene") {
				$entry->{type} = "GeneProduct";
				$entry->{db} = "Entrez Gene";
				$entry->{name} =~ s/$self->{organismCode}://g;
      }
			if ($entry->{type} eq "compound") {
				$entry->{type} = "Metabolite";
				$entry->{db} = "KEGG Compound";
				$entry->{name} =~ s/cpd://g;
			}
			my @ids = split(" ",$entry->{name});
			foreach my $id (@ids) {
				if ($entry->{type} eq "Metabolite" && $entry->{db} eq "KEGG Compound") {
					next if (
						$id =~ /^dr:/ ||  #drug
						$id =~ /^gl:/ #glycan
					);
					print OUT ${$conversionTables->{meta}->{_kegg_compound_to_name} -> {$id}}[0]."\t";
				}
				if ($entry->{type} eq "GeneProduct" && $entry->{db} eq "Entrez Gene") {
					print OUT $conversionTables->{gene}->{_entrez_to_symbol}->{$id}."\t";
				}

				print OUT $entry->{type}."\t".
					$entry->{db}."\t".
					$id."\t".
					$entry->{x}.",".
					$entry->{y}."\n";
			}
		}
		close(OUT);

	}

package GPML;
	sub new {
		my $class = shift;
		my $self = {
			organismCode => "hsa",
			fileExt => "gpml",
			fileName => "",
			@_
		};
		if (!$self->{filePath}) {
			$self->{filePath} = "../../pathlay_data/$self->{organismCode}/maps/wikipathways/";
		}
		
		die "ID for gpml file not provided!\n" unless $self->{fileName}; 
		
		bless $self,$class;
		return($self);
	}
	sub xmlLoader {
		use XML::Simple;
		use Data::Dumper;
		use Encode;
		use Encode::Guess;

		my $self = shift;
		my %args = (
			@_
		);
		my $file = "$self->{filePath}/$self->{fileName}.$self->{fileExt}";
		# print STDERR "$file\n";

		open my $fh, '<:raw', $file or die "Cannot open $file: $!";
		my $raw_content = do { local $/; <$fh> };
		close $fh;

		my $enc = guess_encoding($raw_content, qw/utf-8 iso-8859-1/);

		# If guessing fails, default to ISO-8859-1
		if (ref($enc)) {
			$raw_content = $enc->decode($raw_content);
		} else {
			$raw_content = Encode::decode('iso-8859-1', $raw_content);
		}


		my $xml = XML::Simple->new();
		$self->{data} = $xml->XMLin($raw_content);
	}
	sub nodesPrinter {
		my $self = shift;
		my %args = (
			conversionTables => {},
			@_
		);
		my $conversionTables = $args{conversionTables};
		
		open(OUT,">","$self->{filePath}/$self->{fileName}.nodes");
		print OUT "TEXT	TYPE	DB	ID	X	Y\n";
		print OUT "$self->{data}->{Name}\t$self->{organismCode}\twikipathways\t$self->{fileName}\n";
		foreach my $dataNode ( @{$self-> {data} -> {DataNode}}) {
			if ($dataNode->{Type} eq "GeneProduct" && $dataNode->{Xref}->{Database} ne "Entrez Gene" && $conversionTables->{gene}) {
				print STDERR "Attempting conversion for $dataNode->{TextLabel}...";
				if ($conversionTables->{gene}->{_symbol_to_entrez}->{$dataNode->{TextLabel}}) {
					$dataNode->{Xref}->{ID} = $conversionTables->{gene}->{_symbol_to_entrez}->{$dataNode->{TextLabel}};
					$dataNode->{Xref}->{Database} = "Entrez Gene";
					print STDERR "OK!\n";
				} elsif ($conversionTables->{gene}->{_alias_to_entrez}->{$dataNode->{TextLabel}}) {
					$dataNode->{Xref}->{ID} = $conversionTables->{gene}->{_alias_to_entrez}->{$dataNode->{TextLabel}};
					$dataNode->{Xref}->{Database} = "Entrez Gene";
					print STDERR "OK!*\n";
				} else {
					print STDERR "Fail!\n";
				}
			}
			if ($dataNode->{Type} eq "Metabolite" && $dataNode->{Xref}->{Database} ne "KEGG Compound" && $conversionTables->{meta}) {
				print STDERR "Attempting conversion for $dataNode->{TextLabel}...";
				if ($conversionTables->{meta}->{_name_to_kegg_compound}->{$dataNode->{TextLabel}}) {
					print STDERR "OK!\n";
					$dataNode->{Xref}->{ID} = $conversionTables->{meta}->{_name_to_kegg_compound}->{$dataNode->{TextLabel}};
					$dataNode->{Xref}->{Database} = "KEGG Compound";
				}
				if ($conversionTables->{meta}->{_name_to_kegg_compound}->{ucfirst($dataNode->{TextLabel})}) {
					print STDERR "OK!\n";
					$dataNode->{Xref}->{ID} = $conversionTables->{meta}->{_name_to_kegg_compound}->{ucfirst($dataNode->{TextLabel})};
					$dataNode->{Xref}->{Database} = "KEGG Compound";
				}
				if ($conversionTables->{meta}->{_name_to_kegg_compound}->{lc($dataNode->{TextLabel})}) {
					print STDERR "OK!\n";
					$dataNode->{Xref}->{ID} = $conversionTables->{meta}->{_name_to_kegg_compound}->{lc($dataNode->{TextLabel})};
					$dataNode->{Xref}->{Database} = "KEGG Compound";
				}
			}
			if ($dataNode->{Type} eq "Protein") {
				print STDERR "Attempting conversion for prot $dataNode->{Xref}->{ID} : $dataNode->{TextLabel}...";
				if ($conversionTables->{prot}->{_entry_to_entrez}->{$dataNode->{Xref}->{ID}}) {
					$dataNode->{Xref}->{ID} = $conversionTables->{prot}->{_entry_to_entrez}->{$dataNode->{Xref}->{ID}};
					$dataNode->{Type} = "GeneProduct";
					$dataNode->{Xref}->{Database} = "Entrez Gene";
					print STDERR "OK!\n";
				} else {
					print STDERR "FAIL**\n";
				}
			}
			my $coords = "$dataNode->{Graphics}->{CenterX},$dataNode->{Graphics}->{CenterY}";
			my $outLine = join("\t",(
				$dataNode->{TextLabel}, 
				$dataNode->{Type}, 
				$dataNode->{Xref}->{Database},
				$dataNode->{Xref}->{ID}, 
				# $dataNode->{Graphics}->{CenterX}, 
				# $dataNode->{Graphics}->{CenterY}
				$coords
			));
			$outLine =~ s/\n/ /g;

			print OUT $outLine."\n";
		}
		close(OUT);
	}
package Node;
	sub new {
		my $class = shift;
		my $self = {
			organismCode => "hsa",
			fileExt => "nodes",
			fileName => "",
			mapsDB => "kegg",
			@_
		};
		die "ID for nodes file not provided!\n" unless $self->{fileName}; 
		if (!$self->{filePath}) {
			$self->{filePath} = "../../pathlay_data/$self->{organismCode}/maps/$self->{mapsDB}/";
		}
		bless $self,$class;
		return($self);
	}
	sub loadContent {
		my $self = shift;
		open(IN,"$self->{filePath}$self->{fileName}.$self->{fileExt}") or print STDERR "Cannot Open: $self->{filePath}$self->{fileName}.$self->{fileExt}\n";

		while(<IN>) {
			#IDNK	GeneProduct	Entrez Gene	414328	534,241
			#D-Glucose	Metabolite	KEGG Compound	C00031	201,203
			chomp;
			my ($name,$type,$idType,$id,$coords) = split("\t",$_);
			if ($id =~ /$self->{fileName}/) {
				$self -> {id} = $id;
				$self -> {name} = $name;
				next;
			}

			my $dataType = $type eq "GeneProduct" ? 'gene' : $type eq "Metabolite" ? 'meta' : undef;
			next if (!defined($dataType));
			next if ($idType ne "Entrez Gene" && $idType ne "KEGG Compound");
			next if ($id =~ /^gl:/);
			$self -> {data} -> {$dataType} -> {$id} = {};
		}
		close(IN);
	}
	sub updateMapAssociationFile {
		my $self = shift;
		my %args = (
			gmtFile => '',
			dataType => '',
			@_
		);
		my $gmtFile = $args{gmtFile};
		my $dataType = $args{dataType};

		$gmtFile -> {fileContent} -> {$self -> {id}} -> {id} = $self -> {id};
		$gmtFile -> {fileContent} -> {$self -> {id}} -> {name} = $self -> {name};
		$gmtFile -> {fileContent} -> {$self -> {id}} -> {content} = $self -> {data}->{$dataType};
		return($gmtFile);
	}

package GMTFile;
	sub new {
		my $class = shift;
		my $self = {
			organismCode => "hsa",
			fileExt => "gmt",
			fileName => "",
			mapsDB => "kegg",
			@_
		};
		die "ID gmt file not provided!\n" unless $self->{fileName}; 
		if (!$self->{filePath}) {
			$self->{filePath} = "../../pathlay_data/$self->{organismCode}/db/$self->{mapsDB}/";
		}
		if ($self->{fileName} =~ /\.$self->{fileExt}$/) {
			$self->{fileExt} = "";
		}
		bless $self,$class;
		return($self);
	}
	sub loadContent {
		my $self = shift;
		open(IN,"$self->{filePath}$self->{fileName}");
		while(<IN>) {
			chomp;
			my ($mapId,$mapName,@ids) = split("\t",$_);
			$self->{fileContent}->{$mapId}->{id} = $mapId;
			$self->{fileContent}->{$mapId}->{name} = $mapName;
			%{$self->{fileContent}->{$mapId}->{content}} = map {$_ => {}} @ids;
		}
		close(IN);
	}
	sub createFromNodes {
		use Data::Dumper;
		my $self = shift;
		my %args = (
			nodesFolder => "",
			dataType => "",
			mapDB => "",
			organismCode => "",
			@_
		);
		my $nodesFolder = $args{nodesFolder};
		my $mapDB = $args{mapDB};
		my $organismCode = $args{organismCode};
		my $dataType = $args{dataType};
		opendir(DIR,$nodesFolder);
		
		foreach my $nodeFile (readdir(DIR)) {
			next if (
				$nodeFile eq "." ||
				$nodeFile eq ".." ||
				$nodeFile !~ /\.nodes$/
			);
			my $nodeId = $nodeFile;
			$nodeId =~ s/\.nodes$//;
			my $nodeFile = new Node(
				organismCode => $organismCode,
				fileName => $nodeId,
				mapsDB => $mapDB,
			);
			$nodeFile -> loadContent();
			$self -> {fileContent} -> {$nodeFile->{id}} -> {id} = $nodeFile->{id};
			$self -> {fileContent} -> {$nodeFile->{id}} -> {name} = $nodeFile->{name};
			%{$self->{fileContent}->{$nodeFile->{id}}->{content}} = map {$_ => {}} keys(%{$nodeFile->{data}->{$dataType}});
		}
		closedir(DIR);
		print STDERR Dumper $self;
	}
	sub printContent {
		my $self = shift;
		my %args = (
			outFile => "",
			@_
		);
		my $outFile = $args{outFile};
		open(OUT,">",$outFile);
		foreach my $mapId (keys %{$self->{fileContent}}) {
			next if (!$mapId);
			print OUT "$mapId\t$self->{fileContent}->{$mapId}->{name}\t".(join("\t",keys(%{$self->{fileContent}->{$mapId}->{content}})))."\n";
		}
		close(OUT);
	}


1;
