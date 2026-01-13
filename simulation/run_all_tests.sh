#!/bin/bash
echo run tests
echo

cd test0_byp
echo "test0_byp"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..


