; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Chuckie Egg by Nigel Alderton, 1984.  Published by A&F Software.
;
;
; Reverse Engineered by Paul Hughes November 2024
;

	DEVICE ZXSPECTRUM48

	cspectmap

	include "spectrum.asm"

; ROM Labels
ROM_BEEP: 			equ $03F8
ROM_STACK_A: 		equ $2D28
ROM_FP_CALC			equ $0028

ROM_KSTATE:			equ $5C04
ROM_LASTK:			equ $5C08

ROM_STKBOT:			equ $5C63	; address of the bottom of ROM calculator stack
ROM_STKEND:			equ $5C65	; address of the bottom of the stack

; Game EQUates

LEVEL_WIDTH			equ 32
LEVEL_HEIGHT 		equ 21
LEVEL_SIZE			equ (LEVEL_WIDTH * LEVEL_HEIGHT)

TILE_BLANK			equ $00
TILE_LADDERLEFT		equ $01
TILE_LADDERRIGHT	equ $02
TILE_EGG			equ $03
TILE_BIRDSEED		equ $04
TILE_PLATFORM		equ $05
TILE_LAST			equ $09

HEN_LEFT:			equ 1
HEN_RIGHT:			equ 2
HEN_DOWN:			equ 3
HEN_UP:				equ 4
HEN_PECKING:		equ 6

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; DEBUG Stuff
;

DISABLE_SPEECH		equ 1
DISABLE_MUSIC		equ 1
DISABLE_COLLISION	equ 0
ONLY_ONE_EGG		equ 0

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

	org $61a8

LevelBuffer:			; current level buffer followed by one buffer for each player.  

	ds (LEVEL_SIZE * 5), 0

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CurrentPlayerScore:
	db $00
	db $00
	db $02
	db $05
	db $05
	db $00
P1Score:
	db $00
	db $00
	db $02
	db $05
	db $05
	db $00
P2Score:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
P3Score:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00
P4Score:
	db $00
	db $00
	db $00
	db $00
	db $00
	db $00

EggsRemaining:
	db $09

P1EggsRemaining:
	db $09
P2EggsRemaining:
	db $0C
P3EggsRemaining:
	db $0C
P4EggsRemaining:
	db $0C

CurrentLevel:
	db $01
P1Level:
	db $01
P2Level:
	db $00
P3Level:
	db $00
P4Level:
	db $00

P1Lives:
	db $01
P2Lives:
	db $05
P3Lives:
	db $05
P4Lives:
	db $05


; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Sprite is copied into here and bit shifted to the correct pixel position
;

SpriteBuffer:

	ds (16 * 3), 0

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Start of the game variables
;

PlayerX:			
	db $AE
PlayerY:
	db $37
PlayerAnimFrame:
	db $00
PlayerDirection:
	db $04				; 4 = left, 0 = right, 0D - climbing
SoundTimer:
	db $82

BackgroundBuffer:		; holds the background behind the sprite
	ds 72, 0

PlayerInAir:			; 0 = on land, 1 = falling, 2 = in air
	db $00

PlayerJumpDirection:	; 0 = up, 1=right, $ff=left
	db $01

InAirCounter:
	db $96

FallingCounter:
	db $96
	db $00

PlayerAirDirection:			; 1 = up, $ff = down
	db $FF

ScrollCounter:
	db $08

ScrollIndex:
	db $04

FrontEndMode:
	db $03
UpBitmask:
	db $1E
UpPort:
	db $FB
DownBitmask:
	db $1E
DownPort:
	db $FD
LeftBitmask:
	db $1D
LeftPort:
	db $DF
RightBitmask:
	db $1E
RightPort:
	db $DF
JumpBitmask:
	db $1E
JumpPort:
	db $7F
Jump2Bitmask:
	db $1E
Jump2Port:
	db $F7

NumberOfPlayers:
	db $01

CurrentPlayer:
	db $01

LiftUpdateCounter:
	db $02

ScoreScreenPos:
	dw $4005

Bonus:
	db $00
	db $01
	db $09
TimeRemaining:
	db $FF
	db $09
	db $09

FiftiesCounter:
	db $32

TensCounter:
	db $0A

TimerRunning:
	db $01

MotherDuckX:
	db $08
MotherDuckY:
	db $98
MotherDuckXVel:
	db $05
MotherDuckYVel:
	db $FB
MotherDuckUpdateCounter:
	db $0C
MotherDuckFrame:
	db $01

Lift1ScreenPos:
	dw $0505
LiftsActive:
	db $FF
Lift1YPos:
	db $00
Lift2ScreenPos:
	dw $FD05
Lift2YPos:
	db $43
PlayerOnLift:
	db $00

CurrentHen:
	db $00

Hen1:
	db $AC			; x
	db $54			; y
	db $04			; direction 1=left,2=right,3=down,4=up
	db $00			; frame number?
Hen2:
	db $DC
	db $84
	db $03
	db $00
Hen3:
	db $70
	db $28
	db $01
	db $00
Hen4:
	db $FF
	db $FF
	db $FF
	db $FF
Hen5:
	db $FF
	db $FF
	db $FF
	db $FF

HenUpdateSpeed:
	db $01

FrameCounter:
	dw $00B8
LastDigitValue:
	db $00
MusicFlag:
	db $01
SFXFreq:
	db $00
	db $00
	db $00

SpeechPlaying:
	db $FF

OratorAllophoneListAddress:
	dw $C9F8

The2W90Keys:
	db $1D
	db $F7
	db $1D
	db $FB
	db $1D
	db $EF
	db $1E
	db $EF
	db $1D
	db $FE
	db $1B
	db $7F

CursorKeys:
	db $17
	db $EF
	db $0F
	db $EF
	db $0F
	db $F7
	db $1B
	db $EF
	db $17
	db $F7
	db $1D
	db $EF

UserDefinedKeys:
	db $1E
	db $FB
	db $1E
	db $FD
	db $1D
	db $DF
	db $1E
	db $DF
	db $1E
	db $7F
	db $1E
	db $F7

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

InstructionsText:
	db "keys are user defineable.      "
	db $00,"cannot",$00,"be",$00
	db "changed",$00,"but",$00,"the"
	db $00,"type",$00,"3key",$00
	db "types",$00,"1",$00,"&",$00
	db "2",$00,"are",$00,"preset"
	db $00,"and",$00,$00,"3     "

InstructionTextKeys:	
	db "q    a    o    p    ",$97
	db " or 12     --cursor--keys--    4 or 91     2    w    9    0    z or m"
	db $C8,$C9,$CA,$CB," ",$B8,$B9
	db $BA,"  ",$BB,$BC,$BD,"  ",$BE
	db $BF,$C0,$20,$20,$C1,$C2,$C3
	db $20,$20,$20,$20,$C4,$C5,$C6
	db $C7,$20,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $00,$00,$4B,$45,$59,$53,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$74,$68,$65,$00
	db $68,$65,$6E,$2D,$68,$6F,$75
	db $73,$65,$2E,$00,$00,$00,$00
	db $00,$00,$00,$6F,$62,$6A,$65
	db $63,$74,$69,$76,$65,$2D,$00
	db $74,$6F,$00,$63,$6F,$6C,$6C
	db $65,$63,$74,$00,$65,$67,$67
	db $73,$00,$66,$72,$6F,$6D,$00
	db $00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$49,$4E,$53,$54
	db $52,$55,$43,$54,$49,$4F,$4E
	db $53,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

	org $84f0

gfx_CharacterSet:
	db $00,$00,$00,$00,$00,$00,$00,$00,$30,$30,$30,$3f,$3f,$30,$30,$30
	db $0c,$0c,$0c,$fc,$fc,$0c,$0c,$0c,$38,$7e,$ff,$ff,$ff,$7e,$38,$00
	db $00,$00,$00,$10,$28,$54,$aa,$00,$fb,$00,$bf,$00,$ef,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$fe,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$63,$94,$84,$64,$14,$14,$94,$63
	db $19,$a5,$25,$25,$25,$25,$a5,$19,$cf,$28,$28,$ce,$48,$48,$28,$2f
	db $00,$f2,$8a,$8a,$f2,$82,$82,$83,$00,$0e,$11,$11,$1f,$11,$11,$d1
	db $00,$45,$45,$29,$11,$11,$11,$11,$00,$ee,$09,$09,$ee,$09,$09,$e9
	db $00,$fb,$20,$20,$20,$20,$20,$23,$00,$e8,$8c,$8b,$88,$88,$88,$e8
	db $00,$5e,$d0,$50,$5e,$50,$50,$5e,$00,$00,$00,$e0,$a4,$ee,$a4,$a0
	db $00,$00,$00,$e1,$81,$e1,$80,$81,$00,$00,$00,$dd,$15,$d5,$55,$dd
	db $00,$00,$00,$dd,$09,$c9,$09,$08,$00,$00,$00,$17,$15,$17,$55,$a5
	db $00,$00,$00,$77,$54,$67,$54,$57,$00,$e3,$94,$94,$e4,$94,$94,$e3
	db $00,$25,$a5,$b5,$ad,$a5,$a5,$24,$00,$26,$29,$28,$26,$21,$29,$c6
	db $00,$87,$84,$84,$87,$84,$84,$f7,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$08,$08,$08,$08,$08,$08,$00,$08
	db $24,$24,$00,$00,$00,$00,$00,$00,$00,$24,$7e,$24,$24,$7e,$24,$00
	db $00,$10,$7c,$50,$7c,$14,$7c,$10,$00,$62,$64,$08,$10,$26,$46,$00
	db $00,$10,$28,$10,$2a,$44,$3a,$00,$00,$08,$10,$00,$00,$00,$00,$00
	db $08,$10,$10,$10,$10,$10,$10,$08,$10,$08,$08,$08,$08,$08,$08,$10
	db $00,$00,$14,$08,$3e,$08,$14,$00,$08,$08,$08,$7f,$08,$08,$08,$00
	db $00,$00,$00,$00,$00,$08,$08,$10,$00,$00,$00,$00,$7e,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$18,$18,$01,$02,$04,$08,$10,$20,$40,$00

gfx_CharacterSetNumbers:	
	db $3e,$43,$45,$49,$51,$61,$41,$3e,$08,$18,$28,$08,$08,$08,$08,$3e
	db $3e,$41,$01,$0e,$30,$40,$40,$7f,$3e,$41,$01,$1e,$01,$01,$41,$3e
	db $40,$48,$48,$48,$7f,$08,$08,$08,$7f,$40,$40,$7e,$01,$01,$41,$3e
	db $3e,$40,$40,$7e,$41,$41,$41,$3e,$7f,$01,$02,$04,$08,$10,$10,$10
	db $3e,$41,$41,$3e,$41,$41,$41,$3e,$3e,$41,$41,$3f,$01,$01,$41,$3e
	db $00,$18,$18,$00,$00,$18,$18,$00,$00,$18,$18,$00,$00,$18,$18,$30
	db $04,$08,$10,$20,$10,$08,$04,$00,$00,$00,$3e,$00,$00,$3e,$00,$00
	db $20,$10,$08,$04,$08,$10,$20,$00,$3e,$41,$01,$02,$04,$08,$00,$08
	db $1e,$21,$4d,$55,$55,$4f,$20,$1e,$3e,$41,$41,$41,$7f,$41,$41,$41
	db $7e,$41,$41,$7e,$41,$41,$41,$7e,$3e,$41,$40,$40,$40,$40,$41,$3e
	db $7e,$41,$41,$41,$41,$41,$41,$7e,$7f,$41,$40,$7c,$40,$40,$41,$7f
	db $7f,$41,$40,$7c,$40,$40,$40,$40,$3e,$41,$40,$40,$47,$41,$41,$3e
	db $41,$41,$41,$7f,$41,$41,$41,$41,$7f,$08,$08,$08,$08,$08,$08,$7f
	db $7f,$08,$08,$08,$08,$08,$48,$30,$42,$44,$48,$70,$48,$44,$42,$42
	db $40,$40,$40,$40,$40,$40,$40,$7f,$41,$63,$55,$49,$41,$41,$41,$41
	db $41,$61,$51,$49,$45,$43,$41,$41,$3e,$41,$41,$41,$41,$41,$41,$3e
	db $7e,$41,$41,$41,$7e,$40,$40,$40,$3e,$41,$41,$41,$49,$45,$43,$3e
	db $7e,$41,$41,$41,$7e,$44,$42,$41,$3e,$41,$40,$3e,$01,$01,$41,$3e
	db $7f,$08,$08,$08,$08,$08,$08,$08,$41,$41,$41,$41,$41,$41,$41,$3e
	db $41,$41,$41,$41,$41,$22,$14,$08,$41,$41,$41,$41,$41,$49,$55,$22
	db $41,$22,$14,$08,$08,$14,$22,$41,$41,$22,$14,$08,$08,$08,$08,$08
	db $7f,$02,$04,$08,$10,$20,$40,$7f,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$3c,$66,$66,$7e,$66,$66,$66
	db $00,$7c,$66,$66,$78,$66,$66,$7c,$00,$3c,$66,$60,$60,$60,$66,$3c
	db $00,$7c,$66,$66,$66,$66,$66,$7c,$00,$7e,$62,$60,$7c,$60,$62,$7e
	db $00,$7e,$62,$60,$7c,$60,$60,$60,$00,$3c,$66,$60,$6e,$62,$62,$3c
	db $00,$66,$66,$66,$7e,$66,$66,$66,$00,$7e,$18,$18,$18,$18,$18,$7e
	db $00,$7f,$0c,$0c,$0c,$4c,$4c,$38,$00,$66,$66,$6c,$78,$6c,$66,$66
	db $00,$60,$60,$60,$60,$60,$62,$7e,$00,$c6,$ee,$d6,$c6,$c6,$c6,$c6
	db $00,$66,$66,$76,$7e,$6e,$66,$66,$00,$3c,$66,$66,$66,$66,$66,$3c
	db $00,$7c,$66,$66,$7c,$60,$60,$60,$00,$3c,$66,$66,$66,$76,$6c,$3a
	db $00,$7c,$66,$66,$78,$66,$66,$66,$00,$3c,$66,$60,$3c,$06,$66,$3c
	db $00,$7e,$18,$18,$18,$18,$18,$18,$00,$66,$66,$66,$66,$66,$66,$3c
	db $00,$66,$66,$66,$66,$66,$3c,$18,$00,$c6,$c6,$c6,$c6,$d6,$ee,$c6
	db $00,$66,$66,$3c,$18,$3c,$66,$66,$00,$66,$66,$3c,$18,$18,$18,$18
	db $00,$7e,$06,$0c,$18,$30,$60,$7e,$00,$08,$1c,$3e,$7f,$3e,$1c,$08
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $3c,$42,$b9,$a5,$b9,$a5,$42,$3c,$3c,$42,$99,$a1,$a1,$99,$42,$3c
	db $f0,$f0,$f0,$f0,$00,$00,$00,$00,$0f,$0f,$0f,$0f,$00,$00,$00,$00
	db $ff,$ff,$ff,$ff,$00,$00,$00,$00,$00,$00,$00,$00,$f0,$f0,$f0,$f0
	db $f0,$f0,$f0,$f0,$f0,$f0,$f0,$f0,$0f,$0f,$0f,$0f,$f0,$f0,$f0,$f0
	db $ff,$ff,$ff,$ff,$f0,$f0,$f0,$f0,$00,$00,$00,$00,$0f,$0f,$0f,$0f
	db $f0,$f0,$f0,$f0,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f
	db $ff,$ff,$ff,$ff,$0f,$0f,$0f,$0f,$00,$00,$00,$00,$ff,$ff,$ff,$ff
	db $f0,$f0,$f0,$f0,$ff,$ff,$ff,$ff,$0f,$0f,$0f,$0f,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$00,$00,$f0,$92,$f7,$92,$90,$00
	db $00,$00,$70,$40,$70,$40,$40,$00,$00,$00,$e9,$89,$8f,$89,$e9,$00
	db $00,$00,$4b,$4a,$4a,$4a,$7b,$00,$00,$00,$a5,$28,$30,$28,$a5,$00
	db $00,$00,$dc,$90,$9c,$90,$dc,$00,$00,$00,$3b,$22,$3a,$22,$3b,$00
	db $00,$00,$de,$10,$d6,$52,$de,$00,$00,$4e,$a9,$89,$4e,$28,$a8,$48
	db $00,$42,$a5,$84,$82,$81,$a5,$42,$00,$42,$a5,$84,$42,$21,$a5,$42
	db $00,$e9,$89,$8d,$eb,$89,$89,$e9,$00,$87,$84,$84,$87,$84,$84,$f7
	db $00,$a2,$22,$22,$a2,$22,$14,$88,$00,$f4,$84,$84,$f4,$84,$84,$f7

gfx_LevelNumbers:
	db $00,$1e,$21,$23,$25,$29,$31,$1e,$00,$04,$0c,$14,$04,$04,$04,$1f
	db $00,$1e,$21,$01,$1e,$20,$20,$3f,$00,$1e,$21,$01,$0e,$01,$21,$1e
	db $00,$06,$0a,$12,$22,$3f,$02,$02,$00,$3f,$20,$3e,$01,$01,$21,$1e
	db $00,$1e,$21,$20,$3e,$21,$21,$1e,$00,$3f,$01,$02,$04,$08,$08,$08
	db $00,$1e,$21,$21,$1e,$21,$21,$1e,$00,$1e,$21,$21,$1f,$01,$21,$1e
	db $00,$00,$07,$0c,$08,$0c,$07,$01,$00,$00,$c0,$60,$20,$60,$c0,$00
	db $00,$00,$03,$05,$0a,$15,$29,$2a,$1f,$e0,$18,$67,$89,$11,$11,$21
	db $f0,$0e,$31,$cc,$22,$11,$11,$08,$00,$00,$80,$40,$a0,$50,$28,$a8
	db $52,$52,$52,$52,$72,$5a,$57,$52,$21,$21,$21,$21,$21,$21,$21,$df
	db $08,$08,$08,$08,$08,$08,$09,$fe,$94,$94,$94,$94,$9c,$b4,$d4,$94
	db $52,$52,$52,$52,$32,$0a,$07,$00,$21,$21,$21,$21,$21,$21,$21,$ff
	db $08,$08,$08,$08,$08,$08,$09,$fe,$94,$94,$94,$94,$98,$b0,$c0,$00
	db $00,$00,$1c,$1c,$7f,$00,$00,$00,$18,$3c,$3c,$7e,$7e,$7e,$7e,$3c
	db $00,$02,$02,$02,$02,$03,$00,$03,$00,$27,$24,$27,$24,$e4,$00,$ff
	db $00,$c0,$40,$c0,$00,$00,$00,$c0,$00,$fd,$45,$45,$45,$fd,$00,$ff
	db $00,$f4,$14,$15,$15,$f7,$00,$ff,$00,$51,$59,$55,$53,$d1,$00,$ff
	db $00,$83,$82,$83,$82,$fb,$00,$ff,$00,$e7,$04,$c7,$04,$e4,$00,$ff
	db $00,$df,$04,$84,$04,$04,$00,$ff,$00,$f2,$92,$f2,$a2,$92,$00,$ff
	db $00,$7a,$42,$5b,$4a,$7a,$00,$ff,$00,$5f,$44,$c4,$44,$44,$00,$ff
	db $00,$7e,$08,$08,$48,$78,$00,$ff,$00,$42,$42,$42,$42,$7e,$00,$ff
	db $00,$7f,$49,$49,$41,$41,$00,$ff,$00,$3f,$21,$3f,$20,$20,$00,$ff
	db $00,$fe,$10,$10,$10,$10,$00,$ff,$00,$41,$22,$1c,$08,$08,$00,$ff
	db $00,$3f,$21,$3f,$20,$20,$00,$ff,$00,$3f,$20,$3c,$20,$3f,$00,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	
gfx_PlayerRight:
	db $00,$00,$03,$80,$03,$c0,$03,$c0,$3f,$fc,$03,$40,$03,$c0,$01,$80
	db $03,$e0,$06,$f0,$06,$f0,$06,$e0,$03,$c0,$01,$00,$01,$c0,$00,$00

	db $00,$00,$03,$80,$03,$c0,$03,$c0,$3f,$fc,$03,$40,$03,$c0,$01,$80
	db $03,$e0,$06,$f0,$05,$f0,$05,$e0,$03,$c0,$04,$50,$02,$20,$00,$00
	
	db $00,$00,$03,$80,$03,$c0,$03,$c0,$3f,$fc,$03,$40,$03,$c0,$01,$80
	db $03,$e0,$06,$f0,$06,$f0,$06,$e0,$03,$c0,$01,$00,$01,$c0,$00,$00
	
	db $00,$00,$03,$80,$03,$c0,$03,$c0,$3f,$fc,$03,$40,$03,$c0,$01,$80
	db $03,$e0,$06,$f0,$07,$30,$07,$e0,$03,$c0,$04,$50,$02,$20,$00,$00
	
