#!/bin/bash
echo run tests
echo


cd test0_byp
echo "test0_byp"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..


cd test1_ecl
echo "test1_ecl"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..


cd test2_exu
echo "test2_exu"
result=$(./simulate.sh)
if echo "$result" | grep "PASS"; then
    printf "PASS!\n"
elif echo "$result" | grep "FAIL"; then
    printf "FAIL!\n"
    exit 1
else
    printf "Unknown result\n"
    exit 1
fi
echo ""
cd ..

