extends Node

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

var selected_folder : Array = [
	"Cannon A",
	"Cannon B",
	"Cannon C",
	"HiCannon B",
	"HiCannon C",
	"HiCannon D",
	"M-Cannon C",
	"M-Cannon D",
	"M-Cannon E",
	"Sword E",
	"Sword F",
	"Sword G",
	"MiniBomb B",
	"MiniBomb C",
	"MiniBomb D",
	"HeatShot B",
	"HeatShot C",
	"HeatShot D",
	"Heat-V C",
	"Heat-V D",
	"Heat-V E",
	"HeatSide D",
	"HeatSide E",
	"HeatSide F",
]

var _active_folder : Array = []


func create_active_folder() -> void:
	_active_folder.clear()
	for chip in selected_folder:
		_active_folder.append(_get_chip_data(chip))
	_active_folder.shuffle()

func get_chip_from_folder() -> Dictionary:
	var result = null
	if not _active_folder.empty():
		result = _active_folder.front()
		_active_folder.pop_front()
	return result


func _get_chip_data(chip : String) -> Dictionary:
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
	return data

func _ready() -> void:
	pass