gfx_PlayerLeft:
	db $00,$00,$01,$c0,$03,$c0,$03,$c0,$3f,$fc,$02,$c0,$03,$c0,$01,$80
	db $07,$c0,$0f,$60,$0f,$60,$07,$60,$03,$c0,$00,$80,$03,$80,$00,$00

	db $00,$00,$01,$c0,$03,$c0,$03,$c0,$3f,$fc,$02,$c0,$03,$c0,$01,$80
	db $07,$c0,$0f,$60,$0f,$a0,$07,$a0,$03,$c0,$0a,$20,$04,$40,$00,$00
	
	db $00,$00,$01,$c0,$03,$c0,$03,$c0,$3f,$fc,$02,$c0,$03,$c0,$01,$80
	db $07,$c0,$0f,$60,$0f,$60,$07,$60,$03,$c0,$00,$80,$03,$80,$00,$00
	
	db $00,$00,$01,$c0,$03,$c0,$03,$c0,$3f,$fc,$02,$c0,$03,$c0,$01,$80
	db $07,$c0,$0f,$60,$0c,$e0,$07,$e0,$03,$c0,$0a,$20,$04,$40,$00,$00


	db $00,$79,$00,$ee,$00,$fc,$00,$fa,$00,$71,$00,$70,$00,$30,$00,$38
	db $1e,$1c,$7f,$9c,$ff,$fc,$bf,$7c,$4f,$78,$70,$f0,$3f,$e0,$0f,$80
	db $00,$78,$00,$ec,$00,$ff,$00,$f8,$00,$70,$00,$70,$00,$30,$00,$38
	db $1e,$1c,$70,$9c,$cf,$7c,$bf,$7c,$7f,$f8,$7f,$f0,$3f,$e0,$0f,$80
	db $9e,$00,$77,$00,$3f,$00,$5f,$00,$8e,$00,$0e,$00,$0c,$00,$1c,$00
	db $38,$78,$39,$fe,$3f,$ff,$3e,$fd,$1e,$f2,$0f,$0e,$07,$fc,$01,$f0
	db $1e,$00,$37,$00,$ff,$00,$1f,$00,$0e,$00,$0e,$00,$0c,$00,$1c,$00
	db $38,$78,$39,$0e,$3e,$f3,$3e,$fd,$1f,$fe,$0f,$fe,$07,$fc,$01,$f0

	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$02,$40,$03,$c0,$03,$c0,$3f,$fc,$03,$c0,$09,$80,$17,$e0
	db $1f,$f0,$0f,$f8,$07,$e8,$07,$e8,$02,$70,$02,$00,$0e,$00,$00,$00
	db $00,$00,$02,$40,$03,$c0,$03,$c0,$3f,$fc,$03,$c0,$01,$80,$07,$e0
	db $1f,$f8,$0f,$f0,$07,$e0,$07,$e0,$02,$40,$0e,$70,$00,$00,$00,$00
	db $00,$00,$02,$40,$03,$c0,$03,$c0,$3f,$fc,$03,$c0,$01,$90,$07,$e8
	db $0f,$f8,$1f,$f0,$17,$e0,$17,$e0,$0e,$40,$00,$40,$00,$70,$00,$00
	
	db $00,$00,$02,$40,$03,$c0,$03,$c0,$3f,$fc,$03,$c0,$01,$80,$07,$e0
	db $1f,$f8,$0f,$f0,$07,$e0,$07,$e0,$02,$40,$0e,$70,$00,$00

gfx_HenLeft:

	db $00,$00,$30,$00,$d0,$00,$30,$00,$20,$00,$40,$00,$40,$00,$c0,$00
	db $ce,$00,$ff,$00,$ff,$00,$7f,$00,$3e,$00,$08,$00,$08,$00,$08,$00
	db $18,$00,$0c,$00,$0b,$00,$0c,$00,$04,$00,$02,$00,$02,$00,$03,$00
	db $73,$00,$ff,$00,$ff,$00,$fe,$00,$7c,$00,$10,$00,$10,$00,$10,$00
	db $18,$00,$01,$80,$03,$c0,$03,$c0,$01,$80,$01,$80,$01,$80,$07,$e0
	db $0f,$f0,$0f,$f0,$0f,$f0,$07,$e0,$02,$40,$02,$60,$02,$00,$02,$00
	db $06,$00,$01,$80,$03,$c0,$03,$c0,$01,$80,$01,$80,$01,$80,$07,$e0
	db $0f,$f0,$0f,$f0,$0f,$f0,$07,$e0,$02,$40,$06,$40,$00,$40,$00,$40
	db $00,$60,$0b,$00,$05,$00,$0b,$00,$02,$00,$04,$00,$04,$00,$0c,$00
	db $0c,$e0,$0f,$f0,$0f,$f0,$07,$f0,$03,$e0,$01,$80,$0a,$40,$04,$20
	db $00,$40,$00,$d0,$00,$a0,$00,$d0,$00,$40,$00,$20,$00,$20,$00,$30
	db $07,$30,$0f,$f0,$0f,$f0,$0f,$e0,$07,$c0,$01,$80,$02,$50,$04,$20
	db $02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$70,$00
	db $58,$1e,$27,$ff,$51,$ff,$00,$7f,$10,$3e,$28,$08,$54,$08,$aa,$08
	db $00,$18,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0e
	db $78,$1a,$ff,$e4,$ff,$8a,$fe,$00,$7c,$08,$10,$14,$10,$2a,$10,$55
	db $18,$00,$00,$00,$00,$00,$00,$00,$0c,$00,$0f,$00,$0f,$80,$1f,$c0

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MoveAndDrawHens:
	LD   A,(CurrentLevel)
	CP   $08			; hens on levels 1..8
	JR   C,ProcessHens

	CP   $10			; hens on levels 16+
	RET  C

ProcessHens:
	LD   HL,(FrameCounter)
	INC  HL
	LD   H,$00
	LD   (FrameCounter),HL
	LD   C,$01
	BIT  0,(HL)
	JR   Z,FrameEven

	DEC  C
FrameEven:
	LD   HL,CurrentHen
	LD   A,(HL)
	INC  A
	CP   $05
	JR   NZ,NextHen

	XOR  A
NextHen:
	LD   (HL),A
	SLA  A				; each hen is 4 bytes each
	SLA  A
	ADD  A,low Hen1		;$57
	LD   H,high Hen1	;$73			; $7357 Hen1
	LD   L,A
	LD   E,(HL)			; x
	LD   A,E
	XOR  $FF
	RET  Z				; $ff == not in use

	INC  HL
	LD   D,(HL)			; y
	INC  HL
	LD   A,(HL)			; direction
	EX   DE,HL
	XOR  A				; a == 0 = only reset hen's background tiles
	CALL DrawBackgroundandHen
	EX   DE,HL
	LD   A,(HL)			; hen direction
	CP   HEN_PECKING+1	; $07
	JR   C,UseHenDirection

	LD   C,E			; we're pecking, c=Hen X
	SUB  HEN_PECKING	; $06
	LD   (HL),A			; remove the pecking from the direction
	LD   B,A			; b=hen frame
	CP   $02
	JR   Z,HenRight

	LD   A,E			; hen faces left
	SUB  $08
	LD   E,A

HenRight:
	EX   DE,HL
	XOR  A
	CALL DrawBackgroundandHen		; reset background behind hen
	LD   A,B						; a=Hen frame number
	LD   L,C						; l=Hen X
	CALL DrawBackgroundandHen		; draw Hen
	RET 

UseHenDirection:					; for moving Hens (non pecking)
	CP   HEN_DOWN					; $03 - down
	JR   NC,HenGoingUp
									; must be left / right, first check for bird seed
	BIT  2,E						; hen x
	JR   NZ,HenOnPlatform

	LD   B,A						; b=hen direction
	CALL CheckForBirdSeed
	LD   A,E
	ADD  A,$08						; hen x + 8
	JR   C,ChangeHenDirection

	DJNZ CheckBelow2
	SUB  $10						; hen x - 8
	JR   C,ChangeHenDirection		; off left edge of screen

CheckBelow2:
	LD   E,A
	DEC  D
	EX   DE,HL
	CALL GetMapCharAtXY
	EX   DE,HL
	AND  A
	JR   Z,ChangeHenDirection

	CP   TILE_EGG				; $03 egg tile
	JR   C,HenOnPlatform		; either side of ladder or a blank space 0, 1, 2

	CP   TILE_PLATFORM			; $05 ground tile
	JR   Z,HenOnPlatform

ChangeHenDirection:
	LD   A,$03
	SUB  (HL)
	LD   (HL),A			; hen direction = (3 - hen direction)

HenOnPlatform:
	LD   B,(HL)			; b=hen direction
	DEC  HL
	LD   D,(HL)			; d=hen y
	DEC  HL
	LD   A,(HL)			; a=hen x
	ADD  A,$04			; move right 4 pixels
	DJNZ HenMovingRight

	SUB  $08			; move left 4 pixels
HenMovingRight:
	LD   (HL),A			; store new hen x
	INC  B
	LD   E,A			; de = y,x
	EX   DE,HL			; hl = y,x
	LD   A,B			; a=hen frame number
	CALL DrawBackgroundandHen
	INC  DE
	INC  DE
	BIT  2,L
	RET  Z

	DEC  C
	RET  NZ

	PUSH HL
	LD   HL,(FrameCounter)
	LD   A,(HL)
	POP  HL				; hl = hen y,x
	LD   C,$02			; num of characters to check above
	BIT  1,A
	JR   Z,CheckAboveHen

CheckNextChar:
	PUSH HL
	LD   A,H
	SUB  $08
	LD   H,A			; hen y - 8
	CALL GetMapCharAtXY
	POP  HL
	DEC  A
	JR   Z,FoundLadder	; left side of ladder
	
	DEC  C
	JR   NZ,CheckAboveHen
	
	RET 


FoundLadder:
	LD   A,HEN_DOWN		; $03 down
	LD   (DE),A			; hen direction
	RET 

CheckAboveHen:
	PUSH HL
	LD   A,H
	ADD  A,$10
	LD   H,A			; hen y - 16
	CALL GetMapCharAtXY
	POP  HL
	DEC  A
	JR   Z,FoundLadder2

	DEC  C
	JR   NZ,CheckNextChar
	RET 

FoundLadder2:
	LD   A,HEN_UP		; $04 up
	LD   (DE),A			; hen direction
	RET 

HenGoingUp:
	BIT  2,D
	JR   NZ,OnLadder

	SUB  $02
	LD   B,A
	LD   A,D
	ADD  A,$10			; y+16
	DJNZ SetDirection

	SUB  $18			; y - 8
SetDirection:
	LD   D,A
	EX   DE,HL
	CALL GetMapCharAtXY
	EX   DE,HL
	DEC  A
	JR   Z,OnLadder

	LD   A,$07
	SUB  (HL)
	LD   (HL),A			; hen direction = 7 - hen direction

OnLadder:
	LD   B,(HL)			; b=hen direction
	DEC  HL
	LD   A,(HL)			; a=hen y
	DEC  HL
	LD   E,(HL)			; e=hen x
	ADD  A,$04			; a=hen y + 4 = going down the ladder
	DEC  B
	DEC  B
	DJNZ SetLadderMoveDirection

	SUB  $08			; a=hen y - 4 = going up the ladder
SetLadderMoveDirection:
	INC  HL
	LD   (HL),A			; store new hen y
	LD   D,A			; d=hen y
	EX   DE,HL
	LD   A,B
	ADD  A,$03			; a=hen direction + 3 = sprite frame
	CALL DrawBackgroundandHen

	BIT  2,H
	RET  NZ

	DEC  C
	RET  NZ

	INC  DE
	LD   A,H
	SUB  $08
	LD   H,A
	PUSH HL
	LD   HL,(FrameCounter)
	LD   A,(HL)
	POP  HL
	LD   C,$02
	BIT  1,A
	JR   Z,CheckHensRight

CheckHensLeft:
	PUSH HL
	LD   A,L
	SUB  $08
	LD   L,A				; hen x - 8 = check to the hen's left
	CALL GetMapCharAtXY
	POP  HL
	CP   TILE_PLATFORM		; $05 platform tile
	JR   Z,IsPlatformTileL

	DEC  C
	RET  Z

	JR   CheckHensRight

IsPlatformTileL:
	LD   A,HEN_LEFT				; $01 go left
	LD   (DE),A					; HenDirection
	RET 

CheckHensRight:
	PUSH HL
	LD   A,L
	ADD  A,$10
	LD   L,A					; hen x + 8 - check to hen's right
	CALL GetMapCharAtXY
	POP  HL
	CP   TILE_PLATFORM			;$05
	JR   Z,IsPlatformTileR

	DEC  C
	RET  Z
	
	JR   CheckHensLeft

IsPlatformTileR:
	LD   A,HEN_RIGHT			; $02 - go right
	LD   (DE),A					; HenDirection
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CheckForBirdSeed:			; de = y,x hl = hen direction in hen structure
	PUSH BC
	PUSH HL
	PUSH DE
	LD   A,E				; hen x
	ADD  A,$08
	JR   C,OffScreen

	LD   E,A				; e=hen x
	LD   A,(HL)				; a=hen direction
	CP   $02				; right
	JR   Z,GetHenMapChar

	LD   A,E
	SUB  $10
	JR   C,OffScreen

	LD   E,A				; e=hen x - 16
GetHenMapChar:
	EX   DE,HL
	CALL GetMapAddressAndChar
	CP   TILE_BIRDSEED		;$04 bird seed tile
	JR   NZ,OffScreen

	LD   (HL),TILE_BLANK	; remove bird seed from map
	LD   A,(DE)
	ADD  A,HEN_PECKING		;$06
	LD   (DE),A				; set hen direction to 7/8 as we have bird seed infront of us
	POP  HL
	CP   $08
	JR   Z,DrawPeckingHen

	LD   A,L				; move x back 8 pixels for pecking
	SUB  $08
	LD   L,A

DrawPeckingHen:
	LD   A,(DE)				; hen pecking frame
	CALL DrawBackgroundandHen
	POP  HL
	POP  HL
	POP  HL
	RET 

OffScreen:
	POP  DE
	POP  HL
	POP  BC
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawBackgroundandHen:			; a = frame number (0==only draw background tiles), hl = y,x
	PUSH BC
	PUSH DE
	PUSH AF
	PUSH HL
	EX   DE,HL
	LD   HL,PlayerX
	LD   A,E			; hen x
	ADD  A,$05			; hen x + 5
	CP   (HL)
	JR   C,NotOverlapping

	SUB  $0D			;  hen x - 8
	JR   NC,NotLeftEdge

	XOR  A
NotLeftEdge:
	CP   (HL)
	JR   NC,NotOverlapping
	INC  HL			; we are within x range of hen, try Y
	LD   A,D			; hen y
	CP   (HL)			; player y
	JR   NC,NotOverlapping			; hen below player

	ADD  A,$1C			; 28 pixel high hen
	CP   (HL)
	JR   C,NotOverlapping			; hen above player

	IF DISABLE_COLLISION == 0
		LD   B,$06
CleanUp:				; player overlaps hen; don't redraw the hen's background
		POP  HL			; and pop off the return address, thus exiting the main loop
		DJNZ CleanUp	; and causing a player death.
		RET 
	ENDIF

NotOverlapping:		; player isn't overlapping the hen, so let's reset the background and plot the hen
	POP  HL			; HL = hen y, x
	POP  AF
	PUSH AF
	PUSH HL
	AND  A
	JP   Z,PlotTileBackground			; if a==0 only reset the background, don't draw the hen

	LD   IXH,A			; ixh holds frame number of sprite
	CP   $04
	JR   NZ,NotFrameFour
	DEC  A

NotFrameFour:
	EX   DE,HL			; de = hen y, x
	CP   $07
	JR   NC,DrawHenFrame			; pecking left/right

	CP   $03			; down
	JR   NZ,HenLeftRight

	BIT  2,D			; frame 3/4
	JR   Z,DrawHenFrame

	INC  A
	JR   DrawHenFrame

HenLeftRight:
	BIT  2,E
	JR   Z,DrawHenFrame
	ADD  A,$04			; frame 4/5
DrawHenFrame:			; a=hen frame to draw
	LD   B,$00
	LD   C,A
	SLA  C
	SLA  C
	SLA  C
	SLA  C
	SLA  C				; x32
	RL   B
	LD   HL,gfx_HenLeft
	ADD  HL,BC
	EX   DE,HL
	LD   C,$02
	LD   A,L
	CP   $F9
	JR   C,DrawHen
	DEC  C

DrawHen:
	CALL GetScreenAddress
	LD   B,$10			; 16 pixels high
HenDrawLoop:
	LD   A,(DE)			; sprite data
	DEC  C
	JR   Z,NextLine

	INC  DE
	OR   (HL)
	LD   (HL),A			; write to screen
	INC  HL
	LD   A,(DE)
	OR   (HL)
	DEC  DE
	DEC  DE
	DEC  DE
	LD   (HL),A			; write to screen
	DEC  HL

NextLine:
	INC  C
	DEC  H
	LD   A,H
	AND  $07
	CP   $07
	JR   NZ,LineSkip

	LD   A,H
	ADD  A,$08
	LD   H,A
	LD   A,L
	SUB  $20
	LD   L,A
	JR   NC,LineSkip

	LD   A,H
	SUB  $08
	LD   H,A

LineSkip:
	DJNZ HenDrawLoop

	POP  HL
	PUSH HL
	LD   D,$02			; d=width of attr fill
	LD   A,IXH
	CP   $07
	JR   NC,SetAttrHeight

	BIT  2,L			; hen x
	JR   NZ,SetAttrHeight

	DEC  D				; adjust width
SetAttrHeight:
	LD   E,$03			; e=height of attr fill
	BIT  2,H			; hen y
	JR   NZ,WidthAndHeighSet

	DEC  E				; adjust height
WidthAndHeighSet:
	CALL GetAttrAddressHL
NextHenAttrLine:
	LD   B,D
	PUSH HL
HenAttrLoop:
	LD   (HL),$05			; cyan
	INC  HL
	DJNZ HenAttrLoop
	
	POP  HL
	LD   BC,$0020
	AND  A
	SBC  HL,BC
	DEC  E
	JR   NZ,NextHenAttrLine
	
	POP  HL
	POP  AF
	POP  DE
	POP  BC
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlotTileBackground:			; resets the background where a hen will be drawn
	LD   IXL,$02			; ixl = x count of character tiles to plot
	LD   A,L				; hen x
	CP   $F8				; 248
	JR   C,InXRange

	DEC  IXL				; only 1 character to tile to print.
InXRange:
	LD   A,H				; hen y
	AND  $F8				; 11111000
	LD   H,A				; hen y on 8 pixel boundary
	CALL GetScreenAddress
	EX   DE,HL				; de = screen address
	POP  HL
	PUSH HL
	CALL GetMapAddress		; hl = map address
	PUSH HL
	POP  BC					; bc = map address
	POP  HL					; hl = hen y,x
	PUSH HL
	CALL GetAttrAddressHL	; rets HL attr address, de = screen address
	LD   IXH,$03
NextTileLine:
	PUSH IX
	PUSH HL
	PUSH BC
	PUSH DE
TilePlotLoop:
	PUSH HL
	LD   A,(BC)					; map tile at hen's feet
	ADD  A,low TileColours		;$4F
	LD   H,high TileColours		;$98			; $984f - TileColours
	LD   L,A
	LD   A,(HL)			; a = tile colour
	POP  HL
	LD   (HL),A			; write to attribute 
	PUSH HL
	PUSH BC
	LD   A,(BC)			; map tile at hen's feet
	SLA  A
	SLA  A
	SLA  A				; x8

	LD   HL,gfx_CharacterSet+7
	LD   B,$00
	LD   C,A
	ADD  HL,BC			; hl = address of map tile gfx
	PUSH DE
	LD   B,$08

PlotTileLoop:
	LD   A,(HL)			; copy tile to screen
	LD   (DE),A
	DEC  D
	DEC  HL
	DJNZ PlotTileLoop

	POP  DE
	INC  DE			; inc screen address 
	POP  BC
	INC  BC			; inc map address
	POP  HL
	INC  HL			; inc attribute address
	DEC  IXL
	JR   NZ,TilePlotLoop

	POP  DE
	POP  BC
	POP  HL
	LD   A,E
	SUB  $20
	LD   E,A
	JR   NC,NoSkip

	LD   A,D
	SUB  $08
	LD   D,A

NoSkip:
	PUSH DE
	LD   DE,$0020
	AND  A
	SBC  HL,DE			; next attribute line up
	PUSH HL
	PUSH BC
	POP  HL
	ADD  HL,DE			; next map line down
	PUSH HL
	POP  BC
	POP  HL
	POP  DE
	POP  IX
	DEC  IXH
	JR   NZ,NextTileLine

	POP  HL
	POP  AF
	POP  DE
	POP  BC
	LD   IX,PlayerX
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;


