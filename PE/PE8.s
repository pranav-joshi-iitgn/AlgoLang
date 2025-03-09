# This code can be run on the SPIM simulator. It can be installed on debian/ubuntu as :
# `sudo apt-get install spim`
# Then, you can run the code as `spim -f <filename>`

.data
.text
.globl main

pathfinder:
add $t1,$ra,$zero
jr $ra

main:
addi $s0,$sp,0
addi $s5,$sp,4

addi $t8,$zero,1
addi $t9,$zero,1
addi $s1,$s0,-4

# Definition : s is -4($s0)

# putting "7316717653133062491922511967442657474235534919493496983520312774506326239578318016984801869478851843858615607891129494954595017379583319528532088055111254069874715852386305071569329096329522744304355766896648950445244523161731856403098711121722383113622298934233803081353362766142828064444866452387493035890729629049156044077239071381051585930796086670172427121883998797908792274921901699720888093776657273330010533678812202354218097512545405947522435258490771167055601360483958644670632441572215539753697817977846174064955149290862569321978468622482839722413756570560574902614079729686524145351004748216637048440319989000889524345065854122758866688116427171479924442928230863465674813919123162824586178664583591245665294765456828489128831426076900422421902267105562632111110937054421750694165896040807198403850962455444362981230987879927244284909188845801561660979191338754992005240636899125607176060588611646710940507754100225698315520005593572972571636269561882670428252483600823257530420752963450" on heap 
add $t0,$s5,$zero
addi $s5, $s5,4004
addi $t1,$zero,4000 # add size at start
sw $t1,0($t0)
addi $t1,$zero,55 # 7
sw $t1, 4($t0)
addi $t1,$zero,51 # 3
sw $t1, 8($t0)
addi $t1,$zero,49 # 1
sw $t1, 12($t0)
addi $t1,$zero,54 # 6
sw $t1, 16($t0)
addi $t1,$zero,55 # 7
sw $t1, 20($t0)
addi $t1,$zero,49 # 1
sw $t1, 24($t0)
addi $t1,$zero,55 # 7
sw $t1, 28($t0)
addi $t1,$zero,54 # 6
sw $t1, 32($t0)
addi $t1,$zero,53 # 5
sw $t1, 36($t0)
addi $t1,$zero,51 # 3
sw $t1, 40($t0)
addi $t1,$zero,49 # 1
sw $t1, 44($t0)
addi $t1,$zero,51 # 3
sw $t1, 48($t0)
addi $t1,$zero,51 # 3
sw $t1, 52($t0)
addi $t1,$zero,48 # 0
sw $t1, 56($t0)
addi $t1,$zero,54 # 6
sw $t1, 60($t0)
addi $t1,$zero,50 # 2
sw $t1, 64($t0)
addi $t1,$zero,52 # 4
sw $t1, 68($t0)
addi $t1,$zero,57 # 9
sw $t1, 72($t0)
addi $t1,$zero,49 # 1
sw $t1, 76($t0)
addi $t1,$zero,57 # 9
sw $t1, 80($t0)
addi $t1,$zero,50 # 2
sw $t1, 84($t0)
addi $t1,$zero,50 # 2
sw $t1, 88($t0)
addi $t1,$zero,53 # 5
sw $t1, 92($t0)
addi $t1,$zero,49 # 1
sw $t1, 96($t0)
addi $t1,$zero,49 # 1
sw $t1, 100($t0)
addi $t1,$zero,57 # 9
sw $t1, 104($t0)
addi $t1,$zero,54 # 6
sw $t1, 108($t0)
addi $t1,$zero,55 # 7
sw $t1, 112($t0)
addi $t1,$zero,52 # 4
sw $t1, 116($t0)
addi $t1,$zero,52 # 4
sw $t1, 120($t0)
addi $t1,$zero,50 # 2
sw $t1, 124($t0)
addi $t1,$zero,54 # 6
sw $t1, 128($t0)
addi $t1,$zero,53 # 5
sw $t1, 132($t0)
addi $t1,$zero,55 # 7
sw $t1, 136($t0)
addi $t1,$zero,52 # 4
sw $t1, 140($t0)
addi $t1,$zero,55 # 7
sw $t1, 144($t0)
addi $t1,$zero,52 # 4
sw $t1, 148($t0)
addi $t1,$zero,50 # 2
sw $t1, 152($t0)
addi $t1,$zero,51 # 3
sw $t1, 156($t0)
addi $t1,$zero,53 # 5
sw $t1, 160($t0)
addi $t1,$zero,53 # 5
sw $t1, 164($t0)
addi $t1,$zero,51 # 3
sw $t1, 168($t0)
addi $t1,$zero,52 # 4
sw $t1, 172($t0)
addi $t1,$zero,57 # 9
sw $t1, 176($t0)
addi $t1,$zero,49 # 1
sw $t1, 180($t0)
addi $t1,$zero,57 # 9
sw $t1, 184($t0)
addi $t1,$zero,52 # 4
sw $t1, 188($t0)
addi $t1,$zero,57 # 9
sw $t1, 192($t0)
addi $t1,$zero,51 # 3
sw $t1, 196($t0)
addi $t1,$zero,52 # 4
sw $t1, 200($t0)
addi $t1,$zero,57 # 9
sw $t1, 204($t0)
addi $t1,$zero,54 # 6
sw $t1, 208($t0)
addi $t1,$zero,57 # 9
sw $t1, 212($t0)
addi $t1,$zero,56 # 8
sw $t1, 216($t0)
addi $t1,$zero,51 # 3
sw $t1, 220($t0)
addi $t1,$zero,53 # 5
sw $t1, 224($t0)
addi $t1,$zero,50 # 2
sw $t1, 228($t0)
addi $t1,$zero,48 # 0
sw $t1, 232($t0)
addi $t1,$zero,51 # 3
sw $t1, 236($t0)
addi $t1,$zero,49 # 1
sw $t1, 240($t0)
addi $t1,$zero,50 # 2
sw $t1, 244($t0)
addi $t1,$zero,55 # 7
sw $t1, 248($t0)
addi $t1,$zero,55 # 7
sw $t1, 252($t0)
addi $t1,$zero,52 # 4
sw $t1, 256($t0)
addi $t1,$zero,53 # 5
sw $t1, 260($t0)
addi $t1,$zero,48 # 0
sw $t1, 264($t0)
addi $t1,$zero,54 # 6
sw $t1, 268($t0)
addi $t1,$zero,51 # 3
sw $t1, 272($t0)
addi $t1,$zero,50 # 2
sw $t1, 276($t0)
addi $t1,$zero,54 # 6
sw $t1, 280($t0)
addi $t1,$zero,50 # 2
sw $t1, 284($t0)
addi $t1,$zero,51 # 3
sw $t1, 288($t0)
addi $t1,$zero,57 # 9
sw $t1, 292($t0)
addi $t1,$zero,53 # 5
sw $t1, 296($t0)
addi $t1,$zero,55 # 7
sw $t1, 300($t0)
addi $t1,$zero,56 # 8
sw $t1, 304($t0)
addi $t1,$zero,51 # 3
sw $t1, 308($t0)
addi $t1,$zero,49 # 1
sw $t1, 312($t0)
addi $t1,$zero,56 # 8
sw $t1, 316($t0)
addi $t1,$zero,48 # 0
sw $t1, 320($t0)
addi $t1,$zero,49 # 1
sw $t1, 324($t0)
addi $t1,$zero,54 # 6
sw $t1, 328($t0)
addi $t1,$zero,57 # 9
sw $t1, 332($t0)
addi $t1,$zero,56 # 8
sw $t1, 336($t0)
addi $t1,$zero,52 # 4
sw $t1, 340($t0)
addi $t1,$zero,56 # 8
sw $t1, 344($t0)
addi $t1,$zero,48 # 0
sw $t1, 348($t0)
addi $t1,$zero,49 # 1
sw $t1, 352($t0)
addi $t1,$zero,56 # 8
sw $t1, 356($t0)
addi $t1,$zero,54 # 6
sw $t1, 360($t0)
addi $t1,$zero,57 # 9
sw $t1, 364($t0)
addi $t1,$zero,52 # 4
sw $t1, 368($t0)
addi $t1,$zero,55 # 7
sw $t1, 372($t0)
addi $t1,$zero,56 # 8
sw $t1, 376($t0)
addi $t1,$zero,56 # 8
sw $t1, 380($t0)
addi $t1,$zero,53 # 5
sw $t1, 384($t0)
addi $t1,$zero,49 # 1
sw $t1, 388($t0)
addi $t1,$zero,56 # 8
sw $t1, 392($t0)
addi $t1,$zero,52 # 4
sw $t1, 396($t0)
addi $t1,$zero,51 # 3
sw $t1, 400($t0)
addi $t1,$zero,56 # 8
sw $t1, 404($t0)
addi $t1,$zero,53 # 5
sw $t1, 408($t0)
addi $t1,$zero,56 # 8
sw $t1, 412($t0)
addi $t1,$zero,54 # 6
sw $t1, 416($t0)
addi $t1,$zero,49 # 1
sw $t1, 420($t0)
addi $t1,$zero,53 # 5
sw $t1, 424($t0)
addi $t1,$zero,54 # 6
sw $t1, 428($t0)
addi $t1,$zero,48 # 0
sw $t1, 432($t0)
addi $t1,$zero,55 # 7
sw $t1, 436($t0)
addi $t1,$zero,56 # 8
sw $t1, 440($t0)
addi $t1,$zero,57 # 9
sw $t1, 444($t0)
addi $t1,$zero,49 # 1
sw $t1, 448($t0)
addi $t1,$zero,49 # 1
sw $t1, 452($t0)
addi $t1,$zero,50 # 2
sw $t1, 456($t0)
addi $t1,$zero,57 # 9
sw $t1, 460($t0)
addi $t1,$zero,52 # 4
sw $t1, 464($t0)
addi $t1,$zero,57 # 9
sw $t1, 468($t0)
addi $t1,$zero,52 # 4
sw $t1, 472($t0)
addi $t1,$zero,57 # 9
sw $t1, 476($t0)
addi $t1,$zero,53 # 5
sw $t1, 480($t0)
addi $t1,$zero,52 # 4
sw $t1, 484($t0)
addi $t1,$zero,53 # 5
sw $t1, 488($t0)
addi $t1,$zero,57 # 9
sw $t1, 492($t0)
addi $t1,$zero,53 # 5
sw $t1, 496($t0)
addi $t1,$zero,48 # 0
sw $t1, 500($t0)
addi $t1,$zero,49 # 1
sw $t1, 504($t0)
addi $t1,$zero,55 # 7
sw $t1, 508($t0)
addi $t1,$zero,51 # 3
sw $t1, 512($t0)
addi $t1,$zero,55 # 7
sw $t1, 516($t0)
addi $t1,$zero,57 # 9
sw $t1, 520($t0)
addi $t1,$zero,53 # 5
sw $t1, 524($t0)
addi $t1,$zero,56 # 8
sw $t1, 528($t0)
addi $t1,$zero,51 # 3
sw $t1, 532($t0)
addi $t1,$zero,51 # 3
sw $t1, 536($t0)
addi $t1,$zero,49 # 1
sw $t1, 540($t0)
addi $t1,$zero,57 # 9
sw $t1, 544($t0)
addi $t1,$zero,53 # 5
sw $t1, 548($t0)
addi $t1,$zero,50 # 2
sw $t1, 552($t0)
addi $t1,$zero,56 # 8
sw $t1, 556($t0)
addi $t1,$zero,53 # 5
sw $t1, 560($t0)
addi $t1,$zero,51 # 3
sw $t1, 564($t0)
addi $t1,$zero,50 # 2
sw $t1, 568($t0)
addi $t1,$zero,48 # 0
sw $t1, 572($t0)
addi $t1,$zero,56 # 8
sw $t1, 576($t0)
addi $t1,$zero,56 # 8
sw $t1, 580($t0)
addi $t1,$zero,48 # 0
sw $t1, 584($t0)
addi $t1,$zero,53 # 5
sw $t1, 588($t0)
addi $t1,$zero,53 # 5
sw $t1, 592($t0)
addi $t1,$zero,49 # 1
sw $t1, 596($t0)
addi $t1,$zero,49 # 1
sw $t1, 600($t0)
addi $t1,$zero,49 # 1
sw $t1, 604($t0)
addi $t1,$zero,50 # 2
sw $t1, 608($t0)
addi $t1,$zero,53 # 5
sw $t1, 612($t0)
addi $t1,$zero,52 # 4
sw $t1, 616($t0)
addi $t1,$zero,48 # 0
sw $t1, 620($t0)
addi $t1,$zero,54 # 6
sw $t1, 624($t0)
addi $t1,$zero,57 # 9
sw $t1, 628($t0)
addi $t1,$zero,56 # 8
sw $t1, 632($t0)
addi $t1,$zero,55 # 7
sw $t1, 636($t0)
addi $t1,$zero,52 # 4
sw $t1, 640($t0)
addi $t1,$zero,55 # 7
sw $t1, 644($t0)
addi $t1,$zero,49 # 1
sw $t1, 648($t0)
addi $t1,$zero,53 # 5
sw $t1, 652($t0)
addi $t1,$zero,56 # 8
sw $t1, 656($t0)
addi $t1,$zero,53 # 5
sw $t1, 660($t0)
addi $t1,$zero,50 # 2
sw $t1, 664($t0)
addi $t1,$zero,51 # 3
sw $t1, 668($t0)
addi $t1,$zero,56 # 8
sw $t1, 672($t0)
addi $t1,$zero,54 # 6
sw $t1, 676($t0)
addi $t1,$zero,51 # 3
sw $t1, 680($t0)
addi $t1,$zero,48 # 0
sw $t1, 684($t0)
addi $t1,$zero,53 # 5
sw $t1, 688($t0)
addi $t1,$zero,48 # 0
sw $t1, 692($t0)
addi $t1,$zero,55 # 7
sw $t1, 696($t0)
addi $t1,$zero,49 # 1
sw $t1, 700($t0)
addi $t1,$zero,53 # 5
sw $t1, 704($t0)
addi $t1,$zero,54 # 6
sw $t1, 708($t0)
addi $t1,$zero,57 # 9
sw $t1, 712($t0)
addi $t1,$zero,51 # 3
sw $t1, 716($t0)
addi $t1,$zero,50 # 2
sw $t1, 720($t0)
addi $t1,$zero,57 # 9
sw $t1, 724($t0)
addi $t1,$zero,48 # 0
sw $t1, 728($t0)
addi $t1,$zero,57 # 9
sw $t1, 732($t0)
addi $t1,$zero,54 # 6
sw $t1, 736($t0)
addi $t1,$zero,51 # 3
sw $t1, 740($t0)
addi $t1,$zero,50 # 2
sw $t1, 744($t0)
addi $t1,$zero,57 # 9
sw $t1, 748($t0)
addi $t1,$zero,53 # 5
sw $t1, 752($t0)
addi $t1,$zero,50 # 2
sw $t1, 756($t0)
addi $t1,$zero,50 # 2
sw $t1, 760($t0)
addi $t1,$zero,55 # 7
sw $t1, 764($t0)
addi $t1,$zero,52 # 4
sw $t1, 768($t0)
addi $t1,$zero,52 # 4
sw $t1, 772($t0)
addi $t1,$zero,51 # 3
sw $t1, 776($t0)
addi $t1,$zero,48 # 0
sw $t1, 780($t0)
addi $t1,$zero,52 # 4
sw $t1, 784($t0)
addi $t1,$zero,51 # 3
sw $t1, 788($t0)
addi $t1,$zero,53 # 5
sw $t1, 792($t0)
addi $t1,$zero,53 # 5
sw $t1, 796($t0)
addi $t1,$zero,55 # 7
sw $t1, 800($t0)
addi $t1,$zero,54 # 6
sw $t1, 804($t0)
addi $t1,$zero,54 # 6
sw $t1, 808($t0)
addi $t1,$zero,56 # 8
sw $t1, 812($t0)
addi $t1,$zero,57 # 9
sw $t1, 816($t0)
addi $t1,$zero,54 # 6
sw $t1, 820($t0)
addi $t1,$zero,54 # 6
sw $t1, 824($t0)
addi $t1,$zero,52 # 4
sw $t1, 828($t0)
addi $t1,$zero,56 # 8
sw $t1, 832($t0)
addi $t1,$zero,57 # 9
sw $t1, 836($t0)
addi $t1,$zero,53 # 5
sw $t1, 840($t0)
addi $t1,$zero,48 # 0
sw $t1, 844($t0)
addi $t1,$zero,52 # 4
sw $t1, 848($t0)
addi $t1,$zero,52 # 4
sw $t1, 852($t0)
addi $t1,$zero,53 # 5
sw $t1, 856($t0)
addi $t1,$zero,50 # 2
sw $t1, 860($t0)
addi $t1,$zero,52 # 4
sw $t1, 864($t0)
addi $t1,$zero,52 # 4
sw $t1, 868($t0)
addi $t1,$zero,53 # 5
sw $t1, 872($t0)
addi $t1,$zero,50 # 2
sw $t1, 876($t0)
addi $t1,$zero,51 # 3
sw $t1, 880($t0)
addi $t1,$zero,49 # 1
sw $t1, 884($t0)
addi $t1,$zero,54 # 6
sw $t1, 888($t0)
addi $t1,$zero,49 # 1
sw $t1, 892($t0)
addi $t1,$zero,55 # 7
sw $t1, 896($t0)
addi $t1,$zero,51 # 3
sw $t1, 900($t0)
addi $t1,$zero,49 # 1
sw $t1, 904($t0)
addi $t1,$zero,56 # 8
sw $t1, 908($t0)
addi $t1,$zero,53 # 5
sw $t1, 912($t0)
addi $t1,$zero,54 # 6
sw $t1, 916($t0)
addi $t1,$zero,52 # 4
sw $t1, 920($t0)
addi $t1,$zero,48 # 0
sw $t1, 924($t0)
addi $t1,$zero,51 # 3
sw $t1, 928($t0)
addi $t1,$zero,48 # 0
sw $t1, 932($t0)
addi $t1,$zero,57 # 9
sw $t1, 936($t0)
addi $t1,$zero,56 # 8
sw $t1, 940($t0)
addi $t1,$zero,55 # 7
sw $t1, 944($t0)
addi $t1,$zero,49 # 1
sw $t1, 948($t0)
addi $t1,$zero,49 # 1
sw $t1, 952($t0)
addi $t1,$zero,49 # 1
sw $t1, 956($t0)
addi $t1,$zero,50 # 2
sw $t1, 960($t0)
addi $t1,$zero,49 # 1
sw $t1, 964($t0)
addi $t1,$zero,55 # 7
sw $t1, 968($t0)
addi $t1,$zero,50 # 2
sw $t1, 972($t0)
addi $t1,$zero,50 # 2
sw $t1, 976($t0)
addi $t1,$zero,51 # 3
sw $t1, 980($t0)
addi $t1,$zero,56 # 8
sw $t1, 984($t0)
addi $t1,$zero,51 # 3
sw $t1, 988($t0)
addi $t1,$zero,49 # 1
sw $t1, 992($t0)
addi $t1,$zero,49 # 1
sw $t1, 996($t0)
addi $t1,$zero,51 # 3
sw $t1, 1000($t0)
addi $t1,$zero,54 # 6
sw $t1, 1004($t0)
addi $t1,$zero,50 # 2
sw $t1, 1008($t0)
addi $t1,$zero,50 # 2
sw $t1, 1012($t0)
addi $t1,$zero,50 # 2
sw $t1, 1016($t0)
addi $t1,$zero,57 # 9
sw $t1, 1020($t0)
addi $t1,$zero,56 # 8
sw $t1, 1024($t0)
addi $t1,$zero,57 # 9
sw $t1, 1028($t0)
addi $t1,$zero,51 # 3
sw $t1, 1032($t0)
addi $t1,$zero,52 # 4
sw $t1, 1036($t0)
addi $t1,$zero,50 # 2
sw $t1, 1040($t0)
addi $t1,$zero,51 # 3
sw $t1, 1044($t0)
addi $t1,$zero,51 # 3
sw $t1, 1048($t0)
addi $t1,$zero,56 # 8
sw $t1, 1052($t0)
addi $t1,$zero,48 # 0
sw $t1, 1056($t0)
addi $t1,$zero,51 # 3
sw $t1, 1060($t0)
addi $t1,$zero,48 # 0
sw $t1, 1064($t0)
addi $t1,$zero,56 # 8
sw $t1, 1068($t0)
addi $t1,$zero,49 # 1
sw $t1, 1072($t0)
addi $t1,$zero,51 # 3
sw $t1, 1076($t0)
addi $t1,$zero,53 # 5
sw $t1, 1080($t0)
addi $t1,$zero,51 # 3
sw $t1, 1084($t0)
addi $t1,$zero,51 # 3
sw $t1, 1088($t0)
addi $t1,$zero,54 # 6
sw $t1, 1092($t0)
addi $t1,$zero,50 # 2
sw $t1, 1096($t0)
addi $t1,$zero,55 # 7
sw $t1, 1100($t0)
addi $t1,$zero,54 # 6
sw $t1, 1104($t0)
addi $t1,$zero,54 # 6
sw $t1, 1108($t0)
addi $t1,$zero,49 # 1
sw $t1, 1112($t0)
addi $t1,$zero,52 # 4
sw $t1, 1116($t0)
addi $t1,$zero,50 # 2
sw $t1, 1120($t0)
addi $t1,$zero,56 # 8
sw $t1, 1124($t0)
addi $t1,$zero,50 # 2
sw $t1, 1128($t0)
addi $t1,$zero,56 # 8
sw $t1, 1132($t0)
addi $t1,$zero,48 # 0
sw $t1, 1136($t0)
addi $t1,$zero,54 # 6
sw $t1, 1140($t0)
addi $t1,$zero,52 # 4
sw $t1, 1144($t0)
addi $t1,$zero,52 # 4
sw $t1, 1148($t0)
addi $t1,$zero,52 # 4
sw $t1, 1152($t0)
addi $t1,$zero,52 # 4
sw $t1, 1156($t0)
addi $t1,$zero,56 # 8
sw $t1, 1160($t0)
addi $t1,$zero,54 # 6
sw $t1, 1164($t0)
addi $t1,$zero,54 # 6
sw $t1, 1168($t0)
addi $t1,$zero,52 # 4
sw $t1, 1172($t0)
addi $t1,$zero,53 # 5
sw $t1, 1176($t0)
addi $t1,$zero,50 # 2
sw $t1, 1180($t0)
addi $t1,$zero,51 # 3
sw $t1, 1184($t0)
addi $t1,$zero,56 # 8
sw $t1, 1188($t0)
addi $t1,$zero,55 # 7
sw $t1, 1192($t0)
addi $t1,$zero,52 # 4
sw $t1, 1196($t0)
addi $t1,$zero,57 # 9
sw $t1, 1200($t0)
addi $t1,$zero,51 # 3
sw $t1, 1204($t0)
addi $t1,$zero,48 # 0
sw $t1, 1208($t0)
addi $t1,$zero,51 # 3
sw $t1, 1212($t0)
addi $t1,$zero,53 # 5
sw $t1, 1216($t0)
addi $t1,$zero,56 # 8
sw $t1, 1220($t0)
addi $t1,$zero,57 # 9
sw $t1, 1224($t0)
addi $t1,$zero,48 # 0
sw $t1, 1228($t0)
addi $t1,$zero,55 # 7
sw $t1, 1232($t0)
addi $t1,$zero,50 # 2
sw $t1, 1236($t0)
addi $t1,$zero,57 # 9
sw $t1, 1240($t0)
addi $t1,$zero,54 # 6
sw $t1, 1244($t0)
addi $t1,$zero,50 # 2
sw $t1, 1248($t0)
addi $t1,$zero,57 # 9
sw $t1, 1252($t0)
addi $t1,$zero,48 # 0
sw $t1, 1256($t0)
addi $t1,$zero,52 # 4
sw $t1, 1260($t0)
addi $t1,$zero,57 # 9
sw $t1, 1264($t0)
addi $t1,$zero,49 # 1
sw $t1, 1268($t0)
addi $t1,$zero,53 # 5
sw $t1, 1272($t0)
addi $t1,$zero,54 # 6
sw $t1, 1276($t0)
addi $t1,$zero,48 # 0
sw $t1, 1280($t0)
addi $t1,$zero,52 # 4
sw $t1, 1284($t0)
addi $t1,$zero,52 # 4
sw $t1, 1288($t0)
addi $t1,$zero,48 # 0
sw $t1, 1292($t0)
addi $t1,$zero,55 # 7
sw $t1, 1296($t0)
addi $t1,$zero,55 # 7
sw $t1, 1300($t0)
addi $t1,$zero,50 # 2
sw $t1, 1304($t0)
addi $t1,$zero,51 # 3
sw $t1, 1308($t0)
addi $t1,$zero,57 # 9
sw $t1, 1312($t0)
addi $t1,$zero,48 # 0
sw $t1, 1316($t0)
addi $t1,$zero,55 # 7
sw $t1, 1320($t0)
addi $t1,$zero,49 # 1
sw $t1, 1324($t0)
addi $t1,$zero,51 # 3
sw $t1, 1328($t0)
addi $t1,$zero,56 # 8
sw $t1, 1332($t0)
addi $t1,$zero,49 # 1
sw $t1, 1336($t0)
addi $t1,$zero,48 # 0
sw $t1, 1340($t0)
addi $t1,$zero,53 # 5
sw $t1, 1344($t0)
addi $t1,$zero,49 # 1
sw $t1, 1348($t0)
addi $t1,$zero,53 # 5
sw $t1, 1352($t0)
addi $t1,$zero,56 # 8
sw $t1, 1356($t0)
addi $t1,$zero,53 # 5
sw $t1, 1360($t0)
addi $t1,$zero,57 # 9
sw $t1, 1364($t0)
addi $t1,$zero,51 # 3
sw $t1, 1368($t0)
addi $t1,$zero,48 # 0
sw $t1, 1372($t0)
addi $t1,$zero,55 # 7
sw $t1, 1376($t0)
addi $t1,$zero,57 # 9
sw $t1, 1380($t0)
addi $t1,$zero,54 # 6
sw $t1, 1384($t0)
addi $t1,$zero,48 # 0
sw $t1, 1388($t0)
addi $t1,$zero,56 # 8
sw $t1, 1392($t0)
addi $t1,$zero,54 # 6
sw $t1, 1396($t0)
addi $t1,$zero,54 # 6
sw $t1, 1400($t0)
addi $t1,$zero,55 # 7
sw $t1, 1404($t0)
addi $t1,$zero,48 # 0
sw $t1, 1408($t0)
addi $t1,$zero,49 # 1
sw $t1, 1412($t0)
addi $t1,$zero,55 # 7
sw $t1, 1416($t0)
addi $t1,$zero,50 # 2
sw $t1, 1420($t0)
addi $t1,$zero,52 # 4
sw $t1, 1424($t0)
addi $t1,$zero,50 # 2
sw $t1, 1428($t0)
addi $t1,$zero,55 # 7
sw $t1, 1432($t0)
addi $t1,$zero,49 # 1
sw $t1, 1436($t0)
addi $t1,$zero,50 # 2
sw $t1, 1440($t0)
addi $t1,$zero,49 # 1
sw $t1, 1444($t0)
addi $t1,$zero,56 # 8
sw $t1, 1448($t0)
addi $t1,$zero,56 # 8
sw $t1, 1452($t0)
addi $t1,$zero,51 # 3
sw $t1, 1456($t0)
addi $t1,$zero,57 # 9
sw $t1, 1460($t0)
addi $t1,$zero,57 # 9
sw $t1, 1464($t0)
addi $t1,$zero,56 # 8
sw $t1, 1468($t0)
addi $t1,$zero,55 # 7
sw $t1, 1472($t0)
addi $t1,$zero,57 # 9
sw $t1, 1476($t0)
addi $t1,$zero,55 # 7
sw $t1, 1480($t0)
addi $t1,$zero,57 # 9
sw $t1, 1484($t0)
addi $t1,$zero,48 # 0
sw $t1, 1488($t0)
addi $t1,$zero,56 # 8
sw $t1, 1492($t0)
addi $t1,$zero,55 # 7
sw $t1, 1496($t0)
addi $t1,$zero,57 # 9
sw $t1, 1500($t0)
addi $t1,$zero,50 # 2
sw $t1, 1504($t0)
addi $t1,$zero,50 # 2
sw $t1, 1508($t0)
addi $t1,$zero,55 # 7
sw $t1, 1512($t0)
addi $t1,$zero,52 # 4
sw $t1, 1516($t0)
addi $t1,$zero,57 # 9
sw $t1, 1520($t0)
addi $t1,$zero,50 # 2
sw $t1, 1524($t0)
addi $t1,$zero,49 # 1
sw $t1, 1528($t0)
addi $t1,$zero,57 # 9
sw $t1, 1532($t0)
addi $t1,$zero,48 # 0
sw $t1, 1536($t0)
addi $t1,$zero,49 # 1
sw $t1, 1540($t0)
addi $t1,$zero,54 # 6
sw $t1, 1544($t0)
addi $t1,$zero,57 # 9
sw $t1, 1548($t0)
addi $t1,$zero,57 # 9
sw $t1, 1552($t0)
addi $t1,$zero,55 # 7
sw $t1, 1556($t0)
addi $t1,$zero,50 # 2
sw $t1, 1560($t0)
addi $t1,$zero,48 # 0
sw $t1, 1564($t0)
addi $t1,$zero,56 # 8
sw $t1, 1568($t0)
addi $t1,$zero,56 # 8
sw $t1, 1572($t0)
addi $t1,$zero,56 # 8
sw $t1, 1576($t0)
addi $t1,$zero,48 # 0
sw $t1, 1580($t0)
addi $t1,$zero,57 # 9
sw $t1, 1584($t0)
addi $t1,$zero,51 # 3
sw $t1, 1588($t0)
addi $t1,$zero,55 # 7
sw $t1, 1592($t0)
addi $t1,$zero,55 # 7
sw $t1, 1596($t0)
addi $t1,$zero,54 # 6
sw $t1, 1600($t0)
addi $t1,$zero,54 # 6
sw $t1, 1604($t0)
addi $t1,$zero,53 # 5
sw $t1, 1608($t0)
addi $t1,$zero,55 # 7
sw $t1, 1612($t0)
addi $t1,$zero,50 # 2
sw $t1, 1616($t0)
addi $t1,$zero,55 # 7
sw $t1, 1620($t0)
addi $t1,$zero,51 # 3
sw $t1, 1624($t0)
addi $t1,$zero,51 # 3
sw $t1, 1628($t0)
addi $t1,$zero,51 # 3
sw $t1, 1632($t0)
addi $t1,$zero,48 # 0
sw $t1, 1636($t0)
addi $t1,$zero,48 # 0
sw $t1, 1640($t0)
addi $t1,$zero,49 # 1
sw $t1, 1644($t0)
addi $t1,$zero,48 # 0
sw $t1, 1648($t0)
addi $t1,$zero,53 # 5
sw $t1, 1652($t0)
addi $t1,$zero,51 # 3
sw $t1, 1656($t0)
addi $t1,$zero,51 # 3
sw $t1, 1660($t0)
addi $t1,$zero,54 # 6
sw $t1, 1664($t0)
addi $t1,$zero,55 # 7
sw $t1, 1668($t0)
addi $t1,$zero,56 # 8
sw $t1, 1672($t0)
addi $t1,$zero,56 # 8
sw $t1, 1676($t0)
addi $t1,$zero,49 # 1
sw $t1, 1680($t0)
addi $t1,$zero,50 # 2
sw $t1, 1684($t0)
addi $t1,$zero,50 # 2
sw $t1, 1688($t0)
addi $t1,$zero,48 # 0
sw $t1, 1692($t0)
addi $t1,$zero,50 # 2
sw $t1, 1696($t0)
addi $t1,$zero,51 # 3
sw $t1, 1700($t0)
addi $t1,$zero,53 # 5
sw $t1, 1704($t0)
addi $t1,$zero,52 # 4
sw $t1, 1708($t0)
addi $t1,$zero,50 # 2
sw $t1, 1712($t0)
addi $t1,$zero,49 # 1
sw $t1, 1716($t0)
addi $t1,$zero,56 # 8
sw $t1, 1720($t0)
addi $t1,$zero,48 # 0
sw $t1, 1724($t0)
addi $t1,$zero,57 # 9
sw $t1, 1728($t0)
addi $t1,$zero,55 # 7
sw $t1, 1732($t0)
addi $t1,$zero,53 # 5
sw $t1, 1736($t0)
addi $t1,$zero,49 # 1
sw $t1, 1740($t0)
addi $t1,$zero,50 # 2
sw $t1, 1744($t0)
addi $t1,$zero,53 # 5
sw $t1, 1748($t0)
addi $t1,$zero,52 # 4
sw $t1, 1752($t0)
addi $t1,$zero,53 # 5
sw $t1, 1756($t0)
addi $t1,$zero,52 # 4
sw $t1, 1760($t0)
addi $t1,$zero,48 # 0
sw $t1, 1764($t0)
addi $t1,$zero,53 # 5
sw $t1, 1768($t0)
addi $t1,$zero,57 # 9
sw $t1, 1772($t0)
addi $t1,$zero,52 # 4
sw $t1, 1776($t0)
addi $t1,$zero,55 # 7
sw $t1, 1780($t0)
addi $t1,$zero,53 # 5
sw $t1, 1784($t0)
addi $t1,$zero,50 # 2
sw $t1, 1788($t0)
addi $t1,$zero,50 # 2
sw $t1, 1792($t0)
addi $t1,$zero,52 # 4
sw $t1, 1796($t0)
addi $t1,$zero,51 # 3
sw $t1, 1800($t0)
addi $t1,$zero,53 # 5
sw $t1, 1804($t0)
addi $t1,$zero,50 # 2
sw $t1, 1808($t0)
addi $t1,$zero,53 # 5
sw $t1, 1812($t0)
addi $t1,$zero,56 # 8
sw $t1, 1816($t0)
addi $t1,$zero,52 # 4
sw $t1, 1820($t0)
addi $t1,$zero,57 # 9
sw $t1, 1824($t0)
addi $t1,$zero,48 # 0
sw $t1, 1828($t0)
addi $t1,$zero,55 # 7
sw $t1, 1832($t0)
addi $t1,$zero,55 # 7
sw $t1, 1836($t0)
addi $t1,$zero,49 # 1
sw $t1, 1840($t0)
addi $t1,$zero,49 # 1
sw $t1, 1844($t0)
addi $t1,$zero,54 # 6
sw $t1, 1848($t0)
addi $t1,$zero,55 # 7
sw $t1, 1852($t0)
addi $t1,$zero,48 # 0
sw $t1, 1856($t0)
addi $t1,$zero,53 # 5
sw $t1, 1860($t0)
addi $t1,$zero,53 # 5
sw $t1, 1864($t0)
addi $t1,$zero,54 # 6
sw $t1, 1868($t0)
addi $t1,$zero,48 # 0
sw $t1, 1872($t0)
addi $t1,$zero,49 # 1
sw $t1, 1876($t0)
addi $t1,$zero,51 # 3
sw $t1, 1880($t0)
addi $t1,$zero,54 # 6
sw $t1, 1884($t0)
addi $t1,$zero,48 # 0
sw $t1, 1888($t0)
addi $t1,$zero,52 # 4
sw $t1, 1892($t0)
addi $t1,$zero,56 # 8
sw $t1, 1896($t0)
addi $t1,$zero,51 # 3
sw $t1, 1900($t0)
addi $t1,$zero,57 # 9
sw $t1, 1904($t0)
addi $t1,$zero,53 # 5
sw $t1, 1908($t0)
addi $t1,$zero,56 # 8
sw $t1, 1912($t0)
addi $t1,$zero,54 # 6
sw $t1, 1916($t0)
addi $t1,$zero,52 # 4
sw $t1, 1920($t0)
addi $t1,$zero,52 # 4
sw $t1, 1924($t0)
addi $t1,$zero,54 # 6
sw $t1, 1928($t0)
addi $t1,$zero,55 # 7
sw $t1, 1932($t0)
addi $t1,$zero,48 # 0
sw $t1, 1936($t0)
addi $t1,$zero,54 # 6
sw $t1, 1940($t0)
addi $t1,$zero,51 # 3
sw $t1, 1944($t0)
addi $t1,$zero,50 # 2
sw $t1, 1948($t0)
addi $t1,$zero,52 # 4
sw $t1, 1952($t0)
addi $t1,$zero,52 # 4
sw $t1, 1956($t0)
addi $t1,$zero,49 # 1
sw $t1, 1960($t0)
addi $t1,$zero,53 # 5
sw $t1, 1964($t0)
addi $t1,$zero,55 # 7
sw $t1, 1968($t0)
addi $t1,$zero,50 # 2
sw $t1, 1972($t0)
addi $t1,$zero,50 # 2
sw $t1, 1976($t0)
addi $t1,$zero,49 # 1
sw $t1, 1980($t0)
addi $t1,$zero,53 # 5
sw $t1, 1984($t0)
addi $t1,$zero,53 # 5
sw $t1, 1988($t0)
addi $t1,$zero,51 # 3
sw $t1, 1992($t0)
addi $t1,$zero,57 # 9
sw $t1, 1996($t0)
addi $t1,$zero,55 # 7
sw $t1, 2000($t0)
addi $t1,$zero,53 # 5
sw $t1, 2004($t0)
addi $t1,$zero,51 # 3
sw $t1, 2008($t0)
addi $t1,$zero,54 # 6
sw $t1, 2012($t0)
addi $t1,$zero,57 # 9
sw $t1, 2016($t0)
addi $t1,$zero,55 # 7
sw $t1, 2020($t0)
addi $t1,$zero,56 # 8
sw $t1, 2024($t0)
addi $t1,$zero,49 # 1
sw $t1, 2028($t0)
addi $t1,$zero,55 # 7
sw $t1, 2032($t0)
addi $t1,$zero,57 # 9
sw $t1, 2036($t0)
addi $t1,$zero,55 # 7
sw $t1, 2040($t0)
addi $t1,$zero,55 # 7
sw $t1, 2044($t0)
addi $t1,$zero,56 # 8
sw $t1, 2048($t0)
addi $t1,$zero,52 # 4
sw $t1, 2052($t0)
addi $t1,$zero,54 # 6
sw $t1, 2056($t0)
addi $t1,$zero,49 # 1
sw $t1, 2060($t0)
addi $t1,$zero,55 # 7
sw $t1, 2064($t0)
addi $t1,$zero,52 # 4
sw $t1, 2068($t0)
addi $t1,$zero,48 # 0
sw $t1, 2072($t0)
addi $t1,$zero,54 # 6
sw $t1, 2076($t0)
addi $t1,$zero,52 # 4
sw $t1, 2080($t0)
addi $t1,$zero,57 # 9
sw $t1, 2084($t0)
addi $t1,$zero,53 # 5
sw $t1, 2088($t0)
addi $t1,$zero,53 # 5
sw $t1, 2092($t0)
addi $t1,$zero,49 # 1
sw $t1, 2096($t0)
addi $t1,$zero,52 # 4
sw $t1, 2100($t0)
addi $t1,$zero,57 # 9
sw $t1, 2104($t0)
addi $t1,$zero,50 # 2
sw $t1, 2108($t0)
addi $t1,$zero,57 # 9
sw $t1, 2112($t0)
addi $t1,$zero,48 # 0
sw $t1, 2116($t0)
addi $t1,$zero,56 # 8
sw $t1, 2120($t0)
addi $t1,$zero,54 # 6
sw $t1, 2124($t0)
addi $t1,$zero,50 # 2
sw $t1, 2128($t0)
addi $t1,$zero,53 # 5
sw $t1, 2132($t0)
addi $t1,$zero,54 # 6
sw $t1, 2136($t0)
addi $t1,$zero,57 # 9
sw $t1, 2140($t0)
addi $t1,$zero,51 # 3
sw $t1, 2144($t0)
addi $t1,$zero,50 # 2
sw $t1, 2148($t0)
addi $t1,$zero,49 # 1
sw $t1, 2152($t0)
addi $t1,$zero,57 # 9
sw $t1, 2156($t0)
addi $t1,$zero,55 # 7
sw $t1, 2160($t0)
addi $t1,$zero,56 # 8
sw $t1, 2164($t0)
addi $t1,$zero,52 # 4
sw $t1, 2168($t0)
addi $t1,$zero,54 # 6
sw $t1, 2172($t0)
addi $t1,$zero,56 # 8
sw $t1, 2176($t0)
addi $t1,$zero,54 # 6
sw $t1, 2180($t0)
addi $t1,$zero,50 # 2
sw $t1, 2184($t0)
addi $t1,$zero,50 # 2
sw $t1, 2188($t0)
addi $t1,$zero,52 # 4
sw $t1, 2192($t0)
addi $t1,$zero,56 # 8
sw $t1, 2196($t0)
addi $t1,$zero,50 # 2
sw $t1, 2200($t0)
addi $t1,$zero,56 # 8
sw $t1, 2204($t0)
addi $t1,$zero,51 # 3
sw $t1, 2208($t0)
addi $t1,$zero,57 # 9
sw $t1, 2212($t0)
addi $t1,$zero,55 # 7
sw $t1, 2216($t0)
addi $t1,$zero,50 # 2
sw $t1, 2220($t0)
addi $t1,$zero,50 # 2
sw $t1, 2224($t0)
addi $t1,$zero,52 # 4
sw $t1, 2228($t0)
addi $t1,$zero,49 # 1
sw $t1, 2232($t0)
addi $t1,$zero,51 # 3
sw $t1, 2236($t0)
addi $t1,$zero,55 # 7
sw $t1, 2240($t0)
addi $t1,$zero,53 # 5
sw $t1, 2244($t0)
addi $t1,$zero,54 # 6
sw $t1, 2248($t0)
addi $t1,$zero,53 # 5
sw $t1, 2252($t0)
addi $t1,$zero,55 # 7
sw $t1, 2256($t0)
addi $t1,$zero,48 # 0
sw $t1, 2260($t0)
addi $t1,$zero,53 # 5
sw $t1, 2264($t0)
addi $t1,$zero,54 # 6
sw $t1, 2268($t0)
addi $t1,$zero,48 # 0
sw $t1, 2272($t0)
addi $t1,$zero,53 # 5
sw $t1, 2276($t0)
addi $t1,$zero,55 # 7
sw $t1, 2280($t0)
addi $t1,$zero,52 # 4
sw $t1, 2284($t0)
addi $t1,$zero,57 # 9
sw $t1, 2288($t0)
addi $t1,$zero,48 # 0
sw $t1, 2292($t0)
addi $t1,$zero,50 # 2
sw $t1, 2296($t0)
addi $t1,$zero,54 # 6
sw $t1, 2300($t0)
addi $t1,$zero,49 # 1
sw $t1, 2304($t0)
addi $t1,$zero,52 # 4
sw $t1, 2308($t0)
addi $t1,$zero,48 # 0
sw $t1, 2312($t0)
addi $t1,$zero,55 # 7
sw $t1, 2316($t0)
addi $t1,$zero,57 # 9
sw $t1, 2320($t0)
addi $t1,$zero,55 # 7
sw $t1, 2324($t0)
addi $t1,$zero,50 # 2
sw $t1, 2328($t0)
addi $t1,$zero,57 # 9
sw $t1, 2332($t0)
addi $t1,$zero,54 # 6
sw $t1, 2336($t0)
addi $t1,$zero,56 # 8
sw $t1, 2340($t0)
addi $t1,$zero,54 # 6
sw $t1, 2344($t0)
addi $t1,$zero,53 # 5
sw $t1, 2348($t0)
addi $t1,$zero,50 # 2
sw $t1, 2352($t0)
addi $t1,$zero,52 # 4
sw $t1, 2356($t0)
addi $t1,$zero,49 # 1
sw $t1, 2360($t0)
addi $t1,$zero,52 # 4
sw $t1, 2364($t0)
addi $t1,$zero,53 # 5
sw $t1, 2368($t0)
addi $t1,$zero,51 # 3
sw $t1, 2372($t0)
addi $t1,$zero,53 # 5
sw $t1, 2376($t0)
addi $t1,$zero,49 # 1
sw $t1, 2380($t0)
addi $t1,$zero,48 # 0
sw $t1, 2384($t0)
addi $t1,$zero,48 # 0
sw $t1, 2388($t0)
addi $t1,$zero,52 # 4
sw $t1, 2392($t0)
addi $t1,$zero,55 # 7
sw $t1, 2396($t0)
addi $t1,$zero,52 # 4
sw $t1, 2400($t0)
addi $t1,$zero,56 # 8
sw $t1, 2404($t0)
addi $t1,$zero,50 # 2
sw $t1, 2408($t0)
addi $t1,$zero,49 # 1
sw $t1, 2412($t0)
addi $t1,$zero,54 # 6
sw $t1, 2416($t0)
addi $t1,$zero,54 # 6
sw $t1, 2420($t0)
addi $t1,$zero,51 # 3
sw $t1, 2424($t0)
addi $t1,$zero,55 # 7
sw $t1, 2428($t0)
addi $t1,$zero,48 # 0
sw $t1, 2432($t0)
addi $t1,$zero,52 # 4
sw $t1, 2436($t0)
addi $t1,$zero,56 # 8
sw $t1, 2440($t0)
addi $t1,$zero,52 # 4
sw $t1, 2444($t0)
addi $t1,$zero,52 # 4
sw $t1, 2448($t0)
addi $t1,$zero,48 # 0
sw $t1, 2452($t0)
addi $t1,$zero,51 # 3
sw $t1, 2456($t0)
addi $t1,$zero,49 # 1
sw $t1, 2460($t0)
addi $t1,$zero,57 # 9
sw $t1, 2464($t0)
addi $t1,$zero,57 # 9
sw $t1, 2468($t0)
addi $t1,$zero,56 # 8
sw $t1, 2472($t0)
addi $t1,$zero,57 # 9
sw $t1, 2476($t0)
addi $t1,$zero,48 # 0
sw $t1, 2480($t0)
addi $t1,$zero,48 # 0
sw $t1, 2484($t0)
addi $t1,$zero,48 # 0
sw $t1, 2488($t0)
addi $t1,$zero,56 # 8
sw $t1, 2492($t0)
addi $t1,$zero,56 # 8
sw $t1, 2496($t0)
addi $t1,$zero,57 # 9
sw $t1, 2500($t0)
addi $t1,$zero,53 # 5
sw $t1, 2504($t0)
addi $t1,$zero,50 # 2
sw $t1, 2508($t0)
addi $t1,$zero,52 # 4
sw $t1, 2512($t0)
addi $t1,$zero,51 # 3
sw $t1, 2516($t0)
addi $t1,$zero,52 # 4
sw $t1, 2520($t0)
addi $t1,$zero,53 # 5
sw $t1, 2524($t0)
addi $t1,$zero,48 # 0
sw $t1, 2528($t0)
addi $t1,$zero,54 # 6
sw $t1, 2532($t0)
addi $t1,$zero,53 # 5
sw $t1, 2536($t0)
addi $t1,$zero,56 # 8
sw $t1, 2540($t0)
addi $t1,$zero,53 # 5
sw $t1, 2544($t0)
addi $t1,$zero,52 # 4
sw $t1, 2548($t0)
addi $t1,$zero,49 # 1
sw $t1, 2552($t0)
addi $t1,$zero,50 # 2
sw $t1, 2556($t0)
addi $t1,$zero,50 # 2
sw $t1, 2560($t0)
addi $t1,$zero,55 # 7
sw $t1, 2564($t0)
addi $t1,$zero,53 # 5
sw $t1, 2568($t0)
addi $t1,$zero,56 # 8
sw $t1, 2572($t0)
addi $t1,$zero,56 # 8
sw $t1, 2576($t0)
addi $t1,$zero,54 # 6
sw $t1, 2580($t0)
addi $t1,$zero,54 # 6
sw $t1, 2584($t0)
addi $t1,$zero,54 # 6
sw $t1, 2588($t0)
addi $t1,$zero,56 # 8
sw $t1, 2592($t0)
addi $t1,$zero,56 # 8
sw $t1, 2596($t0)
addi $t1,$zero,49 # 1
sw $t1, 2600($t0)
addi $t1,$zero,49 # 1
sw $t1, 2604($t0)
addi $t1,$zero,54 # 6
sw $t1, 2608($t0)
addi $t1,$zero,52 # 4
sw $t1, 2612($t0)
addi $t1,$zero,50 # 2
sw $t1, 2616($t0)
addi $t1,$zero,55 # 7
sw $t1, 2620($t0)
addi $t1,$zero,49 # 1
sw $t1, 2624($t0)
addi $t1,$zero,55 # 7
sw $t1, 2628($t0)
addi $t1,$zero,49 # 1
sw $t1, 2632($t0)
addi $t1,$zero,52 # 4
sw $t1, 2636($t0)
addi $t1,$zero,55 # 7
sw $t1, 2640($t0)
addi $t1,$zero,57 # 9
sw $t1, 2644($t0)
addi $t1,$zero,57 # 9
sw $t1, 2648($t0)
addi $t1,$zero,50 # 2
sw $t1, 2652($t0)
addi $t1,$zero,52 # 4
sw $t1, 2656($t0)
addi $t1,$zero,52 # 4
sw $t1, 2660($t0)
addi $t1,$zero,52 # 4
sw $t1, 2664($t0)
addi $t1,$zero,50 # 2
sw $t1, 2668($t0)
addi $t1,$zero,57 # 9
sw $t1, 2672($t0)
addi $t1,$zero,50 # 2
sw $t1, 2676($t0)
addi $t1,$zero,56 # 8
sw $t1, 2680($t0)
addi $t1,$zero,50 # 2
sw $t1, 2684($t0)
addi $t1,$zero,51 # 3
sw $t1, 2688($t0)
addi $t1,$zero,48 # 0
sw $t1, 2692($t0)
addi $t1,$zero,56 # 8
sw $t1, 2696($t0)
addi $t1,$zero,54 # 6
sw $t1, 2700($t0)
addi $t1,$zero,51 # 3
sw $t1, 2704($t0)
addi $t1,$zero,52 # 4
sw $t1, 2708($t0)
addi $t1,$zero,54 # 6
sw $t1, 2712($t0)
addi $t1,$zero,53 # 5
sw $t1, 2716($t0)
addi $t1,$zero,54 # 6
sw $t1, 2720($t0)
addi $t1,$zero,55 # 7
sw $t1, 2724($t0)
addi $t1,$zero,52 # 4
sw $t1, 2728($t0)
addi $t1,$zero,56 # 8
sw $t1, 2732($t0)
addi $t1,$zero,49 # 1
sw $t1, 2736($t0)
addi $t1,$zero,51 # 3
sw $t1, 2740($t0)
addi $t1,$zero,57 # 9
sw $t1, 2744($t0)
addi $t1,$zero,49 # 1
sw $t1, 2748($t0)
addi $t1,$zero,57 # 9
sw $t1, 2752($t0)
addi $t1,$zero,49 # 1
sw $t1, 2756($t0)
addi $t1,$zero,50 # 2
sw $t1, 2760($t0)
addi $t1,$zero,51 # 3
sw $t1, 2764($t0)
addi $t1,$zero,49 # 1
sw $t1, 2768($t0)
addi $t1,$zero,54 # 6
sw $t1, 2772($t0)
addi $t1,$zero,50 # 2
sw $t1, 2776($t0)
addi $t1,$zero,56 # 8
sw $t1, 2780($t0)
addi $t1,$zero,50 # 2
sw $t1, 2784($t0)
addi $t1,$zero,52 # 4
sw $t1, 2788($t0)
addi $t1,$zero,53 # 5
sw $t1, 2792($t0)
addi $t1,$zero,56 # 8
sw $t1, 2796($t0)
addi $t1,$zero,54 # 6
sw $t1, 2800($t0)
addi $t1,$zero,49 # 1
sw $t1, 2804($t0)
addi $t1,$zero,55 # 7
sw $t1, 2808($t0)
addi $t1,$zero,56 # 8
sw $t1, 2812($t0)
addi $t1,$zero,54 # 6
sw $t1, 2816($t0)
addi $t1,$zero,54 # 6
sw $t1, 2820($t0)
addi $t1,$zero,52 # 4
sw $t1, 2824($t0)
addi $t1,$zero,53 # 5
sw $t1, 2828($t0)
addi $t1,$zero,56 # 8
sw $t1, 2832($t0)
addi $t1,$zero,51 # 3
sw $t1, 2836($t0)
addi $t1,$zero,53 # 5
sw $t1, 2840($t0)
addi $t1,$zero,57 # 9
sw $t1, 2844($t0)
addi $t1,$zero,49 # 1
sw $t1, 2848($t0)
addi $t1,$zero,50 # 2
sw $t1, 2852($t0)
addi $t1,$zero,52 # 4
sw $t1, 2856($t0)
addi $t1,$zero,53 # 5
sw $t1, 2860($t0)
addi $t1,$zero,54 # 6
sw $t1, 2864($t0)
addi $t1,$zero,54 # 6
sw $t1, 2868($t0)
addi $t1,$zero,53 # 5
sw $t1, 2872($t0)
addi $t1,$zero,50 # 2
sw $t1, 2876($t0)
addi $t1,$zero,57 # 9
sw $t1, 2880($t0)
addi $t1,$zero,52 # 4
sw $t1, 2884($t0)
addi $t1,$zero,55 # 7
sw $t1, 2888($t0)
addi $t1,$zero,54 # 6
sw $t1, 2892($t0)
addi $t1,$zero,53 # 5
sw $t1, 2896($t0)
addi $t1,$zero,52 # 4
sw $t1, 2900($t0)
addi $t1,$zero,53 # 5
sw $t1, 2904($t0)
addi $t1,$zero,54 # 6
sw $t1, 2908($t0)
addi $t1,$zero,56 # 8
sw $t1, 2912($t0)
addi $t1,$zero,50 # 2
sw $t1, 2916($t0)
addi $t1,$zero,56 # 8
sw $t1, 2920($t0)
addi $t1,$zero,52 # 4
sw $t1, 2924($t0)
addi $t1,$zero,56 # 8
sw $t1, 2928($t0)
addi $t1,$zero,57 # 9
sw $t1, 2932($t0)
addi $t1,$zero,49 # 1
sw $t1, 2936($t0)
addi $t1,$zero,50 # 2
sw $t1, 2940($t0)
addi $t1,$zero,56 # 8
sw $t1, 2944($t0)
addi $t1,$zero,56 # 8
sw $t1, 2948($t0)
addi $t1,$zero,51 # 3
sw $t1, 2952($t0)
addi $t1,$zero,49 # 1
sw $t1, 2956($t0)
addi $t1,$zero,52 # 4
sw $t1, 2960($t0)
addi $t1,$zero,50 # 2
sw $t1, 2964($t0)
addi $t1,$zero,54 # 6
sw $t1, 2968($t0)
addi $t1,$zero,48 # 0
sw $t1, 2972($t0)
addi $t1,$zero,55 # 7
sw $t1, 2976($t0)
addi $t1,$zero,54 # 6
sw $t1, 2980($t0)
addi $t1,$zero,57 # 9
sw $t1, 2984($t0)
addi $t1,$zero,48 # 0
sw $t1, 2988($t0)
addi $t1,$zero,48 # 0
sw $t1, 2992($t0)
addi $t1,$zero,52 # 4
sw $t1, 2996($t0)
addi $t1,$zero,50 # 2
sw $t1, 3000($t0)
addi $t1,$zero,50 # 2
sw $t1, 3004($t0)
addi $t1,$zero,52 # 4
sw $t1, 3008($t0)
addi $t1,$zero,50 # 2
sw $t1, 3012($t0)
addi $t1,$zero,49 # 1
sw $t1, 3016($t0)
addi $t1,$zero,57 # 9
sw $t1, 3020($t0)
addi $t1,$zero,48 # 0
sw $t1, 3024($t0)
addi $t1,$zero,50 # 2
sw $t1, 3028($t0)
addi $t1,$zero,50 # 2
sw $t1, 3032($t0)
addi $t1,$zero,54 # 6
sw $t1, 3036($t0)
addi $t1,$zero,55 # 7
sw $t1, 3040($t0)
addi $t1,$zero,49 # 1
sw $t1, 3044($t0)
addi $t1,$zero,48 # 0
sw $t1, 3048($t0)
addi $t1,$zero,53 # 5
sw $t1, 3052($t0)
addi $t1,$zero,53 # 5
sw $t1, 3056($t0)
addi $t1,$zero,54 # 6
sw $t1, 3060($t0)
addi $t1,$zero,50 # 2
sw $t1, 3064($t0)
addi $t1,$zero,54 # 6
sw $t1, 3068($t0)
addi $t1,$zero,51 # 3
sw $t1, 3072($t0)
addi $t1,$zero,50 # 2
sw $t1, 3076($t0)
addi $t1,$zero,49 # 1
sw $t1, 3080($t0)
addi $t1,$zero,49 # 1
sw $t1, 3084($t0)
addi $t1,$zero,49 # 1
sw $t1, 3088($t0)
addi $t1,$zero,49 # 1
sw $t1, 3092($t0)
addi $t1,$zero,49 # 1
sw $t1, 3096($t0)
addi $t1,$zero,48 # 0
sw $t1, 3100($t0)
addi $t1,$zero,57 # 9
sw $t1, 3104($t0)
addi $t1,$zero,51 # 3
sw $t1, 3108($t0)
addi $t1,$zero,55 # 7
sw $t1, 3112($t0)
addi $t1,$zero,48 # 0
sw $t1, 3116($t0)
addi $t1,$zero,53 # 5
sw $t1, 3120($t0)
addi $t1,$zero,52 # 4
sw $t1, 3124($t0)
addi $t1,$zero,52 # 4
sw $t1, 3128($t0)
addi $t1,$zero,50 # 2
sw $t1, 3132($t0)
addi $t1,$zero,49 # 1
sw $t1, 3136($t0)
addi $t1,$zero,55 # 7
sw $t1, 3140($t0)
addi $t1,$zero,53 # 5
sw $t1, 3144($t0)
addi $t1,$zero,48 # 0
sw $t1, 3148($t0)
addi $t1,$zero,54 # 6
sw $t1, 3152($t0)
addi $t1,$zero,57 # 9
sw $t1, 3156($t0)
addi $t1,$zero,52 # 4
sw $t1, 3160($t0)
addi $t1,$zero,49 # 1
sw $t1, 3164($t0)
addi $t1,$zero,54 # 6
sw $t1, 3168($t0)
addi $t1,$zero,53 # 5
sw $t1, 3172($t0)
addi $t1,$zero,56 # 8
sw $t1, 3176($t0)
addi $t1,$zero,57 # 9
sw $t1, 3180($t0)
addi $t1,$zero,54 # 6
sw $t1, 3184($t0)
addi $t1,$zero,48 # 0
sw $t1, 3188($t0)
addi $t1,$zero,52 # 4
sw $t1, 3192($t0)
addi $t1,$zero,48 # 0
sw $t1, 3196($t0)
addi $t1,$zero,56 # 8
sw $t1, 3200($t0)
addi $t1,$zero,48 # 0
sw $t1, 3204($t0)
addi $t1,$zero,55 # 7
sw $t1, 3208($t0)
addi $t1,$zero,49 # 1
sw $t1, 3212($t0)
addi $t1,$zero,57 # 9
sw $t1, 3216($t0)
addi $t1,$zero,56 # 8
sw $t1, 3220($t0)
addi $t1,$zero,52 # 4
sw $t1, 3224($t0)
addi $t1,$zero,48 # 0
sw $t1, 3228($t0)
addi $t1,$zero,51 # 3
sw $t1, 3232($t0)
addi $t1,$zero,56 # 8
sw $t1, 3236($t0)
addi $t1,$zero,53 # 5
sw $t1, 3240($t0)
addi $t1,$zero,48 # 0
sw $t1, 3244($t0)
addi $t1,$zero,57 # 9
sw $t1, 3248($t0)
addi $t1,$zero,54 # 6
sw $t1, 3252($t0)
addi $t1,$zero,50 # 2
sw $t1, 3256($t0)
addi $t1,$zero,52 # 4
sw $t1, 3260($t0)
addi $t1,$zero,53 # 5
sw $t1, 3264($t0)
addi $t1,$zero,53 # 5
sw $t1, 3268($t0)
addi $t1,$zero,52 # 4
sw $t1, 3272($t0)
addi $t1,$zero,52 # 4
sw $t1, 3276($t0)
addi $t1,$zero,52 # 4
sw $t1, 3280($t0)
addi $t1,$zero,51 # 3
sw $t1, 3284($t0)
addi $t1,$zero,54 # 6
sw $t1, 3288($t0)
addi $t1,$zero,50 # 2
sw $t1, 3292($t0)
addi $t1,$zero,57 # 9
sw $t1, 3296($t0)
addi $t1,$zero,56 # 8
sw $t1, 3300($t0)
addi $t1,$zero,49 # 1
sw $t1, 3304($t0)
addi $t1,$zero,50 # 2
sw $t1, 3308($t0)
addi $t1,$zero,51 # 3
sw $t1, 3312($t0)
addi $t1,$zero,48 # 0
sw $t1, 3316($t0)
addi $t1,$zero,57 # 9
sw $t1, 3320($t0)
addi $t1,$zero,56 # 8
sw $t1, 3324($t0)
addi $t1,$zero,55 # 7
sw $t1, 3328($t0)
addi $t1,$zero,56 # 8
sw $t1, 3332($t0)
addi $t1,$zero,55 # 7
sw $t1, 3336($t0)
addi $t1,$zero,57 # 9
sw $t1, 3340($t0)
addi $t1,$zero,57 # 9
sw $t1, 3344($t0)
addi $t1,$zero,50 # 2
sw $t1, 3348($t0)
addi $t1,$zero,55 # 7
sw $t1, 3352($t0)
addi $t1,$zero,50 # 2
sw $t1, 3356($t0)
addi $t1,$zero,52 # 4
sw $t1, 3360($t0)
addi $t1,$zero,52 # 4
sw $t1, 3364($t0)
addi $t1,$zero,50 # 2
sw $t1, 3368($t0)
addi $t1,$zero,56 # 8
sw $t1, 3372($t0)
addi $t1,$zero,52 # 4
sw $t1, 3376($t0)
addi $t1,$zero,57 # 9
sw $t1, 3380($t0)
addi $t1,$zero,48 # 0
sw $t1, 3384($t0)
addi $t1,$zero,57 # 9
sw $t1, 3388($t0)
addi $t1,$zero,49 # 1
sw $t1, 3392($t0)
addi $t1,$zero,56 # 8
sw $t1, 3396($t0)
addi $t1,$zero,56 # 8
sw $t1, 3400($t0)
addi $t1,$zero,56 # 8
sw $t1, 3404($t0)
addi $t1,$zero,52 # 4
sw $t1, 3408($t0)
addi $t1,$zero,53 # 5
sw $t1, 3412($t0)
addi $t1,$zero,56 # 8
sw $t1, 3416($t0)
addi $t1,$zero,48 # 0
sw $t1, 3420($t0)
addi $t1,$zero,49 # 1
sw $t1, 3424($t0)
addi $t1,$zero,53 # 5
sw $t1, 3428($t0)
addi $t1,$zero,54 # 6
sw $t1, 3432($t0)
addi $t1,$zero,49 # 1
sw $t1, 3436($t0)
addi $t1,$zero,54 # 6
sw $t1, 3440($t0)
addi $t1,$zero,54 # 6
sw $t1, 3444($t0)
addi $t1,$zero,48 # 0
sw $t1, 3448($t0)
addi $t1,$zero,57 # 9
sw $t1, 3452($t0)
addi $t1,$zero,55 # 7
sw $t1, 3456($t0)
addi $t1,$zero,57 # 9
sw $t1, 3460($t0)
addi $t1,$zero,49 # 1
sw $t1, 3464($t0)
addi $t1,$zero,57 # 9
sw $t1, 3468($t0)
addi $t1,$zero,49 # 1
sw $t1, 3472($t0)
addi $t1,$zero,51 # 3
sw $t1, 3476($t0)
addi $t1,$zero,51 # 3
sw $t1, 3480($t0)
addi $t1,$zero,56 # 8
sw $t1, 3484($t0)
addi $t1,$zero,55 # 7
sw $t1, 3488($t0)
addi $t1,$zero,53 # 5
sw $t1, 3492($t0)
addi $t1,$zero,52 # 4
sw $t1, 3496($t0)
addi $t1,$zero,57 # 9
sw $t1, 3500($t0)
addi $t1,$zero,57 # 9
sw $t1, 3504($t0)
addi $t1,$zero,50 # 2
sw $t1, 3508($t0)
addi $t1,$zero,48 # 0
sw $t1, 3512($t0)
addi $t1,$zero,48 # 0
sw $t1, 3516($t0)
addi $t1,$zero,53 # 5
sw $t1, 3520($t0)
addi $t1,$zero,50 # 2
sw $t1, 3524($t0)
addi $t1,$zero,52 # 4
sw $t1, 3528($t0)
addi $t1,$zero,48 # 0
sw $t1, 3532($t0)
addi $t1,$zero,54 # 6
sw $t1, 3536($t0)
addi $t1,$zero,51 # 3
sw $t1, 3540($t0)
addi $t1,$zero,54 # 6
sw $t1, 3544($t0)
addi $t1,$zero,56 # 8
sw $t1, 3548($t0)
addi $t1,$zero,57 # 9
sw $t1, 3552($t0)
addi $t1,$zero,57 # 9
sw $t1, 3556($t0)
addi $t1,$zero,49 # 1
sw $t1, 3560($t0)
addi $t1,$zero,50 # 2
sw $t1, 3564($t0)
addi $t1,$zero,53 # 5
sw $t1, 3568($t0)
addi $t1,$zero,54 # 6
sw $t1, 3572($t0)
addi $t1,$zero,48 # 0
sw $t1, 3576($t0)
addi $t1,$zero,55 # 7
sw $t1, 3580($t0)
addi $t1,$zero,49 # 1
sw $t1, 3584($t0)
addi $t1,$zero,55 # 7
sw $t1, 3588($t0)
addi $t1,$zero,54 # 6
sw $t1, 3592($t0)
addi $t1,$zero,48 # 0
sw $t1, 3596($t0)
addi $t1,$zero,54 # 6
sw $t1, 3600($t0)
addi $t1,$zero,48 # 0
sw $t1, 3604($t0)
addi $t1,$zero,53 # 5
sw $t1, 3608($t0)
addi $t1,$zero,56 # 8
sw $t1, 3612($t0)
addi $t1,$zero,56 # 8
sw $t1, 3616($t0)
addi $t1,$zero,54 # 6
sw $t1, 3620($t0)
addi $t1,$zero,49 # 1
sw $t1, 3624($t0)
addi $t1,$zero,49 # 1
sw $t1, 3628($t0)
addi $t1,$zero,54 # 6
sw $t1, 3632($t0)
addi $t1,$zero,52 # 4
sw $t1, 3636($t0)
addi $t1,$zero,54 # 6
sw $t1, 3640($t0)
addi $t1,$zero,55 # 7
sw $t1, 3644($t0)
addi $t1,$zero,49 # 1
sw $t1, 3648($t0)
addi $t1,$zero,48 # 0
sw $t1, 3652($t0)
addi $t1,$zero,57 # 9
sw $t1, 3656($t0)
addi $t1,$zero,52 # 4
sw $t1, 3660($t0)
addi $t1,$zero,48 # 0
sw $t1, 3664($t0)
addi $t1,$zero,53 # 5
sw $t1, 3668($t0)
addi $t1,$zero,48 # 0
sw $t1, 3672($t0)
addi $t1,$zero,55 # 7
sw $t1, 3676($t0)
addi $t1,$zero,55 # 7
sw $t1, 3680($t0)
addi $t1,$zero,53 # 5
sw $t1, 3684($t0)
addi $t1,$zero,52 # 4
sw $t1, 3688($t0)
addi $t1,$zero,49 # 1
sw $t1, 3692($t0)
addi $t1,$zero,48 # 0
sw $t1, 3696($t0)
addi $t1,$zero,48 # 0
sw $t1, 3700($t0)
addi $t1,$zero,50 # 2
sw $t1, 3704($t0)
addi $t1,$zero,50 # 2
sw $t1, 3708($t0)
addi $t1,$zero,53 # 5
sw $t1, 3712($t0)
addi $t1,$zero,54 # 6
sw $t1, 3716($t0)
addi $t1,$zero,57 # 9
sw $t1, 3720($t0)
addi $t1,$zero,56 # 8
sw $t1, 3724($t0)
addi $t1,$zero,51 # 3
sw $t1, 3728($t0)
addi $t1,$zero,49 # 1
sw $t1, 3732($t0)
addi $t1,$zero,53 # 5
sw $t1, 3736($t0)
addi $t1,$zero,53 # 5
sw $t1, 3740($t0)
addi $t1,$zero,50 # 2
sw $t1, 3744($t0)
addi $t1,$zero,48 # 0
sw $t1, 3748($t0)
addi $t1,$zero,48 # 0
sw $t1, 3752($t0)
addi $t1,$zero,48 # 0
sw $t1, 3756($t0)
addi $t1,$zero,53 # 5
sw $t1, 3760($t0)
addi $t1,$zero,53 # 5
sw $t1, 3764($t0)
addi $t1,$zero,57 # 9
sw $t1, 3768($t0)
addi $t1,$zero,51 # 3
sw $t1, 3772($t0)
addi $t1,$zero,53 # 5
sw $t1, 3776($t0)
addi $t1,$zero,55 # 7
sw $t1, 3780($t0)
addi $t1,$zero,50 # 2
sw $t1, 3784($t0)
addi $t1,$zero,57 # 9
sw $t1, 3788($t0)
addi $t1,$zero,55 # 7
sw $t1, 3792($t0)
addi $t1,$zero,50 # 2
sw $t1, 3796($t0)
addi $t1,$zero,53 # 5
sw $t1, 3800($t0)
addi $t1,$zero,55 # 7
sw $t1, 3804($t0)
addi $t1,$zero,49 # 1
sw $t1, 3808($t0)
addi $t1,$zero,54 # 6
sw $t1, 3812($t0)
addi $t1,$zero,51 # 3
sw $t1, 3816($t0)
addi $t1,$zero,54 # 6
sw $t1, 3820($t0)
addi $t1,$zero,50 # 2
sw $t1, 3824($t0)
addi $t1,$zero,54 # 6
sw $t1, 3828($t0)
addi $t1,$zero,57 # 9
sw $t1, 3832($t0)
addi $t1,$zero,53 # 5
sw $t1, 3836($t0)
addi $t1,$zero,54 # 6
sw $t1, 3840($t0)
addi $t1,$zero,49 # 1
sw $t1, 3844($t0)
addi $t1,$zero,56 # 8
sw $t1, 3848($t0)
addi $t1,$zero,56 # 8
sw $t1, 3852($t0)
addi $t1,$zero,50 # 2
sw $t1, 3856($t0)
addi $t1,$zero,54 # 6
sw $t1, 3860($t0)
addi $t1,$zero,55 # 7
sw $t1, 3864($t0)
addi $t1,$zero,48 # 0
sw $t1, 3868($t0)
addi $t1,$zero,52 # 4
sw $t1, 3872($t0)
addi $t1,$zero,50 # 2
sw $t1, 3876($t0)
addi $t1,$zero,56 # 8
sw $t1, 3880($t0)
addi $t1,$zero,50 # 2
sw $t1, 3884($t0)
addi $t1,$zero,53 # 5
sw $t1, 3888($t0)
addi $t1,$zero,50 # 2
sw $t1, 3892($t0)
addi $t1,$zero,52 # 4
sw $t1, 3896($t0)
addi $t1,$zero,56 # 8
sw $t1, 3900($t0)
addi $t1,$zero,51 # 3
sw $t1, 3904($t0)
addi $t1,$zero,54 # 6
sw $t1, 3908($t0)
addi $t1,$zero,48 # 0
sw $t1, 3912($t0)
addi $t1,$zero,48 # 0
sw $t1, 3916($t0)
addi $t1,$zero,56 # 8
sw $t1, 3920($t0)
addi $t1,$zero,50 # 2
sw $t1, 3924($t0)
addi $t1,$zero,51 # 3
sw $t1, 3928($t0)
addi $t1,$zero,50 # 2
sw $t1, 3932($t0)
addi $t1,$zero,53 # 5
sw $t1, 3936($t0)
addi $t1,$zero,55 # 7
sw $t1, 3940($t0)
addi $t1,$zero,53 # 5
sw $t1, 3944($t0)
addi $t1,$zero,51 # 3
sw $t1, 3948($t0)
addi $t1,$zero,48 # 0
sw $t1, 3952($t0)
addi $t1,$zero,52 # 4
sw $t1, 3956($t0)
addi $t1,$zero,50 # 2
sw $t1, 3960($t0)
addi $t1,$zero,48 # 0
sw $t1, 3964($t0)
addi $t1,$zero,55 # 7
sw $t1, 3968($t0)
addi $t1,$zero,53 # 5
sw $t1, 3972($t0)
addi $t1,$zero,50 # 2
sw $t1, 3976($t0)
addi $t1,$zero,57 # 9
sw $t1, 3980($t0)
addi $t1,$zero,54 # 6
sw $t1, 3984($t0)
addi $t1,$zero,51 # 3
sw $t1, 3988($t0)
addi $t1,$zero,52 # 4
sw $t1, 3992($t0)
addi $t1,$zero,53 # 5
sw $t1, 3996($t0)
addi $t1,$zero,48 # 0
sw $t1, 4000($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

lw $t1,0($s1) # get value
addi $t0,$s0,-4 # load variable address
sw $t1,0($t0) # update the value at variable address
addi $s1,$s1,4 # remove the value on stack

# putting "still working on solution" on heap 
add $t0,$s5,$zero
addi $s5, $s5,104
addi $t1,$zero,100 # add size at start
sw $t1,0($t0)
addi $t1,$zero,115 # s
sw $t1, 4($t0)
addi $t1,$zero,116 # t
sw $t1, 8($t0)
addi $t1,$zero,105 # i
sw $t1, 12($t0)
addi $t1,$zero,108 # l
sw $t1, 16($t0)
addi $t1,$zero,108 # l
sw $t1, 20($t0)
addi $t1,$zero,32 #  
sw $t1, 24($t0)
addi $t1,$zero,119 # w
sw $t1, 28($t0)
addi $t1,$zero,111 # o
sw $t1, 32($t0)
addi $t1,$zero,114 # r
sw $t1, 36($t0)
addi $t1,$zero,107 # k
sw $t1, 40($t0)
addi $t1,$zero,105 # i
sw $t1, 44($t0)
addi $t1,$zero,110 # n
sw $t1, 48($t0)
addi $t1,$zero,103 # g
sw $t1, 52($t0)
addi $t1,$zero,32 #  
sw $t1, 56($t0)
addi $t1,$zero,111 # o
sw $t1, 60($t0)
addi $t1,$zero,110 # n
sw $t1, 64($t0)
addi $t1,$zero,32 #  
sw $t1, 68($t0)
addi $t1,$zero,115 # s
sw $t1, 72($t0)
addi $t1,$zero,111 # o
sw $t1, 76($t0)
addi $t1,$zero,108 # l
sw $t1, 80($t0)
addi $t1,$zero,117 # u
sw $t1, 84($t0)
addi $t1,$zero,116 # t
sw $t1, 88($t0)
addi $t1,$zero,105 # i
sw $t1, 92($t0)
addi $t1,$zero,111 # o
sw $t1, 96($t0)
addi $t1,$zero,110 # n
sw $t1, 100($t0)
# add the pointer on stack
addi $s1,$s1,-4
sw $t0,0($s1)

# Print
lw $t0, 0($s1)
srl $t1,$t0,29
addi $t3,$zero,7
beq $t1,$zero,label2 # 000 -> int
beq $t1,$t3,label2 # 111 -> int
srl $t1,$t1,1
bne $t1,$t8,error # 010 or 011 are for str and list
lw $t1,0($t0) # 4n
addi $v0,$zero,11 # str
label1: # print character routine
slt $t3,$zero,$t1
beq $t3,$zero,label3 # if t1 <= 0, finish
addi $t0,$t0,4 # next character
lw $a0,0($t0) #put char in buffer
syscall # print char
addi $t1,$t1,-4 # decr remaining bytes by 1
j label1 # continue printing charactters
label2:# int
addi $v0, $zero,1
add $a0,$t0,$zero
syscall
label3:# end print
addi $s1,$s1,4
# print newline via syscall 11 to clean up
addi $a0, $zero, 10
addi $v0, $zero, 11 
syscall




# print newline via syscall 11 to clean up
addi $a0, $0, 10
addi $v0, $0, 11 
syscall
theend:
# Exit via syscall 10
addi $v0,$zero,10
syscall #10
error:
addi $a0, $zero, -1
addi $v0, $zero, 1
syscall
# Exit via syscall 10
addi $v0,$zero,10
syscall #10