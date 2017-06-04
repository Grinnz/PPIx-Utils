package PPIx::Utils::Classification;

use strict;
use warnings;
use B::Keywords;
use Exporter 'import';
use ReadonlyX;
use Scalar::Util 'blessed';

use PPIx::Utils::Traversal qw(first_arg parse_arg_list);
# Functions also used by PPIx::Utils::Traversal
use PPIx::Utils::_Common qw(
    is_ppi_expression_or_generic_statement
    is_ppi_simple_statement
);

our $VERSION = '0.001';

our @EXPORT_OK = qw(
    is_assignment_operator
    is_class_name
    is_function_call
    is_hash_key
    is_in_void_context
    is_included_module_name
    is_integer
    is_label_pointer
    is_method_call
    is_package_declaration
    is_perl_bareword
    is_perl_builtin
    is_perl_builtin_with_list_context
    is_perl_builtin_with_multiple_arguments
    is_perl_builtin_with_no_arguments
    is_perl_builtin_with_one_argument
    is_perl_builtin_with_optional_argument
    is_perl_builtin_with_zero_and_or_one_arguments
    is_perl_filehandle
    is_perl_global
    is_qualified_name
    is_subroutine_name
    is_unchecked_call
    is_ppi_expression_or_generic_statement
    is_ppi_generic_statement
    is_ppi_statement_subclass
    is_ppi_simple_statement
    is_ppi_constant_element
    is_subroutine_declaration
    is_in_subroutine
);

our %EXPORT_TAGS = (all => [@EXPORT_OK]);

sub _name_for_sub_or_stringified_element {
    my $elem = shift;

    if ( blessed $elem and $elem->isa('PPI::Statement::Sub') ) {
        return $elem->name();
    }

    return "$elem";
}

Readonly::Hash my %BUILTINS => map { $_ => 1 } @B::Keywords::Functions;

sub is_perl_builtin {
    my $elem = shift;
    return undef if !$elem;

    return exists $BUILTINS{ _name_for_sub_or_stringified_element($elem) };
}

Readonly::Hash my %BAREWORDS => map { $_ => 1 } @B::Keywords::Barewords;

sub is_perl_bareword {
    my $elem = shift;
    return undef if !$elem;

    return exists $BAREWORDS{ _name_for_sub_or_stringified_element($elem) };
}

sub _build_globals_without_sigils {
    # B::Keywords as of 1.08 forgot $\
    my @globals =
        map { substr $_, 1 }
            @B::Keywords::Arrays,
            @B::Keywords::Hashes,
            @B::Keywords::Scalars,
            '$\\';

    # Not all of these have sigils
    foreach my $filehandle (@B::Keywords::Filehandles) {
        (my $stripped = $filehandle) =~ s< \A [*] ><>xms;
        push @globals, $stripped;
    }

    return @globals;
}

Readonly::Array my @GLOBALS_WITHOUT_SIGILS => _build_globals_without_sigils();

Readonly::Hash my %GLOBALS => map { $_ => 1 } @GLOBALS_WITHOUT_SIGILS;

sub is_perl_global {
    my $elem = shift;
    return undef if !$elem;
    my $var_name = "$elem"; #Convert Token::Symbol to string
    $var_name =~ s{\A [\$@%*] }{}xms;  #Chop off the sigil
    return exists $GLOBALS{ $var_name };
}

Readonly::Hash my %FILEHANDLES => map { $_ => 1 } @B::Keywords::Filehandles;

sub is_perl_filehandle {
    my $elem = shift;
    return undef if !$elem;

    return exists $FILEHANDLES{ _name_for_sub_or_stringified_element($elem) };
}

# egrep '=item.*LIST' perlfunc.pod
Readonly::Hash my %BUILTINS_WHICH_PROVIDE_LIST_CONTEXT =>
    map { $_ => 1 }
        qw{
            chmod
            chown
            die
            exec
            formline
            grep
            import
            join
            kill
            map
            no
            open
            pack
            print
            printf
            push
            reverse
            say
            sort
            splice
            sprintf
            syscall
            system
            tie
            unlink
            unshift
            use
            utime
            warn
        };

sub is_perl_builtin_with_list_context {
    my $elem = shift;

    return
        exists
            $BUILTINS_WHICH_PROVIDE_LIST_CONTEXT{
                _name_for_sub_or_stringified_element($elem)
            };
}