GetAttrAddressHL:			; input HL = y/x.  Output HL=attribute address
	PUSH AF
	PUSH DE
	LD   A,$BF
	SUB  H
	LD   H,$00
	EX   DE,HL
	LD   HL,$5800
	SRL  E
	SRL  E
	SRL  E
	ADD  HL,DE
	AND  $F8
	SLA  A
	RL   D
	SLA  A
	RL   D
	LD   E,A
	ADD  HL,DE
	POP  DE
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetMapAddress:			; input HL=y/x position, on output HL = address in level buffer
	PUSH AF
	CALL GetMapAddressAndChar
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetScreenAddress:			; input HL = y/x coord, output HL = screen address
	PUSH AF
	PUSH DE
	PUSH BC

	EX   DE,HL
	LD   HL,$4000
	LD   BC,$0800			; size of one third of the screen
	LD   A,D
	CP   $80
	JR   NC,.FirstThird

	CP   $40
	JR   NC,.SecondThird
	
	ADD  HL,BC

.SecondThird:
	ADD  HL,BC

.FirstThird:
	AND  $38				; 00111000
	LD   C,A
	LD   A,$38				; 00111000
	SUB  C
	SLA  A
	SLA  A
	LD   B,$00
	LD   C,A
	ADD  HL,BC
	LD   A,D
	AND  $07
	XOR  $07
	LD   D,A
	SRL  E
	SRL  E
	SRL  E
	ADD  HL,DE

	POP  BC
	POP  DE
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetMapCharAtXY:			; gets map char in a, that is at hl =y,x
	PUSH HL
	CALL GetMapAddressAndChar
	POP  HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; Hen start positions for upto five hens over 8 levels
;
; x, y, direction, frame number
; x, y, direction, frame number
; x, y, direction, frame number
; x, y, direction, frame number
; x, y, direction, frame number
; Hen Speed
;
;

HenStarts:
	db $08
	db $68
	db $88
	db $02
	db $00
	db $48
	db $68
	db $01
	db $00
	db $40
	db $48
	db $01
	db $00
	db $98
	db $08
	db $02
	db $00
	db $48
	db $28
	db $01

	db $00
	db $0C
	db $10
	db $08
	db $02
	db $00
	db $48
	db $88
	db $02
	db $00
	db $E0
	db $48
	db $02
	db $00
	db $90
	db $48
	db $01
	db $00
	db $A8
	db $88
	db $01

	db $00
	db $0C
	db $10
	db $68
	db $01
	db $00
	db $E8
	db $20
	db $01
	db $00
	db $70
	db $80
	db $02
	db $00
	db $64
	db $50
	db $03
	db $00
	db $0C
	db $28
	db $04

	db $00
	db $10
	db $28
	db $08
	db $01
	db $00
	db $D8
	db $08
	db $02
	db $00
	db $D8
	db $88
	db $02
	db $00
	db $78
	db $88
	db $02
	db $00
	db $58
	db $08
	db $01

	db $00
	db $10
	db $10
	db $28
	db $01
	db $00
	db $28
	db $48
	db $02
	db $00
	db $28
	db $68
	db $01
	db $00
	db $A8
	db $48
	db $02
	db $00
	db $E0
	db $08
	db $02

	db $00
	db $10
	db $18
	db $08
	db $01
	db $00
	db $18
	db $68
	db $01
	db $00
	db $C0
	db $28
	db $02
	db $00
	db $E8
	db $68
	db $02
	db $00
	db $A0
	db $48
	db $02

	db $00
	db $0C
	db $C8
	db $88
	db $01
	db $00
	db $0C
	db $58
	db $04
	db $00
	db $BC
	db $40
	db $03
	db $00
	db $28
	db $68
	db $02
	db $00
	db $0C
	db $18
	db $04

	db $00
	db $0C
	db $7C
	db $70
	db $04
	db $00
	db $7C
	db $30
	db $04
	db $00
	db $A0
	db $08
	db $01
	db $00
	db $38
	db $48
	db $01
	db $00
	db $C0
	db $48
	db $02

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ResetTileColours:
	PUSH AF
	PUSH BC
	PUSH DE
	PUSH HL
	LD   B,$03
	LD   A,L
	CP   $F1
	JR   C,.Skip1
	DEC  B
.Skip1:
	LD   C,$03
	LD   A,H
	CP   $11
	JR   NC,.Skip2
	DEC  C

.Skip2:
	CALL GetAttrAddressInDE
	CALL GetCharAddress
NextColourTileLine:
	PUSH BC
	PUSH DE
	PUSH HL
NextColourTile:
	LD   A,(HL)
	CP   $09
	JR   C,GetTileColour
	LD   A,$06				; YELLOW
	JR   SetAttribute

GetTileColour:
	ADD  A,low TileColours	;$4F			; TileColours Lo
	PUSH BC
	LD   B,high TileColours	;$98			; TileColours Hi
	LD   C,A
	LD   A,(BC)
	POP  BC
SetAttribute:
	LD   (DE),A			; write attribute
	INC  DE
	INC  HL
	DJNZ NextColourTile

	POP  HL
	LD   DE,$0020
	AND  A
	SBC  HL,DE			; move up a level line
	POP  DE
	PUSH HL
	EX   DE,HL
	LD   DE,$0020
	ADD  HL,DE			; move down an attribute line
	EX   DE,HL
	POP  HL
	POP  BC
	DEC  C
	JR   NZ,NextColourTileLine

	POP  HL
	POP  DE
	POP  BC
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetAttrAddressInDE:			; returns in DE the address of the attribute at HL = y/x
	PUSH AF
	PUSH HL
	LD   A,$BF
	SUB  H
	LD   H,$00
	EX   DE,HL
	LD   HL,$5800
	SRL  E
	SRL  E
	SRL  E
	ADD  HL,DE
	AND  $F8
	SLA  A
	RL   D
	SLA  A
	RL   D
	LD   E,A
	ADD  HL,DE
	EX   DE,HL
	POP  HL
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetCharAddress:			; give a position in HL (y/x) = return in HL the address in the LevelBuffer of that position
	PUSH AF
	PUSH DE
	EX   DE,HL
	LD   HL,LevelBuffer
	LD   A,D
	LD   D,$00
	SRL  E
	SRL  E
	SRL  E
	ADD  HL,DE
	AND  $F8
	LD   E,A
	SLA  E
	RL   D
	SLA  E
	RL   D
	ADD  HL,DE
	POP  DE
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TitleText:
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,"by",$00
	db $00,"n.alderton",$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,"1",$00,"to",$00,"4",$00,"players",$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,"of",$00
	db "skill",$00,"for",$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,"a",$00,"game",$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$82,$80,$81,$82,$00,$82,$80,$00,$00,$00,$00,$00
	db $00,$00,$86,$00,$84,$8A,$89,$81,$84,$00,$00,$00,$00,$00,$00
	db $00,$86,$80,$85,$82,$87,$82,$80,$7F,$00,$00,$82,$80,$80,$80
	db $82,$80,$82,$80,$80,$81,$81,$82,$81,$82,$84,$00,$86,$84,$84
	db $84,$84,$00,$86,$83,$00,$84,$89,$82,$86,$80,$84,$84,$84,$84
	db $86,$80,$84,$85,$81,$86,$89,$82,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,"presents",$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,"A"
	db $00,"&",$00,"F",$00,"SOFTWARE"

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScoreText:
	db $0B
	db $0C
	db $0D
	db $0E
	db $0F
	db $10
	db $11
PlayerNumber:
	db $9F
	db $00
	db $00
	db $9B
	db $9C
	db $9D
	db $00
LevelDigit1:
	db $9E
LevelDigit2:
	db $A0
	db $00
	db $00
	db $1B
	db $1C
	db $1D
	db $00

BonusDigits:
	db $A0
	db $9E
	db $9E
	db $9E
	db $00
	db $00
	db $12
	db $13
	db $14
	db $00

TimeDigits:
	db $A7
	db $9E
	db $9E

LiftReset1:
	db $05
	db $05
	db $FF
	db $00
	db $05
	db $05
	db $FF
	db $00
	db $05
	db $05
	db $FF
	db $00
	db $E8
	db $54
	db $40
	db $03
	db $F2
	db $54
	db $90
	db $03
	db $F9
	db $54
	db $C8
	db $03
	db $EF
	db $54
	db $78
	db $03
	db $FE
	db $54
	db $F0
	db $03
	db $05
	db $05
	db $FF
	db $00
	db $6E
	db $73
	db $00
	db $00

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

HighScores:
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
	db '0'
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
	db '0'
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
	db '0'
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
	db '0'
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
	db '0'
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
	db '0'
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
	db '0'
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
	db '0'
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'

NinthHighScoreLastByte:
	db '0'

TenthHighScore:
	db ' '
	db $8F
	db $90
	db $91
	db $92
	db $93
	db $94
	db $95
	db $96
	db ' '
	db '0'
	db '0'
	db '1'
	db '0'
	db '0'
TenthHighScoreLastByte:
	db '0'

TileColours:
	db $06
	db $03
	db $03
	db $07
	db $03
	db $04
	db $06
	db $07
	db $07

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MainLoop:
	
;	LD   HL,(data_5C3D)			; error from tape loader
;	DEC  HL
;	LD   A,H
;	OR   L
;ErrorHang:
;	JR   NZ,ErrorHang

	LD   HL,SFXFreq
	LD   A,(SoundTimer)
	AND  $0F
	JR   NZ,SkipSound2

	LD   A,(HL)
	AND  A
	JR   Z,SkipSound2

	DEC  (HL)
	AND  $03
	JR   NZ,SkipSound2

	LD   A,(HL)
	AND  $1F
	ADD  A,$06
	LD   H,A
	LD   L,$02
	CALL PlaySquareWave

SkipSound2:
	LD   A,(PlayerInAir)
	AND  A
	JR   Z,LastHen

	LD   A,(SoundTimer)
	DEC  A
	JR   NZ,SkipSound
	LD   L,$01
	LD   A,(PlayerY)
	XOR  $FF
	LD   H,A
	CALL PlaySquareWave

SkipSound:
	LD   A,(FallingCounter)
	PUSH AF
	CALL CollidePlayerToWorld
	POP  AF
	DEC  A
	JR   NZ,LastHen			; don't run player to hen collisions

	LD   HL,Hen1
	LD   B,$05				; max 5 hens

NextHenLoop:
	LD   E,(HL)				; e=hen x
	LD   A,E
	XOR  $FF
	JR   Z,LastHen

	INC  HL
	LD   D,(HL)				; d=hen y
	INC  HL
	INC  HL
	INC  HL

	IF DISABLE_COLLISION == 0
		CALL CollidePlayerAndHen
		AND  A
		RET  NZ
	ENDIF

	DJNZ NextHenLoop

LastHen:
	LD   HL,SoundTimer
	DEC  (HL)
	JP   NZ,LoopDone

	LD   (HL),$82				; reset timer
	LD   A,$FE
	IN   A,($FE)
	BIT  0,A					; shift
	JR   NZ,ContinueMainLoop

	LD   A,$BF					; shift is pressed
	IN   A,($FE)
	BIT  4,A					; H
	JR   NZ,NotPause

PauseLoop:						; SHIFT + H = Hold (pause) game
	LD   A,$FD
	IN   A,($FE)
	BIT  1,A
	JR   NZ,PauseLoop

	JR   ContinueMainLoop

NotPause:
	LD   A,$FD
	IN   A,($FE)
	BIT  0,A					; A
	JR   NZ,ContinueMainLoop
	POP  HL
	JP   Start					; SHIFT + A = ABORT game

ContinueMainLoop:
	LD   A,(TimerRunning)
	AND  A
	JR   Z,NoTimerUpdate1

	LD   HL,FiftiesCounter
	DEC  (HL)
	JR   NZ,NoTimerUpdate1

	LD   (HL),$32					; set back to 50
	LD   B,$00						; b = 0 = update timers
	CALL DecreaseTimerOrBonus		; decrease timer every 50 frames

NoTimerUpdate1:
	LD   HL,MotherDuckUpdateCounter
	DEC  (HL)
	JR   NZ,NoDuckUpdate

	LD   (HL),$0C					; update mother duck movement every 12 frames
	CALL MoveMotherDuck

NoDuckUpdate:
	LD   HL,LiftUpdateCounter
	DEC  (HL)
	JR   NZ,NoLiftUpdate

	LD   (HL),$02
	CALL UpdateAndDrawLifts			; update lifts every 2 frames (25hz)
	LD   A,(PlayerOnLift)
	AND  A
	JR   Z,NoLiftUpdate

	LD   A,(PlayerY)
	INC  A
	LD   (PlayerY),A
	CP   $A5
	RET  NC

NoLiftUpdate:
	CALL PlayerPickUp
	LD   HL,TensCounter
	DEC  (HL)
	JR   NZ,NoTimerUpdate2

	LD   (HL),$0A					; update bonus every 5 frames
	LD   B,$01						; update bonus
	CALL DecreaseTimerOrBonus
	LD   HL,$0402
	CALL PlaySquareWave

NoTimerUpdate2:
	LD   HL,HenUpdateSpeed
	DEC  (HL)
	JR   NZ,NoHenUpdates

	LD   C,$03						; reset hen update speed
	LD   A,(CurrentLevel)
	CP   $20
	JR   C,NoSpeedUp				; < level 32

	DEC  C							; if level > 32 speed up the hen updates

NoSpeedUp:
	LD   (HL),C						; set the HenUpdateSpeed
	CALL MoveAndDrawHens

NoHenUpdates:
	LD   HL,(PlayerX)
	CALL ResetTileColours
	LD   A,(PlayerInAir)
	AND  A
	JR   NZ,HarryInTheAir

	LD   A,(JumpPort)				; not in the air, test for jump key
	IN   A,($FE)
	AND  $1F
	LD   C,A
	LD   A,(JumpBitmask)
	OR   C
	CP   $1F
	JR   NZ,DoJump

	LD   A,(Jump2Port)				; secondary jump key
	IN   A,($FE)
	AND  $1F
	LD   C,A
	LD   A,(Jump2Bitmask)
	OR   C
	CP   $1F
	JR   Z,HarryInTheAir

DoJump:
	LD   IX,PlayerX
	LD   (IX+$4D),$02			; $7325 - PlayerInAir - 2 = InAir
	LD   (IX+$4F),$8C			; $7327 - InAirCounter
	LD   (IX+$50),$00			; $7328 - FallingCounter
	LD   (IX+$52),$01			; $732a - PlayerAirDirection
	LD   (IX+$7D),$00			; $7355 - PlayerOnLift

	LD   D,$01
	LD   E,$00					; right
	LD   A,(RightPort)
	IN   A,($FE)
	AND  $1F
	LD   C,A
	LD   A,(RightBitmask)
	OR   C
	CP   $1F
	JR   NZ,SetPlayerDirection

	LD   D,$FF
	LD   E,$04					; left
	LD   A,(LeftPort)
	IN   A,($FE)
	AND  $1F
	LD   C,A
	LD   A,(LeftBitmask)
	OR   C
	CP   $1F
	JR   NZ,SetPlayerDirection

	INC  D						; d = jumping straight up (0)
	LD   E,(IX+$03)				; $723b - PlayerDirection

SetPlayerDirection:
	LD   (IX+$4E),D				; $7326 - PlayerJumpDirection
	LD   (IX+$03),E				; $72db - PlayerDirection
	JR   LoopDone

HarryInTheAir:	
	LD   A,(PlayerInAir)
	AND  A
	JR   NZ,IsInAir
	
	CALL TryMovingLeftRight		; Harry isn't in the air, do left/right movement
	LD   A,(PlayerDirection)
	CP   $0D
	CALL NZ,MoveAndDrawPlayer
	
	LD   A,(PlayerOnLift)
	AND  A
	CALL Z,CheckForFalling

IsInAir:
	CALL TryClimbLadder

LoopDone:
	JP   MainLoop

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayerPickUp:					; player picking up eggs and corn
	LD   HL,(PlayerX)
	LD   A,H
	SUB  $08
	LD   H,A
	LD   A,L
	ADD  A,$08
	LD   L,A
	CALL GetMapAddressAndChar
	CP   TILE_EGG				;$03 egg
	JR   NZ,NotEgg

	LD   (HL),TILE_BLANK		;$00				
	LD   A,(CurrentLevel)
	SRL  A
	SRL  A
	CP   TILE_LAST				; $09
	JR   C,NoClamp

	LD   A,$09
NoClamp:
	LD   B,A
	INC  B
	XOR  A

CalcLp:
	ADD  A,$0A
	DJNZ CalcLp

	LD   B,A
	CALL AddToScore
	LD   A,$FF
	LD   (SFXFreq),A

	LD   HL,EggsRemaining
	DEC  (HL)
	RET  NZ
	POP  HL
	RET 

NotEgg:
	CP   TILE_BIRDSEED				;$04 corn
	RET  NZ

	LD   (HL),TILE_BLANK			;$00
	LD   B,$05
	CALL AddToScore
	LD   HL,$FFFF
	LD   (FiftiesCounter),HL
	LD   A,L
	LD   (SFXFreq),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawSpriteNum:					; HL = y/x coords, A = sprite number to draw
	PUSH AF
	PUSH BC
	PUSH DE
	PUSH IX
	PUSH HL
	LD   C,L
	LD   HL,gfx_PlayerRight
	LD   E,A					; a * 32
	XOR  A
	RL   E
	RLA
	RL   E
	RLA
	RL   E
	RLA
	RL   E
	RLA
	RL   E
	RLA
	LD   D,A
	ADD  HL,DE
	
	LD   DE,SpriteBuffer		; copy sprite to SpriteBuffer for pixel shifting
	LD   B,$10
	XOR  A
CopyLoop:
	LDI
	LDI
	INC  BC
	INC  BC
	LD   (DE),A
	INC  DE
	DJNZ CopyLoop
	
	LD   A,$07
	AND  C
	CP   $00
	JR   Z,NoShift

NextShift:					; Shift sprite buffer into the correct pixel position
	LD   B,$10				; 16 pixels high
	LD   HL,SpriteBuffer
ShiftSpriteLp:
	SRL  (HL)
	INC  HL
	RR   (HL)
	INC  HL
	RR   (HL)
	INC  HL
	DJNZ ShiftSpriteLp

	DEC  A
	JR   NZ,NextShift

NoShift:
	POP  HL					; hl = y,x
	PUSH HL
	LD   IX,BackgroundBuffer
	EX   DE,HL				; de = y,x
	LD   HL,LevelBuffer
	LD   A,D				; y
	AND  $F8				; 11111000
	LD   B,$00
	SLA  A
	RL   B
	SLA  A
	RL   B
	LD   C,A				; x4
	ADD  HL,BC				; start y line of map (levels are stored upside down)
	LD   B,$00
	LD   C,E				; x
	SRL  C
	SRL  C
	SRL  C					; x / 8
	ADD  HL,BC
	EX   DE,HL
	LD   BC,$0303
NextBackChar:
	PUSH BC
	LD   HL,gfx_CharacterSet
	LD   A,(DE)
	LD   B,$00
	SLA  A
	RL   B
	SLA  A
	RL   B
	SLA  A					; * 8
	RL   B
	LD   C,A
	ADD  HL,BC
	
	LD   B,$08

CopyBackLoop:				; copy background tiles into buffer
	LD   A,(HL)
	LD   (IX+$00),A
	INC  IX
	INC  IX
	INC  IX
	INC  HL
	DJNZ CopyBackLoop

	LD   B,$17
DecLoop:
	DEC  IX
	DJNZ DecLoop
	POP  BC
	INC  DE
	DJNZ NextBackChar
	EX   DE,HL
	LD   DE,$0023
	AND  A
	SBC  HL,DE
	LD   DE,$0015
	ADD  IX,DE
	EX   DE,HL
	LD   B,$03
	DEC  C
	JR   NZ,NextBackChar

	POP  HL					; hl = y/x
	PUSH HL
	LD   A,H
	AND  $07
	XOR  $07
	LD   H,A				; h = 7 - ( y & 7 )
	SLA  A					; x2
	ADD  A,H				; x3
	LD   C,A
	LD   B,$00
	LD   HL,BackgroundBuffer			; plot shifted sprite into background buffer
	LD   DE,SpriteBuffer
	ADD  HL,BC
	LD   B,$30
PlotLoop:
	LD   A,(DE)
	OR   (HL)
	LD   (DE),A
	INC  DE
	INC  HL
	DJNZ PlotLoop
	
	POP  DE					; de = y/x
	PUSH DE
	LD   HL,$4000			; screen
	LD   BC,$0800			; offset to next third of the screen
	LD   A,D				; y
	CP   $80
	JR   NC,FirstThird

	CP   $40
	JR   NC,SecondThird
	
	ADD  HL,BC

SecondThird:
	ADD  HL,BC

