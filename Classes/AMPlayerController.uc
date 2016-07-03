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
var bool isBot;
var bool enemySighted;
var PlayerController enemyPlayer;
var float lastShotFiredTime;
var AMPlayerController BotMaster;
var Pawn unpossessedPawn;
var int numPathNode;
var float lastPathNodeTime;
var bool pathNodeReached;
var array<int> lastNumAlternativePathNodes;
var array<PathNode> UsedPathNodes;
var int StartRecordingPathNodes;
var PathNode PathNodeGoal;
var int StartPathNodeGoal;
var AMPlayerController FindPlayer;
var string PID;
//KME
