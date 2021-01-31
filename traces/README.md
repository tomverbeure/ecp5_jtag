Waveforms captures from ECP5 board to check exact behavior for JTAGG signals.

Findings:
* TCK       = JTCK
* JTDI      = FF(posedge TCK, TDI)
* JRSTN     = FF(negdge TCK, !(FSM==Test-Logic-Reset))
* JSHIFT    = (FSM==Shift-DR) & (IR==0x32 || IR==0x38)
* JUPDATE   = (FSM==Update-DR) & (IR==0x32 || IR==0x38)


* JCE1      = (FSM==Capture-DR || Shift-DR) & (IR==0x32)
* JCE2      = (FSM==Capture-DR || Shift-DR) & (IR==0x38)
* JRTI1     = (FSM==Run-Test/Idle) & (IR==0x32)
* JRTI2     = (FSM==Run-Test/Idle) & (IR==0x38)
* TDO       = FF(negedge TCK, JTDO1) if (IR==0x32 && FSM==Shift-DR)
* TDO       = FF(negedge TCK, JTDO2) if (IR==0x38 && FSM==Shift-DR)

Note: when JUPDATE, JTDO1 or JTDO2 are routed a GPIO, the led doesn't blink anymore,
even when the signal is FF'ed first with JTCK. 

The signals are toggling on the logic analyzer at the right time, so something
very strange is going on.