FirstThird:
	AND  $38				; $38 (56) - (y & 00111000 (56))
	LD   C,A
	LD   A,$38
	SUB  C
	SLA  A
	SLA  A					; x4
	LD   C,A
	LD   B,$00
	ADD  HL,BC
	LD   A,D
	AND  $07
	LD   C,A
	LD   A,$07
	SUB  C
	LD   D,A				; d = 7 - (y & 7)
	SRL  E
	SRL  E
	SRL  E					; x / 8
	ADD  HL,DE
	EX   DE,HL				; de = screen address
	LD   B,$10
	LD   HL,SpriteBuffer	; copy sprite and background to screen

SpriteRowLoop:
	LD   A,(HL)				; three characters wide (16 pixels wide shifted into the adjacent 8 pixels)
	LD   (DE),A
	INC  HL
	INC  E
	LD   A,(HL)
	LD   (DE),A
	INC  HL
	INC  E
	LD   A,(HL)
	LD   (DE),A
	INC  HL
	DEC  E
	DEC  E
	INC  D
	LD   A,D
	AND  $07
	JR   NZ,DoNextRow

	LD   A,D
	SUB  $08
	LD   D,A
	LD   A,E
	ADD  A,$20
	LD   E,A
	JR   NC,DoNextRow
	LD   A,D
	ADD  A,$08
	LD   D,A

DoNextRow:
	DJNZ SpriteRowLoop
	POP  HL
	PUSH HL
	LD   C,$03				; 3 attrs wide
	LD   A,L
	CP   $F1				; off right edge?
	JR   C,NoClip

	DEC  C					; yes reduce attr width by 1

NoClip:
	LD   B,$03				; 3 attrs high
	LD   A,H
	AND  $07
	XOR  $07
	JR   Z,ClipAttr

	LD   A,H
	CP   $11
	JR   NC,SetAttributes

ClipAttr:
	DEC  B

SetAttributes:
	CALL AttributePosition
	LD   DE,$0020
ColLoop2:
	LD   IXL,C
	PUSH HL
ColLoop:
	LD   (HL),$06			; ink yellow, paper black
	INC  HL
	DEC  IXL
	JR   NZ,ColLoop

	POP  HL
	ADD  HL,DE
	DJNZ ColLoop2

	LD   HL,MotherDuckX
	LD   A,(PlayerX)
	ADD  A,$08
	JR   NC,NoRightClip
	LD   A,$FF

NoRightClip:
	CP   (HL)
	JR   C,NoOverlapping

	SUB  $10
	JR   NC,NoLeftClip

	XOR  A
NoLeftClip:
	CP   (HL)
	JR   NC,NoOverlapping

	INC  HL
	LD   A,(PlayerY)
	ADD  A,$09
	CP   (HL)
	JR   C,NoOverlapping

	SUB  $12
	JR   NC,NoTopClip

	XOR  A
NoTopClip:
	CP   (HL)
	JR   NC,NoOverlapping

	if DISABLE_COLLISION == 0	; if we're overlapping MotheDuck then clean up the stack so that we
		LD   B,$05					; end up RETing out of the main loop and causing the player's death.
ClearStack:
		POP  HL
		DJNZ ClearStack

		LD   BC,Start			;$A410
CleanUpReturnAddr:
		POP  HL
		PUSH HL
		AND  A
		SBC  HL,BC
		RET  NC

		POP  HL
		JR   CleanUpReturnAddr
	ENDIF

NoOverlapping:
	POP  HL
	POP  IX
	POP  DE
	POP  BC
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

AttributePosition:			; HL = y/x position, returns HL = attribute address for position
	PUSH AF
	PUSH DE
	LD   A,$BF
	SUB  H
	LD   H,$00
	EX   DE,HL
	LD   HL,$5800
	SRL  E
	SRL  E
	SRL  E
	ADD  HL,DE
	AND  $F8
	SLA  A
	RL   D
	SLA  A
	RL   D
	LD   E,A
	ADD  HL,DE
	POP  DE
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PrintCharacter:
	NOP 
	NOP 
	NOP 
	NOP 
	PUSH HL
	PUSH BC
	PUSH DE
	PUSH AF
	LD   A,H
	EX   DE,HL
	LD   HL,$4000			; top of the screen
	LD   BC,$0800			; offset for each third
	CP   $10
	JR   NC,FirstThird_1

	CP   $08
	JR   NC,SecondThird_1

	ADD  HL,BC
SecondThird_1:
	ADD  HL,BC
FirstThird_1:
	AND  $07
	XOR  $07
	SLA  A
	SLA  A
	SLA  A
	SLA  A
	SLA  A
	LD   C,A
	LD   B,$00
	ADD  HL,BC
	LD   C,E
	ADD  HL,BC
	POP  AF
	PUSH AF
	LD   C,A
	XOR  A
	SLA  C
	RLA
	SLA  C
	RLA
	SLA  C
	RLA
	LD   B,A
	EX   DE,HL
	LD   HL,gfx_CharacterSet
	ADD  HL,BC
	LD   B,$08
CharLoop:
	LD   A,(HL)
	LD   (DE),A
	INC  HL
	INC  D
	DJNZ CharLoop

	POP  AF
	POP  DE
	POP  BC
	POP  HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; ISR points here, must be at $9c9c
;

	org $9c9c

	JP   OratorPlayerInterrupt			; $9c9c - IM2 address

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlaySquareWave:
	LD   A,$10
	OUT  ($FE),A
	LD   B,H

WaitOn:
	DJNZ WaitOn
	XOR  A
	OUT  ($FE),A
	LD   B,H
WaitOff:
	DJNZ WaitOff

	DEC  L
	JR   NZ,PlaySquareWave
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

OratorPlayerInterrupt:

	IF DISABLE_SPEECH == 1
	RETI
	ENDIF

	PUSH AF
	PUSH HL
	LD   A,(SpeechPlaying)
	CP   $FF
	JR   Z,SpeechDone

	DEC  A
	JR   Z,SpeechRunning
	
	LD   (SpeechPlaying),A
	JR   SpeechDone

SpeechRunning:
	LD   HL,(OratorAllophoneListAddress)
	LD   A,(HL)
	LD   (SpeechPlaying),A
	CP   $FF
	JR   Z,SpeechDone
	
	INC  HL
	LD   A,(HL)			; get allophone
	OUT  ($9F),A
	INC  HL
	LD   (OratorAllophoneListAddress),HL

SpeechDone:
	POP  HL
	EI  
	POP  AF
	RETI

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayFullerOrator:			; a=word to say

	IF DISABLE_SPEECH == 1
	RET
	ENDIF

	LD   B,A
	LD   A,(SpeechPlaying)
	CP   $FF
	RET  NZ

	LD   HL,OratorWordAllophoneAddresses

FindAllophonesForWord:
	INC  HL
	INC  HL
	DJNZ FindAllophonesForWord

	LD   E,(HL)
	INC  HL
	LD   D,(HL)
	LD   (OratorAllophoneListAddress),DE

	LD   A,$01
	LD   (SpeechPlaying),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MoveAndDrawPlayer:
	LD   IX,PlayerX
	LD   HL,(PlayerX)
	LD   A,(PlayerDirection)
	AND  A
	JR   NZ,DirRight

	DEC  L			; x-1
DirRight:
	EX   DE,HL			; de = y,x
	LD   HL,LevelBuffer
	LD   A,D
	AND  $F8
	LD   B,$00
	SLA  A
	RL   B
	SLA  A
	RL   B
	LD   C,A
	ADD  HL,BC
	LD   B,$00
	LD   C,E
	SRL  C
	SRL  C
	SRL  C
	ADD  HL,BC
	LD   BC,$0020

	LD   A,(LeftPort)			; left keypress
	IN   A,($FE)
	AND  $1F
	LD   D,A
	LD   A,(LeftBitmask)
	OR   D
	CP   $1F
	JR   Z,TryMovingRight

	LD   A,(PlayerX)
	DEC  A
	JR   Z,NoRightPress

	LD   A,(HL)
	CP   $05
	JR   NC,NoRightPress

	AND  A
	SBC  HL,BC
	LD   A,(HL)
	CP   $05
	JR   NC,NoRightPress

	DEC  (IX+$00)			; PlayerX -= 1
	LD   (IX+$03),$04			; PlayerDirection = LEFT
	LD   A,(PlayerX)
	AND  $03
	JR   NZ,NoWalkSound

	LD   HL,$2805			; play walk sound every 4 pixels moved
	CALL PlaySquareWave
NoWalkSound:
	JR   DrawPlayer2

TryMovingRight:
	LD   A,(RightPort)			; right keypress
	IN   A,($FE)
	AND  $1F
	LD   D,A
	LD   A,(RightBitmask)
	OR   D
	CP   $1F
	JR   Z,NoRightPress

	LD   A,(PlayerX)			; at the right edge of the screen?
	CP   $EE
	JR   NC,NoRightPress

	INC  HL
	INC  HL
	LD   A,(HL)			; check the map 2 tiles to the right
	CP   TILE_PLATFORM	;$05			; platform tile
	JR   NC,NoRightPress

	AND  A
	SBC  HL,BC			; check one tile row up
	LD   A,(HL)
	CP   TILE_PLATFORM	;$05			; platform tile
	JR   NC,NoRightPress

	INC  (IX+$00)			; player x + 1
	LD   (IX+$03),$00			; PlayerDirection = right
	LD   A,(PlayerX)
	AND  $03
	JR   NZ,NoWalkSound2

	LD   HL,$2806			; play walk sound every 4 pixels moved
	CALL PlaySquareWave
NoWalkSound2:
	JR   DrawPlayer2

NoRightPress:
	LD   (IX+$02),$03			; PlayerAnimFrame
DrawPlayer2:
	LD   HL,(PlayerX)
	LD   A,(PlayerAnimFrame)			; cycle throught the anim frames
	INC  A
	AND  $03
	LD   (PlayerAnimFrame),A

	ADD  A,(IX+$03)			; add in the direction the player is facing
	CALL DrawSpriteNum

	LD   A,(PlayerOnLift)
	AND  A
	RET  Z

	LD   A,(LiftsActive)
	XOR  $FF
	RET  Z

	XOR  $FF
	SUB  $09			; handle player on lifts
	LD   B,A
	LD   A,(PlayerX)
	CP   B
	JR   C,PlayerMovingOnLift

	SUB  $13
	CP   B
	RET  C

PlayerMovingOnLift:
	LD   (IX+$4D),$01			; PlayerInAir = 1 (on lift)
	LD   D,$FF					; jump direction left
	LD   A,(PlayerDirection)
	AND  A
	JR   NZ,SetJumpDirection
	LD   D,$01					; jump directon right
SetJumpDirection:
	LD   (IX+$4E),D				; PlayerJumpDirection
	LD   (IX+$4F),$04			; $7327 - InAirCounter
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	
GetMapAddressAndChar:			; gets the character at HL = y/x - returns HL address in Level buffer and A is that character
	PUSH DE
	PUSH BC
	EX   DE,HL
	LD   HL,LevelBuffer
	LD   A,D
	AND  $F8
	LD   B,$00
	SLA  A
	RL   B
	SLA  A
	RL   B
	LD   C,A
	ADD  HL,BC
	LD   B,$00
	LD   C,E
	SRL  C
	SRL  C
	SRL  C
	ADD  HL,BC
	LD   A,(HL)
	POP  BC
	POP  DE
	RET 
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CollidePlayerAndHen:			; de = hen to check's y,x
	PUSH HL
	LD   HL,PlayerX
	LD   A,E
	ADD  A,$01
	JR   C,NoOverlap

	ADD  A,$04
	CP   (HL)					; player x
	JR   C,NoOverlap			; hen x + 5 < player x

	SUB  $0D
	JR   NC,ContinueOverlap

	XOR  A

ContinueOverlap:
	CP   (HL)					; player x
	JR   NC,NoOverlap			; hen - 8 < player x
	
	INC  HL
	LD   A,D					; hen y
	CP   (HL)					; player y
	JR   NC,NoOverlap
	
	ADD  A,$1C
	CP   (HL)					; player y
	JR   C,NoOverlap
	
	LD   A,$01					; flag A = 1 - the player and hen overlap
	POP  HL
	RET 

NoOverlap:
	XOR  A
	POP  HL
	RET 
	
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TryClimbLadder:
	LD   IX,PlayerX
	LD   A,(IX+$00)			; xpos
	AND  $07
	RET  NZ

	LD   HL,(PlayerX)			; get y/x of player
	INC  H
	EX   DE,HL
	LD   HL,LevelBuffer
	LD   B,$00
	LD   A,D			; d=y
	AND  $F8
	SLA  A
	RL   B
	SLA  A
	RL   B
	LD   C,A
	ADD  HL,BC
	LD   B,$00
	LD   C,E			; e=x
	SRL  C
	SRL  C
	SRL  C
	ADD  HL,BC
	LD   A,(HL)				; character at x/y
	DEC  A
	JR   NZ,TryPushingDown

	LD   A,(UpPort)			; character 1 - left side of the ladder
	IN   A,($FE)
	AND  $1F
	LD   C,A
	LD   A,(UpBitmask)
	OR   C
	CP   $1F
	JR   Z,TryPushingDown

	LD   (IX+$03),$0D			; PlayerDirection = $0d = climbing
	INC  (IX+$01)				; PlayerY++
	LD   A,(PlayerY)
	AND  $03
	JR   NZ,NoClimbSound
	LD   HL,$1E14			; climbing sound on PlayerY mod 4
	CALL PlaySquareWave
NoClimbSound:
	JR   NoClimbSound2

TryPushingDown:
	LD   BC,$0040
	AND  A
	SBC  HL,BC
	LD   BC,$0020
	LD   A,D				; a=y
	AND  $07
	JR   NZ,GetCharacter

	SBC  HL,BC			; look at character above
GetCharacter:
	LD   A,(HL)			; get character at x/y
	DEC  A
	JR   NZ,NotPushingDown
	
	LD   A,(DownPort)			; character == 1 - left side of ladder
	IN   A,($FE)
	AND  $1F
	LD   C,A
	LD   A,(DownBitmask)
	OR   C
	CP   $1F
	JR   Z,NotPushingDown
	
	LD   (IX+$03),$0D			; PlayerDirection = $0d = climbing
	DEC  (IX+$01)				; PlayerY--
	LD   A,(PlayerY)
	AND  $03
	JR   NZ,NoClimbSound2

	LD   HL,$1E15
	CALL PlaySquareWave
NoClimbSound2:
	LD   A,(IX+$02)			; PlayerAnimFrame
	INC  A					; cycle through 4 anim frames
	AND  $03
	LD   (IX+$02),A			; PlayerAnimFrame
	LD   (IX+$4D),$00		; PlayerInAir = 0 = not in air

NotPushingDown:
	LD   HL,(PlayerX)
	LD   A,(IX+$02)			; PlayerAnimFrame
	ADD  A,(IX+$03)			; +PlayerDirection
	CALL DrawSpriteNum
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TryMovingLeftRight:
	LD   A,(PlayerY)
	INC  A
	AND  $07
	RET  NZ				; only check when player y is on a character boundary

	LD   HL,(PlayerX)
	EX   DE,HL			; de = player y/x
	LD   HL,LevelBuffer
	LD   A,D
	AND  $F8
	LD   B,$00
	SLA  A
	RL   B
	SLA  A
	RL   B
	LD   C,A
	ADD  HL,BC
	LD   B,$00
	LD   C,E
	SRL  C
	SRL  C
	SRL  C
	ADD  HL,BC
	LD   BC,$0020

	LD   A,(LeftPort)
	IN   A,($FE)
	AND  $1F
	LD   D,A
	LD   A,(LeftBitmask)
	OR   D
	CP   $1F
	JR   Z,NotLeft
	
	DEC  HL				; check character to left of player
	LD   A,(HL)
	CP   TILE_PLATFORM	; $05 platform Tile
	RET  NC

	AND  A
	SBC  HL,BC			; move up a row in the map
	LD   A,(HL)
	CP   TILE_PLATFORM	;$05 platform tile
	RET  NC

	AND  A
	SBC  HL,BC			; move up one more row in the map
	LD   A,(HL)
	AND  A
	RET  Z				; return if there's nothing there

	CP   TILE_LAST		; $09 any higher and we're touching the chars for the score line! 
	RET  NC

	LD   A,$04			; player direction left
	LD   (PlayerDirection),A
	RET 

NotLeft:
	LD   A,(RightPort)
	IN   A,($FE)
	AND  $1F
	LD   D,A
	LD   A,(RightBitmask)
	OR   D
	CP   $1F
	RET  Z				; not right pressed

	INC  HL
	INC  HL				; check to the right of the player
	LD   A,(HL)
	CP   TILE_PLATFORM	;$05 platform tile
	RET  NC

	AND  A
	SBC  HL,BC			; move up one row in the map
	LD   A,(HL)
	CP   TILE_PLATFORM	;$05 platform tile
	RET  NC

	AND  A
	SBC  HL,BC			; move up one more row in the map
	LD   A,(HL)
	AND  A
	RET  Z			; return if there's nothing there
	
	CP   TILE_LAST	; $09
	RET  NC

	XOR  A			; player direction = right
	LD   (PlayerDirection),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

UpdateAndDrawLifts:
	LD   A,(LiftsActive)
	XOR  $FF
	RET  Z

	LD   IX,PlayerX
	LD   HL,(Lift1ScreenPos)
	LD   C,$00
	CALL DrawLift

	LD   A,(Lift1YPos)
	INC  A
	CP   $A6
	JR   C,NoLiftReset

	LD   HL,LiftReset1
	LD   BC,$0004
	LD   DE,Lift1ScreenPos
	LDIR

	LD   A,$03

NoLiftReset:
	LD   (Lift1YPos),A
	LD   HL,(Lift1ScreenPos)
	CALL UpdateLiftPosition

	LD   (Lift1ScreenPos),HL
	LD   C,$FF
	CALL DrawLift

	LD   HL,(Lift2ScreenPos)
	LD   C,$00
	CALL DrawLift

	LD   A,(Lift2YPos)
	INC  A
	CP   $A6
	JR   C,NoLiftReset2

	LD   HL,LiftReset1
	LD   BC,$0003
	LD   DE,Lift2ScreenPos
	LDIR

	LD   A,$03
NoLiftReset2:
	LD   (Lift2YPos),A
	LD   HL,(Lift2ScreenPos)
	CALL UpdateLiftPosition

	LD   (Lift2ScreenPos),HL
	LD   C,$FF
	CALL DrawLift
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawLift:				; HL = Lift1ScreenPos or Lift2ScreenPos, C = byte to draw
	PUSH HL
	DEC  HL
	LD   (HL),$00		; LiftScreenPos
	INC  HL
	INC  HL
	INC  HL
	LD   A,L
	AND  $1F
	JR   Z,Skip

	LD   (HL),$00		; LiftScreenPos+1

Skip:
	POP  HL
	LD   B,$04			; 4 pixels high

LiftDrawLoop:
	LD   (HL),C			; LiftScreenPos
	INC  L
	LD   (HL),C			; LiftScreenPos+1
	DEC  L
	CALL MoveLineDown
	DJNZ LiftDrawLoop
	RET 

MoveLineDown:
	INC  H
	LD   A,H
	AND  $07
	RET  NZ
	
	LD   A,H
	SUB  $08
	LD   H,A
	LD   A,L
	ADD  A,$20
	LD   L,A
	RET  NC
	
	LD   A,H
	ADD  A,$08
	LD   H,A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

UpdateLiftPosition:			; update screen line to the next line above
	DEC  H
	LD   A,H
	AND  $07
	CP   $07
	JR   NZ,UpdateDone
	
	LD   A,H
	ADD  A,$08
	LD   H,A
	LD   A,L
	SUB  $20
	LD   L,A
	JR   NC,UpdateDone
	
	LD   A,H
	SUB  $08
	LD   H,A
UpdateDone:
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

MoveMotherDuck:
	LD   IX,PlayerX
	LD   A,(MotherDuckX)
	CP   (IX+$00)
	JR   Z,TryAlignDuckY
	JR   C,DuckRight

	LD   A,(MotherDuckXVel)
	DEC  A
	CP   $FA
	JR   NZ,NotMax

	INC  A
NotMax:
	JR   SetDuckXVel

DuckRight:
	LD   A,(MotherDuckXVel)
	INC  A
	CP   $06
	JR   NZ,SetDuckXVel

	DEC  A
SetDuckXVel:
	LD   (MotherDuckXVel),A

TryAlignDuckY:
	LD   A,(MotherDuckY)
	CP   (IX+$01)
	JR   Z,DrawMotherDuck
	JR   C,DuckUp

	LD   A,(MotherDuckYVel)
	DEC  A
	CP   $FA
	JR   NZ,NotMax2

	INC  A
NotMax2:
	JR   SetDuckYVel

DuckUp:
	LD   A,(MotherDuckYVel)
	INC  A
	CP   $06
	JR   NZ,SetDuckYVel

	DEC  A
SetDuckYVel:
	LD   (MotherDuckYVel),A

