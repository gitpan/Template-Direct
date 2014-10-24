#!perl -T

use Test::More tests => 39;
use strict;

BEGIN {
  use_ok( 'Template::Direct' );
}

my $document = Template::Direct->new(
	Directory => 'data/',
	Location  => 'simple.html',
);

my $result = $document->compile(
	[ {
		Simple1 => 'foo',
		Simple2 => 'bar',
		hash    => {
			A => '1',
			B => '2',
			C => '3',
		},
		array   => [ 'A', 'B', 'C' ],
		array2  => [ [ 'A', 'B', 'C' ], [ 'D', 'E', 'F' ], [ 'G', 'H', 'I' ] ],
		array3  => [ { A => 1, B => 2, C => 3 }, { A => 4, B => 5, C => 6 } ],
		array4  => [ { A => [qw/1 2 3/] }, { A => [qw/4 5 6/] }, { A => [qw/7 8 9/] } ],
		array5  => [ { subhash => { A => '1', B => '2', C => undef } }, { subhash => undef }, undef ],
		array6  => [ {
			name   => 'One',
			'values' => [
				{ name => 'A' },
				{ name => 'Uno' },
				{ name => 'Ngang'},
			] }, {
			name => 'Two',
			'values' => [
				{ name => 'B' },
				{ name => 'Duo' },
				{ name => 'Song' },
			] },
		],
		integer => 12,
		struct1 => [
			{ name => 'A',   value => '1' },
			{ name => 'B',   value => '2', children => [
                { name => 'BA',   value => '21' },
                { name => 'BB',   value => '22' },
			]},	
			{ name => 'C', value => '3', children => [
				{ name => 'CA',   value => '31' },
				{ name => 'CB',   value => '32' },
				{ name => 'CC', value => '33', children => [
					{ name => 'CCA', value => '331' },
					{ name => 'CCB', value => '332' },
				]},
			]},
		],
		struct2 => [
			{ name => 'A', value => '1' },
			{ name => 'B', value => '2', other => ['K', 'L'], children => [
				{ id => 'Alpha', other => ['V', 'X'] },
				{ id => 'Beta', other => ['J', 'M'], subchildren => [
					{ name => 'B-Beta', value => '22', other => ['F', 'P'] },
					{ name => 'C-Beta', value => '33', other => ['S', 'T'], children => [
						{ id => 'Delta', other => ['Y', 'L'] },
						{ id => 'Gamma', other => ['S', 'D'] },
					] },
				] },
			] },
		],
		struct3 => [
			{ v1 => { name => 'A' }, v2 => { name => 'Z' } },
			{ v1 => { name => 'B' }, v2 => { name => 'H' } },
			{ v1 => { name => 'C' }, v2 => { name => 'X' } },
		]
	} ],
);

my %tests = (
	s1 => 'Variables 1',
	s2 => 'Variables 2',
	h0 => 'Hash Listing',
	h1 => 'Hash Variables 1',
	h2 => 'Hash Variables 2',
	h3 => 'Hash Listed Integer List',
	l0 => 'Array Listing',
	l1 => 'Array Variables 1',
	l2 => 'Array Variables 2',
	l3 => 'Double Array Listing',
	l4 => 'Array List with Hash Variables',
	l5 => 'Double List with Hash names',
	nl0 => 'Invalid List Displays No Entry',
	nl1 => 'Invalid List Alternative Format',
	i0 => 'Integer List',
	i1 => 'Integer Variables',
	i2 => 'Hash Integer List',
	i3 => 'Integer in List Name',
	c1 => 'Undefined List',
	e1 => 'Structurised Data',
	e2 => 'Double Structured Data',
	e3 => 'Double Prefixed first list',
	e4 => 'Double Prefixed second list',
	oe1 => 'Structure Conditional',
	oe2 => 'Double Structure Conditional',
	o1 => 'Simple Conditional',
	o2 => 'Complex Conditional',
	o3 => 'Not Conditional',
	o4 => 'Else-if Conditional',
	o5 => 'Multi Level Conditional',
	o6 => 'Conditional in Static Array',
	o7 => 'Conditional in Variable Array',
	o8 => 'Not Conditional in Variable Array',
	l6 => 'Arrays can exists after conditionals',
	li => 'Lists within lists with the same values',
	p1 => 'Included Page',
);
my %expected = (
	s1 => 'foo',
	s2 => 'bar',
	h0 => 'A=1, C=3, B=2',
	h1 => '1',
	h2 => '2',
	h3 => 'A=1; C=1, 2, 3; B=1, 2',
	l0 => 'A, B, C',
	l1 => 'A',
	l2 => 'B',
	l3 => '(A, B, C) - (D, E, F) - (G, H, I)',
	l4 => '(1, 2, 3) - (4, 5, 6)',
	l5 => '(1, 2, 3) - (4, 5, 6) - (7, 8, 9)',
	nl0 => 'TRUE',
	nl1 => 'TRUE',
	i0 => '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12',
	i1 => '12',
	i2 => '1, 2',
	i3 => '1, 2, 3, 4',
	c1 => '-A=1, C=, B=2, -',
	e1 => 'A:1,B:2(BA:21,BB:22),C:3(CA:31,CB:32,CC:33(CCA:331,CCB:332))',
	e2 => 'A=1,B=2(id:Alpha|id:Beta[B-Beta=22,C-Beta=33(id:Delta|id:Gamma)])',
	e3 => 'A=1,B=2(id:Alpha|V,X|id:Beta|J,M[B-Beta=22,C-Beta=33(id:Delta|Y,L|id:Gamma|S,D)])',
	e4 => 'A=1,B=2|K@L(id:Alpha|V,X|id:Beta|J,M[B-Beta=22|F@P,C-Beta=33|S@T(id:Delta|Y,L|id:Gamma|S,D)])',
	oe1 => 'Ey, Bee, Not',
	oe2 => 'Ey, Not, See',
	o1 => 'True',
	o2 => 'True',
	o3 => 'True',
	o4 => 'True',
	o5 => 'True',
	o6 => 'True',
	o7 => 'True',
	o8 => 'True',
	l6 => 'A, B, C',
	li => 'One=[A, Uno, Ngang], Two=[B, Duo, Song]',
	p1 => '*A=1, C=3, B=2*',
);

my $a = is(ref($document), 'Template::Direct', 'Document object creation');

if($a) {
	my @results = split(/\n/, $result);
	ok( scalar($#results), "Document Contents" );

	#print join("\n", @results);

	foreach my $result (@results) {
		chomp($result);
		if($result =~ /^(\w+)\:(.*)$/) {
			my $id = $1;
			my $sr = $2;
			if($tests{$id}) {
				#print "BLAH: $sr\n";
				is($sr, $expected{$id}, $tests{$id});
			}
		}
	}
}

