
irscan ecp5.tap 0x32
drscan ecp5.tap 32 0x876543210
drscan ecp5.tap 32 0x012345678
sleep 400
runtest 100
sleep 400
pathmove RESET
sleep 400
irscan ecp5.tap 0x38
drscan ecp5.tap 32 0x876543210
drscan ecp5.tap 32 0x012345678
sleep 400
irscan ecp5.tap 0x32
drscan ecp5.tap 32 0x876543210
drscan ecp5.tap 32 0x012345678
sleep 400
irscan ecp5.tap 0x38
drscan ecp5.tap 32 0x876543210
drscan ecp5.tap 32 0x012345678
sleep 400
irscan ecp5.tap 0x00
drscan ecp5.tap 32 0x876543210
sleep 400
irscan ecp5.tap 0xff
drscan ecp5.tap 32 0x876543210
sleep 400
irscan ecp5.tap 0x32
drscan ecp5.tap 32 0x876543210
drscan ecp5.tap 32 0x012345678
sleep 400
irscan ecp5.tap 0x38
drscan ecp5.tap 32 0x876543210
drscan ecp5.tap 32 0x012345678
sleep 400
