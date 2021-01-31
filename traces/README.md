Waveforms captures from ECP5 board to check exact behavior for JTAGG signals.

Findings:
* TCK == JTCK
* JTDI = FF(posedge TCK, TDI)
* JRSTN = FF(negdge TCK, !(FSM==Test-Logic-Reset))
* JSHIFT = (FSM==Shift-DR) & (IR==0x32 || IR==0x38)



