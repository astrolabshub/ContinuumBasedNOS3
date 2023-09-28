#!/bin/bash
echo "Running make..."
make clean
make
echo "Running make launch..."
make launch
echo "Keeping container alive..."
tail -f /dev/null