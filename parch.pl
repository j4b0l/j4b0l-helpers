#!/usr/bin/env perl

# ParCh - Parentheses Checker
# This script will help you make your code dry (or semi-dry).
# This script checks if parentheses are correctly and consequently placed
# throuthout whole commit.
# Unparametrized for now - patience you must have, my young padawan

use strict;
use warnings;

my $path = shift or die "needs one parameter - path to repository";
my $brackets;
my $indentTabs=0;
my $indentSpaces=0;
my $errors=0;
$brackets->{'both-on-EOL-no-space'}=0;
$brackets->{'both-on-EOL-with-space'}=0;
$brackets->{'round-enter-curly'}=0;

if ( -d $path ) {
    chdir($path);
    my $previousClosedRoundBracket='';
    my $command = 'git show HEAD|grep ^+|sed s/^+//g';

    foreach (`$command`) {
        if (/\)\{/) {
            $brackets->{'both-on-EOL-no-space'}++;
        } elsif (/\)\s+\{\s*$/) {
            $brackets->{'both-on-EOL-with-space'}++;
        } elsif (/\)\s*$/) {
            $previousClosedRoundBracket=$_;
        } elsif (/^\s+\{/ && $previousClosedRoundBracket ne "") {
            $brackets->{'round-enter-curly'}++;
            $previousClosedRoundBracket="";
        }
        if (/^\t+\w/) {
            $indentTabs++;
        } elsif (/^\s+\w/) {
            $indentSpaces++;
        }
    }
}

if (($brackets->{'both-on-EOL-no-space'}+$brackets->{'both-on-EOL-with-space'})*$brackets->{'round-enter-curly'}++>0) {
    print "You use various conventions of curly bracket placement, please make it more consistent.\n";
    $errors++;
}

if ($brackets->{'both-on-EOL-no-space'}>0) {
    print "You should consider placing space between ) and { while opening new code block.\n";
    $errors++;
}

if ($indentTabs>0) {
    print "You should use spaces instead of tabs for code formatting.\n";
    $errors++;
}

if ($errors>0) {
    exit 1;
} else {
    exit 0;
}

