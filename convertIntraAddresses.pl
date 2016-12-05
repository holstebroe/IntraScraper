#!/bin/perl

 use Text::CSV;

 @ARGV == 1 or die ("$0 <csv file>");
 my $fileName = $ARGV[0];
 
 my @rows;
 my $csv = Text::CSV->new ( { binary => 1 } )  # should set binary attribute.
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();
				 
 $csv->eol ("\r\n");
open my $fh, "<:encoding(utf8)", $fileName or die "$fileName: $!";
# open my $fh, "<$fileName" or die "$fileName: $!";
 while ( my $row = $csv->getline( $fh ) ) {
     push @rows, $row;
 }
 $csv->eof or $csv->error_diag();
 close $fh;

 my @columns = $csv->fields();

&printGoogleHeader();

shift @rows; # remove header
foreach my $row (@rows)
{
   my @fields = @$row;
   my $name = $fields[0];
   $name =~ s/^\s*//g;
   $name =~ s/\s*$//g;
   my @parent = split(/\n/, $fields[1]);
   my @address = split(/\n/, $fields[2]);
   my @landline = split(/\n/, $fields[3]);
   my @mobile = split(/\n/, $fields[4]);
   my @work = split(/\n/, $fields[5]);
   my @email = split(/\n/, $fields[8]);
   &printGoogleContact($name, $parent[0], $address[0], $landline[0], $mobile[0], $work[0], $email[0], "mor");
   &printGoogleContact($name, $parent[1], $address[1], $landline[1], $mobile[1], $work[1], $email[1], "far");
}

sub printGoogleHeader
{
	print "Name,Given Name,Additional Name,Family Name,Yomi Name,Given Name Yomi,Additional Name Yomi,Family Name Yomi,Name Prefix,Name Suffix,Initials,Nickname,Short Name,Maiden Name,Birthday,Gender,Location,Billing Information,Directory Server,Mileage,Occupation,Hobby,Sensitivity,Priority,Subject,Notes,Group Membership,E-mail 1 - Type,E-mail 1 - Value,E-mail 2 - Type,E-mail 2 - Value,E-mail 3 - Type,E-mail 3 - Value,E-mail 4 - Type,E-mail 4 - Value,Phone 1 - Type,Phone 1 - Value,Phone 2 - Type,Phone 2 - Value,Phone 3 - Type,Phone 3 - Value,Phone 4 - Type,Phone 4 - Value,Address 1 - Type,Address 1 - Formatted,Address 1 - Street,Address 1 - City,Address 1 - PO Box,Address 1 - Region,Address 1 - Postal Code,Address 1 - Country,Address 1 - Extended Address,Organization 1 - Type,Organization 1 - Name,Organization 1 - Yomi Name,Organization 1 - Title,Organization 1 - Department,Organization 1 - Symbol,Organization 1 - Location,Organization 1 - Job Description,Website 1 - Type,Website 1 - Value\n";

}

sub printGoogleContact
{
	my ($child, $parent, $address, $landline, $mobile, $work, $email, $relation) = @_;
	my $childFirstName = (split / /, $child)[0];
	my $parentFirstName = (split / /, $parent)[0];
	my $genetiv = (substr $childFirstName, -1) eq "s" ? "'" : "s";
	my $nickName = "$parentFirstName (${childFirstName}${genetiv} $relation)";
	$email =~ s/^\s*//g;
	$email =~ s/\s*$//g;
	$mobile = '' if ($mobile eq $landline);
	$work = '' if ($work eq $mobile);
	
	print "$parent,,,,,,,,,,,$nickName,,,,,,,,,,,,,,,* Virum B 2013,*,$email,,,,,,,Home,$landline,Mobile,$mobile,Work,$work,,,Home,\"$address\",,,,,,,,,,,,,,,,,\n";
}
