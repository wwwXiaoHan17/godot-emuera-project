extends RefCounted
## eraTW 的 ASCII 彩色地图数据（大地图/原型共用）
##
## 来源：eraTW（eratw-sub-modding-develop）ERB/COLOREDMAPS/COLOREDFIELD.ERB 的
## AA:00..AA:31 与 MAPROW_COLORS:00..31 两段，原样搬过来，只去掉 U+200B（零宽空格）。
## 2026-11-05：GEMono SC 已把 ∬（U+222C）和 卍（U+534D）补进字符集，
## 这里用原字符，不再替换。
##
## 颜色每行一个逗号分隔的标记："" = 沿用上一个颜色，"def"/"0" = 默认色，
## "0xRRGGBB" = 具体颜色，其他名字（floran 等）= 季节色，由行部件按近似色处理。
## 数字字符（0-9）是地点编号，行部件会把它们变成可点的按钮（方案 A）。

## 32 行字符画（全角格宽 32 格，行内混有半角字符）。
const ROWS := [
	"┏━━━━━━━━━━━━━━━━↑━━━━━━━━━━━━━┓",
	"┃Ω旦旦┃　　　　　　　火　　∬∬10∬∬▲▲　　（　　⌒　　⌒┃",
	"┃旦旦旦┃　　　　　　ﾐﾐ川シ　　∬∬∬ ▲▲▲   　　（　仝　～┃",
	"┃━━门┛　　06　　　仝州　　　　▲▲▲▲▲▲▲（　　　　　　┃",
	"┃||　　　　　　　　　≡　　　　 ▲▲▲▲08▲仝▲▲ （　　　ノ┃",
	"┃||||　　　　　仝　　三　　 |||▲▲▲▲▲▲▲三三▲　～ ~　　┃",
	"┃||||||||　　　　　　　　 ||||▲▲▲森▲▲木▲三三▲ 　　　　┃",
	"┃木||||||||||||＝||||||||||||▲▲▲▲木▲▲▲▲▲||▲林　　　┃",
	"┃木木||||||||||||||||||||||▲▲∩09林木▲林▲森▲ﾐﾐﾐﾐ▲▲　　┃",
	"┃木木木木木|||||||||||||▲▲▲(((三林木林林林▲林ﾐﾐﾐﾐ林林林　┃",
	"┃林林林木森林::＝::木林林林林▲▲木▲林林▲▲▲▲ﾐﾐﾐﾐ▲林林木┃",
	"┃林林林森森木言┃言木林林┏━━┓木木木林木07林▲||▲林林▲木┃",
	"┃林森森森森木言┃言木┏━┛林林┗━┓木森┏┛森森||林森林林森┃",
	"┃森森森森林林林┗━━┛森森森林林林┃木森┃森森林||林林森林森┃",
	"┃森森森森林林::::林森森森森森森森森┃木林┗┓林木||林林木木森┃",
	"┃森森森森林森::::林森森森森森森森森┣━━━┻━━三三林▲木森┃",
	"┃森森森森森森森森森森合林森05森森森┗┓森林林林林三三┣╋┫森┃",
	"┃森林林林林森森森森森森森森森森合林林┃森林林林林三三￣03￣三┃",
	"┃森林林木木木林▲森森森森森森森森林林┃森森林仝林三三三三三三┃",
	"┃林竹竹竹竹竹▲▲▲森森森林森森森林┏┛森森林林森森三三三三三┃",
	"┃竹竹竹竹竹竹竹▲▲森森林林林林林林┃林森森林森森森三三三三三┃",
	"┃竹竹竹竹竹竹竹竹▲林林┏━┳━━━┛森森森森森森森森林林木▲┃",
	"┃竹竹竹竹竹竹竹竹林┏━┛林┃林林木木木木木木林森森森林木▲▲┃",
	"┃竹竹竹竹04竹竹竹━┛林森林┃林林林木木木木木林林森森林林林▲┃",
	"┃竹竹竹仝竹竹竹竹木林林森森┃┏━━━━━┓木木林林森林林林林┃",
	"┃竹竹竹竹竹竹竹林林林林森森┃┃合合02合合┃木木林林森森林林林┃",
	"┃竹竹竹竹竹竹γγ林木木木木┃┃合合╋合合┃木林林林森森林林森┃",
	"┃森ρρρρ木γγ林木木林林┃┗━━┃━━┛木林林林森森森林Ⅱ┃",
	"┃森ρρρρ木木林林木木01卍┻━━━┻━━━┓林林林┏━00仝11Ω",
	"┃森ρρρ林仝林林林木木木木木木木木木木木木┗━━━┛森森森▲┃",
	"┃森木木林林林木木木木木木▲▲森森森森森林林林林林森森森森森▲┃",
	"┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛",
]

