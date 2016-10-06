class AMPlayerController extends SwatGame.SwatMutator;

//KMS
struct NormalCamperStruct
{
    var int camperstarttime;
    var int oldkills;
    var int TimeLastMsg;
    var bool DoneInitialWarn;
    var Vector OldLocation;
};

struct AntiCheatStruct
{
    var int TimesNotRecoiled;
    var Rotator OldRotation;
    var float Startfiring;
    var float LastStartfiring;
    var int StartfiringTimesNotRecoiled;
    var int lastnumrounds;
    var bool WeaponWasIdle;
    var float stopfirestarttime;
    var int SavedTimesNotRecoiled;
    var int LastNoRecoilCheck;
    var int Totalbulletsfired;
    var int LastNumOfBulletsBeforeStartFiring;
    var Rotator TasedOldRotation;
    var float LastTasedTime;
    var int MovingWhileTasedTimes;
    var int LongPepperSprayRangeTimes;
    var int LongTaseRangeTimes;
    var int LastStungBulletsInGun;
    var float LastStungTime;
    var int ShootingWhileStungTimes;
    var bool DisableTempCheatMovingCheck;
    var int OldPing;
    var float LastPingChangeTime;
    var bool DisableCheatCheckBecausePing;
    var float LastCheatDetectionOffTimeCheck;
    var float CheatDectionOffTotal;
    var int MyBanCode;
    var bool CanBeBanned;
};
//KME

struct Idle
{
	var vector oldLocation;
	var rotator oldRotation;
	var bool wasDead;
	var bool wasDucked;
	var int idleTime;
	var int IdleWarningTime;
	var int idleWait;
	var int savedTime;
};

struct NonLethaled
{
	var float flashbanged;
	var float gassed;
	var float peppered;
	var float stung;
	var float tased;
};

var PlayerController PC;
var Controller	CurrentController;
var NonLethaled nonLethal;
var bool VIPArrested;
var bool forceLessLethal;
var bool goLessLethalNow;
var bool seenMOTD;
var bool isSuperAdmin;
var bool isAdmin;
var bool isSubAdmin;
var bool isSpectator;
var bool wasSpectator;
var bool teamForced;
var bool teamKillActionTaken;
var bool shouldKick;
var bool shouldBan;
var bool kicked;
var bool noWeapons;
var bool muted;
var bool killedVIP;
var int specMode;
var int	Timer;
var int Team;
var int PingWarningTime;
var int OverPingTime;
var int vipKills;
var int numMessages;
var int id;
var int checkingKey;
var array<float> chatTimes;
var float mutedTime;
var float lastMessageTime;
var float joinTime;
var string networkAddress;
var string Name;
var string lessLethalReason;
var string kickReason;
var string banner;
var string bannersIP;
var string banComment;
var string banTime;
var Idle idleCheck;

// KMS
var bool wasDead;
var bool IsDead;
var NormalCamperStruct NormalCamper;
var int campingtimes;
var float lastShotFiredTime;
var Pawn unpossessedPawn;
var string PID;
var AntiCheatStruct AntiCheat;
//KME