DrawMotherDuck:
	LD   HL,(MotherDuckX)
	LD   A,$0C				; clear part of cage containing MotherDuck
	CALL DrawSpriteNum
	CALL ResetTileColours
	LD   A,(MotherDuckX)
	BIT  7,(IX+$72)			; $734a - MotherDuckXVel
	JR   NZ,IsNeg

	ADD  A,(IX+$72)
	CP   $EE
	JR   C,SetDuckX

	SUB  (IX+$72)			; reached edge flip velocity to move away
	SUB  (IX+$72)
	LD   (IX+$72),$FB		; -5
	JR   SetDuckX

IsNeg:
	ADD  A,(IX+$72)
	JR   C,SetDuckX

	SUB  (IX+$72)
	SUB  (IX+$72)
	LD   (IX+$72),$05		; reached edge flip velocity to move away

SetDuckX:
	LD   (MotherDuckX),A
	LD   A,(MotherDuckY)
	ADD  A,(IX+$73)			; $734b - MotherDuckYVel
	CP   $A6
	JR   C,NotBottom

	SUB  (IX+$73)
	SUB  (IX+$73)
	LD   (IX+$73),$FB			; -5
	JR   SetDuckY

NotBottom:
	CP   $14
	JR   NC,SetDuckY

	SUB  (IX+$73)
	SUB  (IX+$73)
	LD   (IX+$73),$05			; +5
SetDuckY:
	LD   (MotherDuckY),A
	LD   A,(CurrentLevel)
	CP   $08
	JR   NC,SetMotherDuckPos

	LD   HL,$9808			; level 8 or less plant MotherDuck in the cage
	LD   (MotherDuckX),HL

SetMotherDuckPos:
	LD   HL,(MotherDuckX)
	LD   C,$08				; Mother Duck facing right
	LD   A,(PlayerX)
	CP   (IX+$70)			; $7348 - MotherDuckX
	JR   NC,DrawDuck

	LD   C,$0A				; MotherDuck facing left
DrawDuck:
	LD   A,C
	ADD  A,(IX+$75)			; $734d - MotherDuckFrame
	CALL DrawSpriteNum
	LD   A,(MotherDuckFrame)
	XOR  $01
	LD   (MotherDuckFrame),A
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DecreaseTimerOrBonus:			; b == 0 = timer update. b == 1 = bonus update
	LD   HL,Bonus+2
	LD   DE,$0003
	INC  B
	DEC  B
	JR   Z,UpdateValues

	ADD  HL,DE			; move to the timer values
UpdateValues:
	LD   A,$FF
	LD   D,$03
DecLoop1:
	DEC  (HL)
	CP   (HL)
	JR   NZ,DoneDec

	DEC  D
	JR   NZ,ResetDigit

	POP  HL
	INC  B
	DEC  B
	RET  NZ
	PUSH HL
	LD   HL,TimerRunning
	LD   (HL),$00
	RET 

ResetDigit:
	LD   (HL),$09
	DEC  HL
	JR   DecLoop1

DoneDec:
	LD   DE,$000A
	LD   HL,$4053		; screen pos
	INC  B
	DEC  B
	JR   Z,Skip2

	ADD  HL,DE			; adjust screen pos
Skip2:
	EX   DE,HL
	LD   HL,Bonus		; bonus text
	INC  B
	DEC  B
	JR   Z,DrawBonus

	INC  HL				; move to time text
	INC  HL
	INC  HL

DrawBonus:
	PUSH HL
	POP  BC
	LD   IXL,$03

NextDigit:
	PUSH DE
	LD   A,(BC)
	SLA  A
	SLA  A
	SLA  A
	LD   HL,gfx_LevelNumbers			; level number graphics
	PUSH BC
	LD   B,$00
	LD   C,A
	ADD  HL,BC
	LD   B,$08

DrawCharLp:
	LD   A,(HL)
	LD   (DE),A
	INC  D
	INC  L
	DJNZ DrawCharLp

	POP  BC
	POP  DE
	INC  DE
	INC  BC
	DEC  IXL
	JR   NZ,NextDigit
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CollidePlayerToWorld:
	LD   A,(SoundTimer)
	DEC  A
	JR   Z,InAirChecks

	LD   A,(PlayerInAir)
	DEC  A
	JP   NZ,NotInAir
	RET 

InAirChecks:					; collide with screen edges, lifts and then onto tilemap
	LD   HL,(PlayerX)
	CALL ResetTileColours
	LD   A,L					; a=x
	ADD  A,(IX+$4E)				; PlayerJumpDirection
	LD   (PlayerX),A
	AND  A
	JR   NZ,NotHitLeftEdge

	LD   (IX+$4E),$01			; PlayerJumpDirection = 1 (right)
	JR   NotHitRightEdge

NotHitLeftEdge:
	CP   $EE
	JR   C,NotHitRightEdge

	LD   (IX+$4E),$FF			; PlayerJumpDirection = $ff (left)

NotHitRightEdge:

	LD   HL,Lift1YPos			; try colliding with lifts
	CALL CollideWithLift

	LD   HL,Lift2YPos
	CALL CollideWithLift

	JR   CollideWithWorld		; now do collision with the tile map

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CollideWithLift:
	LD   A,(LiftsActive)
	XOR  $FF
	RET  Z

	XOR  $FF
	SUB  $09
	LD   B,A
	LD   A,(PlayerX)
	CP   B
	RET  C
	
	SUB  $13
	CP   B
	RET  NC
	
	LD   B,$06
	LD   A,(HL)
	ADD  A,$10

CheckYLoop:
	DEC  A
	CP   (IX+$01)			; PlayerY
	JR   Z,OnLift
	
	DJNZ CheckYLoop
	RET 

OnLift:
	LD   (IX+$7D),$01			; PlayerOnLift
	LD   (IX+$4D),$00			; PlayerInAir = 0 on ground/lift
	EX   DE,HL
	LD   HL,(PlayerX)
	LD   A,$0C
	CALL DrawSpriteNum
	LD   A,(DE)
	ADD  A,$11
	LD   (PlayerY),A
	POP  HL
	CALL SayRandomWord
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CollideWithWorld:
	LD   A,(PlayerInAir)
	DEC  A
	JR   NZ,NotInAir

	DEC  (IX+$4F)			; $7327 - InAirCounter
	JR   NZ,BounceWhileInAir

	LD   HL,PlayerInAir			; start fall
	LD   (HL),$02				; set to "in air"
	INC  HL
	LD   (HL),$00				; PlayerJumpDirection (0=right)
	INC  HL
	LD   (HL),$FA				; $7327 - InAirCounter
	LD   (IX+$52),$FF			; PlayerAirDirection ($ff=down)
	LD   A,(PlayerAnimFrame)
	CALL DrawPlayer
	RET 

NotInAir:
	LD   HL,FallingCounter
	DEC  (HL)
	RET  NZ

	PUSH HL
	LD   HL,(PlayerX)
	CALL ResetTileColours
	POP  HL
	
	LD   A,(PlayerAirDirection)
	DEC  A
	JR   Z,GoingUp
	
	INC  A
	AND  A
	JR   NZ,IsFalling

SetToFall:
	LD   (IX+$52),$FF			; PlayerAirDirection ($ff = down)
	LD   A,$FA
	JR   NotJumpApex

IsFalling:
	LD   A,(InAirCounter)
	SUB  $0A
	CP   $28
	JR   NC,NoClamp2
	
	LD   A,$28
NoClamp2:
	JR   NotJumpApex

GoingUp:
	LD   A,(PlayerY)
	CP   $A7
	JR   C,TestApex
	
	INC  (IX+$01)				; PlayerY
	JR   SetToFall

TestApex:
	LD   A,(InAirCounter)
	ADD  A,$0A
	CP   $04
	JR   NZ,NotJumpApex

	LD   (IX+$52),$00			; PlayerAirDirection
	XOR  A
NotJumpApex:
	LD   (InAirCounter),A
	LD   (HL),A					; $7328 - FallingCounter
	LD   A,(PlayerY)
	ADD  A,(IX+$52)				; PlayerAirDirection
	CP   $10
	JR   NC,SetPlayerY

	if DISABLE_COLLISION == 0
		POP  HL
		POP  HL
		RET 
	ELSE
		LD   (IX+$4D),$00			; PlayerInAir (0=on ground)
		LD   HL,PlayerDirection
		LD   (HL),0
		RET 
	ENDIF

SetPlayerY:
	LD   (PlayerY),A

BounceWhileInAir:
	LD   A,$01			; frame num
	CALL DrawPlayer

	CALL GetMapAddressAndChar
	LD   BC,$003F
	AND  A
	SBC  HL,BC
	LD   A,(PlayerAirDirection)
	DEC  A
	JR   Z,CheckBelow

	LD   A,(PlayerJumpDirection)
	AND  A
	JR   Z,CheckBelow

	DEC  A
	JR   Z,GoingRight

	LD   A,(PlayerX)			; going left
	AND  $07
	CP   $04
	JR   NC,CheckBelow

	DEC  HL
	LD   A,(HL)					; tile to the left
	INC  HL
	CP   TILE_PLATFORM			;$05 FLOOR_TILE
	JR   NZ,CheckBelow

	JR   BounceOffFloor			; hitting a floor edge to the left/right of you, mid fall/jump

GoingRight:
	LD   A,(PlayerX)
	AND  $07
	CP   $03
	JR   C,CheckBelow

	INC  HL
	LD   A,(HL)
	DEC  HL
	CP   TILE_PLATFORM			; $05
	JR   NZ,CheckBelow

BounceOffFloor:
	LD   A,(PlayerJumpDirection)			; flip player's jump direction
	XOR  $FE
	LD   (PlayerJumpDirection),A

CheckBelow:
	LD   A,(HL)			; tile beneath feet
	AND  A
	RET  Z				; nothing below
	
	CP   TILE_PLATFORM	; $05 FLOOR_TILE
	JR   Z,LandedOnFloor

	CP   TILE_EGG		; $03 EGG_TILE
	RET  NC
	DEC  HL				; tile to the left
	DEC  A
	JR   Z,WasLadder

	INC  HL				; tile to the right
	INC  HL
WasLadder:
	LD   A,(HL)
	CP   TILE_PLATFORM	;$05 FLOOR_TILE
	RET  NZ

LandedOnFloor:
	LD   A,(PlayerY)			; move until we're snapped to a y char boundary
	INC  A
	AND  $07
	RET  NZ

	LD   (IX+$4D),$00			; PlayerInAir (0=on ground)
	LD   HL,PlayerDirection
	LD   A,(HL)
	CP   $0D
	RET  NZ						; not climbing

	LD   (HL),$00				; no direction
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DrawPlayer:
	LD   HL,(PlayerX)
	ADD  A,(IX+$03)			; PlayerDirection
	CALL DrawSpriteNum
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SayRandomWord:
	LD   A,R
	AND  $07
	INC  A
	LD   B,A
	LD   HL,SpeechTable-1			; SpeechTable-1
PickWord:
	INC  HL
	DJNZ PickWord

	LD   A,(HL)
	JP   PlayFullerOrator

SpeechTable:
	db $04
	db $06
	db $09
	db $0D
	db $12
	db $16
	db $04
	db $0D
	db $C9
	db $4F
	db $04
	db $C9
	db $00
	db $00

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

AddToScore:
	LD   A,B
	AND  A
	JR   Z,PrintScore

	LD   A,$0A
AddLoop:
	LD   HL,CurrentPlayerScore+4		;$6ECC
BumpDigit:
	INC  (HL)
	CP   (HL)							; 10
	JR   NZ,NextDig

	LD   (HL),$00
	DEC  HL
	JR   BumpDigit

NextDig:
	DJNZ AddLoop

	LD   HL,LastDigitValue
	LD   A,(CurrentPlayerScore+1)
	CP   (HL)
	JR   Z,PrintScore

	LD   (HL),A

	LD   A,(CurrentPlayer)
	ADD  A,low (P1Lives-1)		;$EF
	LD   H,high (P1Lives-1)		;$6E
	LD   L,A
	LD   C,(HL)
	INC  (HL)
	SUB  $EF
	LD   B,A
	LD   A,C
	CP   $06
	JR   NC,PrintScore

	LD   A,$FD
.Loop:
	ADD  A,$07
	DJNZ .Loop

	ADD  A,C
	LD   L,A
	LD   H,$16
	LD   A,$B6
	CALL PrintCharacter

PrintScore:
	LD   DE,(ScoreScreenPos)
	LD   BC,CurrentPlayerScore
	LD   IXL,$06

NextNumber:
	PUSH DE
	LD   A,(BC)
	SLA  A
	SLA  A
	SLA  A
	PUSH BC
	ADD  A,low gfx_CharacterSetNumbers		;$70
	LD   H,high gfx_CharacterSetNumbers		;$86
	LD   L,A
	LD   B,$08

DigitLoop:
	LD   A,(HL)
	LD   (DE),A
	INC  D
	INC  L
	DJNZ DigitLoop

	POP  BC
	POP  DE
	INC  DE
	INC  BC
	DEC  IXL
	JR   NZ,NextNumber

	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Start:
	DI
	LD 	 SP,$6000
	XOR	 A
	OUT  (254),A

	LD HL,$5DC0				; loader sets these up for use by the music routine	
	LD (ROM_STKBOT),HL		; which uses the ROM FP calculator stack
	LD (ROM_STKEND),HL	

	LD   HL,FrontEndMode
	LD   (HL),$06			; GAMESTATE_INTROMUSIC

	LD   HL,MusicFlag

	IF DISABLE_MUSIC == 1
	LD   (HL),$01			; MUSIC_STOP
	ELSE
	LD   (HL),$00			; MUSIC_PLAY
	ENDIF

	LD   A,$B2				; $b200 page for ISR.  Contains 256 $9c bytes
	LD   I,A				; thus pointing the ISR service address to $9c9c
	IM   2

	EI

FrontEnd:
	CALL ClearScreen
	LD   H,$02
	LD   BC,TitleText

NextTitleLine:
	LD   L,$00
TextLoop:
	LD   A,(BC)
	CALL PrintCharacter
	INC  BC
	INC  L
	LD   A,L
	CP   $0E			; 14 chars wide
	JR   NZ,TextLoop

	INC  H
	LD   A,H
	CP   $18			; 24 lines
	JR   NZ,NextTitleLine
	
	CALL PrintHighScoreTable
	
	LD   HL,$5800
	LD   B,$0E
	LD   C,$04
	LD   A,$03
	CALL FillBuffer
	LD   C,$07
	LD   A,$06
	CALL FillBuffer
	LD   C,$0A
	LD   A,$04
	CALL FillBuffer

	LD   HL,TitleMusic
	LD   A,(MusicFlag)
	AND  A
	JR   NZ,SkipMusic
	
	CALL PlayMusic			; play music
	
	LD   A,$14
	CALL PlayFullerOrator	; play speech
	LD   A,$01				; finished playing music
	LD   (MusicFlag),A

SkipMusic:
	
	LD   HL,$5AE0			; attribute memory
	LD   B,$20				; 32 wide
SetAttrLp:
	LD   (HL),$05
	INC  HL
	DJNZ SetAttrLp

	LD   HL,ScrollIndex
	LD   (HL),$4E

FrontEndLoop:
	LD   HL,$50E1			; Screen position of scrolling line
	CALL ScrollLine
	LD   BC,$01F4
	CALL DelayBC
	LD   HL,ScrollCounter
	DEC  (HL)				; scroll for 8 pixels
	JR   NZ,TestKeys

	LD   (HL),$08			; reset scroll counter
	LD   HL,ScrollingText
	LD   A,(ScrollIndex)
	INC  A					; next character in scrolling message
	CP   $4E				; length of scroll text
	JR   C,SetScrollIndex
	
	XOR  A
SetScrollIndex:
	LD   (ScrollIndex),A	; get character index into scrolling message
	LD   E,A
	LD   D,$00
	ADD  HL,DE
	LD   A,(HL)
	LD   HL,$001E
	CALL PrintCharacter

TestKeys:
	LD   A,$FD
	IN   A,($FE)
	BIT  1,A				; "S"
	JP   Z,PressStart

	LD   A,$FB
	IN   A,($FE)
	BIT  3,A				; "R"
	JP   Z,RedefineKeys

	LD   A,$DF
	IN   A,($FE)
	BIT  2,A				; "I"
	JR   Z,ShowInstructions

	JP   FrontEndLoop

;
;
;

ShowInstructions:
	CALL ClearScreen
	LD   H,$03
	LD   BC,InstructionsText			;$8390

.NextLine:
	LD   L,$00
.NextChar:
	LD   A,(BC)
	CALL PrintCharacter
	INC  BC
	INC  L
	LD   A,L
	CP   $20
	JR   NZ,.NextChar

	INC  H
	INC  H
	LD   A,H
	CP   $19
	JR   NZ,.NextLine

	LD   HL,$5800			; address to fill
	LD   B,$20				; width to fill
	LD   C,$06				; height to fill
	LD   A,$05				; value to fill
	CALL FillBuffer

	LD   C,$09
	LD   A,$17
	CALL FillBuffer

	LD   C,$06
	LD   A,$05
	CALL FillBuffer

	LD   C,$03
	LD   A,$04
	CALL FillBuffer

	LD   HL,ScrollIndex
	LD   (HL),$57
	INC  HL
	LD   (HL),$0A			; FrontEndState

	CALL WaitForSpeech
	LD   A,$18
	CALL PlayFullerOrator

InstrScrollLoop:
	LD   HL,$50E1
	CALL ScrollLine
	LD   BC,$01F4
	CALL DelayBC
	LD   HL,ScrollCounter
	DEC  (HL)
	JR   NZ,.TestKeys

	LD   (HL),$08
	LD   HL,InstructionsScrollText			;$ACCA
	LD   A,(ScrollIndex)
	INC  A
	CP   $57
	JR   C,.NoWrap

	XOR  A
.NoWrap:
	LD   (ScrollIndex),A
	LD   E,A
	LD   D,$00
	ADD  HL,DE
	LD   A,(HL)
	LD   HL,$001E
	CALL PrintCharacter

.TestKeys:
	LD   A,(SpeechPlaying)
	XOR  $FF
	JR   NZ,NoStart			; can't start the game if we're talking

	LD   A,$FD
	IN   A,($FE)
	BIT  1,A
	JP   Z,PressStart

NoStart:
	LD   A,$FB
	IN   A,($FE)
	BIT  3,A
	JP   Z,RedefineKeys
	
	LD   A,$F7				; 1,2,3,4 keys
	IN   A,($FE)
	AND  $07				; only worry about 1,2,3
	CP   $07
	JR   Z,NoNumberPress
	
	LD   B,A				;0-7
	LD   A,(FrontEndMode)
	CP   B
	JR   Z,NoNumberPress
	
	LD   HL,$5980			; which selected line to flash
	CP   $05
	JR   Z,SetLine1
	
	LD   HL,$59C0
	JR   C,SetLine1
	
	LD   HL,$5940
SetLine1:
	LD   A,B
	LD   (FrontEndMode),A
	CP   $05
	LD   DE,$5980
	JR   Z,SetLine2
	
	LD   DE,$59C0
	JR   C,SetLine2
	
	LD   DE,$5940
SetLine2:
	LD   B,$20
	LD   A,$97
SetLineAttrs:
	LD   (HL),$17
	LD   (DE),A
	INC  HL
	INC  DE
	DJNZ SetLineAttrs

NoNumberPress:
	JP   InstrScrollLoop

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PressStart:
	LD   IXH,$02				; colour pulse
	CALL DoAttributeSquarePulse

	LD   HL,$4000
	LD   BC,$1800
ClrLoop:
	LD   (HL),$00
	INC  HL
	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,ClrLoop

	LD   IXH,$01				; black pulse
	CALL DoAttributeSquarePulse

	LD   C,$E8
	LD   DE,NumberOfPlayersScrollText
	LD   B,$01
NextChar:
	DJNZ NextScroll

	LD   A,(DE)
	INC  DE
	LD   HL,$0C1E
	CALL PrintCharacter
	LD   B,$08
NextScroll:
	LD   HL,$4861			; screen position
	CALL ScrollLine
	DEC  C
	JR   NZ,NextChar

Wait1234:					; wait for 1,2,3 or 4 to be pressed
	LD   A,$F7
	IN   A,($FE)
	AND  $0F
	CP   $0F
	JR   Z,Wait1234
	LD   B,$00

NumPlayerLp:
	INC  B
	SRL  A
	JR   C,NumPlayerLp

	LD   L,B
	LD   H,$01
	LD   (NumberOfPlayers),HL
	LD   B,$F0
ScrollOff:
	LD   HL,$4861				; screen position
	CALL ScrollLine
	DJNZ ScrollOff

	LD   A,$05
	LD   DE,LevelBuffer			; copy level 1 map into all five player's levelbuffers
CopyLevel1:
	LD   BC,LEVEL_SIZE			;$02A0
	LD   HL,Level1
	LDIR
	DEC  A
	JR   NZ,CopyLevel1

	LD   HL,CurrentPlayerScore
	LD   B,$1E
ScoreClear:
	LD   (HL),$00
	INC  HL
	DJNZ ScoreClear

	LD   B,$05
