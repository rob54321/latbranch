#!/usr/bin/perl
# this script reads the command line parameter as
# the project name. It clones this project, determines
# the latest branch from the server and checks it out.
# this is done so builddebiantree can have an option
# where the latest code can be placed in a debian package
# without knowing the branch name or remote name.

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
# lbranch no parameters passed or returned
sub lbranch { 
	# get remote name
	my $rname = getremote;
	
	# get heads and sort
	# line 0 will be the latest head, line 1 next etc
	my @line = `git ls-remote --heads --sort=-committerdate $rname`;

	# each line contains "commit refs/heads/branch_name"
	# the first line will have the newest date
	# get branch latest branch, it will appear first on the list
	my $lbranch = (split (/\//, $line[0]))[2];
	chomp($lbranch);

	# checkout latest branch so software is available to place in the linux repo
	my $rc = system("git checkout $lbranch");
	die ("Could not checkout $lbranch from $rname:$!\n") unless $rc == 0;
	
	# print remote name and latest branch
	print "remote: $rname\t latest branch: $lbranch\n";
}

#####################################################################
# main entry
#####################################################################

# target directory to clone into
my $targetdir = "/home/robert/tmp/gproject";
unlink $targetdir;

# clone the project
cloneg $targetdir;

# change directory to target directory after clone
chdir $targetdir;

# get latest branch, check it out 
lbranch;