# egrep '=item.*[A-Z],' perlfunc.pod
Readonly::Hash my %BUILTINS_WHICH_TAKE_MULTIPLE_ARGUMENTS =>
    map { $_ => 1 }
        qw{
            accept
            atan2
            bind
            binmode
            bless
            connect
            crypt
            dbmopen
            fcntl
            flock
            gethostbyaddr
            getnetbyaddr
            getpriority
            getservbyname
            getservbyport
            getsockopt
            index
            ioctl
            link
            listen
            mkdir
            msgctl
            msgget
            msgrcv
            msgsnd
            open
            opendir
            pipe
            read
            recv
            rename
            rindex
            seek
            seekdir
            select
            semctl
            semget
            semop
            send
            setpgrp
            setpriority
            setsockopt
            shmctl
            shmget
            shmread
            shmwrite
            shutdown
            socket
            socketpair
            splice
            split
            substr
            symlink
            sysopen
            sysread
            sysseek
            syswrite
            truncate
            unpack
            vec
            waitpid
        },
        keys %BUILTINS_WHICH_PROVIDE_LIST_CONTEXT;

sub is_perl_builtin_with_multiple_arguments {
    my $elem = shift;

    return
        exists
            $BUILTINS_WHICH_TAKE_MULTIPLE_ARGUMENTS{
                _name_for_sub_or_stringified_element($elem)
            };
}

Readonly::Hash my %BUILTINS_WHICH_TAKE_NO_ARGUMENTS =>
    map { $_ => 1 }
        qw{
            endgrent
            endhostent
            endnetent
            endprotoent
            endpwent
            endservent
            fork
            format
            getgrent
            gethostent
            getlogin
            getnetent
            getppid
            getprotoent
            getpwent
            getservent
            setgrent
            setpwent
            split
            time
            times
            wait
            wantarray
        };

sub is_perl_builtin_with_no_arguments {
    my $elem = shift;

    return
        exists
            $BUILTINS_WHICH_TAKE_NO_ARGUMENTS{
                _name_for_sub_or_stringified_element($elem)
            };
}

Readonly::Hash my %BUILTINS_WHICH_TAKE_ONE_ARGUMENT =>
    map { $_ => 1 }
        qw{
            closedir
            dbmclose
            delete
            each
            exists
            fileno
            getgrgid
            getgrnam
            gethostbyname
            getnetbyname
            getpeername
            getpgrp
            getprotobyname
            getprotobynumber
            getpwnam
            getpwuid
            getsockname
            goto
            keys
            local
            prototype
            readdir
            readline
            readpipe
            rewinddir
            scalar
            sethostent
            setnetent
            setprotoent
            setservent
            telldir
            tied
            untie
            values
        };

sub is_perl_builtin_with_one_argument {
    my $elem = shift;

    return
        exists
            $BUILTINS_WHICH_TAKE_ONE_ARGUMENT{
                _name_for_sub_or_stringified_element($elem)
            };
}

Readonly::Hash my %BUILTINS_WHICH_TAKE_OPTIONAL_ARGUMENT =>
    map { $_ => 1 }
        grep { not exists $BUILTINS_WHICH_TAKE_ONE_ARGUMENT{ $_ } }
        grep { not exists $BUILTINS_WHICH_TAKE_NO_ARGUMENTS{ $_ } }
        grep { not exists $BUILTINS_WHICH_TAKE_MULTIPLE_ARGUMENTS{ $_ } }
        @B::Keywords::Functions;

sub is_perl_builtin_with_optional_argument {
    my $elem = shift;

    return
        exists
            $BUILTINS_WHICH_TAKE_OPTIONAL_ARGUMENT{
                _name_for_sub_or_stringified_element($elem)
            };
}

sub is_perl_builtin_with_zero_and_or_one_arguments {
    my $elem = shift;

    return undef if not $elem;

    my $name = _name_for_sub_or_stringified_element($elem);

    return (
            exists $BUILTINS_WHICH_TAKE_ONE_ARGUMENT{ $name }
        or  exists $BUILTINS_WHICH_TAKE_NO_ARGUMENTS{ $name }
        or  exists $BUILTINS_WHICH_TAKE_OPTIONAL_ARGUMENT{ $name }
    );
}

sub is_qualified_name {
    my $name = shift;

    return undef if not $name;

    return index ( $name, q{::} ) >= 0;
}

