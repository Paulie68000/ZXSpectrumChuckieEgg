
;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
;
;

SCRNADDR:	equ		0x4000			; screen
ATTRADDR:	equ		0x5800			; attributes

; colour attributes

BRIGHT:		equ		0x40			
FLASH:		equ		0x80
PAPER:		equ		0x8				; multply PAPER with inks to get paper colour

WHITE:		equ		0x7				; ink colours
YELLOW:		equ		0x6
CYAN:		equ		0x5
GREEN:		equ		0x4
MAGENTA:	equ		0x3
RED:		equ		0x2
BLUE:		equ		0x1
BLACK:		equ		0x0

; xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; SPECTRUM screen map
;

L_0            EQU  $4000
L_1            EQU  $4100
L_2            EQU  $4200
L_3            EQU  $4300
L_4            EQU  $4400
L_5            EQU  $4500
L_6            EQU  $4600
L_7            EQU  $4700
L_8            EQU  $4020
L_9            EQU  $4120
L_10           EQU  $4220
L_11           EQU  $4320
L_12           EQU  $4420
L_13           EQU  $4520
L_14           EQU  $4620
L_15           EQU  $4720
L_16           EQU  $4040
L_17           EQU  $4140
L_18           EQU  $4240
L_19           EQU  $4340
L_20           EQU  $4440
L_21           EQU  $4540
L_22           EQU  $4640
L_23           EQU  $4740
L_24           EQU  $4060
L_25           EQU  $4160
L_26           EQU  $4260
L_27           EQU  $4360
L_28           EQU  $4460
L_29           EQU  $4560
L_30           EQU  $4660
L_31           EQU  $4760
L_32           EQU  $4080
L_33           EQU  $4180
L_34           EQU  $4280
L_35           EQU  $4380
L_36           EQU  $4480
L_37           EQU  $4580
L_38           EQU  $4680
L_39           EQU  $4780
L_40           EQU  $40A0
L_41           EQU  $41A0
L_42           EQU  $42A0
L_43           EQU  $43A0
L_44           EQU  $44A0
L_45           EQU  $45A0
L_46           EQU  $46A0
L_47           EQU  $47A0
L_48           EQU  $40C0
L_49           EQU  $41C0
L_50           EQU  $42C0
L_51           EQU  $43C0
L_52           EQU  $44C0
L_53           EQU  $45C0
L_54           EQU  $46C0
L_55           EQU  $47C0
L_56           EQU  $40E0
L_57           EQU  $41E0
L_58           EQU  $42E0
L_59           EQU  $43E0
L_60           EQU  $44E0
L_61           EQU  $45E0
L_62           EQU  $46E0
L_63           EQU  $47E0
L_64           EQU  $4800
L_65           EQU  $4900
L_66           EQU  $4A00
L_67           EQU  $4B00
L_68           EQU  $4C00
L_69           EQU  $4D00
L_70           EQU  $4E00
L_71           EQU  $4F00
L_72           EQU  $4820
L_73           EQU  $4920
L_74           EQU  $4A20
L_75           EQU  $4B20
L_76           EQU  $4C20
L_77           EQU  $4D20
L_78           EQU  $4E20
L_79           EQU  $4F20
L_80           EQU  $4840
L_81           EQU  $4940
L_82           EQU  $4A40
L_83           EQU  $4B40
L_84           EQU  $4C40
L_85           EQU  $4D40
L_86           EQU  $4E40
L_87           EQU  $4F40
L_88           EQU  $4860
L_89           EQU  $4960
L_90           EQU  $4A60
L_91           EQU  $4B60
L_92           EQU  $4C60
L_93           EQU  $4D60
L_94           EQU  $4E60
L_95           EQU  $4F60
L_96           EQU  $4880
L_97           EQU  $4980
L_98           EQU  $4A80
L_99           EQU  $4B80
L_100          EQU  $4C80
L_101          EQU  $4D80
L_102          EQU  $4E80
L_103          EQU  $4F80
L_104          EQU  $48A0
L_105          EQU  $49A0
L_106          EQU  $4AA0
L_107          EQU  $4BA0
L_108          EQU  $4CA0
L_109          EQU  $4DA0
L_110          EQU  $4EA0
L_111          EQU  $4FA0
L_112          EQU  $48C0
L_113          EQU  $49C0
L_114          EQU  $4AC0
L_115          EQU  $4BC0
L_116          EQU  $4CC0
L_117          EQU  $4DC0
L_118          EQU  $4EC0
L_119          EQU  $4FC0
L_120          EQU  $48E0
L_121          EQU  $49E0
L_122          EQU  $4AE0
L_123          EQU  $4BE0
L_124          EQU  $4CE0
L_125          EQU  $4DE0
L_126          EQU  $4EE0
L_127          EQU  $4FE0
L_128          EQU  $5000
L_129          EQU  $5100
L_130          EQU  $5200
L_131          EQU  $5300
L_132          EQU  $5400
L_133          EQU  $5500
L_134          EQU  $5600
L_135          EQU  $5700
L_136          EQU  $5020
L_137          EQU  $5120
L_138          EQU  $5220
L_139          EQU  $5320
L_140          EQU  $5420
L_141          EQU  $5520
L_142          EQU  $5620
L_143          EQU  $5720
L_144          EQU  $5040
L_145          EQU  $5140
L_146          EQU  $5240
L_147          EQU  $5340
L_148          EQU  $5440
L_149          EQU  $5540
L_150          EQU  $5640
L_151          EQU  $5740
L_152          EQU  $5060
L_153          EQU  $5160
L_154          EQU  $5260
L_155          EQU  $5360
L_156          EQU  $5460
L_157          EQU  $5560
L_158          EQU  $5660
L_159          EQU  $5760
L_160          EQU  $5080
L_161          EQU  $5180
L_162          EQU  $5280
L_163          EQU  $5380
L_164          EQU  $5480
L_165          EQU  $5580
L_166          EQU  $5680
L_167          EQU  $5780
L_168          EQU  $50A0
L_169          EQU  $51A0
L_170          EQU  $52A0
L_171          EQU  $53A0
L_172          EQU  $54A0
L_173          EQU  $55A0
L_174          EQU  $56A0
L_175          EQU  $57A0
L_176          EQU  $50C0
L_177          EQU  $51C0
L_178          EQU  $52C0
L_179          EQU  $53C0
L_180          EQU  $54C0
L_181          EQU  $55C0
L_182          EQU  $56C0
L_183          EQU  $57C0
L_184          EQU  $50E0
L_185          EQU  $51E0
L_186          EQU  $52E0
L_187          EQU  $53E0
L_188          EQU  $54E0
L_189          EQU  $55E0
L_190          EQU  $56E0
L_191          EQU  $57E0

