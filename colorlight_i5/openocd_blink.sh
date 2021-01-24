#!/bin/bash

sudo openocd -f cmsisdap.cfg -c "init; scan_chain; source ./blink.tcl; exit;"