sub _is_followed_by_parens {
    my $elem = shift;
    return undef if !$elem;

    my $sibling = $elem->snext_sibling() || return undef;
    return $sibling->isa('PPI::Structure::List');
}

sub is_hash_key {
    my $elem = shift;
    return undef if !$elem;

    #If followed by an argument list, then its a function call, not a literal
    return undef if _is_followed_by_parens($elem);

    #Check curly-brace style: $hash{foo} = bar;
    my $parent = $elem->parent();
    return undef if !$parent;
    my $grandparent = $parent->parent();
    return undef if !$grandparent;
    return 1 if $grandparent->isa('PPI::Structure::Subscript');


    #Check declarative style: %hash = (foo => bar);
    my $sib = $elem->snext_sibling();
    return undef if !$sib;
    return 1 if $sib->isa('PPI::Token::Operator') && $sib eq '=>';

    return undef;
}

sub is_included_module_name {
    my $elem  = shift;
    return undef if !$elem;
    my $stmnt = $elem->statement();
    return undef if !$stmnt;
    return undef if !$stmnt->isa('PPI::Statement::Include');
    return $stmnt->schild(1) == $elem;
}

sub is_integer {
    my ($value) = @_;
    return 0 if not defined $value;

    return $value =~ m{ \A [+-]? \d+ \z }xms;
}

sub is_label_pointer {
    my $elem = shift;
    return undef if !$elem;

    my $statement = $elem->statement();
    return undef if !$statement;

    my $psib = $elem->sprevious_sibling();
    return undef if !$psib;

    return $statement->isa('PPI::Statement::Break')
        && $psib =~ m/(?:redo|goto|next|last)/xmso;
}

sub _is_dereference_operator {
    my $elem = shift;
    return undef if !$elem;

    return $elem->isa('PPI::Token::Operator') && $elem eq q{->};
}

sub is_method_call {
    my $elem = shift;
    return undef if !$elem;

    return _is_dereference_operator( $elem->sprevious_sibling() );
}

sub is_class_name {
    my $elem = shift;
    return undef if !$elem;

    return _is_dereference_operator( $elem->snext_sibling() )
        && !_is_dereference_operator( $elem->sprevious_sibling() );
}

sub is_package_declaration {
    my $elem  = shift;
    return undef if !$elem;
    my $stmnt = $elem->statement();
    return undef if !$stmnt;
    return undef if !$stmnt->isa('PPI::Statement::Package');
    return $stmnt->schild(1) == $elem;
}

sub is_subroutine_name {
    my $elem  = shift;
    return undef if !$elem;
    my $sib   = $elem->sprevious_sibling();
    return undef if !$sib;
    my $stmnt = $elem->statement();
    return undef if !$stmnt;
    return $stmnt->isa('PPI::Statement::Sub') && $sib eq 'sub';
}

sub is_function_call {
    my $elem = shift or return undef;

    return undef if is_perl_bareword($elem);
    return undef if is_perl_filehandle($elem);
    return undef if is_package_declaration($elem);
    return undef if is_included_module_name($elem);
    return undef if is_method_call($elem);
    return undef if is_class_name($elem);
    return undef if is_subroutine_name($elem);
    return undef if is_label_pointer($elem);
    return undef if is_hash_key($elem);

    return 1;
}

sub is_in_void_context {
    my ($token) = @_;

    # If part of a collective, can't be void.
    return undef if $token->sprevious_sibling();

    my $parent = $token->statement()->parent();
    if ($parent) {
        return undef if $parent->isa('PPI::Structure::List');
        return undef if $parent->isa('PPI::Structure::For');
        return undef if $parent->isa('PPI::Structure::Condition');
        return undef if $parent->isa('PPI::Structure::Constructor');
        return undef if $parent->isa('PPI::Structure::Subscript');

        my $grand_parent = $parent->parent();
        if ($grand_parent) {
            return undef if
                    $parent->isa('PPI::Structure::Block')
                and not $grand_parent->isa('PPI::Statement::Compound');
        }
    }

    return 1;
}

