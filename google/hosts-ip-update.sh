#!/bin/bash
#
# Copyright 2018 by Gregory L. Dietsche <gregory.dietsche@cuw.edu>
#
# This script generates a /etc/hosts file that can be used to turn safe search on permanently.
#
# From Google:
# If you’re managing a Google Account for a school or workplace, you can
# prevent most adult content from showing up in search results by turning on
# the SafeSearch setting. To force SafeSearch for your network, you’ll need to
# update your DNS configuration. Set the DNS entry for www.google.com (and any
# other Google ccTLD country subdomains your users may use) to be a CNAME for
# forcesafesearch.google.com.
#
# Forked And Modified since 20-04-2025

# Delete ALL before Executing
sed -i d /home/runner/work/safesearch-enforcing-hosts/safesearch-enforcing-hosts/google/hosts.txt
sed -i d /home/runner/work/safesearch-enforcing-hosts/safesearch-enforcing-hosts/google/hosts-ipv4only.txt

# Where to download the list of domains that google search uses.
hostURLs=https://www.google.com/supported_domains

# Files
tempfile='/home/runner/work/safesearch-enforcing-hosts/safesearch-enforcing-hosts/google/supported-domains'
output='/home/runner/work/safesearch-enforcing-hosts/safesearch-enforcing-hosts/google/hosts.txt'
output2='/home/runner/work/safesearch-enforcing-hosts/safesearch-enforcing-hosts/google/hosts-ipv4only.txt'

# IP Address for Google Safe Search
IPSix=$(dig forcesafesearch.google.com AAAA +short)
IPFour=$(dig forcesafesearch.google.com A +short)
if [ -z "$IPSix" ] || [ -z "$IPFour" ]; then
        echo "Getting IP address for forcesafesearch.google.com failed"
	exit 1
fi

# Fetch a current list of Google owned domains
code=$(curl --silent --write-out %{http_code} --output $tempfile $hostURLs)
if [ "$code" -ne "200" ] ; then
        rm $tempfile
        echo Fetching list of google owned domains failed with http status code $code
        exit $code
fi

# Function: generate_hosts

function generate_hosts {
	sed "s/^./$1 /"  $tempfile >> $output
	sed "s/^/$1 www/" $tempfile >> $output
}

function generate_hosts2 {
	sed "s/^./$1 /"  $tempfile >> $output2
	sed "s/^/$1 www/" $tempfile >> $output2
}

# Generate hosts file that will cause/ Safe Search to be always on
echo "# Google Safe Search Host List" > $output
echo "# Generated on $(date)" >> $output
echo "# From: $hostURLs" >> $output
echo >> $output
echo "# $IPFour forcesafesearch.google.com" >> $output
echo "# $IPSix forcesafesearch.google.com" >> $output
echo >> $output
generate_hosts $IPFour
generate_hosts $IPSix

# Generate ipv4-only hosts 
echo "# Google Safe Search Host List (IPv4-Only)" > $output2
echo "# Generated on $(date)" >> $output2
echo "# From: $hostURLs" >> $output2
echo >> $output2
echo "# $IPFour forcesafesearch.google.com" >> $output2
echo >> $output2
generate_hosts2 $IPFour


rm $tempfile
