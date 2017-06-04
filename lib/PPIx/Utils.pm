package PPIx::Utils;

use strict;
use warnings;
use Exporter 'import';

use PPIx::Utils::Characters ':all';
use PPIx::Utils::Classification ':all';
use PPIx::Utils::Language ':all';
use PPIx::Utils::Traversal ':all';

our $VERSION = '0.001';

our @EXPORT_OK = (
    @PPIx::Utils::Characters::EXPORT_OK,
    @PPIx::Utils::Classification::EXPORT_OK,
    @PPIx::Utils::Language::EXPORT_OK,
    @PPIx::Utils::Traversal::EXPORT_OK,
);

our %EXPORT_TAGS = (
    all            => [@EXPORT_OK],
    characters     => [@PPIx::Utils::Characters::EXPORT_OK],
    classification => [@PPIx::Utils::Classification::EXPORT_OK],
    language       => [@PPIx::Utils::Language::EXPORT_OK],
    traversal      => [@PPIx::Utils::Traversal::EXPORT_OK],
);

1;

=head1 NAME

PPIx::Utils - Utility functions for PPI

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Maintained by Dan Book <dbook@cpan.org>

Code originally from L<Perl::Critic::Utils> and L<Perl::Critic::Utils::PPI> by
Jeffrey Ryan Thalhammer <jeff@imaginative-software.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2005-2011 by Imaginative Software Systems.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 SEE ALSO

L<Perl::Critic::Utils>
