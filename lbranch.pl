#!/usr/bin/perl
# this script determines the branch with the latest branch
# in a cloned project. The current branch may not be 
# the latest branch. The latest branch is checked out
# so the files will be from the last commit of the latest branch.

use strict;
use warnings;

# sub to clone a git project
# cloneg (targetdirectory)
sub cloneg {
	# get parameters
	my($directory) = $_[0];

	# project name is project_name.git
	# remove directory
	system("rm -rf $directory");
	
	# pname = project_name
	# project name was passed as a command line parameter
	my $pname = $ARGV[0];
	# check a repository name was given on the command line.
	# initialise-linux.git is given as initialise-linux
	die "No project name given on command line\n" unless $ARGV[0];
	my $rc = system("git clone -n -v https://github.com/rob54321/$pname" . ".git" . " $directory");
	# die if unsuccessful
	die "Error cloning $pname.git:$!\n" unless $rc == 0;
}

# sub to get the remote name
sub getremote {
	my @remotelist = `git remote`;
	chomp (@remotelist);
	print "remote list: @remotelist\n";
	return $remotelist[0];
}


# sub to determine latest commit of latest branch
# and checkout the latest branch
# sub to get latest branch with latest commit checked out
# lbranch(ref_to_%binfo, ref to @branch)
sub lbranch { 
	# get parameters
	my ($rbinfo, $rbranch) = @_;

	# get remote name
	my $rname = getremote;
	
	# get heads and sort
	# line 0 will be the latest head, line 1 next etc
	my @line = `git ls-remote --heads --sort=-committerdate $rname`;

	for (my $i =0; $i<= $#line; $i++) {

		# each line contains commit, refs/heads/branch_name
		# get branch 
		my $branch = (split (/\//, $line[$i]))[2];
		chomp($branch);

		# make an ordered list of branches, newest first.
		# a hash has no order
		push(@{$rbranch}, $branch);
		
		# get the commit for the branch
		$rbinfo->{$branch} = (split(/\s+/, $line[$i]))[0];
	}

	# checkout latest branch so software is available to place in the linux repo
	my $rc = system("git checkout $rbranch->[0]");
	die ("Could not checkout $rbranch->[0] from $rname:$!\n") unless $rc == 0;
	
	# print results from newest to oldest
	for (my $i = 0; $i <= $#{$rbranch}; $i++) {
		print "$rbranch->[$i] => $rbinfo->{$rbranch->[$i]}\n";
	}

	# print remote name and latest branch
	print "remote: $rname\t latest branch: $rbranch->[0]\n";
}

#####################################################################
# main entry
#####################################################################

# binfo contains (branch_name => commit_hash)
# there is no order in a hash
# hence @branch is used to keep an ordered list
# of branches. Newest to oldest.
my %binfo;

# an ordered list of branches
# newest first. a hash has no order
my @branch = ();

# target directory to clone into
my $targetdir = "/home/robert/tmp/gproject";
unlink $targetdir;

# clone the project
cloneg $targetdir;

# change directory to target directory after clone
chdir $targetdir;

# get latest branch, check it out 
lbranch (\%binfo, \@branch);
