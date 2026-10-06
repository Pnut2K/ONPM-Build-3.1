#########################
L-Cancelling Rework [Eon]
#########################
.macro getInt(<id>)
{
    %workModuleCmd(<id>, 0x18)
}
.macro setInt(<id>)
{
.alias arg_Hi = <id> / 0x10000
.alias arg_Lo = <id> & 0xFFFF
    lis r5, arg_Hi
    ori r5, r5, arg_Lo
	%ModuleCmd(0x64, 0x1C)
}
.macro decInt(<id>)
{
    %workModuleCmd(<id>, 0x28)
}
.macro workModuleCmd(<id>, <cmd>)
{
.alias arg_Hi = <id> / 0x10000
.alias arg_Lo = <id> & 0xFFFF
    lis r4, arg_Hi
    ori r4, r4, arg_Lo
	%ModuleCmd(0x64, <cmd>)
}

.macro ModuleCmd(<module>, <cmd>)
{
    lwz r3, 0xD8(r31)
    lwz r3, <module>(r3)
    lwz r12, 0x0(r3)
    lwz r12, <cmd>(r12)
    mtctr r12
    bctrl
}
#initStatus
HOOK @ $80874314
{
	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r31, 0xC(r1)
  stw r30, 0x10(r1)
	mr r31, r4

	li r4, 0
	%setInt(0x1000005a)


  %getInt(0x1000004D)
  cmpwi r3, 1
  beq lcancel
  #controller module get held
  %ModuleCmd(0x5C, 0xAC) 
  mr r30, r3
  #controller module get pressed this frame
  %ModuleCmd(0x5C, 0xA0)
  and r3, r30, r3
  andi. r3, r3, 0x8
  beq end
lcancel: 
	li r4, 0x7
	%setInt(0x1000005a)
end:
  lwz r30, 0x10(r1)
	lwz r31, 0xC(r1)
	lwz r0, 0x34(r1)
	mtlr r0
	addi r1, r1, 0x30
	blr
}

#execStatus
HOOK @ $80874318 
{
	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r31, 0xC(r1)
	stw r30, 0x10(r1)
	mr r31, r4

  %getInt(0x1000004D)
  cmpwi r3, 1
  beq lcancel
  #controller module get held
  %ModuleCmd(0x5C, 0xAC) 
  mr r30, r3
  #controller module get pressed this frame
  %ModuleCmd(0x5C, 0xA0)
  and r3, r30, r3
  andi. r3, r3, 0x8
  beq decCount
lcancel:
	li r4, 0x7
	%setInt(0x1000005a)
	b end


	#decrement lcancel timer every frame, detect shield and set to 8 if so

decCount:
	%decInt(0x1000005a)
end:
	#original command equivalent, writing what was r4 to r3
	mr r3, r31
	lwz r31, 0xC(r1)
  lwz r30, 0x10(r1)
	lwz r0, 0x34(r1)
	mtlr r0
	addi r1, r1, 0x30
  lis r12, 0x808a
  ori r12, r12, 0x019C
  mtctr r12
  bctr
}

word 0x8087431C @ $80B11830
word 0x8087431C @ $80B0DCB8
#execStop
HOOK @ $8087431C 
{
	stwu r1, -0x30(r1)
	mflr r0
	stw r0, 0x34(r1)
	stw r31, 0xC(r1)
	stw r30, 0x10(r1)
  mr r31, r4
  
	#if requirement 0x4E (any shield pressed)
  %getInt(0x1000004D)
  cmpwi r3, 1
  beq lcancel
  #controller module get held
  %ModuleCmd(0x5C, 0xAC) 
  mr r30, r3
  #controller module get pressed this frame
  %ModuleCmd(0x5C, 0xA0)
  and r3, r30, r3
  andi. r3, r3, 0x8
  beq end
lcancel:
	li r4, 0x8
	%setInt(0x1000005a)
end:
	lwz r31, 0xC(r1)
	lwz r30, 0x10(r1)
	lwz r0, 0x34(r1)
	mtlr r0
	addi r1, r1, 0x30
	blr
}


#############################################################################################################################################################
L-Cancel Landing Lag and Success Rate and Score Display is Auto L-Cancel Option + White L-cancel Flash v3.1b [Magus, Standardtoaster, wiiztec, Eon, DukeItOut, mawwwk]
#
# 3.1: Added replay support
#############################################################################################################################################################
#check frame = 6 and disable flash
HOOK @ $80874850 
{
	cmpwi r3, 5
	mr r31, r3		# Original op
	bne end
	#soColorBlendModule
	lwz r3, 0xD8(r28)
	lwz r3, 0xAC(r3)
	li r4, 1
	lwz r12, 0(r3)
	lwz r12, 0x20(r12)
	mtctr r12
	bctrl
end:
	lwz r4, 0xD8(r28)
}
#land and detect lcancel state, set flash and stat appropriately
op nop @ $8081BE8C

