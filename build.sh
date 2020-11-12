#!/bin/bash

mkdir out

cd pppd
make
mv ./pppd ../out/
make clean
cd ..


cd pptp
make
mv ./pptp ../out/
make clean
cd ..
