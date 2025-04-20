#################################
Reset Teams on re-enter CSS [Eon]
#################################
#Calls assignTeams if teams are enabled
HOOK @ $80683634
{  
  mr r3, r30
  lis r12, 0x8068
  ori r12, r12, 0x4D84
  mtctr r12 
  bctrl 
  cmpwi r3, 1 #if is teams (if not go to vanilla code)
  bne end 
  #if not second teams option added by below code, end
  lis r3, 0x9019
  lbz r3, -0x5F1C(r3)
  cmpwi r3, 0
  bne end
  mr r3, r30 #assign random teams
  lis r12, 0x8068
  ori r12, r12, 0xAC4C
  mtctr r12 
  bctrl 
end:
  li r3, 42
}
 
Second Teams option [PyotrLuzhin, Fracture, Yohan1044]
#stolen code from the `Team Glow CSS Toggle [PyotrLuzhin, Fracture, Yohan1044]` to add a third team option
* C268A494 00000003
* 889F05CB 899F05C8
* 7C846278 989F05CB
* 7FE3FB78 00000000
 
* C268A498 0000000B
* 3D809019 888CA0E4
* 2C00001F 40820024
* 2C0400CC 4182001C
* 2C040000 40810020
* 38800000 38A00001
* 38000020 48000018
* 38800001 38A00000
* 4800000C 38800000
* 38A00000 988CA0E4
* 98ACA0E5 5404D97E
* 60000000 00000000
 
* C268EEF4 00000005
* FC20F890 3D809019
* 898CA0E5 2C0C0001
* 40820010 3D8040C0
* 91820000 C0220000
* 60000000 00000000
 
 
 
Assign Teams randomises colour & order [Eon]
.macro randi(<i>)
{
  li r3, <i> 
  lis r12, 0x8003
  ori r12, r12, 0xfc7c
  mtctr r12 
  bctrl 
}
.alias totalTeams = 2	 #assumes this is prime (since all values less than it create a loop len totalTeams when adding and modulo'ing)
.alias totalTeamsSubOne = totalTeams-1
HOOK @ $8068ACD0
{
  cmpwi r6, 1 #r6 = number of chars to give each team, but i want how many teams to assign
  bne 0x8 
  li r6, totalTeams
  mr r30, r6  
 
  #initialise list filled with one random team 
  %randi(totalTeams) 
  li r4, 0x8
initialLoop:   #set everyone to base team 
  stwx r3, r1, r4 
  addi r4, r4, 0x4
  cmpwi r4, 0x14
  ble initialLoop
 
  %randi(totalTeamsSubOne)
  addi r29, r3, 1   #teamTwoOffset, loop through teams available by doing team = (team[0] + teamsTwoOffset*teamNum) % totalTeams
  li r28, 0
assignTeams:
  addi r28, r28, 1 #start at team 1 since team 0 is filled out already
  cmpw r28, r30
  bge end
  li r3, -1
  cmpwi r30, 2
  bne calcTeam
  %randi(3) #selects a random port from remaining ones to ignore
calcTeam:
  lwz r4, 0x8(r1) #teamOne
  mullw r5, r28, r29
  add r4, r5, r4
moduloTeams:
  cmpwi r4, totalTeams
  blt moduloDone
  subi r4, r4, totalTeams
  b moduloTeams
moduloDone:
  #r3 = gap
  #r4 = team
  #r5 = where to store into array
  mulli r5, r28, 4
  addi r5, r5, 0x4
assignTeamLoop:
  addi r5, r5, 4
  cmpwi r5, 0x14
  bgt assignTeams
  cmpwi r3, 0
  subi r3, r3, 1
  beq assignTeamLoop
  stwx r4, r1, r5
  b assignTeamLoop
end:
  lis r12, 0x8068
  ori r12, r12, 0xAD1C
  mtctr r12
  bctr   
}