EggsSet:
	IF ONLY_ONE_EGG == 1
		LD   (HL),$01			; !CHEAT! just 1 egg to collect
	ELSE
		LD   (HL),$0C			; 12 eggs to collect
	ENDIF
	INC  HL
	DJNZ EggsSet

	LD   B,$05
LevelSet:
	LD   (HL),$00			; level 0
	INC  HL
	DJNZ LevelSet

	LD   B,$04
LivesSet:
	LD   (HL),$05			; 5 lives
	INC  HL
	DJNZ LivesSet

	LD   HL,$9F9E			; "01"
	LD   (LevelDig1),HL
	CALL WaitForSpeech

NextPlayerPlayLevel:
	LD   A,(NumberOfPlayers)
	DEC  A
	JR   Z,OnePlayer

	LD   A,(CurrentPlayer)
	ADD  A,$19
	CALL PlayFullerOrator

	LD   BC,Player1ScrollText
	LD   A,(CurrentPlayer)
	ADD  A,$30
	LD   (PlayerNumText),A			; modify player number in string
	LD   C,$08
	LD   DE,Player1ScrollText
	CALL ScrollTextLine
	LD   BC,$0000
	CALL DelayBC

OnePlayer:

	CALL PlayLevel					; Play a level of the game

	CALL WaitForSpeech
	LD   BC,$0006
	LD   HL,CurrentPlayerScore
	LD   A,(CurrentPlayer)
GetPlayerScore:
	ADD  HL,BC
	DEC  A
	JR   NZ,GetPlayerScore

	EX   DE,HL
	LD   HL,CurrentPlayerScore
	LDIR							; copy in this player's score

	IM   2
	LD   A,(EggsRemaining)
	AND  A
	JP   NZ,LoseLife

LevelCompleted:
	LD   A,(TimerRunning)
	AND  A
	JR   Z,BonusDone

	LD   B,$00
	CALL DecreaseTimerOrBonus		; add time remaining to score
	LD   B,$01
	CALL AddToScore
	LD   HL,$1E04
	CALL PlaySquareWave
	JR   LevelCompleted

BonusDone:
	LD   D,$02
BigWait:
	LD   BC,$0000
	CALL DelayBC
	DEC  D
	JR   NZ,BigWait

	CALL FourAttributePulses

	LD   BC,$0006
	LD   HL,CurrentPlayerScore 	;$6EC8
	LD   A,(CurrentPlayer)
.Loop:
	ADD  HL,BC
	DEC  A
	JR   NZ,.Loop

	EX   DE,HL					; copy current player's score into this player's score
	LD   HL,CurrentPlayerScore	;$6EC8
	LDIR

	LD   HL,CurrentLevel		;$6EEB
	INC  (HL)
	LD   A,(HL)
	INC  A
	CP   $C8
	JR   C,.NoWrap

	SUB  $C8
	JR   .NoWrap2

.NoWrap:
	CP   $64
	JR   C,.NoWrap2

	SUB  $64
.NoWrap2:
	LD   B,$00
.RepeatSub:
	SUB  $0A
	JR   C,.Done
	INC  B
	JR   .RepeatSub

.Done:
	ADD  A,$A8
	LD   (LevelDig2),A				;modify digit 2 in scroll text
	LD   A,B
	AND  A
	JR   Z,.Skip
	ADD  A,$9E
.Skip:
	LD   (LevelDig1),A				;modify digit 1 in scroll text

	LD   DE,LevelScrollText
	LD   C,$08
	CALL ScrollTextLine

	LD   DE,LevelBuffer
	LD   BC,LEVEL_SIZE				;$02A0
	LD   HL,Level1-LEVEL_SIZE		;$B110
	LD   A,(CurrentLevel)
	AND  $07
	INC  A

.Loop2:
	ADD  HL,BC
	DEC  A
	JR   NZ,.Loop2
	LDIR							; copy next level into LevelBuffer

	IF ONLY_ONE_EGG == 1
		LD   A,$01					; !CHEAT! just 1 egg to collect 
	ELSE
		LD   A,$0C					; 12 eggs to collect 
	ENDIF
	LD   (EggsRemaining),A
	JP   OnePlayer

;
;
;

LoseLife:
	LD   HL,LoseLifeMusic
	CALL PlayMusic
	CALL PlayGameOverSpeech
	CALL WaitForSpeech

	LD   BC,$0000
	CALL DelayBC
	CALL ClearScreen
	LD   HL,TimeRemaining
	LD   A,(HL)
	CP   $FF
	JR   NZ,NoTimeOut

	INC  HL
	LD   A,$09
	CP   (HL)
	JR   NZ,NoTimeOut

	INC  HL
	CP   (HL)
	JR   NZ,NoTimeOut

	LD   DE,OutOfTimeScrollText
	LD   C,$0D
	CALL ScrollTextLine

NoTimeOut:
	LD   HL,LevelBuffer
	LD   BC,LEVEL_SIZE			;$02A0
	PUSH HL
	POP  DE
	LD   A,(CurrentPlayer)

GetLevLoop:
	ADD  HL,BC
	DEC  A
	JR   NZ,GetLevLoop
	EX   DE,HL
	LDIR						; copy this player's level into the LevelBuffer

	LD   A,(CurrentPlayer)
	LD   E,A
	LD   D,$00

	LD   HL,EggsRemaining
	LD   A,(HL)
	ADD  HL,DE
	LD   (HL),A
	LD   HL,CurrentLevel
	LD   A,(HL)
	ADD  HL,DE
	LD   (HL),A

	LD   HL,P4Level
	ADD  HL,DE
	DEC  (HL)
	JR   NZ,LivesRemain

	LD   C,$12
	LD   A,(NumberOfPlayers)
	DEC  A
	JR   NZ,PlayersRemain
	
	LD   C,$09
PlayersRemain:
	LD   DE,GameOverScrollText
	CALL ScrollTextLine

LivesRemain:
	LD   B,$05
NextPlayer:
	LD   HL,(NumberOfPlayers)
	LD   A,H
	CP   L						; compare with CurrentPlayer
	JR   NZ,Skip1
	
	XOR  A
Skip1:
	INC  A
	LD   (CurrentPlayer),A
	LD   HL,P1Lives-1			; (p1Lives-1) - gets number of lives for current player 
	LD   E,A
	LD   D,$00
	ADD  HL,DE
	LD   A,(HL)
	AND  A
	JR   NZ,HasLivesRemaining
	
	DJNZ NextPlayer
	JR   CheckPlayersHighScores

HasLivesRemaining:
	LD   BC,$0004
	AND  A
	SBC  HL,BC
	LD   A,(HL)
	LD   (CurrentLevel),A
	INC  BC
	AND  A
	SBC  HL,BC
	LD   A,(HL)
	LD   (EggsRemaining),A
	LD   A,(CurrentPlayer)
	INC  BC
	LD   HL,CurrentPlayerScore

PlayerScoreLoop:
	ADD  HL,BC
	DEC  A
	JR   NZ,PlayerScoreLoop

	LD   DE,CurrentPlayerScore
	LDIR
	LD   A,(CurrentPlayer)
	LD   HL,LevelBuffer			; 673 bytes per level
	LD   BC,LEVEL_SIZE			; $02A0

PlayerLevelLoop:
	ADD  HL,BC
	DEC  A
	JR   NZ,PlayerLevelLoop

	LD   DE,LevelBuffer
	LDIR						; copy the player's level into the LevelBuffer
	JP   NextPlayerPlayLevel

;
;
;

CheckPlayersHighScores:
	LD   IXH,$02
	CALL DoAttributeSquarePulse
	LD   HL,$4000
	LD   BC,$0018
ClrLoop2:
	LD   (HL),$00
	INC  HL
	DJNZ ClrLoop2
	DEC  C
	JR   NZ,ClrLoop2
	
	LD   IXH,$01
	CALL DoAttributeSquarePulse

	LD   HL,P1Score					;
	LD   B,$18
ResetScores:
	LD   A,(HL)
	ADD  A,$30
	LD   (HL),A
	INC  HL
	DJNZ ResetScores

	LD   A,$01
	LD   HL,P1Score
CheckPlayersScore:
	ADD  A,$30
	LD   (PlayerNumText_1),A
	SUB  $30
	CALL CheckHighScore
	DEC  D
	JR   Z,.NextPlayer

	PUSH AF
	PUSH HL
	CALL FourAttributePulses
	POP  HL
	POP  AF

.NextPlayer:
	LD   DE,$0006
	ADD  HL,DE
	LD   IX,PlayerX
	CP   (IX+$62)			; NumberOfPlayers
	JP   Z,FrontEnd

	INC  A
	JR   CheckPlayersScore

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CheckHighScore:
	PUSH BC
	PUSH AF
	PUSH HL
	LD   B,$0A					; ten scores
	LD   DE,HighScores+10

TryNextScore:
	CALL CompareScore
	DEC  A
	JR   Z,InHighScoreTable

	LD   C,$10
NextScoreLp:
	INC  DE
	DEC  C
	JR   NZ,NextScoreLp

	DJNZ TryNextScore

	POP  HL
	POP  AF
	POP  BC
	LD   D,$01
	RET 

InHighScoreTable:
	LD   IXH,B
	LD   HL,TenthHighScore
	DEC  B
	JR   Z,InsertScore			; if it's the last score on the table

	LD   HL,$0000
	LD   DE,$0010
GetScoreAddr:
	ADD  HL,DE
	DJNZ GetScoreAddr

	PUSH HL
	POP  BC
	LD   DE,TenthHighScoreLastByte
	LD   HL,NinthHighScoreLastByte
	LDDR
	INC  HL

InsertScore:
	LD   B,$0A
BlankName:
	LD   (HL),$00
	INC  HL
	DJNZ BlankName

	LD   BC,$0006
	PUSH HL
	POP  DE
	POP  HL
	PUSH HL
	PUSH DE
	LDIR			; copy score into table

	LD   C,$0B
	LD   H,$17
	LD   DE,PlayerText

NextTxtLine:
	LD   L,$00
	LD   B,$0F

TxtLoop:
	LD   A,(DE)
	INC  DE
	CALL PrintCharacter
	INC  L
	DJNZ TxtLoop

	DEC  H
	DEC  H
	DEC  C
	JR   NZ,NextTxtLine

	CALL PrintHighScoreTable
	LD   HL,$5800
	LD   A,$03
	LD   B,$0F
	LD   C,$04
	CALL FillBuffer
	INC  A
	LD   C,$09
	CALL FillBuffer
	LD   A,$02
	CALL FillBuffer

	CALL WaitForSpeech
	LD   A,$07
	CALL PlayFullerOrator
	CALL WaitForSpeech

	POP  HL
	LD   BC,$000A
	AND  A
	SBC  HL,BC
	EX   DE,HL
	LD   A,IXH
	SLA  A
	INC  A
	LD   H,A
	IM   1						; interrupt mode 1 so we can get keys from the ROM routine
	EI 
	LD   L,$10

EnterNextChar:
	LD   A,$B7
	CALL PrintCharacter

KeyLoop:
	LD   A,(ROM_KSTATE)			; KSTATE
	XOR  $FF
	JR   NZ,KeyLoop

KeyLoop2:
	HALT
	LD   A,(ROM_KSTATE)
	XOR  $FF
	JR   Z,KeyLoop2

	LD   A,(ROM_LASTK)			; LASTK - last key pressed
	CP   $0D
	JR   Z,FinishedNameEntry	; enter

	CP   $0C					; delete?
	JR   NZ,DrawTheCharacter

	LD   A,L
	CP   $10
	JR   Z,KeyLoop2

	XOR  A						; delete a character
	DEC  DE
	LD   (DE),A
	CALL PrintCharacter
	DEC  L
	JR   EnterNextChar

DrawTheCharacter:
	CP   $20					; < 32
	JR   C,KeyLoop2
	LD   B,A
	LD   A,L
	CP   $19
	JR   Z,KeyLoop2
	LD   A,B
	LD   (DE),A
	CALL PrintCharacter
	INC  L
	INC  DE
	JR   EnterNextChar

FinishedNameEntry:
	POP  HL
	POP  AF
	POP  BC
	LD   D,$02
	IM   2
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SetAttributeSquare:
	PUSH AF
	PUSH HL
	PUSH BC
	PUSH DE
	PUSH HL
	POP  BC
	CALL GetScreenAddressDE
	EX   DE,HL
	LD   A,B
	SUB  H
	LD   B,H
	LD   H,A
	LD   A,C
	ADD  A,L
	LD   C,L
	LD   L,A
	CALL GetScreenAddressDE
	LD   A,(ScrollIndex)

FillHoriz:
	LD   (DE),A
	LD   (HL),A
	INC  DE
	DEC  HL
	DEC  C
	JR   NZ,FillHoriz

	LD   IXL,B
	LD   BC,$0020
FillVert:
	LD   (DE),A
	LD   (HL),A
	AND  A
	SBC  HL,BC
	EX   DE,HL
	ADD  HL,BC
	EX   DE,HL
	DEC  IXL
	JR   NZ,FillVert

	POP  DE
	POP  BC
	POP  HL
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DelayBC:
	PUSH AF
DelLp:
	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,DelLp

	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

DoAttributeSquarePulse:			; ixh == 0 black the squares, ixh=1 coloured sqaures, ixh=2 coloured squares
	LD   HL,$0C0B
	LD   DE,$0109
	LD   A,$12
	DEC  IXH
	JR   NZ,SetIndex
	
	LD   A,$03			; ixh ==0
SetIndex:
	INC  IXH
	LD   B,$0C
DoNextSquare:
	LD   (ScrollIndex),A
	CALL SetAttributeSquare
	PUSH BC
	LD   BC,$1388
	CALL DelayBC
	POP  BC
	INC  H
	DEC  L
	INC  D
	INC  D
	INC  E
	INC  E
	DEC  IXH
	JR   Z,NoReset
	
	ADD  A,$09
	CP   $30
	JR   C,NoReset
	
	LD   A,$12
NoReset:
	INC  IXH
	DJNZ DoNextSquare
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

WaitForSpeech:

	IF DISABLE_SPEECH == 1
	RET
	ENDIF

	LD   A,(SpeechPlaying)
	XOR  $FF
	JR   NZ,WaitForSpeech
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FourAttributePulses:
	LD   IXH,$00			; colour mode
	LD   HL,ScrollIndex
	LD   (HL),$09

DoPulse:
	LD   HL,$0605
	LD   D,$01

NextSquare:
	PUSH HL
	PUSH DE
	LD   E,D
	CALL SetAttributeSquare
	LD   A,$14
	ADD  A,L
	LD   L,A
	LD   A,$0C
	ADD  A,H
	LD   H,A
	CALL SetAttributeSquare
	LD   A,$08
	ADD  A,E
	LD   E,A
	LD   A,L
	SUB  $14
	LD   L,A
	LD   A,$08
	ADD  A,E
	CALL SetAttributeSquare
	LD   A,H
	SUB  $0C
	LD   H,A
	LD   A,$0C
	ADD  A,L
	LD   L,A
	CALL SetAttributeSquareBumpColour

	POP  DE
	POP  HL
	INC  E
	INC  E
	INC  D
	INC  D
	INC  H
	DEC  L
	LD   BC,$2710
	CALL DelayBC

	LD   A,L
	CP   $FF
	JR   NZ,NextSquare

	LD   BC,$1800			; clear the screen attributes
	LD   HL,$4000
ClrLp2:
	LD   (HL),$00
	INC  HL
	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,ClrLp2

	LD   A,IXH
	LD   IXH,$01			; blank out attr pulse mode
	LD   HL,ScrollIndex
	LD   (HL),$04
	AND  A
	JR   Z,DoPulse
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScrollTextLine:				; scroll a line of text onto screen in DE
	LD   HL,$5960			; attribute line
	LD   B,$80
SetCol:
	LD   (HL),$04			; green
	INC  HL
	DJNZ SetCol

	LD   B,$01
Scroll1Pixel:
	LD   HL,$4861			; screen line
	CALL ScrollLine
	DJNZ Scroll1Pixel

	LD   A,(DE)
	LD   HL,$0C1E			; y,x
	INC  DE
	CALL PrintCharacter
	LD   B,$08				; 8 pixels to scroll
	DEC  C
	JR   NZ,Scroll1Pixel

	LD   B,$00
ScrollLineOff:
	LD   HL,$4861			; screen line
	CALL ScrollLine
	DJNZ ScrollLineOff

	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SetAttributeSquareBumpColour:
	INC  IXH
	DEC  IXH
	JR   NZ,NoColChange

	LD   A,(ScrollIndex)
	ADD  A,$09
	LD   (ScrollIndex),A

NoColChange:
	CALL SetAttributeSquare
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CompareScore:
	PUSH BC
	PUSH DE
	PUSH HL
	LD   C,$01
	LD   B,$06			; 6 digits

NextScoreDigit:
	LD   A,(DE)
	INC  DE
	CP   (HL)
	INC  HL
	JR   C,PlayerScoreMore
	JR   NZ,PlayerScoreLess
	DJNZ NextScoreDigit

PlayerScoreLess:
	DEC  C
PlayerScoreMore:
	LD   A,C
	POP  HL
	POP  DE
	POP  BC
	RET 
GetScreenAddressDE:			; return screen address for y,x in DE with y=0 at bottom!
	PUSH DE
	PUSH BC
	EX   DE,HL
	LD   HL,$5B00			; start at the bottom of the screen
	LD   BC,$0020
	INC  D
Yloop:
	AND  A
	SBC  HL,BC
	DEC  D
	JR   NZ,Yloop

	ADD  HL,DE
	POP  BC
	POP  DE
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FillBuffer:			; fills a buffer (HL) with a stride of 32, b wide, c high with a
	PUSH BC
	LD   DE,$0020
FillHeight:
	PUSH BC
	PUSH HL
FillWidth:
	LD   (HL),A
	INC  HL
	DJNZ FillWidth

	POP  HL
	ADD  HL,DE
	POP  BC
	DEC  C
	JR   NZ,FillHeight

	POP  BC
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

RedefineKeys:
	CALL ClearScreen
	LD   HL,FrontEndMode
	LD   (HL),$03
	LD   HL,UserDefinedKeys
	LD   B,$0A

ResetKeys:
	LD   (HL),$00
	INC  HL
	DJNZ ResetKeys

	LD   HL,$1100
	LD   B,$20
	LD   DE,RedefineKeyText
RDKeyText:
	LD   A,(DE)
	CALL PrintCharacter
	INC  L
	INC  DE
	DJNZ RDKeyText

	LD   H,$0E
	LD   C,$05
NextRowLoop:
	LD   B,$0A
	LD   L,$0A

LineLoop:
	LD   A,(DE)
	CALL PrintCharacter
	INC  DE
	INC  L
	DJNZ LineLoop

	DEC  H
	DEC  H
	DEC  C
	JR   NZ,NextRowLoop

	LD   HL,$58C0			; attribute line
	LD   B,$20
AttrLoop:
	LD   (HL),$04
	INC  HL
	DJNZ AttrLoop

WaitForKey:
	CALL GetKeyPress
	LD   A,L
	AND  A
	JR   NZ,WaitForKey

	LD   A,$05
	LD   IX,UserDefinedKeys
	LD   HL,$592A
	LD   BC,InstructionTextKeys			;$83F6
	LD   DE,$0E16

RedefineNext:
	CALL RedefineKey
	PUSH BC
	LD   BC,$0040
	ADD  HL,BC
	POP  BC
	DEC  D
	DEC  D
	INC  IX
	INC  IX
	INC  BC
	INC  BC
	INC  BC
	INC  BC
	INC  BC
	DEC  A
	JR   NZ,RedefineNext
	JP   SkipMusic

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CheckKeyAlreadyUsed:
	LD   HL,CursorKeys+11
	LD   B,$00

ScanKeys:
	INC  HL
	INC  HL
	INC  B
	LD   A,B
	CP   $06
	JR   Z,ScannedAll

	LD   A,(HL)
	AND  A
	JR   NZ,ScanKeys

ScannedAll:
	DEC  HL
	DEC  HL
	DEC  B
	INC  B
	LD   D,(HL)
	DEC  HL
	LD   E,(HL)

ScanNext:
	DEC  HL
	LD   A,(HL)
	DEC  HL
	CP   D
	JR   NZ,NoMatch

	LD   A,(HL)
	CP   E
	JR   NZ,NoMatch

	LD   B,$01			; duplicate key found
	RET 

NoMatch:
	DJNZ ScanNext
	LD   B,$00			; this key hasn't been used already
	RET

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayGameOverSpeech:
	LD   A,R
	LD   HL,GameOverSpeech-1			; GameOverSpeech-1
	AND  $07
	INC  A
	LD   B,A
SelectSpeech:
	INC  HL
	DJNZ SelectSpeech

	LD   A,(HL)
	JP   PlayFullerOrator

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GetKeyPress:
	LD   D,$00
	LD   HL,$0000
	LD   B,$08
	LD   C,$FE
