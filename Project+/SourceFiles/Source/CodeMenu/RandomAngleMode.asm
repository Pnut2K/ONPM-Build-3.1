################################################################
Random Angle Mode 1.3 [PyotrLuzhin, Eon, QuickLava]
# v1.3 - Rolls old Full Random Mode as another Code Menu Setting
################################################################
#Code Menu Variant by Desi
.alias CM_HeaderStart = 0x804E
.alias CM_RandAngleLOCOff = 0x02BC  # Code Menu Header offset to Random Angle Mode Line Address.

HOOK @ $807449e0    # 0xD8 bytes into symbol "set/[soCollisionAttackModuleImpl]/so_collision_attack_mod" @ 0x80744908
{
  lwz r6, 0x14(r30)

  lis r4, CM_HeaderStart                       # \
  lwz r4, CM_RandAngleLOCOff(r4)               # / Get address of Random Angle Line
  lwz r4, 0x8(r4)                              # Get the current value of the line.
  cmplwi r4, 0x1                               # \ 
  blt+ exit                                    # / If value < 1 (ie. 0), Random Angle Mode is off, skip to exit!
  bgt getMatchRandomSeed                       # If value > 1 (ie. 2), Random Angle Mode is set to Static, jump to that.
  
getFrameRandomSeed:                            # Otherwise, Random Angle Mode is 1 (True Random)...
  lwz r4, -0x4364(r13)                         # ... so grab current frame's random seed!
  b adjustSeed                                 # Skip grabbing Match Random Seed.
  
getMatchRandomSeed:
  lis r4, 0x8071
  subi r4, r4, 0x7340
  addi r4, r4, 0x10
  lwz r4, 0x54(r4) #FightSeed
  
adjustSeed:                                    # Now adjust seed based on current fighter state.
  lwz r6, 0x28(r28) #= moduleAccessor

  #getFighter
  lwz r5, 0x8(r6)
  lwz r5, 0x110(r5) #fighterKind
  add r4, r4, r5


  #getAnimKind
  lwz r5, 0xD8(r6)
  lwz r5, 0x8(r5)
  lhz r5, 0x5A(r5)
  mulli r5, r5, 100
  add r4, r4, r5

  lwz r6, 0x18(r30)
  mulli r5, r6, 0x1000
  add r4, r4, r5


  #just write my own randi that doesnt have a state coz this is its own call and thats easier than saving and restoring the games seed
  #r4 is starting seed
  lis r6, 0x41C6
  addi r6, r6, 0x4E6D
  mullw r6, r4, r6
  li r5, 360
  divwu r5, r6, r5
  mulli r5, r5, 360
  sub r6, r6, r5
  addi r6, r6, 1
  //  rlwinm r6, r6, 16, 17, 31 #(mask by 0x7FFF0000 and rotate to start)
exit:
  mr r4, r29
  mr r5, r27
}


