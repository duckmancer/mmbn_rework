extends Node

enum Element {
	NONE,
	WIND,
	BREAK,
	SWORD,
	QUAKE,
	BLOCK,
	HEART,
	INVIS,
	PLUS,
	FIRE,
	AQUA,
	ELEC,
	WOOD,
	HIDE,
}

enum ChipID {
	# ~~~ STANDARD CHIPS ~~~
	CANNON = 0,
	HICANNON,
	M_CANNON,
	AIRSHOT,
	VULCAN1,
	VULCAN2,
	VULCAN3,
	SPREADER,
	HEATSHOT,
	HEAT_V,
	HEATSIDE,
	BUBBLER,
	BUB_V,
	BUBLSIDE,
	THUNDER1,
	THUNDER2,
	THUNDER3,
	WIDESHT1,
	WIDESHT2,
	WIDESHT3,
	FLMLINE1,
	FLMLINE2,
	FLMLINE3,
	GUNSOL1,
	GUNSOL2,
	GUNSOL3,
	BLIZZARD,
	HEATBRTH,
	ELECSHOK,
	WOODPWDR,
	SANDRING,
	TWNFNG1,
	TWNFNG2,
	TWNFNG3,
	ELEMFLAR,
	ICEELEM,
	ELEMLEAF,
	ELEMSAND,
	MAGBOLT1,
	MAGBOLT2,
	MAGBOLT3,
	TORNADO,
	STATIC,
	MINIBOMB,
	ENERGBOM,
	MEGENBOM,
	BALL,
	BLKBOMB,
	GEYSER,
	BUGBOMB,
	BINDER1,
	BINDER2,
	BINDER3,
	SWORD,
	WIDESWRD,
	LONGSWRD,
	WIDEBLDE,
	LONGBLDE,
	CUSTSWRD,
	VARSWRD,
	SLASHER,
	WINDRACK,
	AIRHOC1,
	AIRHOC2,
	AIRHOC3,
	COUNTER1,
	COUNTER2,
	COUNTER3,
	BOOMER1,
	BOOMER2,
	BOOMER3,
	SIDBMBO1,
	SIDBMBO2,
	SIDBMBO3,
	LANCE,
	WHITWEB1,
	WHITWEB2,
	WHITWEB3,
	MOKORUS1,
	MOKORUS2,
	MOKORUS3,
	CIRCGUN1,
	CIRCGUN2,
	CIRCGUN3,
	SNAKE,
	MAGNUM,
	BIGHAMR1,
	BIGHAMR2,
	BIGHAMR3,
	BOYBOMB1,
	BOYBOMB2,
	BOYBOMB3,
	TIMEBOMB,
	MINE,
	ROCKCUBE,
	WIND,
	FAN,
	FANFARE,
	DISCORD,
	TIMPANI,
	SILENCE,
	VDOLL,
	GUARD1,
	GUARD2,
	GUARD3,
	CRAKOUT,
	DUBLCRAK,
	TRIPCRAK,
	RECOV10,
	RECOV30,
	RECOV50,
	RECOV80,
	RECOV120,
	RECOV150,
	RECOV200,
	RECOV300,
	REPAIR,
	PANLGRAB,
	AREAGRAB,
	METAGEL,
	GRABBNSH,
	GRABRVNG,
	PNLRETRN,
	GEDDON1,
	GEDDON2,
	GEDDON3,
	SLOGAUGE,
	FSTGAUGE,
	BLINDER,
	NRTHWIND,
	HOLYPANL,
	HOLE,
	INVIS,
	POPUP,
	BARRIER,
	BARR100,
	BARR200,
	ANTIFIRE,
	ANTIAQUA,
	ANTIELEC,
	ANTIWOOD,
	ANTIDMG,
	ANTISWRD,
	ANTINAVI,
	ANTIRECV,
	COPYDMG,
	LIFESYNC,
	ATK_10,
	NAVI_20,
	COLORPNT,

# ~~~ MEGA CHIPS ~~~
	SUPRVULC,
	NEOVARI,
	SHOTSTAR,
	GODHAMMR,
	GUARDIAN,
	JEALOUSY,
	BUGCHAIN,
	BUGFIX,
	FULLCUST,
	LIFEAURA,
	SNCTUARY,
	ATK_30,
	DBLPOINT,
	MURAMASA,
	ANUBIS,
	ELEMDARK,
	BLAKWING,
	DRKLINE,
	