ScanPort:
	LD   A,C
	IN   A,($FE)
	AND  $1F
	CP   $1F
	JR   Z,NextPort

	DEC  D
	JR   NZ,KeyPressed

	LD   HL,$0000
	RET 

KeyPressed:
	LD   D,$01
	LD   L,A
	LD   H,C
	LD   E,B

NextPort:
	SLA  C
	SET  0,C

	DJNZ ScanPort
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

RedefineKey:
	PUSH AF
	PUSH HL
	PUSH DE
	PUSH BC
	LD   B,$0D				; 13
FillLp:
	LD   (HL),$03			; set colour
	INC  HL
	DJNZ FillLp

WaitKey2:
	CALL GetKeyPress
	LD   A,L
	AND  A
	JR   Z,WaitKey2

	LD   C,L
	LD   B,E
	LD   (IX+$00),L			; write out port and bit for this key
	LD   (IX+$01),H
	LD   HL,RefinedKeyText
	LD   DE,$0005

.Loop:
	ADD  HL,DE
	DJNZ .Loop

.Loop2:
	INC  HL
	SRL  C
	JR   C,.Loop2

	LD   A,(HL)
	POP  BC
	PUSH BC
	LD   (BC),A
	PUSH AF
	CALL CheckKeyAlreadyUsed
	POP  AF
	DEC  B
	JR   Z,WaitKey2			; key has already been used

	POP  BC
	POP  HL
	PUSH HL
	PUSH BC
	CALL PrintCharacter		; print the key pressed

WaitKeyUp:					; debounce
	CALL GetKeyPress
	LD   A,L
	AND  A
	JR   NZ,WaitKeyUp

	POP  BC
	POP  DE
	POP  HL
	POP  AF
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayMusic:

	IF DISABLE_MUSIC == 1
	RET
	ENDIF

	LD   C,(HL)
	INC  HL
	LD   B,(HL)
	INC  HL
	LD   A,C
	AND  A
	RET  Z

	PUSH HL
	PUSH BC
	CALL ROM_STACK_A	; a (pitch)->stack
	RST  ROM_FP_CALC
	db $A4				; stack constant 10
	db $05				; div y / x
	db $38				; complete calc
	POP  BC
	LD   A,B
	CALL ROM_STACK_A	; duration->stack
	CALL ROM_BEEP		; ROM beeper
	POP  HL
	JR   PlayMusic

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ScrollLine:
	PUSH DE
	PUSH BC
	PUSH AF
	LD   D,$08

ScrollLineLoop:
	PUSH HL
	POP  BC
	INC  BC
	LD   E,$1E
ScrollLoop:
	SLA  (HL)
	LD   A,(BC)
	BIT  7,A
	JR   Z,NoSet

	SET  0,(HL)
NoSet:
	INC  HL
	INC  BC
	DEC  E
	JR   NZ,ScrollLoop

	LD   BC,$00E2
	ADD  HL,BC
	DEC  D
	JR   NZ,ScrollLineLoop

	POP  AF
	POP  BC
	POP  DE
	RET 
; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

ClearScreen:
	LD   HL,$5AFF
	LD   BC,$1B00

.Loop:
	LD   (HL),$00
	DEC  BC
	DEC  HL
	LD   A,C
	OR   B
	JR   NZ,.Loop
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PrintHighScoreTable:
	LD   DE,HighScoreTableText
	LD   H,$17
	LD   L,$10
	LD   B,$10			; 16 chars wide

PrintHighLoop:
	LD   A,(DE)
	CALL PrintCharacter
	INC  L
	INC  DE
	DJNZ PrintHighLoop

	LD   H,$15
	LD   DE,HighScores
NextHighScorePrint:
	LD   L,$10
	LD   B,$10

HighScoreLoop:
	LD   A,(DE)
	CALL PrintCharacter
	INC  L
	INC  DE
	DJNZ HighScoreLoop
	DEC  H
	DEC  H
	LD   A,H
	CP   $02
	JR   NC,NextHighScorePrint

	LD   HL,$5810			; attribute 
	LD   DE,$0010
	LD   C,$15

NextHighAttrLine:
	LD   B,$10

FillHighAttrLine:
	LD   (HL),$17
	INC  HL
	DJNZ FillHighAttrLine

	ADD  HL,DE
	DEC  C
	JR   NZ,NextHighAttrLine

	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

GameOverSpeech:
	db $01
	db $10
	db $13
	db $17
	db $1E
	db $20
	db $21
	db $01

HighScoreTableText:
	db "high score table"

RedefineKeyText:
	db "press the key you wish to use tomove up   move down move left move rightjump"

RefinedKeyText:						; what ASCII character maps to the port and bit of the keyboard matrix
	db $20, $20, $20, $20, $20, $20
	db $97, $99, $6D, $6E, $62	; Space Sym M N B
	db $9A, $6C, $6B, $6A, $68	; Enter  L K J H
	db $70, $6F, $69, $75, $79	; P O I U Y 
	db $30, $39, $38, $37, $36	; 0 9 8 7 6
	db $31, $32, $33, $34, $35	; 1 2 3 4 5
	db $71, $77, $65, $72, $74	; Q W E R T
	db $61, $73, $64, $66, $67	; A S D F G
	db $98, $7A, $78, $63, $76	; Shift Z X C V

ScrollingText:
	db "{",$00,"press S to start game {",$00
	db "press R to redefine keys {",$00,"press I for instructions {"
	db $00

InstructionsScrollText:
	db "{",$00,"press S to start game {",$00
	db "press R to redefine keys {",$00
	db "press 1,2 or 3 to select key type "

NumberOfPlayersScrollText:
	db "1,2,3 or 4 players ?          "

GameOverScrollText:
	db "game over "

Player1ScrollText:
	db 'p'
	db 'l'
	db 'a'
	db 'y'
	db 'e'
	db 'r'
	db ' '
PlayerNumText:
	db $31
	db $20

LevelScrollText:
	db 'l'
	db 'e'
	db 'v'
	db 'e'
	db 'l'
	db ' '
LevelDig1:
	db $00
LevelDig2:
	db $A0

OutOfTimeScrollText:
	db "OUT OF TIME !"

PlayerText:
	db "   PLAYER  "

PlayerNumText_1:
	db $31
	db "                    well  done!  you have beaten one of todays highest scores.                 "
	db "please type  in your name or initials then  press  ENTER. "

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

TitleMusic:
	db $01
	db $10
	db $01
	db $10
	db $01
	db $12
	db $01
	db $12
	db $01
	db $0D
	db $01
	db $0D
	db $02
	db $10
	db $01
	db $10
	db $01
	db $10
	db $01
	db $12
	db $01
	db $12
	db $01
	db $0D
	db $01
	db $0D
	db $02
	db $10
	db $01
	db $10
	db $01
	db $10
	db $02
	db $12
	db $02
	db $15
	db $02
	db $14
	db $02
	db $14
	db $02
	db $12
	db $02
	db $10
	db $02
	db $0E
	db $01
	db $0E
	db $01
	db $0E
	db $01
	db $10
	db $01
	db $10
	db $01
	db $0B
	db $01
	db $0B
	db $02
	db $0E
	db $01
	db $0E
	db $01
	db $0E
	db $01
	db $10
	db $01
	db $10
	db $01
	db $0B
	db $01
	db $0B
	db $02
	db $0E
	db $01
	db $0E
	db $01
	db $0E
	db $02
	db $10
	db $02
	db $12
	db $02
	db $13
	db $02
	db $10
	db $02
	db $0E
	db $02
	db $0B
	db $02
	db $07
	db $00
	db $00

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

LoseLifeMusic:
	db $02
	db $08
	db $02
	db $08
	db $02
	db $08
	db $02
	db $08
	db $02
	db $06
	db $02
	db $04
	db $02
	db $04
	db $02
	db $03
	db $02
	db $01
	db $02
	db $01
	db $02
	db $04
	db $02
	db $08
	db $02
	db $0D
	db $02
	db $0D
	db $02
	db $0D
	db $02
	db $0D
	db $02
	db $0B
	db $02
	db $09
	db $02
	db $09
	db $02
	db $08
	db $02
	db $06
	db $02
	db $06
	db $02
	db $08
	db $02
	db $09
	db $00
	db $00

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

PlayLevel:
	LD   HL,$5AFF
	LD   BC,$1B00
ClrLp:
	LD   (HL),$00
	DEC  HL
	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,ClrLp

	; draw level

	LD   BC,LevelBuffer
	LD   H,$00
NextRow:
	LD   L,$00
NextColumn:
	LD   A,(BC)
	CALL PrintCharacter
	INC  BC
	INC  L
	LD   A,L
	CP   $20
	JR   NZ,NextColumn
	INC  H
	LD   A,H
	CP   $15
	JR   NZ,NextRow

	LD   A,(CurrentLevel)
	LD   B,A
	INC  B
	XOR  A

.Loop:
	ADD  A,$01
	DAA
	DJNZ .Loop

	LD   D,A
	AND  $0F
	ADD  A,$9E
	LD   (LevelDigit2),A
	LD   A,D
	LD   B,$04
.Loop2:
	SRL  A
	DJNZ .Loop2

	ADD  A,$9E
	LD   (LevelDigit1),A
	LD   A,(CurrentLevel)
	INC  A
	CP   $0A
	JR   C,.NoReset

	LD   A,$09
.NoReset:
	LD   (Bonus),A
	ADD  A,$9E
	LD   (BonusDigits),A
	LD   A,(CurrentLevel)
	SRL  A
	SRL  A
	SRL  A
	SRL  A
	CP   $05
	JR   C,.NoClamp
	
	LD   A,$05
.NoClamp:
	LD   C,A
	LD   A,$09
	SUB  C
	LD   (TimeRemaining),A
	ADD  A,$9E
	LD   (TimeDigits),A
	LD   A,(CurrentPlayer)
	ADD  A,$9E
	LD   (PlayerNumber),A
	LD   HL,$1700
	LD   DE,ScoreText
	LD   B,$03

ScoreTextLp:
	LD   A,(DE)
	CALL PrintCharacter
	INC  L
	INC  DE
	DJNZ ScoreTextLp

	LD   HL,$1500
	LD   B,$20
TopPanelLp:
	LD   A,(DE)
	CALL PrintCharacter
	INC  L
	INC  DE
	DJNZ TopPanelLp

	LD   HL,$3FFE
	LD   (ScoreScreenPos),HL
	LD   A,(NumberOfPlayers)
	LD   HL,P1Score				;$6ECE
.NextPlayer:
	LD   DE,CurrentPlayerScore
	LD   BC,$0006
	LDIR
	PUSH HL
	LD   BC,$0007
	LD   HL,(ScoreScreenPos)
	ADD  HL,BC
	LD   (ScoreScreenPos),HL
	LD   B,$00
	PUSH AF
	CALL AddToScore
	POP  AF
	POP  HL
	DEC  A
	JR   NZ,.NextPlayer

	LD   BC,$0006
	LD   HL,CurrentPlayerScore
	LD   A,(CurrentPlayer)

.NextScore:
	ADD  HL,BC
	DEC  A
	JR   NZ,.NextScore

	LD   DE,CurrentPlayerScore
	LDIR

	LD   A,(CurrentPlayerScore+1)
	LD   (LastDigitValue),A
	LD   B,$14
	LD   HL,Hen1
ResetHen:
	LD   (HL),$FF
	INC  HL
	DJNZ ResetHen
	
	LD   A,(CurrentLevel)
	CP   $08
	JR   C,SetupHens
	
	CP   $10
	JR   C,SkipHens

SetupHens:
	AND  $07
	LD   HL,HenStarts - $15 	;$945B
	LD   BC,$0015
	INC  A
HenStartLp:
	ADD  HL,BC
	DEC  A
	JR   NZ,HenStartLp

	LD   B,(HL)					; how many hens on this level
	INC  HL
	LD   A,(CurrentLevel)
	CP   $18
	JR   C,CopyHenData

	LD   B,$14					; copy over hen start positions for this level
CopyHenData:
	LD   DE,Hen1				;$7357
.Loop:
	LD   A,(HL)
	LD   (DE),A
	INC  DE
	INC  HL
	DJNZ .Loop

SkipHens:
	LD   HL,$0001
	LD   (HenUpdateSpeed),HL
	LD   H,$16
	LD   L,$05
	LD   A,(NumberOfPlayers)
	LD   B,A
	LD   DE,P1Lives

NextPlayerLives:
	PUSH HL
	LD   A,(DE)
	CP   $07
	JR   C,NotMaxLives

	LD   A,$06
NotMaxLives:
	INC  DE
	AND  A
	JR   Z,NoLivesToDraw

	LD   C,A			; c=how many lives
	LD   A,$B6			; $b6 hat char for lives
DrawHats:
	CALL PrintCharacter
	INC  L
	DEC  C
	JR   NZ,DrawHats

NoLivesToDraw:
	POP  HL
	LD   A,L
	ADD  A,$07
	LD   L,A
	DJNZ NextPlayerLives

	LD   HL,$0000			; score attrs
	LD   B,$03
	LD   A,$17
	CALL FillPanelAttrLines
	INC  H
	LD   B,$20				; hat attrs
	LD   A,$06
	CALL FillPanelAttrLines
	INC  H
	LD   B,$05
	LD   A,$17
	CALL FillPanelAttrLines			; current player num attrs
	LD   L,$07
	INC  B
	CALL FillPanelAttrLines			; level num attrs
	LD   B,$08
	LD   L,$0F
	CALL FillPanelAttrLines			; bonus attrs
	DEC  B
	LD   L,$19
	CALL FillPanelAttrLines			; time attrs

	LD   HL,$0005
	LD   BC,$0601
ColourPlayersScores:
	LD   D,$0F						; other player's score colours (white on blue)
	LD   A,(CurrentPlayer)
	CP   C
	JR   NZ,NotCurrentPlayer

	LD   D,$17						; current player's score colour (white on red)
NotCurrentPlayer:
	LD   A,D
	CALL FillPanelAttrLines			; colour each player's score
	LD   A,L
	ADD  A,$07
	LD   L,A
	INC  C
	LD   A,(NumberOfPlayers)
	CP   C
	JR   NC,ColourPlayersScores

	; colour in the level tiles...

	LD   HL,LevelBuffer
	LD   DE,$5AE0			; bottom row of attributes
	LD   C,$15				; 21 lines high

NextTileRow:
	LD   B,$20				; 32 bytes wide
	PUSH DE

NextTileCol:
	PUSH BC
	LD   A,(HL)
	CP   TILE_LAST			; $09
	JR   C,GetTileCol

	LD   A,YELLOW			; yellow
	JR   SetTileCol

GetTileCol:
	ADD  A,low TileColours	;$4F
	LD   B,high TileColours	;$98	; $984f - TileColours
	LD   C,A
	LD   A,(BC)

SetTileCol:
	LD   (DE),A
	INC  DE
	INC  HL
	POP  BC
	DJNZ NextTileCol

	POP  DE
	EX   DE,HL
	PUSH DE
	LD   DE,$0020
	AND  A
	SBC  HL,DE			; move to next attr row up
	POP  DE
	EX   DE,HL
	DEC  C
	JR   NZ,NextTileRow

	LD   IX,PlayerX			; reset game variables
	LD   (IX+$00),$64		; PlayerX
	LD   (IX+$01),$17		; PlayerY
	LD   (IX+$70),$08		; MotherDuckX
	LD   (IX+$71),$98		; MotherDuckY
	LD   (IX+$64),$05		; LiftUpdateCounter
	XOR  A
	LD   (IX+$68),A			; Bonus+1
	LD   (IX+$69),A			; Bonus+2
	LD   (IX+$6B),A			; TimeRemaining+1
	LD   (IX+$6C),A			; TimeRemaining+2
	LD   (IX+$72),A			; MotherDuckXVel
	LD   (IX+$73),A			; MotherDuckYvel
	LD   (IX+$75),A			; MotherDuckFrame
	LD   (IX+$7D),A			; PlayerOnLift
	LD   (IX+$02),A			; PlayerAnimFrame
	LD   (IX+$03),A			; PlayerDirection
	LD   (IX+$4D),A			; PlayerInAir
	LD   (CurrentHen),A
	LD   (SFXFreq),A

	INC  A
	LD   (IX+$6F),A			; TimerRunning
	LD   (IX+$6D),A			; FiftiesCounter
	LD   (IX+$6E),A			; TensCounter
	LD   (IX+$74),A			; MotherDuckUpdateCounter
	LD   (IX+$04),A			; SoundTimer

	LD   A,(FrontEndMode)	; set which input keys we're going to use
	CP   $05

	LD   HL,CursorKeys
	JR   Z,SetWorkingKeys
	
	LD   HL,UserDefinedKeys
	JR   C,SetWorkingKeys
	
	LD   HL,The2W90Keys

SetWorkingKeys:
	LD   BC,$000C
	LD   DE,UpBitmask			; copy into working keys
	LDIR

	LD   BC,$0007
	LD   HL,SCRNADDR-2			;$3FFE
	LD   A,(CurrentPlayer)

.Loop:
	ADD  HL,BC
	DEC  A
	JR   NZ,.Loop

	LD   (ScoreScreenPos),HL
	LD   BC,$0004
	LD   HL,LiftReset1			; first lift reset address
	PUSH HL
	POP  DE
	LD   A,(CurrentLevel)
	AND  $07
	INC  A

ResetLp:
	ADD  HL,BC
	DEC  A
	JR   NZ,ResetLp
	LDIR						; copy the lift reset data

	LD   BC,$0004
	AND  A
	SBC  HL,BC
	LD   DE,Lift1ScreenPos
	LDIR

	LD   (IX+$7C),$43			; Lift2YPos
	LD   HL,(Lift1ScreenPos)
	LD   BC,$0800
	AND  A
	SBC  HL,BC
	LD   (Lift2ScreenPos),HL

	CALL FullerOratorRandom

	IF DISABLE_SPEECH == 0
	LD   D,$1E
Delay1:							; wait for speech to play out (if we have speech!)
	LD   BC,$2710
Delay2:
	DEC  BC
	LD   A,B
	OR   C
	JR   NZ,Delay2
	DEC  D
	JR   NZ,Delay1
	ENDIF

	LD   A,(CurrentPlayer)
	LD   L,A
	LD   H,$00
	LD   DE,P4Level
	ADD  HL,DE
	LD   C,A
	LD   A,(HL)
	CP   $07
	JR   NC,StartGame

	SUB  $03

.Loop:
	ADD  A,$07
	DEC  C
	JR   NZ,.Loop

	LD   H,$16
	LD   L,A
	XOR  A
	CALL PrintCharacter

StartGame:
	JP   MainLoop

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; H  = line 0,1, or 2
; L  = x offset on line (H)
; A  = Attribute colour to fill with
; BC = num of attrs to fill
;

FillPanelAttrLines:			
	PUSH HL
	PUSH BC
	PUSH AF
	LD   E,L
	LD   A,H
	LD   HL,$5800			; attr line 1
	AND  A
	JR   Z,PrepFill

	LD   HL,$5820			; attr line 2
	DEC  A
	JR   Z,PrepFill

	LD   HL,$5840			; attr line 3

PrepFill:
	LD   D,$00
	ADD  HL,DE				; x offset
	POP  AF

FillAttrLp:
	LD   (HL),A
	INC  HL
	DJNZ FillAttrLp

	POP  BC
	POP  HL
	RET 

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

FullerOratorRandom:
	LD   HL,OratorWords-1		;$B15E			; OratorWords-1
	LD   A,R
	AND  $07
	INC  A
	LD   B,A

PickRandomWord:
	INC  HL
	DJNZ PickRandomWord

	LD   A,(HL)
	JP   PlayFullerOrator

OratorWords:			; index into the word list
	db $02
	db $08
	db $0A
	db $0B
	db $0C
	db $11
	db $11
	db $02

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;
	org $b200		; page $b2 for ISR at $9c9c

	ds 256, $9c

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

CheckForFalling:
	LD   A,(PlayerX)
	AND  $07
	RET  Z

	LD   HL,(PlayerX)
	CALL GetMapAddressAndChar
	LD   BC,$003F
	AND  A
	SBC  HL,BC
	LD   A,(HL)
	CP   TILE_PLATFORM		; $05			; PLATFORM
	RET  NC

	CP   TILE_LADDERLEFT	;$01			; LADDER_LEFT
	RET  Z

	CP   TILE_LADDERRIGHT	;$02			; LADDER_RIGHT
	RET  Z

	LD   A,$01				; Player falling
	LD   (PlayerInAir),A
	LD   D,$FF				; d=jump direction left
	LD   A,(PlayerDirection)
	AND  A
	JR   NZ,SetPlayerDir

	LD   D,$01				; d = jump direction right

SetPlayerDir:
	LD   A,D
	LD   (PlayerJumpDirection),A
	LD   A,$04
	LD   (InAirCounter),A
	RET 


; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

