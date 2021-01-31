#!/bin/bash

sudo openocd -f cmsisdap.cfg -c "init; scan_chain; source ./tdi_toggle.tcl; exit;"