HOOK @ $8087459C
{
#get LA-Basic[90]
  lwz r3, 0xD8(r31)
  lwz r3, 0x64(r3)
  lis r4, 0x1000
  ori r4, r4, 90
  
  lwz r12, 0x0(r3)
  lwz r12, 0x18(r12)
  mtctr r12
  bctrl
  cmpwi r3, 0
  ble checkForAutoLcancel
trueLcancel:
  #start flash effect
  lwz r3, 0xD8(r31)
  lwz r3, 0xAC(r3)

  #initial colour
  lis r0, 0xFFFF
  ori r0, r0, 0xFFDC
  addi r4, r1, 0x18
  stw r0, 0(r4)

  li r5, 1
  lwz r12, 0(r3)
  lwz r12, 0x24(r12)
  mtctr r12
  bctrl

  lwz r3, 0xD8(r31)
  lwz r3, 0xAC(r3)
  #time to transition
  lis r0, 0x40C0
  stw r0, 0x18(r1)
  lfs f1, 0x18(r1)
  #target colour of transition
  lis r0, 0xFFFF
  ori r0, r0, 0xFF00
  addi r4, r1, 0x18
  stw r0, 0(r4)
  
  li r5, 1		# true
  lwz r12, 0(r3)
  lwz r12, 0x28(r12)
  mtctr r12
  bctrl
  
  li r6, 1
  b applyLcancel
checkForAutoLcancel:  
  li r6, 0
  lis r11, 0x805A
  lwz r11, 0xE0(r11)
  lwz r11, 0x08(r11)
  lbz r11, 0xE5(r11)	# 0x4D (+ 0x98)
  andi. r11, r11, 1		# bit used for ALC
  beq calcStat

applyLcancel:
  lfs f0, -0x5B98(r2)		# Load 0.5
  fmuls f30, f30, f0

calcStat:
  cmpwi r6, 0				# Check whether to increment L-cancel aerial count later
  lis r12, 0x80B8			# Load 1.0
  ori r12, r12, 0x8300
  lfs f6, 0x94(r12)
  lwz r4, 0xD8(r31)			# Get pointer to LA-Basic data
  lwz r4, 0x64(r4)
  lwz r4, 0x20(r4)
  lwz r4, 0xC(r4)
  lfs f5, 0x238(r4)			# Increment total landing aerial count
  fadds f5, f5, f6
  stfs f5, 0x238(r4)
  
  lis r5, 0x80B8			# Get per-port address?
  lwz r5, 0x7C28(r5)
  lwz r5, 0x154(r5)
  lwz r5, 0(r5)
  lwz r6, 0x8(r31)
  lwz r6, 0x10C(r6)
  rlwinm r6, r6, 0, 24, 31
  mulli r6, r6, 0x244
  add r5, r5, r6
  lwz r5, 0x28(r5)
  addi r5, r5, 0x850
  lfs f4, 0x23C(r4)		# Load L-canceled aerial count
  ble recalculate
  fadds f4, f6, f4		# If successful, add 1 to L-canceled aerial count
  stfs f4, 0x23C(r4)

recalculate:			# For results screen stats
  fdivs f5, f4, f5		# Divide by total landing aerial count to get %
  lfs f6, 0xA0(r12)		# Load 100.0
  fmuls f5, f6, f5		# 100.0 * percent
  fctiwz f5, f5
  stfd f5, 0x30(r2)
  lhz r3, 0x36(r2)		# Percentage stored as an int
  stw r3, 0(r5)
  
  fctiwz f30, f30		# Landing lag animation speed modifier
  stfd f30, 0x10(r2)
  lhz r12, 0x16(r2)
  lfd f0, -0x7B90(r2)
  lis r3, 0x4330
  stw r3, 0x10(r2)
  xoris r12, r12, 0x8000
  stw r12, 0x14(r2)
  lfd f30, 0x10(r2)
  fsub f30, f30, f0
  fadds f31, f31, f1
  fdivs f31, f31, f30
}

##############################################
Disable Aerial Attack Landing Lag IASA [Magus]
##############################################
op lwz r0, 0xFF(r0) @ $80FAF168

##############################################
Ignore Damage Gauge Setting [InternetExplorer]
##############################################
op li r3, 1 @ $8005063C

#####################################################################
Damage Gauge Toggles 3-Frame Buffer 1.1 [InternetExplorer, DukeItOut]
#
# 1.1: Added replay support
#####################################################################
HOOK @ $8085B784
{
	lis r12, 0x805A
	lwz r12, 0xE0(r12)
	lwz r12, 0x08(r12)
	lbz r3, 0xE5(r12)	# 0x4D (+ 0x98)
	andi. r3, r3, 2	# bit used for buffer
	li r3, 0		# \ If the handicap damage gauge rule is enabled . . . 
	beq- %END%		# /
	li r3, 3		# Set the buffer to 3 frames instead of 0
}

###################################################
ALC and Buffer Are Preserved in Replays [DukeItOut]
###################################################
HOOK @ $8004FF64
{
	lis r12, 0x805A
	lwz r12, 0xE0(r12)
	lwz r12, 0x08(r12)
	lbz r6, 0xE5(r12)	# 0x4D (+ 0x98)
	andi. r6, r6, 0xFC	# Clear lowest two bits
	lis r4, 0x9018
	
	lbz r5, -0xC94(r4)	# 9017F36C
	cmpwi r5, 1
	bne noBuffer
	ori r6, r6, 0x02	# this bit is being used for buffer
noBuffer:
	lbz r5, -0xC95(r4)	# 9017F36B
	cmpwi r5, 1
	bne noALC
	ori r6, r6, 0x01	# this bit is being used for auto L-cancel
noALC:
	stb r6, 0xE5(r12)	# store this information somewhere a replay can observe it!
	
	lbz r0, 0x1C(r30)	# Original operation
}