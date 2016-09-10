﻿# This file is part of Product Opener.
# 
# Product Opener
# Copyright (C) 2016 Association Open Food Facts
# Contact: contact@openfoodfacts.org
# Address: 21 rue des Iles, 94100 Saint-Maur des Fossés, France
# 
# Product Opener is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
# 
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


package ProductOpener::Text;

BEGIN
{
	use vars       qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
	require Exporter;
	@ISA = qw(Exporter);
	@EXPORT = qw();            # symbols to export by default
	@EXPORT_OK = qw(
					&normalize_percentages
					
					);	# symbols to export on request
	%EXPORT_TAGS = (all => [@EXPORT_OK]);
}

 use vars @EXPORT_OK ;
 use strict;
 use warnings;
 use utf8;

 use CLDR::Number;
 use CLDR::Number::Format::Percent;

sub normalize_percentages($$) {

	my ($text, $locale) = @_;

	my $cldr = CLDR::Number->new(locale => $locale);
	my $regex = _get_locale_percent_regex($cldr);
	my $perf = $cldr->percent_formatter( maximum_fraction_digits => 2 );

	my $output = $text =~ s/$rex/''._format_percentage($1, $cldr, $perf).''/eg;
	return $output;
}

%ProductOpener::Text::regexes = ();
sub _get_locale_percent_regex($) {

	my ($cldr) = @_;

	if (defined $ProductOpener::Text::regexes{$cldr}) {
		return $ProductOpener::Text::regexes{$cldr};
	}

	# this should escape '.' to '\.' to be used in the regex ...
	my $p = quotemeta($cldr->plus_sign);
	my $m = quotemeta($cldr->minus_sign);
	my $g = quotemeta($cldr->group_sign);
	my $d = quotemeta($cldr->decimal_sign);

	# [+-]?(?:\d{3}\.)*\d+(?:,\d+)*\h*% where . is the group sign from the locale, and , is the decimal point
	my $regex = qr/([$p$m]?(?:\d{3}$g)*\d+(?:$d\d+)*\h*%)/;
	$ProductOpener::Text::regexes{$cldr} = $regex;
	return $regex;

}

sub _format_percentage($$$) {

	my ($value, $cldr, $perf) = @_;

	# this should escape '.' to '\.' to be used in the regex ...
	my $p = quotemeta($cldr->plus_sign);
	my $m = quotemeta($cldr->minus_sign);
	my $g = quotemeta($cldr->group_sign);
	my $d = quotemeta($cldr->decimal_sign);

	# 1 make the string float parseable by Perl
	# 1.1 remove % and group sign
	$value =~ s/[%$g]/g;
	# 1.2 replace decimal sign with a decimal dot
	$value =~ s/$d/./g;
}

1;
