#!/usr/bin/env perl


=head1 NAME

 AddBananaOntologyProps.pm

=head1 SYNOPSIS

mx-run ThisPackageName [options] -H hostname -D dbname -u username [-F]

this is a subclass of L<CXGN::Metadata::Dbpatch>
see the perldoc of parent class for more details.

=head1 DESCRIPTION

This patch adds a cvtermprop for institutions using a given set of phenotypic trait.
This subclass uses L<Moose>. The parent class uses L<MooseX::Runnable>

=head1 AUTHOR

 Guillaume Bauchet<gjb99@cornell.edu>

=head1 COPYRIGHT & LICENSE

Copyright 2010 Boyce Thompson Institute for Plant Research

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


package AddBananaOntologyProps;

use Moose;
use Bio::Chado::Schema;
use Try::Tiny;
use JSON::Any;
use SGN::Model::Cvterm;
extends 'CXGN::Metadata::Dbpatch';


has '+description' => ( default => <<'' );
Description of this patch goes here

has '+prereq' => (
	default => sub {
        [],
    },
    
  );

sub patch {
    my $self=shift;
    my @array_ref;

    print STDOUT "Executing the patch:\n " .   $self->name . ".\n\nDescription:\n  ".  $self->description . ".\n\nExecuted by:\n " .  $self->username . " .";

    print STDOUT "\nChecking if this db_patch was executed before or if previous db_patches have been executed.\n";

    print STDOUT "\nExecuting the SQL commands.\n";
    my $schema = Bio::Chado::Schema->connect( sub { $self->dbh->clone } );
   

    print STDERR "INSERTING Cvtermprop TERMS...\n";

    my $ontology_cvterm = $schema->resultset("Cv::Cvterm")->create_with({
	name => "iita_ontology_term",
	cv   => "cvterm_property",
    });

    my $type_id = $formula_cvterm->cvterm_id();

    my @trait_names = ('sprouting proportion|CO:0000008', 'specific gravity|CO:0000163', 'dry matter content by specific gravity|CO:0000160', 'starch content percentage|CO:0000071') ;

    my @iita_trait_set = ('( sprout count at one-month|CO:0000213 / number of planted stakes counting|CO:0000159 )', '( root weight in air|CO:0000157 / ( root weight in air|CO:0000157 - root weight in water|CO:0000158 ) )', '( 158.3 * ( specific gravity|CO:0000163 ) - 142 )', '( 210.8 * ( specific gravity|CO:0000163 ) - 213.4 )') ;

    for (my $n=0; $n<scalar(@trait_names); $n++) {
	#my $trait_cvterm = SGN::Model::Cvterm->get_cvterm_row_from_trait_name($schema, $trait_names[$n]);
	my $dbxref = $self->schema()->resultset("General::Dbxref")->find(
	    {
		'db.name' =>$db_name,
		'me.accession'=>$dbxref_accession,
	    },
	    {join=>'db'}
	    );
	    
	if($dbxref){cvterm=$dbxref->cvterm;}
	    else {
		print STDERR "The trait $trait_names[$n] is not in the database. Skipping...\n";
		next();
    	}

	my $cvterm_id = $trait_cvterm->cvterm_id();
	my $new_prop= $trait_cvterm->create_cvtermprops({iita_ontology_term=>$iita_trait_set[$n]} , {} );	

    }

print "You're done!\n";
}


####
1; #
####