	ROLL,
	ROLLSP,
	ROLLDS,
	GUTSMAN,
	GUSTMNSP,
	GUTSMNDS,
	WINDMAN,
	WINDMNSP,
	WINDMNDS,
	SERCHMAN,
	SRCHMNSP,
	SRCHMNDS,
	FIREMAN,
	FIREMNSP,
	FIREMANDS,
	THUNMAN,
	THUNMNSP,
	THUNMANDS,
	
	PROTOMAN,
	PROTOMSP,
	PROTOMDS,
	NUMBRMAN,
	NUMBMNSP,
	NUMBMNDS,
	METALMAN,
	METLMNSP,
	METLMNDS,
	JUNKMAN,
	JUNKMNSP,
	JUNKMNDS,
	AQUAMAN,
	AQUAMNSP,
	AQUAMNDS,
	WOODMAN,
	WOODMNSP,
	WOODMNDS,
	
	TOPMAN,
	TOPMNSP,
	TOPMNDS,
	BURNMAN,
	BURNMNSP,
	BURNMANDS,
	COLDMAN,
	COLDMNSP,
	COLDMNDS,
	SPARKMAN,
	SPRKMNSP,
	SPRKMNDS,
	SHADEMAN,
	SHADMNSP,
	SHADMNDS,
	LASERMAN,
	LASRMNSP,
	LASRMNDS,
	KENDOMAN,
	KENDMNSP,
	KENDMNDS,
	VIDEOMAN,
	VIDEMNSP,
	VIDEMNDS,

# ~~~ GIGA CHIPS ~~~
	REDSUN,
	HOLYDREM,
	BASS,
	BUGCHARG,
	BLAKBARR,

	BLUEMOON,
	SIGNLRED,
	BASSANLY,
	BUGCURSE,
	DELTARAY,

# ~~~ SECRET CHIPS ~~~
	ROLLARO1,
	ROLLARO2,
	ROLLARO3,
	GUTPNCH1,
	GUTPNCH2,
	GUTPNCH3,
	PROPBOM1,
	PROPBOM2,
	PROPBOM3,
	SEEKBOM1,
	SEEKBOM2,
	SEEKBOM3,
	METEORS1,
	METEORS2,
	METEORS3,
	LIGTNIN1,
	LIGTNIN2,
	LIGTNIN3,
	
	HAWKCUT1,
	HAWKCUT2,
	HAWKCUT3,
	NUMBRBL1,
	NUMBRBL2,
	NUMBRBL3,
	METLGER1,
	METLGER2,
	METLGER3,
	PANLSHT1,
	PANLSHT2,
	PANLSHT3,
	AQUAUP1,
	AQUAUP2,
	AQUAUP3,
	GREENWD1,
	GREENWD2,
	GREENWD3,
	
	GUNSOLEX,
	Z_SAVER,
	
# ~~~ DARK CHIPS ~~~
	DARKBOMB,
	DRKCANON,
	DRKLANCE,
	DRKRECOV,
	DRKSPRED,
	DRKSTAGE,
	DRKSWORD,
	DRKVULCN,

# ~~~ UNOBTAINABLE ~~~
	DUO,
	GRANDPRIXPOWER,
	FINALGUN,
	
	_END,
}

const DEBUG_PACK : Dictionary = {
	"Cannon A" : 4,
	"Cannon B" : 4,
	"AirShot A" : 4,
	"Vulcan1 V" : 4,
	"MiniBomb B" : 4,
	"MiniBomb L" : 4,
	"Sword S" : 4,
	"WideSwrd S" : 4,
	"CrakOut *" : 4,
	"Recov10 A" : 4,
	"Recov10 L" : 4,
	"AreaGrab S" : 4,
	"Atk+10 *" : 4,
	"Guard1 A" : 4,
	"Thunder1 P" : 4,
	"HeatShot D" : 4,
}

const DEFAULT_FOLDER : Dictionary = {
	"Cannon A" : 2,
	"Cannon B" : 2,
	"AirShot A" : 3,
	"Vulcan1 V" : 3,
	"MiniBomb B" : 2,
	"MiniBomb L" : 2,
	"Sword S" : 4,
	"WideSwrd S" : 2,
	"CrakOut *" : 3,
	"Recov10 A" : 2,
	"Recov10 L" : 2,
	"AreaGrab S" : 1,
	"Atk+10 *" : 2,
}