Level1:
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
	db $00,$00,$00,$00,$04,$00,$03,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$04,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00
	db $00,$00,$05,$05,$05,$05,$05,$05,$05,$05,$01,$02,$05,$05,$05,$05,$01,$02,$05,$05,$05,$05,$05,$05,$05,$05,$01,$02,$05,$05,$00,$00
	db $00,$00,$00,$03,$00,$01,$02,$00,$04,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$03,$00,$00,$04,$00,$00,$01,$02,$00,$03,$00,$00
	db $00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$05,$01,$02,$05,$05,$05,$01,$02,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$05,$05,$05,$00,$00
	db $00,$00,$00,$00,$03,$01,$02,$00,$04,$00,$01,$02,$00,$00,$00,$05,$05,$05,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$03,$00,$00,$00
	db $00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00,$00,$03,$00,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$01,$02,$00,$00,$00,$05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$03,$04,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $b2,$b3,$b4,$b5,$00,$00,$00,$00,$05,$05,$01,$02,$05,$05,$05,$05,$00,$00,$05,$05,$05,$05,$05,$05,$05,$05,$05,$00,$00,$05,$05,$05
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$03,$01,$02,$00,$00,$00,$04,$00,$00,$00,$00,$03,$00,$04,$00,$00,$00,$00,$00,$00,$00,$03,$00
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $aa,$ab,$ac,$ad,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$a8,$a9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

Level2:
	db $05,$05,$05,$05,$05,$05,$00,$00,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
	db $00,$04,$00,$01,$02,$04,$00,$00,$03,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$03,$00,$00,$00,$00,$04,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $05,$05,$05,$01,$02,$05,$05,$05,$05,$05,$05,$05,$00,$00,$05,$01,$02,$05,$00,$00,$05,$05,$05,$05,$00,$00,$05,$01,$02,$05,$05,$05
	db $00,$03,$00,$01,$02,$00,$03,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$03,$00,$00,$00,$00,$04,$01,$02,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $05,$05,$05,$01,$02,$05,$00,$00,$05,$01,$02,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$00,$00,$05,$01,$02,$05,$05,$05
	db $00,$03,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$03,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$03,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $05,$05,$05,$01,$02,$05,$05,$05,$05,$01,$02,$05,$05,$05,$05,$01,$02,$05,$00,$00,$05,$01,$02,$05,$05,$05,$05,$05,$05,$05,$05,$05
	db $00,$04,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$03,$00,$00,$01,$02,$04,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $b2,$b3,$b4,$b5,$00,$00,$01,$02,$05,$05,$05,$05,$05,$05,$05,$01,$02,$05,$00,$00,$05,$05,$05,$05,$05,$05,$05,$01,$02,$05,$05,$05
	db $ae,$af,$b0,$b1,$00,$00,$01,$02,$00,$00,$00,$00,$03,$00,$00,$01,$02,$00,$00,$00,$04,$00,$00,$00,$03,$00,$00,$01,$02,$00,$03,$00
	db $ae,$af,$b0,$b1,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $aa,$ab,$ac,$ad,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$a8,$a9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

Level3:
	db $05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$05,$00,$00,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
	db $00,$01,$02,$04,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$00,$03,$00,$00,$00,$01,$02,$00
	db $00,$01,$02,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$01,$02,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$05,$05,$00,$05,$05,$00,$00,$00,$00,$00,$00,$00,$03,$00,$01,$02,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$04,$01,$02,$03,$01,$02,$00,$00,$00,$00,$05,$05,$00,$00,$00,$00,$00,$00,$01,$02,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$05,$05,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$03,$00,$05,$05,$00,$00,$00,$00
	db $05,$01,$02,$05,$05,$05,$05,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$00
	db $00,$01,$02,$04,$01,$02,$03,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$05,$05,$05,$00,$05,$05,$00,$00,$00,$00,$00,$01,$02,$00
	db $00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$04,$00,$00,$03,$00,$00,$00,$00,$00,$01,$02,$00
	db $00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$01,$02,$00
	db $05,$05,$05,$05,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$00,$00,$01,$02,$00
	db $00,$04,$03,$00,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$05,$05,$00,$00,$03,$00,$00,$01,$02,$00
	db $00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$05,$05,$05,$00,$04,$00,$00,$00,$00,$00,$00,$03,$00,$00
	db $00,$00,$00,$00,$01,$02,$05,$00,$00,$00,$00,$05,$01,$02,$05,$01,$02,$05,$04,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $b2,$b3,$b4,$b5,$01,$02,$03,$00,$00,$00,$00,$04,$01,$02,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$00,$05,$00,$00,$05,$05,$05
	db $ae,$af,$b0,$b1,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$01,$02,$05,$05,$05,$05,$05,$00,$00,$00,$04,$03,$00
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $aa,$ab,$ac,$ad,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$a8,$a9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

Level4:
	db $05,$05,$05,$05,$05,$05,$05,$05,$00,$05,$05,$05,$05,$05,$05,$05,$05,$00,$00,$00,$00,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
	db $00,$03,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$04,$00,$00,$00,$00,$03,$00,$00,$01,$02,$00,$00,$00,$04,$00,$00
	db $00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$05,$05
	db $05,$05,$05,$05,$01,$02,$05,$05,$00,$00,$05,$05,$01,$02,$05,$05,$05,$00,$00,$00,$00,$05,$05,$05,$01,$02,$05,$05,$00,$00,$00,$00
	db $00,$04,$00,$00,$01,$02,$00,$00,$00,$00,$03,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$03,$00,$00,$00,$00
	db $00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05
	db $05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$05,$01,$02,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$05,$05,$05,$00,$00,$03,$00
	db $00,$03,$00,$00,$05,$05,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$03,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$05,$05,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$04,$00,$05,$05,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00
	db $05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$05,$05,$05,$00,$00,$00,$00,$05,$01,$02,$00,$05,$05,$03,$05,$01,$02,$05
	db $00,$03,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$01,$02,$00,$03,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00
	db $00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00
	db $00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00
	db $b2,$b3,$b4,$b5,$00,$00,$00,$00,$05,$05,$00,$05,$01,$02,$05,$05,$05,$00,$00,$00,$00,$05,$01,$02,$05,$05,$03,$05,$05,$01,$02,$05
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$04,$00,$00,$00,$00,$00,$00,$04,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00
	db $aa,$ab,$ac,$ad,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00
	db $00,$a8,$a9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

Level5:
	db $05,$05,$05,$00,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$00,$00,$05,$05,$05,$05,$00,$00,$00,$00,$05,$05,$05,$05
	db $00,$03,$00,$00,$01,$02,$00,$04,$04,$04,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$04,$01,$02,$04,$00,$00,$00,$00,$04,$00,$00,$00
	db $00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $05,$05,$05,$05,$01,$02,$05,$05,$05,$05,$00,$01,$02,$00,$05,$01,$02,$05,$05,$05,$03,$01,$02,$05,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$03,$00,$00,$01,$02,$00,$00,$03,$00,$00,$01,$02,$00,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$00,$01,$02,$00,$03,$05,$05,$05,$01,$02,$05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$05,$05
	db $00,$03,$00,$01,$02,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$04,$00,$01,$02,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$03,$00
	db $00,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $05,$05,$05,$01,$02,$05,$05,$01,$02,$05,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$03,$00,$01,$02,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$05,$00,$03,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $b2,$b3,$b4,$b5,$00,$00,$05,$01,$02,$05,$05,$05,$05,$05,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05
	db $ae,$af,$b0,$b1,$00,$00,$04,$01,$02,$03,$00,$04,$04,$00,$00,$00,$00,$00,$01,$02,$05,$05,$05,$05,$00,$00,$00,$00,$04,$00,$03,$00
	db $ae,$af,$b0,$b1,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$03,$00,$04,$00,$00,$00,$00,$00,$00,$00,$00
	db $aa,$ab,$ac,$ad,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$a8,$a9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

Level6:
	db $05,$05,$05,$05,$05,$00,$00,$00,$00,$05,$05,$05,$05,$05,$00,$00,$00,$00,$05,$05,$05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$04,$04,$04,$04,$00,$00,$00,$03,$01,$02,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $05,$01,$02,$05,$00,$05,$01,$02,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$05,$05,$00,$00,$01,$02,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$01,$02,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$01,$02,$05,$05,$05
	db $00,$00,$00,$00,$05,$05,$01,$02,$05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$01,$02,$05,$05,$05,$01,$02,$00,$04,$00
	db $00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$04,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$01,$02,$00,$03,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $05,$05,$05,$05,$05,$05,$01,$02,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$01,$02,$05,$05,$05
	db $00,$04,$04,$04,$04,$00,$01,$02,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$03,$00
	db $00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$01,$02,$05,$05,$05,$01,$02,$00,$00,$00
	db $b2,$b3,$b4,$b5,$00,$03,$00,$00,$00,$05,$05,$00,$05,$05,$00,$00,$00,$00,$00,$03,$00,$00,$01,$02,$00,$00,$00,$01,$02,$00,$00,$00
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$01,$02,$05,$05,$05
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$03,$00
	db $aa,$ab,$ac,$ad,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$a8,$a9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

Level7:
	db $00,$00,$00,$00,$00,$05,$05,$05,$05,$00,$00,$00,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$01,$02,$00,$00,$05,$05,$05,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$03,$00,$00,$00
	db $05,$01,$02,$03,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$05,$05,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$04,$01,$02,$00,$00,$00,$05,$05,$05,$05,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$05,$00,$03,$04,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$05,$05,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$03,$00,$00,$00,$00,$00,$00
	db $05,$01,$02,$05,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$05,$00,$00,$05,$05,$05,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$05,$00,$00,$00,$05,$00,$00,$00,$03,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$05,$05,$05,$05,$01,$02,$03,$00,$00,$00,$00,$00,$00
	db $05,$01,$02,$05,$05,$05,$05,$05,$05,$05,$00,$05,$05,$05,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$04,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00
	db $00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $b2,$b3,$b4,$b5,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$05,$05,$01,$02,$05,$05,$05,$05,$05,$05,$00,$00,$00,$00
	db $ae,$af,$b0,$b1,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$04,$01,$02,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00
	db $ae,$af,$b0,$b1,$00,$00,$01,$02,$03,$00,$01,$02,$03,$00,$01,$02,$03,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $aa,$ab,$ac,$ad,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$a8,$a9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

Level8:
	db $05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05
	db $00,$04,$04,$01,$02,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$01,$02,$04,$04,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$04,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$05,$01,$02,$05,$05,$00,$03,$00,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$05,$00,$03,$00,$05,$05,$01,$02,$05,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$05,$05,$05,$05,$05,$05,$05,$00,$03,$00,$05,$05,$01,$02,$05,$05,$00,$03,$00,$05,$05,$05,$05,$05,$05,$05,$00,$00,$00
	db $00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$05,$01,$02,$05,$05,$05,$00,$03,$00,$05,$05,$05,$05,$05,$05,$00,$03,$00,$05,$05,$05,$01,$02,$05,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $b2,$b3,$b4,$b5,$00,$05,$05,$00,$03,$00,$05,$05,$03,$05,$05,$01,$02,$05,$05,$03,$05,$05,$00,$03,$00,$05,$05,$00,$00,$00,$00,$00
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $ae,$af,$b0,$b1,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$02,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $aa,$ab,$ac,$ad,$00,$00,$03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$03,$00,$00,$00,$00,$00,$00
	db $00,$a8,$a9,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

OratorWordAllophoneAddresses:			; addresses of allophone lists for each word
	dw $3834
	dw word1
	dw word2
	dw word4
	dw word5
	dw word7
	dw word8
	dw word10
	dw word11
	dw word12
	dw word13
	dw word15
	dw word17
	dw word19
	dw word20
	dw word21
	dw word25
	dw word27
	dw word28
	dw word30
	dw word32
	dw word35
	dw word37
	dw word38
	dw word39
	dw word40
	dw word43
	dw word44
	dw word45
	dw word46
	dw word47
	dw word48
	dw word49
	dw word51			; last word

word1:
	db $06
	db $35
	db $05
	db $00
	db $04
	db $38
	db $05
	db $35
	db $02
	db $00
	db $FF
	db $FF
word2:
	db $05
	db $3D
	db $07
	db $35
	db $05
	db $00
	db $05
	db $28
	db $06
	db $3B
	db $09
	db $00
	db $05
	db $0C
	db $05
word3:
	db $0D
	db $02
	db $00
	db $FF
	db $FF
word4:
	db $06
	db $10
	db $05
	db $0C
	db $05
	db $37
	db $03
	db $11
	db $02
	db $00
	db $FF
	db $FF
word5:
	db $03
	db $38
	db $06
	db $06
	db $0E
	db $37
	db $05
	db $2D
	db $07
word6:
	db $13
	db $02
	db $00
	db $FF
	db $FF
word7:
	db $05
	db $0B
	db $06
	db $07
	db $05
	db $29
	db $07
	db $37
	db $05
	db $11
	db $08
	db $00
	db $07
	db $2D
	db $05
	db $07
	db $05
	db $23
	db $03
	db $1E
	db $05
	db $3E
	db $02
	db $00
	db $FF
	db $FF
word8:
	db $05
	db $20
	db $08
	db $2B
	db $09
	db $1A
	db $05
	db $11
	db $02
	db $00
	db $FF
word9:
	db $FF
word10:
	db $04
	db $39
	db $05
	db $06
	db $10
	db $00
	db $05
	db $37
	db $06
	db $08
	db $05
	db $3A
	db $02
	db $00
	db $FF
	db $FF
word11:
	db $03
	db $3F
	db $07
	db $13
	db $07
	db $00
	db $06
	db $3E
	db $07
	db $33
	db $02
	db $0D
	db $02
	db $00
	db $FF
	db $FF
word12:
	db $09
	db $2E
	db $06
	db $07
	db $07
	db $3E
	db $09
	db $00
	db $06
	db $21
	db $02
	db $1E
	db $05
	db $1E
	db $05
	db $0B
	db $02
	db $00
	db $FF
	db $FF
word13:
	db $05
	db $39
	db $05
	db $1A
	db $05
	db $23
	db $07
	db $00
	db $04
	db $38
	db $07
	db $35
	db $0A
	db $00
	db $06
	db $1D
	db $06
	db $2F
word14:
	db $02
	db $00
	db $FF
	db $FF
word15:
	db $05
	db $3D
	db $07
	db $35
	db $06
	db $00
	db $03
	db $38
	db $06
	db $20
	db $02
	db $00
	db $FF
word16:
	db $FF
word17:
	db $04
word18:
	db $21
	db $03
	db $35
	db $04
	db $0B
	db $07
	db $11
	db $09
	db $00
	db $05
	db $37
	db $05
	db $11
	db $04
	db $18
	db $05
	db $09
	db $02
	db $00
	db $FF
	db $FF
word19:
	db $05
	db $22
	db $05
	db $35
	db $05
	db $2C
	db $0D
	db $00
	db $06
	db $0F
	db $03
	db $09
	db $02
	db $00
	db $FF
	db $FF
word20:
	db $05
	db $22
	db $05
	db $14
	db $05
	db $10
	db $0F
	db $00
	db $07
	db $35
	db $04
	db $23
	db $03
	db $34
	db $02
	db $00
	db $FF
	db $FF
word21:
	db $05
	db $35
	db $05
	db $38
word22:
	db $06
	db $37
	db $0B
	db $00
	db $05
	db $10
	db $06
word23:
	db $1A
	db $04
	db $0B
	db $02
	db $00
	db $FF
word24:
	db $FF
word25:
	db $06
	db $27
	db $05
	db $17
	db $05
	db $2C
	db $0B
	db $00
	db $05
	db $10
	db $06
	db $0F
	db $04
	db $0B
	db $05
	db $1F
	db $07
word26:
	db $23
	db $09
	db $33
	db $02
	db $00
	db $FF
	db $FF
word27:
	db $05
	db $2D
	db $07
	db $29
	db $04
	db $00
	db $02
	db $1A
	db $04
	db $35
	db $04
	db $11
	db $02
	db $00
	db $FF
	db $FF
word28:
	db $05
	db $3D
	db $02
	db $18
	db $05
	db $11
	db $08
	db $00
	db $05
	db $0C
word29:
	db $04
	db $11
	db $02
	db $00
	db $FF
	db $FF
word30:
	db $05
	db $0D
	db $05
	db $1E
	db $05
	db $28
	db $09
	db $00
	db $05
	db $2E
	db $05
	db $17
	db $05
	db $0B
	db $02
	db $00
word31:
	db $FF
	db $FF
word32:
	db $06
	db $14
	db $0B
	db $00
	db $05
	db $1A
	db $05
	db $2C
	db $05
	db $15
	db $09
	db $00
	db $05
	db $07
	db $05
	db $28
	db $0A
	db $00
	db $04
	db $37
	db $04
	db $37
	db $05
	db $17
	db $04
	db $28
	db $04
word33:
	db $11
	db $05
	db $2E
	db $05
word34:
	db $2F
	db $09
	db $00
	db $05
	db $09
	db $04
	db $0E
	db $05
	db $07
	db $05
	db $2B
	db $05
	db $07
	db $05
	db $0B
	db $04
	db $11
	db $07
	db $37
	db $09
	db $00
	db $05
	db $32
	db $05
	db $0F
	db $04
	db $08
	db $06
	db $13
	db $0B
	db $00
	db $06
	db $07
	db $03
	db $22
	db $02
	db $00
	db $FF
	db $FF
word35:
	db $05
	db $2D
	db $07
	db $35
	db $08
	db $00
	db $05
	db $17
	db $05
	db $0B
	db $08
	db $00
	db $05
	db $0D
	db $05
	db $06
	db $07
	db $10
	db $02
	db $00
	db $FF
word36:
	db $FF
word37:
	db $05
	db $37
	db $05
	db $37
	db $07
	db $16
	db $05
	db $09
	db $05
	db $33
	db $02
	db $00
	db $FF
	db $FF
word38:
	db $05
	db $39
	db $06
	db $35
	db $05
	db $09
	db $05
	db $2D
	db $05
	db $0F
	db $05
	db $37
	db $09
	db $00
	db $05
	db $2A
	db $05
	db $14
	db $08
	db $37
	db $02
	db $00
	db $FF
	db $FF
word39:
	db $06
	db $0C
	db $06
	db $0B
	db $05
	db $37
	db $03
	db $11
	db $04
	db $27
	db $03
	db $0F
	db $04
	db $29
	db $04
	db $25
	db $0A
	db $0F
	db $05
	db $0B
	db $06
	db $37
	db $02
	db $00
	db $FF
	db $FF
word40:
	db $05
	db $38
	db $05
	db $35
	db $09
	db $11
	db $05
	db $14
word41:
	db $05
	db $00
	db $05
	db $38
	db $05
	db $35
	db $09
	db $11
	db $05
	db $14
word42:
	db $02
	db $00
	db $FF
	db $FF
word43:
	db $05
	db $09
	db $05
	db $2D
	db $04
	db $14
	db $07
	db $33
	db $09
	db $00
	db $05
	db $2E
	db $05
	db $17
	db $05
	db $0B
	db $02
	db $00
	db $FF
	db $FF
word44:
	db $05
	db $09
	db $05
	db $2D
	db $04
	db $14
	db $07
	db $33
	db $09
	db $00
	db $05
	db $0D
	db $05
	db $1F
	db $02
	db $00
	db $FF
	db $FF
word45:
	db $05
	db $09
	db $05
	db $2D
	db $04
	db $14
	db $07
	db $33
	db $09
	db $00
	db $05
	db $1D
	db $04
	db $27
	db $05
	db $13
	db $02
	db $00
	db $FF
	db $FF
word46:
	db $05
	db $09
	db $05
	db $2D
	db $04
	db $14
	db $07
	db $33
	db $09
	db $00
	db $05
	db $28
	db $05
	db $3A
	db $02
	db $00
	db $FF
	db $FF
word47:
	db $06
	db $35
	db $09
	db $00
	db $05
	db $05
	db $02
	db $00
	db $FF
	db $FF
word48:
	db $05
	db $3B
	db $09
	db $00
	db $05
	db $19
	db $07
	db $1E
	db $08
	db $00
	db $06
	db $27
	db $09
	db $07
	db $02
	db $21
	db $09
	db $31
	db $02
	db $00
	db $FF
	db $FF
word49:
	db $05
	db $0B
	db $07
	db $17
	db $06
	db $11
	db $09
	db $00
	db $06
	db $22
	db $04
	db $1E
	db $04
	db $21
	db $09
	db $00
	db $05
	db $07
	db $07
	db $38
	db $08
	db $28
	db $02
	db $00
	db $FF
word50:
	db $FF
word51:
	db $06
	db $39
	db $08
word52:
	db $3B
	db $04
	db $15
	db $06
	db $00
	db $06
	db $2D
	db $05
	db $1E
	db $03
	db $29
	db $06
	db $00
	db $0B
	db $00
	db $FF
	db $FF			; end of allophone lists
	


	SAVESNA "Chuckie.sna", Start