Readonly::Hash my %ASSIGNMENT_OPERATORS => map { $_ => 1 } qw( = **= += -= .= *= /= %= x= &= |= ^= <<= >>= &&= ||= //= ) );

sub is_assignment_operator {
    my $elem = shift;

    return $ASSIGNMENT_OPERATORS{ $elem };
}

sub is_unchecked_call {
    my $elem = shift;

    return undef if not is_function_call( $elem );

    # check to see if there's an '=' or 'unless' or something before this.
    if( my $sib = $elem->sprevious_sibling() ){
        return undef if $sib;
    }


    if( my $statement = $elem->statement() ){

        # "open or die" is OK.
        # We can't check snext_sibling for 'or' since the next siblings are an
        # unknown number of arguments to the system call. Instead, check all of
        # the elements to this statement to see if we find 'or' or '||'.

        my $or_operators = sub  {
            my (undef, $elem) = @_;
            return undef if not $elem->isa('PPI::Token::Operator');
            return undef if $elem ne q{or} && $elem ne q{||};
            return 1;
        };

        return undef if $statement->find( $or_operators );


        if( my $parent = $elem->statement()->parent() ){

            # Check if we're in an if( open ) {good} else {bad} condition
            return undef if $parent->isa('PPI::Structure::Condition');

            # Return val could be captured in data structure and checked later
            return undef if $parent->isa('PPI::Structure::Constructor');

            # "die if not ( open() )" - It's in list context.
            if ( $parent->isa('PPI::Structure::List') ) {
                if( my $uncle = $parent->sprevious_sibling() ){
                    return undef if $uncle;
                }
            }
        }
    }

    return undef if _is_fatal($elem);

    # Otherwise, return. this system call is unchecked.
    return 1;
}

# Based upon autodie 2.10.
Readonly::Hash my %AUTODIE_PARAMETER_TO_AFFECTED_BUILTINS_MAP => (
    # Map builtins to themselves.
    (
        map { ($_ => { $_ => 1 }) }
            qw<
                accept bind binmode chdir chmod close closedir connect
                dbmclose dbmopen exec fcntl fileno flock fork getsockopt ioctl
                link listen mkdir msgctl msgget msgrcv msgsnd open opendir
                pipe read readlink recv rename rmdir seek semctl semget semop
                send setsockopt shmctl shmget shmread shutdown socketpair
                symlink sysopen sysread sysseek system syswrite truncate umask
                unlink
            >
    ),

    # Generate these using tools/dump-autodie-tag-contents
    ':threads'      => { map { $_ => 1 } qw< fork                        > },
    ':system'       => { map { $_ => 1 } qw< exec system                 > },
    ':dbm'          => { map { $_ => 1 } qw< dbmclose dbmopen            > },
    ':semaphore'    => { map { $_ => 1 } qw< semctl semget semop         > },
    ':shm'          => { map { $_ => 1 } qw< shmctl shmget shmread       > },
    ':msg'          => { map { $_ => 1 } qw< msgctl msgget msgrcv msgsnd > },
    ':file'     => {
        map { $_ => 1 }
            qw<
                binmode chmod close fcntl fileno flock ioctl open sysopen
                truncate
            >
    },
    ':filesys'      => {
        map { $_ => 1 }
            qw<
                chdir closedir link mkdir opendir readlink rename rmdir
                symlink umask unlink
            >
    },
    ':ipc'      => {
        map { $_ => 1 }
            qw<
                msgctl msgget msgrcv msgsnd pipe semctl semget semop shmctl
                shmget shmread
            >
    },
    ':socket'       => {
        map { $_ => 1 }
            qw<
                accept bind connect getsockopt listen recv send setsockopt
                shutdown socketpair
            >
    },
    ':io'       => {
        map { $_ => 1 }
            qw<
                accept bind binmode chdir chmod close closedir connect
                dbmclose dbmopen fcntl fileno flock getsockopt ioctl link
                listen mkdir msgctl msgget msgrcv msgsnd open opendir pipe
                read readlink recv rename rmdir seek semctl semget semop send
                setsockopt shmctl shmget shmread shutdown socketpair symlink
                sysopen sysread sysseek syswrite truncate umask unlink
            >
    },
    ':default'      => {
        map { $_ => 1 }
            qw<
                accept bind binmode chdir chmod close closedir connect
                dbmclose dbmopen fcntl fileno flock fork getsockopt ioctl link
                listen mkdir msgctl msgget msgrcv msgsnd open opendir pipe
                read readlink recv rename rmdir seek semctl semget semop send
                setsockopt shmctl shmget shmread shutdown socketpair symlink
                sysopen sysread sysseek syswrite truncate umask unlink
            >
    },
    ':all'      => {
        map { $_ => 1 }
            qw<
                accept bind binmode chdir chmod close closedir connect
                dbmclose dbmopen exec fcntl fileno flock fork getsockopt ioctl
                link listen mkdir msgctl msgget msgrcv msgsnd open opendir
                pipe read readlink recv rename rmdir seek semctl semget semop
                send setsockopt shmctl shmget shmread shutdown socketpair
                symlink sysopen sysread sysseek system syswrite truncate umask
                unlink
            >
    },
);

sub _is_fatal {
    my ($elem) = @_;

    my $top = $elem->top();
    return undef if not $top->isa('PPI::Document');

    my $includes = $top->find('PPI::Statement::Include');
    return undef if not $includes;

    for my $include (@{$includes}) {
        next if 'use' ne $include->type();

        if ('Fatal' eq $include->module()) {
            my @args = parse_arg_list($include->schild(1));
            foreach my $arg (@args) {
                return 1 if $arg->[0]->isa('PPI::Token::Quote') && $elem eq $arg->[0]->string();
            }
        }
        elsif ('Fatal::Exception' eq $include->module()) {
            my @args = parse_arg_list($include->schild(1));
            shift @args;  # skip exception class name
            foreach my $arg (@args) {
                return 1 if $arg->[0]->isa('PPI::Token::Quote') && $elem eq $arg->[0]->string();
            }
        }
        elsif ('autodie' eq $include->pragma()) {
            return _is_covered_by_autodie($elem, $include);
        }
    }

    return undef;
}

sub _is_covered_by_autodie {
    my ($elem, $include) = @_;

    my $autodie = $include->schild(1);
    my @args = parse_arg_list($autodie);
    my $first_arg = first_arg($autodie);

    # The first argument to any `use` pragma could be a version number.
    # If so, then we just discard it. We only want the arguments after it.
    if ($first_arg and $first_arg->isa('PPI::Token::Number')){ shift @args };

    if (@args) {
        foreach my $arg (@args) {
            my $builtins =
                $AUTODIE_PARAMETER_TO_AFFECTED_BUILTINS_MAP{
                    $arg->[0]->string
                };

            return 1 if $builtins and $builtins->{$elem->content()};
        }
    }
    else {
        my $builtins =
            $AUTODIE_PARAMETER_TO_AFFECTED_BUILTINS_MAP{':default'};

        return 1 if $builtins and $builtins->{$elem->content()};
    }

    return undef;
}

sub is_ppi_generic_statement {
    my $element = shift;

    my $element_class = blessed($element);

    return undef if not $element_class;
    return undef if not $element->isa('PPI::Statement');

    return $element_class eq 'PPI::Statement';
}

sub is_ppi_statement_subclass {
    my $element = shift;

    my $element_class = blessed($element);

    return undef if not $element_class;
    return undef if not $element->isa('PPI::Statement');

    return $element_class ne 'PPI::Statement';
}

sub is_ppi_constant_element {
    my $element = shift or return undef;

    blessed( $element ) or return undef;

    # TODO implement here documents once PPI::Token::HereDoc grows the
    # necessary PPI::Token::Quote interface.
    return
            $element->isa( 'PPI::Token::Number' )
        ||  $element->isa( 'PPI::Token::Quote::Literal' )
        ||  $element->isa( 'PPI::Token::Quote::Single' )
        ||  $element->isa( 'PPI::Token::QuoteLike::Words' )
        ||  (
                $element->isa( 'PPI::Token::Quote::Double' )
            ||  $element->isa( 'PPI::Token::Quote::Interpolate' ) )
            &&  $element->string() !~ m< (?: \A | [^\\] ) (?: \\\\)* [\$\@] >smx
        ;
}

sub is_subroutine_declaration {
    my $element = shift;

    return undef if not $element;

    return 1 if $element->isa('PPI::Statement::Sub');

    if ( is_ppi_generic_statement($element) ) {
        my $first_element = $element->first_element();

        return 1 if
                $first_element
            and $first_element->isa('PPI::Token::Word')
            and $first_element->content() eq 'sub';
    }

    return undef;
}

sub is_in_subroutine {
    my ($element) = @_;

    return undef if not $element;
    return 1 if is_subroutine_declaration($element);

    while ( $element = $element->parent() ) {
        return 1 if is_subroutine_declaration($element);
    }

    return undef;
}

1;

=head1 NAME

PPIx::Utils::Classification - Utility functions for classification of PPI
elements

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

L<Perl::Critic::Utils>, L<Perl::Critic::Utils::PPI>