const CHIP_DATA : Dictionary = {
	ChipID.CANNON : {
		element = Element.NONE,
		power = 40,
		description = "Cannon to attack 1 enemy",
	},
	ChipID.HICANNON : {
		element = Element.NONE,
		power = 80,
		description = "Cannon to attack 1 enemy",
	},
	ChipID.M_CANNON : {
		element = Element.NONE,
		power = 120,
		description = "Cannon to attack 1 enemy",
	},
	ChipID.MINIBOMB : {
		element = Element.NONE,
		power = 50,
		description = "Throws a bomb 3 squares",
	},
	ChipID.SWORD : {
		element = Element.SWORD,
		power = 80,
		description = "Cuts enmy in front! Range: 1",
	},
	ChipID.WIDESWRD : {
		element = Element.SWORD,
		power = 80,
		description = "Cuts enmy in front! Range: 3",
	},
	ChipID.LONGSWRD : {
		element = Element.SWORD,
		power = 80,
		description = "Cuts enmy in front! Range: 2",
	},
	ChipID.HEATSHOT : {
		element = Element.FIRE,
		power = 60,
		description = "Explodes 1 square behind",
	},
	ChipID.HEAT_V : {
		element = Element.FIRE,
		power = 70,
		description = "Explodes 2 diag. squares",
	},
	ChipID.HEATSIDE : {
		element = Element.FIRE,
		power = 100,
		description = "Explodes up,down on hit",
	},
	ChipID.BUBBLER : {
		element = Element.AQUA,
		power = 40,
		description = "Explodes 1 square behind",
	},
	ChipID.AIRSHOT : {
		element = Element.WIND,
		power = 20,
		description = "Knocks enemy back 1",
	},
	ChipID.VULCAN1 : {
		element = Element.NONE,
		power = 10,
		description = "3-shot to pierce 1 panel!",
	},
	ChipID.VULCAN2 : {
		element = Element.NONE,
		power = 10,
		description = "5-shot to pierce 1 panel!",
	},
	ChipID.VULCAN3 : {
		element = Element.NONE,
		power = 10,
		description = "7-shot to pierce 1 panel!",
	},
	ChipID.AREAGRAB : {
		element = Element.NONE,
		description = "Steals left edge from enmy",
	},
	ChipID.RECOV10 : {
		element = Element.HEART,
		power = 10,
		description = "Recovers 10HP",
	},
	ChipID.ATK_10 : {
		element = Element.PLUS,
		description = "+10 for selected atk chip",
	},
	ChipID.CRAKOUT : {
		element = Element.QUAKE,
		power = 30,
		description = "Destroys 1 panel in front",
	},
	ChipID.GUARD1 : {
		element = Element.NONE,
		power = 60,
		description = "Hold to counter!",
	},
	ChipID.THUNDER1 : {
		element = Element.ELEC,
		power = 40,
		description = "Parlyzing electric attack!",
	},
}


var _active_folder : Array = []


func create_active_folder() -> void:
	_active_folder.clear()
	for chip in PlayerData.chip_folder:
		for _count in PlayerData.chip_folder[chip]:
			_active_folder.append(get_chip_data(chip))
	_active_folder.shuffle()

func get_chip_from_folder() -> Dictionary:
	var result = null
	if not _active_folder.empty():
		result = _active_folder.front()
		_active_folder.pop_front()
	return result


func get_chip_data(chip : String) -> Dictionary:
	var data = {}
	
	var data_parts = chip.split(" ")
	assert(data_parts.size() == 2)
	
	data.pretty_name = data_parts[0]
	data.code = data_parts[1]
	data.name = data.pretty_name.replace("+", "_").replace("-", "_").to_lower()
	
	assert(data.code.length() == 1)
	assert(data.code in "ABCDEFGHIJKLMNOPQRSTUVWXYZ*")
	assert(data.name.to_upper() in ChipID)
	
	data.id = ChipID[data.name.to_upper()]
	if data.id in CHIP_DATA:
		Utils.overwrite_dict(data, CHIP_DATA[data.id])
	return data

func _ready() -> void:
	pass
