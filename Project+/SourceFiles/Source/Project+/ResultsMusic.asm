#############################################################
Custom Victory Themes v1.2a [Dantarion, KingJigglypuff]
#
# Clone Engine Character victory IDs are in CloneEngine.asm
# Remove this code if using BrawlEX/PMEX/P+EX! 
# It's redundant, then, if it is present.
#############################################################
uint32_t[46] |
	0xFF00, 0xFF01, 0xFF02, 0xFF03, 0xFF18, | // Mario, Donkey Kong, Link, Samus, Zero Suit Samus
	0xFF04, 0xFF05, 0xFF06, 0xFF07, 0xFF08, | // Yoshi, Kirby, Fox, Pikachu, Luigi
	0xFF09, 0xFF0A, 0xFF0B, 0xFF0C, 0xFF0D, | // Captain Falcon, Ness, Bowser, Peach, Zelda
	0xFF0E, 0xFF0F, 0xFF0F, 0xFF0F, 0xFF11, | // Sheik, Ice Climbers, Popo, Nana, Marth
	0xFF12, 0xFF13, 0xFF14, 0xFF15, 0xFF16, | // Mr. Game & Watch, Falco, Ganondorf, Wario, Meta-Knight
	0xFF17, 0xFF19, 0xFF1A, 0xFF1B, 0xFF1D, | // Pit, Olimar, Lucas, Diddy Kong, Charizard
	0xFF1D, 0xFF1E, 0xFF1E, 0xFF1F, 0xFF1F, | // Charizard (Solo), Squirtle, Squirtle (Solo), Ivysaur, Ivysaur (Solo)
	0xFF20, 0xFF21, 0xFF22, 0xFF23, 0xFF25, | // Dedede, Lucario, Ike, R.O.B., Jigglypuff
	0xFF29, 0xFF2C, 0xFF2E, 0xFF2F, 0xFF30, | // Toon Link, Wolf, Snake, Sonic, Giga Bowser
	0xFF31 |								  // Wario-Man
	@ $804088C0
# Unique IDs:
# FF0B: Victory!/Bowser


## TODO: Make victory themes just use 0xFF00 + Fighter id instead of table for new version of BrawlEx
# Handled in ifVsResultTask::processAnim

##################################################################################
Classic and All-Star Results Music Id Is Based On Fighter Id [DukeItOut, Kapedani]
##################################################################################
.alias ftKindConversion__convertKind = 0x808545ec

.macro lwi(<reg>, <val>)
{
    .alias  temp_Hi = <val> / 0x10000
    .alias  temp_Lo = <val> & 0xFFFF
    lis     <reg>, temp_Hi
    ori     <reg>, <reg>, temp_Lo
}
.macro call(<addr>)
{
  %lwi(r12, <addr>)
  mtctr r12
  bctrl    
}

HOOK @ $806e0988		# Classic Mode
{
	stwu r1,-0x20(r1)
    mflr r0
    stw r0,0x24(r1)
	stw r6, 0x1C(r1)
	lbz	r3, 0x33(r15)	# get characterKind
    addi r4, r1, 0x8
	%call(ftKindConversion__convertKind)
    lwz r3, 0x8(r1)		# \ 
    ori r3, r3, 0xff00	# | bgmId = 0xFF00FF00 | ftKind
	lwz r6, 0x1C(r1)
    lwz r0,0x24(r1)
    mtlr r0
    addi r1,r1,0x20
	oris r0, r3, 0xFF00	# /
	addi r4, r20, 752
}
HOOK @ $806E3650		# All-Star Mode
{
	stwu r1,-0x20(r1)
    mflr r0
    stw r0,0x24(r1)
	stw r6, 0x1C(r1)
	lbz	r3, 0x98(r6)	# get characterKind
    addi r4, r1, 0x8
	%call(ftKindConversion__convertKind)
    lwz r3, 0x8(r1)		# \ 
    ori r3, r3, 0xff00	# | bgmId = 0xFF00FF00 | ftKind
	lwz r6, 0x1C(r1)
    lwz r0,0x24(r1)
    mtlr r0
    addi r1,r1,0x20
    oris r0, r3, 0xFF00	# /
	addi r4, r23, 136
}