;
;screen addresses of row starts
;

ROW_0          EQU  L_0
ROW_1          EQU  L_8
ROW_2          EQU  L_16
ROW_3          EQU  L_24
ROW_4          EQU  L_32
ROW_5          EQU  L_40
ROW_6          EQU  L_48
ROW_7          EQU  L_56
ROW_8          EQU  L_64
ROW_9          EQU  L_72
ROW_10         EQU  L_80
ROW_11         EQU  L_88
ROW_12         EQU  L_96
ROW_13         EQU  L_104
ROW_14         EQU  L_112
ROW_15         EQU  L_120
ROW_16         EQU  L_128
ROW_17         EQU  L_136
ROW_18         EQU  L_144
ROW_19         EQU  L_152
ROW_20         EQU  L_160
ROW_21         EQU  L_168
ROW_22         EQU  L_176
ROW_23         EQU  L_184

;
;attribute addresses of row starts
;

ATROW_0        EQU  ATTRADDR+(32*0)
ATROW_1        EQU  ATTRADDR+(32*1)
ATROW_2        EQU  ATTRADDR+(32*2)
ATROW_3        EQU  ATTRADDR+(32*3)
ATROW_4        EQU  ATTRADDR+(32*4)
ATROW_5        EQU  ATTRADDR+(32*5)
ATROW_6        EQU  ATTRADDR+(32*6)
ATROW_7        EQU  ATTRADDR+(32*7)
ATROW_8        EQU  ATTRADDR+(32*8)
ATROW_9        EQU  ATTRADDR+(32*9)
ATROW_10       EQU  ATTRADDR+(32*10)
ATROW_11       EQU  ATTRADDR+(32*11)
ATROW_12       EQU  ATTRADDR+(32*12)
ATROW_13       EQU  ATTRADDR+(32*13)
ATROW_14       EQU  ATTRADDR+(32*14)
ATROW_15       EQU  ATTRADDR+(32*15)
ATROW_16       EQU  ATTRADDR+(32*16)
ATROW_17       EQU  ATTRADDR+(32*17)
ATROW_18       EQU  ATTRADDR+(32*18)
ATROW_19       EQU  ATTRADDR+(32*19)
ATROW_20       EQU  ATTRADDR+(32*20)
ATROW_21       EQU  ATTRADDR+(32*21)
ATROW_22       EQU  ATTRADDR+(32*22)
ATROW_23       EQU  ATTRADDR+(32*23)

;xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
;
; spectrum colour values
; paper,ink
;

BLACK_BLACK    EQU  0
BLACK_BLUE     EQU  1
BLACK_RED      EQU  2
BLACK_MAGENTA  EQU  3
BLACK_GREEN    EQU  4
BLACK_CYAN     EQU  5
BLACK_YELLOW   EQU  6
BLACK_WHITE    EQU  7

BLUE_BLACK     EQU  8
BLUE_BLUE      EQU  9
BLUE_RED       EQU  10
BLUE_MAGENTA   EQU  11
BLUE_GREEN     EQU  12
BLUE_CYAN      EQU  13
BLUE_YELLOW    EQU  14
BLUE_WHITE     EQU  15

RED_BLACK      EQU  16
RED_BLUE       EQU  17
RED_RED        EQU  18
RED_MAGENTA    EQU  19
RED_GREEN      EQU  20
RED_CYAN       EQU  21
RED_YELLOW     EQU  22
RED_WHITE      EQU  23

MAGENTA_BLACK  EQU  24
MAGENTA_BLUE   EQU  25
MAGENTA_RED    EQU  26
MAGENTA_MAGENTA EQU  27
MAGENTA_GREEN  EQU  28
MAGENTA_CYAN   EQU  29
MAGENTA_YELLOW EQU  30
MAGENTA_WHITE  EQU  31

GREEN_BLACK    EQU  32
GREEN_BLUE     EQU  33
GREEN_RED      EQU  34
GREEN_MAGENTA  EQU  35
GREEN_GREEN    EQU  36
GREEN_CYAN     EQU  37
GREEN_YELLOW   EQU  38
GREEN_WHITE    EQU  39

CYAN_BLACK     EQU  40
CYAN_BLUE      EQU  41
CYAN_RED       EQU  42
CYAN_MAGENTA   EQU  43
CYAN_GREEN     EQU  44
CYAN_CYAN      EQU  45
CYAN_YELLOW    EQU  46
CYAN_WHITE     EQU  47

YELLOW_BLACK   EQU  48
YELLOW_BLUE    EQU  49
YELLOW_RED     EQU  50
YELLOW_MAGENTA EQU  51
YELLOW_GREEN   EQU  52
YELLOW_CYAN    EQU  53
YELLOW_YELLOW  EQU  54
YELLOW_WHITE   EQU  55

WHITE_BLACK    EQU  56
WHITE_BLUE     EQU  57
WHITE_RED      EQU  58
WHITE_MAGENTA  EQU  59
WHITE_GREEN    EQU  60
WHITE_CYAN     EQU  61
WHITE_YELLOW   EQU  62
WHITE_WHITE    EQU  63