## 每行逐字的颜色标记（逗号分隔，个数与 ROWS 同行的字符数一致）。
const COLORS := [
	"0x797901,,,,,,,,,,,,,,,,,white,0x797901,,,,,,,,,,,,,",
	"0x797901,0x8A8CF5,0x8C463C,0x8C463C,0x780000,def,,,,,,,0x5A1E00,def,,0x790179,0x3D013D,0,,0x3D013D,0x790179,0x292929,,def,,0xC8C8C8,def,,0xC8C8C8,def,,0xC8C8C8,0x3D3D01",
	"0x797901,0x8C463C,0x8C463C,0x8C463C,0x780000,def,,,,,,0x5A1E00,,,,def,,0x790179,,,def,0x292929,0x505050,,def,0x292929,def,,,0xC8C8C8,def,0xD167D7,def,0,0x3D3D01",
	"0x797901,0x780000,,,,def,,0,,def,,,0xC8C8C8,0x5A1E00,def,,,,0x787878,0x505050,0x292929,0x787878,,0xA1A1A1,0x292929,0xA0A0A0,def,,,,,,0x3D3D01",
	"0x797901,0x295179,,def,,,,,,,,,0x505050,def,,,,,0x787878,0x292929,0x505050,,0,,0x292929,0x00F000,0x292929,,def,0xC8C8C8,def,,,0xA0A0A0,0x3D3D01",
	"0x797901,0x295179,0x51A1F1,,,def,,,,,0xC8C8C8,def,,0xC8C8C8,def,,,0x51A1F1,,,0x787878,,,,,0x505050,0x292929,0x51A1F1,,0x292929,def,0xC8C8C8,def,0xC8C8C8,def,,0x3D3D01",
	"0x797901,0x295179,,,,0x51A1F1,,,,def,,,,,,,,,0x295179,,,,0x787878,,,floran,0x505050,0x282828,florad,0x282828,0x51A1F1,,0x292929,0xA1A1A1,def,,,,0x3D3D01",
	"0x797901,floras,0x51A1F1,,,0x295179,,,,,0x51A1F1,,,,0x47291F,0x51A1F1,,,,0x295179,,,,,,,,0x787878,0x292929,,,florad,0x292929,,,,,0x97C9F0,,0x515151,florad,def,,,0x3D3D01",
	"0x797901,floras,,0x51A1F1,0x295179,,,0x51A1F1,0x295179,,,0x51A1F1,,,,,0x295179,,,,,,,,,0x787878,,0x282828,0,,florad,,0x292929,florad,0x292929,floras,0x292929,0x3C89B3,,,,0x292929,,def,,0x3D3D01",
	"0x797901,florad,,floras,,,0x295179,,,,,,,,,,,,,0x515151,,,0x3C78B4,0x50A0F0,,0x51A1F1,florad,,,,,0x505050,florad,0x3C89B3,,,,florad,,,def,0x3D3D01",
	"0x797901,florad,,,,,,0xFFFFFF,,0x47291F,0xFFFFFF,,floran,floras,florad,,,0x151515,,florad,0x515151,florad,,0x292929,,,0x505050,0x3C89B3,,,,0x292929,florad,,,0x3D3D01",
	"0x797901,floran,,florad,,,floran,0x513D29,0x47291F,0x513D29,floran,floras,,0x47291F,,,,florad,,,,,0,,florad,0x292929,0x97C9F0,,0x292929,florad,,0x515151,florad,0x3D3D01",
	"0x797901,floran,,,florad,,floran,0x513D29,0x47291F,0x513D29,floran,0x47291F,,,floras,,0x47291F,,,floras,florad,0x47291F,,florad,,0x97C9F0,,florad,,,,floran,0x3D3D01",
	"0x797901,floran,,,florad,,,floran,0x47291F,,,,floras,,,,,,0x47291F,floras,florad,0x47291F,florad,,,0x97C9F0,,florad,,,floran,,0x3D3D01",
	"0x797901,floran,,,florad,,,0xFFFFFF,,,,floras,,,,,,,,,0x47291F,floras,florad,0x47291F,,florad,,0x97C9F0,,florad,,,,floran,0x3D3D01",
	"0x797901,floran,,,florad,,,0xFFFFFF,,,,floras,,,,,,,,,0x47291F,,,,,,,0x51A1F1,,florad,0xEC0A0A,florad,,0x3D3D01",
	"0x797901,florad,,floran,florad,,,,floras,,,0x513D29,floras,,0,,floras,,,0x47291F,,florad,,,,,0x51A1F1,,0xA0A0A0,,,florad,0x3D3D01",
	"0x797901,florad,,,,,,,,floras,,,,,,,0x513D29,floras,,0x47291F,florad,,,,,0x51A1F1,,0xA0A0A0,0,,0xA0A0A0,0x51A1F1,0x3D3D01",
	"0x797901,florad,,,,,,,0x797979,floras,,,,,,,,,,0x47291F,florad,,,0xA0A0A0,florad,0x51A1F1,,,,,,0x3D3D01",
	"0x797901,florad,bambool,,bamboon,,bambool,0x797979,0x515151,0x505050,floras,,,,,,,,0x47291F,,florad,,,,,floran,0x51A1F1,,,,,0x3D3D01",
	"0x797901,bambool,,bamboon,,bambood,bambool,,0x292929,,floras,,florad,,,floras,,,0x47291F,florad,,,,floran,,,0x51A1F1,,,,,0x3D3D01",
	"0x797901,bambool,bamboon,,bambood,,bamboon,bambool,,0x292929,florad,,0x47291F,,,,,,,florad,,,,floran,,,,florad,,,0x515151,0x3D3D01",
	"0x797901,bamboon,,,bambood,,bamboon,,bambool,florad,0x47291F,,,florad,0x47291F,floral,,floran,,,floral,,,florad,floran,,,florad,,0x292929,0x515151,0x3D3D01",
	"0x797901,bamboon,,bambood,,0,,bamboon,,bambool,0x47291F,,florad,,floran,0x47291F,floral,,,floran,,,,,florad,,floran,,,florad,,0x292929,0x3D3D01",
	"0x797901,bamboon,,bambood,0x7896B4,bamboon,,,bambool,florad,,,,floran,0x47291F,0x515151,,,,,,,floral,floran,florad,,floran,,florad,,,0x3D3D01",
	"0x797901,bamboon,,,bambood,,bamboon,bambool,florad,,,,,floran,0x47291F,0x515151,0x513D29,,0,,0x513D29,,0x515151,floral,floran,florad,,floran,,florad,,,0x3D3D01",
	"0x797901,bamboon,,,,bambool,,sakurad,,florad,,,,floran,0x47291F,0x515151,0x513D29,,0x47291F,0x513D29,,0x515151,floral,florad,,,floran,,florad,,floran,0x3D3D01",
	"0x797901,florad,0xF1DD79,,,,florad,sakurad,,florad,,,,floran,0x47291F,0x515151,,,0x47291F,0x515151,,,floral,florad,,,floran,,,florad,0x47291F,0x3D3D01",
	"0x797901,florad,0xF1DD79,0xF19751,0xF1DD79,,florad,,,,,,0,,0x7896B4,0x47291F,,,,,,,,,florad,,,0x47291F,,0,,0xF00000,0xFFFFFF,,0x790179",
	"0x797901,florad,0xF1DD79,0xF19751,,florad,0xF0DC78,florad,,,,,,,floran,,floral,,,,floran,floral,0x47291F,,,,,floran,,,0x515151,0x3D3D01",
	"0x797901,florad,,,,,,,,,,,,0x515151,,floran,,,,,,,,,,,,,,,0x292929,0x3D3D01",
	"0x3D3D01,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
]
