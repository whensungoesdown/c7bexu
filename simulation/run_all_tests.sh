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


cd test1_ecl
echo "test1_ecl"
if ./simulate.sh | grep PASS; then
	printf ""
else
	printf "Fail!\n"
	exit
fi
echo ""
cd ..
