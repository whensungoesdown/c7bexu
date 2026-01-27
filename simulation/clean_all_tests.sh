#!/bin/bash
echo clean tests
echo

cd test0_byp
echo "test0_byp"
./clean.sh
echo ""
cd ..


cd test1_ecl
echo "test1_ecl"
./clean.sh
echo ""
cd ..


cd test2_exu
echo "test2_exu"
./clean.sh
echo ""
cd ..


cd test4_intr_sync_delay
echo "test4_intr_sync_delay"
./clean.sh
echo ""
cd ..


cd test5_pic
echo "test5_pic"
./clean.sh
echo ""
cd ..
