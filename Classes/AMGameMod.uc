class AMGameMod extends SwatGame.SwatMutator;

import enum Pocket from Engine.HandheldEquipment;
import enum EMPMode from Engine.Repo;

var		globalconfig array<string>	AutoAction;					// Automatic messages/commands etc.
var		globalconfig string			BaseMOTD;					// Base Message of the day.
var		globalconfig bool			BroadCastToAllAdmins;		// Show admin command messages to all admins.
var		globalconfig array<string>	CaseCoordinates;			// S&G Case Spawn Points
var		globalconfig bool			DisableMod;					// Disables the entire mod.
var		globalconfig bool			DisableModMessage;			// Disables 'Admin Mod by...'.
var		globalconfig bool			FlushVariables;				// Flush the variables to disk when saving (slow).
var		globalconfig bool			ForceEquipment;				// Force everyone to use preset equipment.
var		globalconfig string			IdleAction;					// Idle Action.
var		globalconfig int			IdleActionTime;				// Time before kicking for being idle.
var		globalconfig string			IdleAdminAction;			// Idle Action.
var		globalconfig string			IdleSubAdminAction;			// Idle Action.
var		globalconfig int			IdleWarningInterval;		// Time between warning messages.
var		globalconfig bool			IgnoreHighPingAdmins;		// Ignore DeadNHappy.
var		globalconfig bool			IgnoreHighPingSubAdmins;	// Ignore MaxJoinPassword people.
var		globalconfig int			InitialIdleWarningInterval;	// Initial warning message time.
var		globalconfig string			LockedDefaultTeam;			// Team to put them on after connection.
var		globalconfig string			LockedGameType;				// Lock the gametype.
var		globalconfig string			LockedServerName;			// Lock the server name.
var		globalconfig bool			LockMapList;				// Locks the maplist.
var		globalconfig int			MaxPlayerPing;				// Max ping before being kicked.
var		globalconfig string			MOTD;						// Message of the day.
var		globalconfig int			PingKickTime;				// Time before being kicked for high ping.
var		globalconfig int			PingWarningInterval;		// Time between warning messages.
var		globalconfig array<string>	ReplaceEquipment;			// Replace certain equipment.
var		globalconfig bool			ShowKickRoomMessage;		// Show a message when a player is kicked for admin room.
var		globalconfig bool			StrictPlayerNames;			// Make sure the player is not using illegal characters in his/her name.
var		globalconfig bool			SuspectArrestTime;			// Adds time to the round if suspects make an arrest.
var		globalconfig bool			SuspectCaseTime;			// Adds time to the round if suspects make an arrest.
var		globalconfig string			TeamKillAction;				// Kick=Kick,Ban=Ban/KickBan,Nothing=Else.
var		globalconfig bool			TeamKillActionAdminPresent;	// Still check for teamkillers if an admin is here?.
var		globalconfig int			TeamKillActionLevel;		// Number of teamkills required before the above action is taken.
var		globalconfig int			TeamSpread;					// Allow a spread of this much.
var		globalconfig bool			UniquePlayerNames;			// Stop players using the same names.
var		globalconfig string			VIPKillAction;				// Kick=Kick,Ban=Ban/KickBan,Nothing=Else.
var		globalconfig int			VIPKillActionKills;			// Number of VIP kills before the action is taken.

var array<AMPlayerController> PlayerList;
var array<string> AdminIPs;
var array<string> SuperAdminIPs;
var array<string> SubAdminIPs;
var PlayerController wishVIP;
var bool hasEnded;
var bool wasEnded;
var bool teamsLocked;
var bool validkey;
var bool updatecurrent;
var bool updatepending;
var bool initialisedKeyClasses;
#if SWAT_EXPANSION
var AMSaGMod	SmashGrabMod;
#endif
var int savedscores0;
var int savedscores1;
var int AutoPoint;
var int daysInMonth[13];
var string keyMsg;
var string latestversion;
var string webadminheader;
var string webadminfooter;
var string adminmsg;
var AMAccessControl		AccessControl;
var AMAdmin				Admin;
var AMBroadcastHandler	BroadcastHandler;
var AMLink				iLink;
var AMLanguage			Lang;
var AMServerQuery		ServerQuery;
//var AMUAC				UAC;
var AMWebAdminListener	WebAdmin;

var float deleteme;

//KMS
var KZLink KZLink;
var KZMod KZMod;
//KME

struct LoadoutChanger
{
	var Pocket Pocket;
	var class<actor> NewClass;
};

function PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( Level.NetMode != NM_ListenServer && Level.NetMode != NM_DedicatedServer )
		Destroy();

	if ( DisableMod )
		Destroy();
}

function BeginPlay()
{
	Super.BeginPlay();

	if ( Level.Game == None || SwatGameInfo(Level.Game) == None )
		return;

	daysInMonth[1] = 31;
	daysInMonth[2] = 28;
	daysInMonth[3] = 31;
	daysInMonth[4] = 30;
	daysInMonth[5] = 31;
	daysInMonth[6] = 30;
	daysInMonth[7] = 31;
	daysInMonth[8] = 31;
	daysInMonth[9] = 30;
	daysInMonth[10] = 31;
	daysInMonth[11] = 30;
	daysInMonth[12] = 31;

	Lang = Spawn( class'AMLanguage' );
	Lang.AGM = self;

	if ( Level.Game.BroadcastHandler != None && !Level.Game.BroadcastHandler.IsA('AMBroadcastHandler') )
	{
		Level.Game.BroadcastHandler.Destroy();
		Level.Game.BroadcastHandler = Spawn( class'AMBroadcastHandler' );
	}

	if ( Level.Game.AccessControl != None && !Level.Game.AccessControl.IsA('AMAccessControl') )
	{
		Level.Game.AccessControl.Destroy();
		Level.Game.AccessControl = Spawn( class'AMAccessControl' );
	}

	if ( SwatGameInfo(Level.Game).Admin != None && !SwatGameInfo(Level.Game).Admin.IsA('AMAdmin') )
	{
		SwatGameInfo(Level.Game).Admin.Destroy();
		SwatGameInfo(Level.Game).Admin = Spawn( class'AMAdmin' );
	}

	AccessControl = AMAccessControl(Level.Game.AccessControl);
	AccessControl.AGM = self;
	Admin = AMAdmin(SwatGameInfo(Level.Game).Admin);
	Admin.AGM = self;
	BroadcastHandler = AMBroadcastHandler(Level.Game.BroadcastHandler);
	BroadcastHandler.AGM = self;

	teamsLocked = false;
	hasEnded = false;

	iLink = Spawn( class'AMLink' );
	iLink.AGM = self;
	iLink.Initialise( 2 );

    KZLink = Spawn(class'KZLink');
    KZLink.AGM = self;

	//UAC = Spawn( class'AMUAC' );
	//UAC.AGM = self;

	KZMod = Spawn(class'KZMod');
    KZMod.AGM = self;

    KZMod.SetTimer(4.0, false);

	ServerQuery = Spawn( class'AMServerQuery' );
	ServerQuery.AGM = self;

	SetTimer(0.001, false);
}

event Destroyed()
{
	local int i;

	if ( BroadcastHandler != None )
		BroadcastHandler.Destroy();

	if ( AccessControl != None )
		AccessControl.Destroy();

	if ( Admin != None )
		Admin.Destroy();

	if ( iLink != None )
		iLink.Destroy();

	//if ( UAC != None )
	//	UAC.Destroy();

	if ( ServerQuery != None )
		ServerQuery.Destroy();

	if ( WebAdmin != None )
		WebAdmin.Destroy();

	if(KZMod != none)
    {
        KZMod.Destroy();
    }

#if SWAT_EXPANSION
	if ( SmashGrabMod != None )
		SmashGrabMod.Destroy();
#endif

	for ( i = 0; i < PlayerList.Length; i++ )
		if ( PlayerList[i] != None )
			PlayerList[i].Destroy();

	Super.Destroyed();
}

event Timer()
{
	local string Msg, resp;

	if ( AutoAction.Length == 0 )
		return;

	Msg = AutoAction[AutoPoint];

	AutoPoint++;
	if ( AutoPoint >= AutoAction.Length )
		AutoPoint = 0;

	if ( Left( Msg, 5 ) ~= "wait " )
	{
		SetTimer( int(Mid( Msg, 5 )), false);
		return;
	}
	else if ( Left( Msg, 3 ) ~= "ac " )
	{
		Admin.AdminCommand( Mid( Msg, 3 ), Lang.ServerString, "", , resp );
		Admin.ShowAdminMsg( resp, None );
	}
	else if ( Left( Msg, 6 ) ~= "print " )
		Level.Game.Broadcast(None, "[c=ffff00]"$Mid( Msg, 6 ), 'Caption');

	SetTimer(0.001, false);
}

function Tick( float Delta )
{
	if ( Level.Outer.Name == 'Entry' )
		return;

	CheckGameEnded();
#if SWAT_EXPANSION
	CheckUpdateScores();
	//CheckAK47();
	CheckCase( Delta );
#endif
	CheckPlayers();
	CheckVIPReplacement();
	CheckPassworded();
	CheckServerName();
	CheckMaps();
	CheckGameType();
}



function CheckSettingsUpdated()
{
	if ( updatecurrent )
	{
		ServerSettings(Level.CurrentServerSettings).SaveConfig( "", "", false, true );

		if ( FlushVariables )
			ServerSettings(Level.CurrentServerSettings).FlushConfig();
	}

	if ( updatepending )
	{
		ServerSettings(Level.PendingServerSettings).SaveConfig( "", "", false, true );

		if ( FlushVariables )
			ServerSettings(Level.PendingServerSettings).FlushConfig();
	}

	if ( updatecurrent || updatepending )
		Level.Game.Broadcast(None, Lang.ServerString, 'SettingsUpdated');

	updatecurrent = false;
	updatepending = false;
}

function CheckPassworded()
{
	if ( lower(AccessControl.GamePassword) == "none" )
		AccessControl.GamePassword = "";

	if ( AccessControl.GamePassword == "" )
	{
		if ( ServerSettings(Level.PendingServerSettings).bPassworded )
		{
			updatepending = true;
			ServerSettings(Level.PendingServerSettings).bPassworded = false;
		}

		if ( ServerSettings(Level.CurrentServerSettings).bPassworded )
		{
			updatecurrent = true;
			ServerSettings(Level.CurrentServerSettings).bPassworded = false;
		}
	}
	else
	{
		if ( !ServerSettings(Level.PendingServerSettings).bPassworded )
		{
			updatepending = true;
			ServerSettings(Level.PendingServerSettings).bPassworded = true;
		}

		if ( !ServerSettings(Level.CurrentServerSettings).bPassworded )
		{
			updatecurrent = true;
			ServerSettings(Level.CurrentServerSettings).bPassworded = true;
		}
	}

	if ( ServerSettings(Level.PendingServerSettings).Password != AccessControl.GamePassword )
	{
		updatepending = true;
		ServerSettings(Level.PendingServerSettings).Password = AccessControl.GamePassword;
	}

	if ( ServerSettings(Level.CurrentServerSettings).Password != AccessControl.GamePassword )
	{
		updatecurrent = true;
		ServerSettings(Level.CurrentServerSettings).Password = AccessControl.GamePassword;
	}

	CheckSettingsUpdated();
}

function CheckServerName()
{
	if ( LockedServerName == "" || lower(LockedServerName) == "none" )
		return;

	if ( ServerSettings(Level.PendingServerSettings).ServerName != LockedServerName )
	{
		updatepending = true;
		ServerSettings(Level.PendingServerSettings).ServerName = LockedServerName;
	}


	if ( ServerSettings(Level.CurrentServerSettings).ServerName != LockedServerName )
	{
		updatecurrent = true;
		ServerSettings(Level.CurrentServerSettings).ServerName = LockedServerName;
	}

	CheckSettingsUpdated();
}

function CheckMaps()
{
	local int i;

	if ( !LockMapList )
		return;

	if ( Admin.SavedMaps.Length != ServerSettings(Level.CurrentServerSettings).NumMaps )
	{
		RestoreMaps();
		SwatRepo(Level.GetRepo()).SwapServerSettings();
		SwatRepo(Level.GetRepo()).ClearRoundsWon();
		SwatRepo(Level.GetRepo()).NetSwitchLevels( false );
		return;
	}

	if ( Admin.SavedMaps.Length != ServerSettings(Level.PendingServerSettings).NumMaps )
	{
		RestoreMaps();
		return;
	}

	for ( i = 0; i < Admin.SavedMaps.Length; i++ )
	{
		if ( ServerSettings(Level.CurrentServerSettings).Maps[i] != Admin.SavedMaps[i] )
		{
			RestoreMaps();
			ServerSettings(Level.PendingServerSettings).RoundNumber = 0;
			SwatRepo(Level.GetRepo()).SwapServerSettings();
			SwatRepo(Level.GetRepo()).ClearRoundsWon();
			SwatRepo(Level.GetRepo()).NetSwitchLevels( false );
			return;
		}

		if ( ServerSettings(Level.PendingServerSettings).Maps[i] != Admin.SavedMaps[i] )
		{
			RestoreMaps();
			return;
		}
	}
}

function RestoreMaps()
{
	Admin.RestoreMaps( true );

	Level.Game.Broadcast(None, Lang.ServerString, 'SettingsUpdated');
}

function CheckGameType()
{
	local EMPMode GT;

	GT = ServerSettings(Level.PendingServerSettings).GameType;

	if ( caps(Left(LockedGameType,1)) == "B" && GT != MPM_BarricadedSuspects )
		RestoreGameType( MPM_BarricadedSuspects );
	else if ( caps(Left(LockedGameType,1)) == "R" && GT != MPM_RapidDeployment )
		RestoreGameType( MPM_RapidDeployment );
	else if ( caps(Left(LockedGameType,1)) == "V" && GT != MPM_VIPEscort )
		RestoreGameType( MPM_VIPEscort );
#if SWAT_EXPANSION
	else if ( caps(Left(LockedGameType,1)) == "S" && GT != MPM_SmashAndGrab )
		RestoreGameType( MPM_SmashAndGrab );
	else if ( caps(Left(LockedGameType,7)) == "COOPQMM" && GT != MPM_COOPQMM )
		RestoreGameType( MPM_COOPQMM );
#endif
	else if ( caps(Left(LockedGameType,4)) == "COOP" && GT != MPM_COOP )
		RestoreGameType( MPM_COOP );
	else
	{
		GT = ServerSettings(Level.CurrentServerSettings).GameType;

		if ( caps(Left(LockedGameType,1)) == "B" && GT != MPM_BarricadedSuspects )
			RestoreGameType( MPM_BarricadedSuspects );
		else if ( caps(Left(LockedGameType,1)) == "R" && GT != MPM_RapidDeployment )
			RestoreGameType( MPM_RapidDeployment );
		else if ( caps(Left(LockedGameType,1)) == "V" && GT != MPM_VIPEscort )
			RestoreGameType( MPM_VIPEscort );
	#if SWAT_EXPANSION
		else if ( caps(Left(LockedGameType,1)) == "S" && GT != MPM_SmashAndGrab )
			RestoreGameType( MPM_SmashAndGrab );
		else if ( caps(Left(LockedGameType,7)) == "COOPQMM" && GT != MPM_COOPQMM )
			RestoreGameType( MPM_COOPQMM );
	#endif
		else if ( caps(Left(LockedGameType,4)) == "COOP" && GT != MPM_COOP )
			RestoreGameType( MPM_COOP );
		else
			return;

		SwatRepo(Level.GetRepo()).SwapServerSettings();
		SwatRepo(Level.GetRepo()).ClearRoundsWon();
		SwatRepo(Level.GetRepo()).NetSwitchLevels( false );
	}
}

function RestoreGameType(EMPMode NewGameType)
{
	 SwatRepo(Level.GetRepo()).PreLevelChangeCleanup();
    SwatRepo(Level.GetRepo()).UpdateGameSpyStats();

	ServerSettings(Level.PendingServerSettings).GameType = NewGameType;
	ServerSettings(Level.PendingServerSettings).RoundNumber = 0;
	ServerSettings(Level.PendingServerSettings).SaveConfig( "", "", false, true );
	if ( FlushVariables )
		ServerSettings(Level.PendingServerSettings).FlushConfig();

	Level.Game.Broadcast(None, Lang.ServerString, 'SettingsUpdated');
}

function LockTeams()
{
	teamsLocked = !teamsLocked;
}

function CheckGameEnded()
{
	local int i;

	wasEnded = hasEnded;

	if ( (SwatGameReplicationInfo(Level.GetGameReplicationInfo()).RoundTime <= 0 && ServerSettings(Level.CurrentServerSettings).GameType != MPM_COOP
#if SWAT_EXPANSION
		&& ServerSettings(Level.CurrentServerSettings).GameType != MPM_COOPQMM
#endif
		) || SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState != GAMESTATE_MidGame )
		hasEnded = true;
	else
		hasEnded = false;

	if ( !wasEnded && hasEnded )
	{
#if SWAT_EXPANSION
		if ( SmashGrabMod != None && ServerSettings(Level.CurrentServerSettings).GameType == MPM_SmashAndGrab && SmashGrabMod.BaseClass != None && SmashGrabMod.SAGClass != None && SmashGrabMod.gameItem != None )
		{
			SmashGrabMod.shouldSwitchSpawns = false;
			SmashGrabMod.switchedSpawns = false;
			SmashGrabMod.SwitchSpawnPoints( false );
		}
#endif

		for( i = 0; i < PlayerList.Length; i++ )
		{
			if ( PlayerList[i] != None )
				RemoveLessLethal( PlayerList[i] );
		}
	}
}

function OnSwatArrested( Actor arrester )
{
#if SWAT_EXPANSION
	local float ArrestRoundTimeDeduction;

	if ( !hasEnded && SuspectArrestTime && ServerSettings(Level.CurrentServerSettings).GameType == MPM_SmashAndGrab )
	{
		ArrestRoundTimeDeduction = ServerSettings(Level.CurrentServerSettings).ArrestRoundTimeDeduction;

		// round time is added when suspects make an arrest
		if ( ArrestRoundTimeDeduction > 0 )
		{
			SwatGameReplicationInfo(Level.Game.GameReplicationInfo).ServerCountdownTime += ArrestRoundTimeDeduction;
			Level.Game.Broadcast( None, Lang.FormatLangString( Lang.SecondsAddedString, string(ArrestRoundTimeDeduction) ), 'Caption' );
		}
	}
#endif
}

function OnSuspectArrested( Actor arrester )
{
}

#if SWAT_EXPANSION
function CheckAK47()
{
	local AK47MG TheWeapon;

	ForEach DynamicActors( class'AK47MG', TheWeapon )
	{
        TheWeapon.MuzzleVelocity = 36186;
		TheWeapon.MaxAimError = 60.0;
		TheWeapon.LargeAimErrorRecoveryRate = 6.0;
		TheWeapon.SmallAimErrorRecoveryRate = 1.5;
		TheWeapon.AimErrorBreakingPoint = 2.75;
		TheWeapon.StandingAimError = 0.4;
		TheWeapon.WalkingAimError = 2.0;
		TheWeapon.RunningAimError = 10.5;
		TheWeapon.CrouchingAimError = 0.3;
		TheWeapon.EquippedAimErrorPenalty = 8.5;
		TheWeapon.FiredAimErrorPenalty = 1.35;
	}
}

function CheckUpdateScores()
{
	local int scores0;
	local int scores1;

	scores0 = SwatGameInfo(Level.Game).GetTeamFromID(0).NetScoreInfo.GetRoundsWon();
	scores1 = SwatGameInfo(Level.Game).GetTeamFromID(1).NetScoreInfo.GetRoundsWon();

	if ( savedscores0 != scores0 || savedscores1 != scores1 )
	{
		SwatRepo(Level.GetRepo()).UpdateRoundsWon( 0 );
		SwatRepo(Level.GetRepo()).UpdateRoundsWon( 1 );
		savedscores0 = scores0;
		savedscores1 = scores1;
	}
}

function CheckCase( float Delta )
{
	if ( SmashGrabMod == None || hasEnded || SmashGrabMod.SAGClass == None || SmashGrabMod.SAGClass.gameItem == None || !SuspectCaseTime || ServerSettings(Level.CurrentServerSettings).GameType != MPM_SmashAndGrab )
		return;

	if ( SmashGrabMod.SAGClass.gameItem.Owner != None )
		SwatGameReplicationInfo(Level.Game.GameReplicationInfo).ServerCountdownTime += Delta;
}
#endif

function ForceLessLethal( AMPlayerController SPC, String Reason, bool noweapons )
{
	local SwatGamePlayerController SGPC;

	if ( SPC == None || SPC.PC == None )
		return;

	SPC.forceLessLethal = true;
	SPC.noWeapons = noweapons;
	if ( noweapons )
		SPC.lessLethalReason = Lang.FormatLangString( Lang.NoWeaponsString, Reason );
	else
		SPC.lessLethalReason = Lang.FormatLangString( Lang.LessLethalString, Reason );

	SGPC = SwatGamePlayerController(SPC.PC);

	if ( SGPC == None )
		return;

	if ( !SGPC.IsDead() && !SGPC.IsCuffed() && !hasEnded && !SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP && !SwatPlayerReplicationInfo(SPC.PC.PlayerReplicationInfo).bIsTheVIP )
		SGPC.Pawn.Died( None, class'DamageType', SGPC.Pawn.Location, vect(0,0,0) );
}

function RemoveLessLethal( AMPlayerController SPC )
{
	local SwatGamePlayerController SGPC;

	if ( SPC == None || SPC.PC == None )
		return;

	SPC.noWeapons = false;
	SPC.forceLessLethal = false;

	SGPC = SwatGamePlayerController(SPC.PC);

	if ( SGPC == None )
		return;

	if ( SGPC != None && !SGPC.IsDead() && !SGPC.IsCuffed() && !hasEnded && !SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP && !SwatPlayerReplicationInfo(SPC.PC.PlayerReplicationInfo).bIsTheVIP )
		SGPC.Pawn.Died( None, class'DamageType', SGPC.Pawn.Location, vect(0,0,0) );
}

function AMPlayerController GetAMPlayerController( PlayerController PC )
{
	local int i;

	if ( PC == None )
		return None;

	for( i = 0; i < PlayerList.Length; i++ )
		if ( PlayerList[i] != None && PlayerList[i].PC != None && PC == PlayerList[i].PC )
			return PlayerList[i];

	return None;
}

function AMPlayerController GetAMPlayerControllerByName(string Name)
{
    local int i;

    // End:0x0E
    if(Name == "")
    {
        return none;
    }

    for (i = 0; i < PlayerList.Length ; i++)
    {
    	if(((PlayerList[i] != none) && PlayerList[i].PC != none) && PlayerList[i].Name == Name)
        {
            return PlayerList[i];
        }
    }
    return none;
}

function AMPlayerController GetAMPlayerControllerByPawn(Pawn MyPawn)
{
    local int i;

    // End:0x0D
    if(MyPawn == none)
    {
        return none;
    }

    for (i = 0; i < PlayerList.Length ; i++)
    {
    	if((((PlayerList[i] != none) && PlayerList[i].PC != none) && PlayerList[i].PC.Pawn != none) && PlayerList[i].PC.Pawn == MyPawn)
        {
            return PlayerList[i];
        }
    }
    return none;
}

function ChangePlayer( Controller aPlayer, array<LoadoutChanger> NewLoadout )
{
    local SwatMPStartPoint MPStartSpot;

    MPStartSpot = SwatGameInfo(Level.Game).SpawnNetPlayerPawn( aPlayer );
    if( MPstartSpot == None )
        return;

    NetPlayer(aPlayer.Pawn).SwatPlayerID = SwatGamePlayerController(aPlayer).SwatPlayerID;

    aPlayer.Pawn.LastStartTime = Level.TimeSeconds;
    aPlayer.PreviousPawnClass = aPlayer.Pawn.Class;

    aPlayer.Possess(aPlayer.Pawn);
    aPlayer.PawnClass = aPlayer.Pawn.Class;

#if SWAT_EXPANSION
	SwatGameInfo(Level.Game).SetPlayerTeam( SwatGamePlayerController(aPlayer), NetTeam(aPlayer.PlayerReplicationInfo.Team).GetTeamNumber(), true );
#endif

    aPlayer.Pawn.PlayTeleportEffect(true, true);
    aPlayer.ClientSetRotation(aPlayer.Pawn.Rotation);
    ChangeInventory(aPlayer.Pawn, NewLoadout);
    TriggerEvent( MPStartSpot.Event, MPStartSpot, aPlayer.Pawn);

    SwatPlayerReplicationInfo(aPlayer.PlayerReplicationInfo).COOPPlayerStatus = STATUS_Healthy;
}

function ChangeInventory(Pawn inPlayerPawn, array<LoadoutChanger> NewLoadout )
{
    local OfficerLoadOut LoadOut;
    local SwatPlayer PlayerPawn;
    local SwatRepoPlayerItem RepoPlayerItem;
    local NetPlayer theNetPlayer;
    local int i;
    local DynamicLoadOutSpec LoadOutSpec;
	local bool IsSuspect;

    PlayerPawn = SwatPlayer(inPlayerPawn);

    theNetPlayer = NetPlayer( inPlayerPawn );

    if ( NetPlayer(PlayerPawn).GetTeamNumber() == 0 )
        LoadOut = Spawn(class'OfficerLoadOut', PlayerPawn, 'EmptyMultiplayerOfficerLoadOut' );
    else
        LoadOut = Spawn(class'OfficerLoadOut', PlayerPawn, 'EmptyMultiplayerSuspectLoadOut' );

    RepoPlayerItem = SwatGamePlayerController(PlayerPawn.Controller).SwatRepoPlayerItem;


	for ( i = 0; i < NewLoadout.Length; i++ )
        RepoPlayerItem.RepoLoadOutSpec[ NewLoadout[i].Pocket ] = NewLoadout[i].NewClass;

    for( i = 0; i < Pocket.EnumCount; ++i )
		theNetPlayer.SetPocketItemClass( Pocket(i), RepoPlayerItem.RepoLoadOutSpec[ Pocket(i) ] );

#if SWAT_EXPANSION
	if ( RepoPlayerItem.CustomSkinClassName != "" &&
		RepoPlayerItem.CustomSkinClassName != "SwatGame.DefaultCustomSkin" &&
		RepoPlayerItem.CustomSkinClassName != "SwatGame.DefaultSuspectCustomSkin" )
		theNetPlayer.SetCustomSkinClassName( RepoPlayerItem.CustomSkinClassName );
	else
		theNetPlayer.SetCustomSkinClassName( "SwatGame.DefaultCustomSkin" );
#endif

	LoadOutSpec = theNetPlayer.GetLoadoutSpec();

	for ( i = 0; i < NewLoadout.Length; i++ )
        LoadOutSpec.LoadOutSpec[ NewLoadout[i].Pocket ] = NewLoadout[i].NewClass;

	IsSuspect = theNetPlayer.GetTeamNumber() == 1;

    LoadOut.Initialize( LoadOutSpec
#if SWAT_EXPANSION
						, IsSuspect
#endif
						);

    PlayerPawn.ReceiveLoadOut(LoadOut);

    theNetPlayer.InitializeReplicatedCounts();

	SwatGameInfo(Level.Game).SetPlayerDefaults(PlayerPawn);
}

function bool CheckVIPReplacement()
{
	local AMPlayerController APC;
	local Controller C;
	local PlayerController PC;
	local vector loc;
	local rotator rot;

	if ( wishVIP == None || hasEnded )
		return false;

	APC = GetAMPlayerController(wishVIP);

	if ( APC == None )
		return false;

	for (C = Level.ControllerList; C != none; C = C.nextController)
    {
		PC = PlayerController(C);

		if ( PC == None )
			continue;

		if ( SwatGamePlayerController(C).ThisPlayerIsTheVIP && SwatPlayerReplicationInfo(PC.PlayerReplicationInfo).bIsTheVIP )
		{
			if ( C.Pawn != None && NetPlayer(C.Pawn) != None )
			{
				if ( wishVIP == PC
					|| NetPlayer(C.Pawn).IsBeingArrestedNow()
					//|| NetPlayer(C.Pawn).IsNonlethaled()
					|| C.GetStateName() == 'BeingUncuffed' )
					return false;
			}

			APC.VIPArrested = NetPlayer(C.Pawn).IsArrested();

			if ( NetPlayer(C.Pawn).IsFlashbanged() )
				APC.nonLethal.flashbanged = float(ConsoleCommand("get SwatEquipment.FlashbangGrenadeProjectile PlayerStunDuration")) - (Level.TimeSeconds - NetPlayer(C.Pawn).LastFlashbangedTime);
			if ( NetPlayer(C.Pawn).IsGassed() )
				APC.nonLethal.gassed = NetPlayer(C.Pawn).LastGassedDuration - (Level.TimeSeconds - NetPlayer(C.Pawn).LastGassedTime);
			if ( NetPlayer(C.Pawn).IsPepperSprayed() )
				APC.nonLethal.peppered = NetPlayer(C.Pawn).LastPepperedDuration - (Level.TimeSeconds - NetPlayer(C.Pawn).LastPepperedTime);
			if ( NetPlayer(C.Pawn).IsStung() )
				APC.nonLethal.stung = NetPlayer(C.Pawn).LastStungDuration - (Level.TimeSeconds - NetPlayer(C.Pawn).LastStungTime);
			if ( NetPlayer(C.Pawn).IsTased() )
				APC.nonLethal.tased = NetPlayer(C.Pawn).LastTasedDuration - (Level.TimeSeconds - NetPlayer(C.Pawn).LastTasedTime);

			SwatGamePlayerController(C).ThisPlayerIsTheVIP = false;
			loc = C.Pawn.Location;
			rot = C.Pawn.Rotation;
			SwatPlayerReplicationInfo(PC.PlayerReplicationInfo).bIsTheVIP = false;
			NetPlayer(C.Pawn).Destroy();
			SwatGamePlayerController(PC).SwatPlayer.Destroy();

			NetPlayer(wishVIP.Pawn).Destroy();
			SwatGamePlayerController(wishVIP).SwatPlayer.Destroy();
			if ( SwatGamePlayerController(wishVIP).SwatRepoPlayerItem.TeamID != 0 )
				SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController(wishVIP) );
			SwatGamePlayerController(wishVIP).ThisPlayerIsTheVIP = true;
			SwatPlayerReplicationInfo(wishVIP.PlayerReplicationInfo).bIsTheVIP = true;
			SwatGameInfo(Level.Game).RestartPlayer( wishVIP );
			wishVIP.Pawn.SetLocation( loc );
			wishVIP.Pawn.SetViewLocation( loc );
			wishVIP.Pawn.SetRotation( rot );
			wishVIP.Pawn.SetViewRotation( rot );
			wishVIP.Pawn.ClientSetRotation( rot );

			wishVIP = None;
			return true;
		}
    }

	NetPlayer(wishVIP.Pawn).Destroy();
	if ( SwatGamePlayerController(wishVIP).SwatRepoPlayerItem.TeamID != 0 )
		SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController(wishVIP) );
	SwatGamePlayerController(wishVIP).ThisPlayerIsTheVIP = true;
	SwatPlayerReplicationInfo(wishVIP.PlayerReplicationInfo).bIsTheVIP = true;
	SwatGameInfo(Level.Game).RestartPlayer( wishVIP );

	wishVIP = None;

	return true;
}

function ShowMOTD( PlayerController PC )
{
	local string Msg;
	local int i, length, point;

	Msg = BaseMOTD;

	if ( Msg != "" && MOTD != "" )
		Msg = Msg$"\n"$MOTD;

	// replace \\n's with Chr(13)'s
	i = InStr(Msg, "\\n");
	while(i != -1)
	{
		Msg = Left(Msg, i) $ "\n" $ Mid(Msg, i + 2);
		i = InStr(Msg, "\\n");
	}

#if KEYS
	if ( !DisableModMessage || !validKey )
	{
#endif
		if ( Msg != "" )
			Msg = Msg$"\n";

		if ( adminmsg != "" )
			Msg = Msg$adminmsg;
		else
			Msg = Msg$MODMSG;

		Msg = Msg$" (";
		Msg = Msg$"Version "$MOD_VERSION$MOD_VERSION_SUFFIX$")";

		if ( MODMSG_EXTRA != "" )
			Msg = Msg$"\n"$MODMSG_EXTRA;

#if KEYS
	}
#endif

	if ( latestversion != "" && latestversion > MOD_VERSION )
		Msg = Msg$"\n"$Lang.ModOutOfDateString;

	if ( Level.GetEngine().EnableDevTools || Level.Game.bAllowBehindView
		|| (SwatRepo(Level.GetRepo()).GetEnemyFireModifier() != 0.0 && SwatRepo(Level.GetRepo()).GetEnemyFireModifier() != 1.0) )
		Msg = Msg$"\n"$"CHEATS ARE ON";

	while ( Msg != "" )
	{
		point = 0;
		length = len(Msg);
		if ( length > 350 )
		{
			i = 0;
			while ( i != -1 && i < 350 )
			{
				point = i;
				i = InStrAfter(Msg, "\n", i+2);
			}
		}

		if ( point < 1 )
			point = 350;

		Level.Game.BroadcastHandler.BroadcastText(None, PC, "[c=ffff00]"$Left(Msg, point), 'Caption');

		Msg = Mid(Msg, point+1);
	}
}

function CheckPlayers()
{
	local PlayerController PC;
	local Controller C;
	local int i, numPlayingClients;
	local bool exists;
	local AMPlayerController bestSPC, SPC;
	local int NumPlayers;
	NumPlayers = 0;

	if ( SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState >= GAMESTATE_PreGame && SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState <= GAMESTATE_PostGame )
	{
		for (C = Level.ControllerList; C != none; C = C.nextController)
		{
			PC = PlayerController(C);

			if ( PC == None )
				continue;

			if ( SwatGamePlayerController(PC) == None )
				continue;

			if ( SwatGamePlayerController(PC).SwatRepoPlayerItem == None )
				continue;

			if ( NetConnection(PC.Player) == None && PC != Level.GetLocalPlayerController() )
				continue;

			exists = false;

			for( i = 0; i < PlayerList.Length; i++ )
			{
				SPC = PlayerList[i];

				if ( SPC == None )
					continue;

				if ( SPC.PC == None )
					continue;

				if ( SwatGamePlayerController(SPC.PC) == None )
					continue;

				if ( SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem == None )
					continue;

				if ( NetConnection(SPC.PC.Player) == None && SPC.PC != Level.GetLocalPlayerController() )
					continue;

				if ( PC == SPC.PC )
				{
					exists = true;
					break;
				}
			}

			if ( !exists )
				AddToPlayerList( PC );
		}
	}

	for ( i = PlayerList.Length-1; i >= 0; i-- )
	{
		SPC = PlayerList[i];

		if ( SPC == None )
			continue;

		if ( SPC.PC == None || SwatGamePlayerController(SPC.PC) == None || SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem == None || (NetConnection(SPC.PC.Player) == None && SPC.PC != Level.GetLocalPlayerController()) )
		{
			if ( SPC.Name != "" && SPC.networkAddress != "" )
			{
				Admin.ShowAdminMsg( Lang.FormatLangString( Lang.DisconnectedString, SPC.Name, SPC.networkAddress ), None, true );
			}
			//PlayerList.Remove( i, 1 );
			PlayerList[i].Destroy();
			PlayerList[i] = None;
			continue;
		}

		if(SPC.PC == none)
        {
            PlayerList[i].Destroy();
            PlayerList[i] = none;
            continue;
        }


        ++ NumPlayers;


		if ( SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState < GAMESTATE_PreGame || SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState > GAMESTATE_PostGame )
			SPC.seenMOTD = false;

		if ( !SPC.seenMOTD && SPC.PC.PlayerReplicationInfo.Ping < 999 && (SPC.PC.PlayerReplicationInfo.Ping != 0 || SPC.PC == Level.GetLocalPlayerController()) )
		{
			ShowMOTD( SPC.PC );
			SPC.seenMOTD = true;
			Admin.AdminLogin( SPC.PC, SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem.LastAdminPassword );
		}

		if ( SPC.isSpectator )
			Spectate( SPC );
		else
		{
			numPlayingClients++;
			EndSpectate( SPC );
		}

		CheckName( SPC );
		CheckTeam( SPC );
		CheckVIPKiller( SPC );
		CheckLessLethal( SPC );

		CheckEffects( SPC );

		CheckPing( SPC );
		CheckIdle( SPC );
		CheckMultipleTeamKiller( SPC );

		if ( CheckKickOrBan( SPC ) )
		{
			SPC.kicked = true;
			continue;
		}
	}

	while ( numPlayingClients > AccessControl.MaxPlayingClients && AccessControl.MaxPlayingClients > 0 )
	{
		bestSPC = None;

		for ( i = 0; i < PlayerList.Length; i++ )
		{
			SPC = PlayerList[i];

			if ( SPC == None || SPC.isSpectator )
				continue;

			if ( bestSPC == None || SPC.joinTime > bestSPC.joinTime )
				bestSPC = SPC;
		}

		if ( bestSPC == None )
			break;

		Admin.ClientCommand( "spec", bestSPC.PC, true );
		Level.Game.BroadcastHandler.BroadcastText(None, bestSPC.PC, Lang.FormatLangString( Lang.MaxPlayingClientsString ), 'Caption');
		numPlayingClients--;
	}

	Level.Game.NumPlayers = NumPlayers;
}

function CheckEffects( AMPlayerController APC )
{
	local range r;
	local Pawn P;
	local NetPlayer NP;

	if ( SwatGamePlayerController( APC.PC ).IsDead() )
	{
		APC.nonLethal.flashbanged = 0;
		APC.nonLethal.gassed = 0;
		APC.nonLethal.peppered = 0;
		APC.nonLethal.stung = 0;
		APC.nonLethal.tased = 0;
		return;
	}

	P = APC.PC.Pawn;
	NP = NetPlayer(P);

	if ( P == None || NP == None )
		return;

	if ( APC.PC.Pawn == None || NetPlayer(APC.PC.Pawn).GetActiveItem() == None )
		return;

	if ( APC.VIPArrested )
	{
		SwatPawn(APC.PC.Pawn).OnArrestBegan( None );
		SwatPawn(APC.PC.Pawn).OnArrested( None );
		SwatGamePlayerController(APC.PC).PostArrested();
		APC.VIPArrested = false;
	}
	if ( APC.nonlethal.flashbanged > 0 )
	{
		NetPlayer(APC.PC.Pawn).ReactToFlashbangGrenade( None, APC.PC.Pawn, 0.0, 10.0, r, 10, 100, APC.nonlethal.flashbanged, 4, 0 );
		APC.nonlethal.flashbanged = 0;
	}
	if ( APC.nonlethal.gassed > 0 )
	{
		NetPlayer(APC.PC.Pawn).ReactToCSGas( None, APC.nonlethal.gassed, 0, 0 );
		APC.nonlethal.gassed = 0;
	}
	if ( APC.nonlethal.peppered > 0 )
	{
		NetPlayer(APC.PC.Pawn).ReactToBeingPepperSprayed( None, APC.nonlethal.peppered, 0, 0, 0 );
		APC.nonlethal.peppered = 0;
	}
	if ( APC.nonlethal.stung > 0 )
	{
#if !SWAT_EXPANSION
		NetPlayer(APC.PC.Pawn).ReactToStingGrenade(	None, APC.PC.Pawn, 0, 0, r, 0, 0, APC.nonlethal.stung, APC.nonlethal.stung, 0, 0 );
#else
		NetPlayer(APC.PC.Pawn).ReactToLessLeathalShotgun( APC.nonlethal.stung, APC.nonlethal.stung, APC.nonlethal.stung, 0 );
#endif
		APC.nonlethal.stung = 0;
	}
	if ( APC.nonlethal.tased > 0 )
	{
		NetPlayer(APC.PC.Pawn).ReactToBeingTased( None, APC.nonlethal.tased, 0 );
		APC.nonlethal.tased = 0;
	}
}

function CheckIdle( AMPlayerController SPC )
{
	local SwatGamePlayerController SGPC;
	local string Msg, action;

	if ( SPC.isAdmin )
		action = IdleAdminAction;
	else if ( SPC.isSubAdmin )
		action = IdleSubAdminAction;
	else
		action = IdleAction;

	if ( SPC.isSpectator )
		return;

	if ( action ~= "none" || action == "" )
		return;

	if ( SPC.PC == Level.GetLocalPlayerController() )
		return;

	SGPC = SwatGamePlayerController( SPC.PC );

	if ( SGPC == None || !SGPC.HasEnteredFirstRoundOfNetworkGame() || IdleActionTime <= 0 )
	{
		SPC.idleCheck.idleTime = 0;
		SPC.idleCheck.idleWarningTime = 0;
		SPC.idleCheck.idleWait = 0;
		SPC.idleCheck.savedTime = 0;
		return;
	}

	if ( SPC.PC.Pawn == None
		|| SGPC.IsDead()
		|| NetPlayer(SPC.PC.Pawn).IsBeingArrestedNow()
		|| NetPlayer(SPC.PC.Pawn).IsArrested()
		|| NetPlayer(SPC.PC.Pawn).IsTased() )
	{
		if ( !SPC.idleCheck.wasDead && SPC.idleCheck.idleTime != 0 )
			SPC.idleCheck.savedTime = Level.TimeSeconds - SPC.idleCheck.idleTime;
		SPC.idleCheck.wasDead = true;
		return;
	}

	if ( SPC.PC.Pawn.Location != SPC.idleCheck.oldLocation ||
		SPC.PC.Pawn.Rotation != SPC.idleCheck.oldRotation ||
		SPC.PC.Pawn.bIsCrouched != SPC.idleCheck.wasDucked ||
		SPC.PC.Pawn.LeanState != kLeanStateNone ||
		SPC.idleCheck.wasDead )
	{
		SPC.idleCheck.oldLocation = SPC.PC.Pawn.Location;
		SPC.idleCheck.oldRotation = SPC.PC.Pawn.Rotation;
		SPC.idleCheck.wasDucked = SPC.PC.Pawn.bIsCrouched;

		if ( SPC.idleCheck.wasDead )
			SPC.idleCheck.idleWait = Level.TimeSeconds + 5;
		else if ( SPC.idleCheck.idleWait <= Level.TimeSeconds )
		{
			SPC.idleCheck.idleTime = 0;
			SPC.idleCheck.idleWarningTime = 0;
			SPC.idleCheck.idleWait = 0;
			SPC.idleCheck.savedTime = 0;
		}

		SPC.idleCheck.wasDead = false;
		return;
	}

	if ( SPC.idleCheck.idleWait > Level.TimeSeconds )
		return;
	else
		SPC.idleCheck.idleWait = 0;

	if ( SPC.idleCheck.savedTime != 0 )
		SPC.idleCheck.idleTime = Level.TimeSeconds - SPC.idleCheck.savedTime;

	SPC.idleCheck.savedTime = 0;

	if ( SPC.idleCheck.idleTime == 0 )
		SPC.idleCheck.idleTime = Level.TimeSeconds;

	if ( SPC.idleCheck.idleWarningTime == 0 )
		SPC.idleCheck.idleWarningTime = Level.TimeSeconds + InitialIdleWarningInterval - IdleWarningInterval;//Wait a while before annoying them

	if ( Level.TimeSeconds - SPC.idleCheck.idleTime > IdleActionTime )
	{
		SPC.idleCheck.idleTime = 0;
		Admin.AdminCommand( action@SPC.id, Lang.ServerString, "", , Msg );
		Admin.ShowAdminMsg( Msg, None );
		if ( action ~= "kick" )
			SPC.kickReason = Lang.FormatLangString( Lang.KickIdleString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName );
		else if ( action ~= "kickban" )
			SPC.kickReason = Lang.FormatLangString( Lang.KickBanIdleString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName );
		return;
	}

	if ( Level.TimeSeconds - SPC.idleCheck.IdleWarningTime > IdleWarningInterval && Level.TimeSeconds - SPC.idleCheck.idleTime > InitialIdleWarningInterval )
	{
		Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, Lang.FormatLangString( Lang.IdleActionString, action, int(IdleActionTime - (Level.TimeSeconds - SPC.idleCheck.idleTime))+1), 'Caption');
		SPC.idleCheck.idleWarningTime = Level.TimeSeconds;
	}
}

function bool ChooseNewRandomVIP( PlayerController curVIP )
{
	local AMPlayerController OSPC;
	local PlayerController PC;
	local array<AMPlayerController> SwatTeam, SuspectTeam;
	local int i, RandomIndex;

	for ( i = 0; i < PlayerList.Length; i++ )
	{
		OSPC = PlayerList[i];

		if ( OSPC == None || OSPC.PC == None || OSPC.PC == curVIP )
			continue;

		if ( NetTeam(OSPC.PC.PlayerReplicationInfo.Team).GetTeamNumber() == 0 )
			SwatTeam[SwatTeam.Length] = OSPC;
		else if ( NetTeam(OSPC.PC.PlayerReplicationInfo.Team).GetTeamNumber() == 1 )
			SuspectTeam[SuspectTeam.Length] = OSPC;
	}

	if ( SwatTeam.Length > 0 )
	{
		RandomIndex = Rand(SwatTeam.Length);
		wishVIP = SwatTeam[RandomIndex].PC;
	}
	else if ( SuspectTeam.Length > 0 )
	{
		RandomIndex = Rand(SuspectTeam.Length);
		wishVIP = SuspectTeam[RandomIndex].PC;
	}
	else
		return false;

	PC = wishVIP;

	if ( wishVIP != None )
	{
		if ( CheckVIPReplacement() )
		{
			Level.Game.Broadcast(None, Lang.FormatLangString( Lang.ChangedVIPString, Lang.ServerString, PC.PlayerReplicationInfo.PlayerName ), 'Caption');
			return true;
		}
	}
	return false;
}

function CheckVIPKiller( AMPlayerController SPC )
{
	local string action, Msg;

	if ( SwatPlayerReplicationInfo(SPC.PC.PlayerReplicationInfo).netScoreInfo.GetKilledVIPInvalid() > 0 )
	{
		if ( !SPC.killedVIP )
		{
			SPC.killedVIP = true;
			SPC.vipKills++;
		}
		else
			return;
	}
	else
	{
		SPC.killedVIP = false;
		return;
	}

	action = VIPKillAction;

	if ( action ~= "none" || action == "" )
		return;

	if ( SPC.vipKills < VIPKillActionKills || VIPKillActionKills <= 0 )
		return;

	if ( action ~= "kick" )
	{
			SPC.shouldKick = true;
			SPC.kickReason = Lang.FormatLangString( Lang.KickVIPKillString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName );
	}
	else if ( action ~= "kickban" )
	{
			SPC.shouldBan = true;
			SPC.banTime = "";
			SPC.kickReason = Lang.FormatLangString( Lang.KickBanVIPKillString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName );
			SPC.bannersIP = "~AutoVIPKillingBan";
			SPC.banComment = "Banned for killing the VIP.";
	}
	else if ( action ~= "forcelesslethal" )
	{
		if ( !SPC.forceLessLethal )
		{
			ForceLessLethal( SPC, Lang.KilledVIPString, false );
			Level.Game.Broadcast(None, Lang.FormatLangString( Lang.ForceLLString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
		}
	}
	else if ( action ~= "forcenoweapons" )
	{
		if ( !SPC.forceLessLethal )
		{
			ForceLessLethal( SPC, Lang.KilledVIPString,true );
			Level.Game.Broadcast(None, Lang.FormatLangString( Lang.ForceLLString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
		}
	}
	else
	{
		Admin.AdminCommand( action@SPC.id, Lang.ServerString, "", , Msg );
		Admin.ShowAdminMsg( Msg, None );
	}
}

function CheckLessLethal( AMPlayerController SPC )
{
	local SwatGamePlayerController SGPC;

	if ( SPC.PC == None )
		return;

	SGPC = SwatGamePlayerController(SPC.PC);

	if ( SGPC == None || SGPC.ThisPlayerIsTheVIP )
		return;

	if ( SGPC.IsDead() || SGPC.IsCuffed() || hasEnded )
		SPC.goLessLethalNow = true;

	if ( SPC.goLessLethalNow && !SGPC.IsDead() && !SGPC.IsCuffed() && !hasEnded )
	{
		SPC.goLessLethalNow = false;
		if ( !SPC.forcelessLethal )
		{
			if ( ForceEquipment )
				ForceEquip( SPC );
			//else
				ReplacePlayerEquipment( SPC );
		}
		else
			ForceLessLethalNow( SPC );
	}
}

function ForceEquip( AMPlayerController PL )
{
	local array<LoadoutChanger> NewLoadout;
    local LoadoutChanger loadout;
	local DynamicLoadoutSpec LoadoutSpec;
	local int i;

	LoadOutSpec = Spawn(class'DynamicLoadOutSpec', None, 'ForcedCustomSet');

	for ( i = 0; i < Pocket.EnumCount; i++ )
	{
		if ( LoadOutSpec.LoadOutSpec[ Pocket(i) ] != class'AMMod.AMNoOverride' )
		{
			loadout.Pocket = Pocket(i);
			loadout.NewClass = LoadOutSpec.LoadOutSpec[ Pocket(i) ];
			NewLoadout[NewLoadout.Length] = loadout;
		}
	}

	if ( NewLoadout.Length > 0 )
	{
		NetPlayer(PL.PC.Pawn).Destroy();
		ChangePlayer( PL.PC, NewLoadout );
	}
}

function ForceLessLethalNow( AMPlayerController PL )
{
	local array<LoadoutChanger> NewLoadout;
    local LoadoutChanger loadout;
	local DynamicLoadoutSpec LoadoutSpec;
	local int i;

	if ( !PL.forcelesslethal )
		return;

	if ( PL.noWeapons )
		LoadOutSpec = Spawn(class'DynamicLoadOutSpec', None, 'NoWeaponsSet');
	else
		LoadOutSpec = Spawn(class'DynamicLoadOutSpec', None, 'ForcedLessLethal');

	for ( i = 0; i < Pocket.EnumCount; i++ )
	{
		if ( LoadOutSpec.LoadOutSpec[ Pocket(i) ] != class'AMMod.AMNoOverride' )
		{
			loadout.Pocket = Pocket(i);
			loadout.NewClass = LoadOutSpec.LoadOutSpec[ Pocket(i) ];
			NewLoadout[NewLoadout.Length] = loadout;
		}
	}

	if ( NewLoadout.Length > 0 )
	{
		Level.Game.BroadcastHandler.BroadcastText(None, PL.PC, PL.lessLethalReason, 'Caption');
		NetPlayer(PL.PC.Pawn).Destroy();
		ChangePlayer( PL.PC, NewLoadout );
	}
}

function ReplacePlayerEquipment( AMPlayerController PL )
{
	local array<LoadoutChanger> NewLoadout;
    local LoadoutChanger loadout;
	local DynamicLoadoutSpec LoadoutSpec;
	local class<actor>	Replace, Replacement;
	local int i, j, point;

	LoadOutSpec = NetPlayer( PL.PC.Pawn ).GetLoadoutSpec();

	for ( j = 0; j < ReplaceEquipment.Length; j++ )
	{
		point = InStr(ReplaceEquipment[j], " ");
		Replace = class<actor>(DynamicLoadObject(Left(ReplaceEquipment[j], point), class'class'));
		Replacement = class<actor>(DynamicLoadObject(Mid(ReplaceEquipment[j], point+1), class'class'));

		if ( Replace == None )
			continue;

		for ( i = 0; i < Pocket.EnumCount; i++ )
		{
			if ( LoadOutSpec.LoadOutSpec[ Pocket(i) ] == Replace )
			{
				loadout.Pocket = Pocket(i);
				loadout.NewClass = Replacement;
				NewLoadout[NewLoadout.Length] = loadout;
			}
		}
	}

	if ( NewLoadout.Length > 0 )
	{
		Level.Game.BroadcastHandler.BroadcastText(None, PL.PC, Lang.EquipmentReplacedString, 'Caption');
		NetPlayer(PL.PC.Pawn).Destroy();
		ChangePlayer( PL.PC, NewLoadout );
	}
}

function CheckMultipleTeamKiller( AMPlayerController SPC )
{
	local int i, teamkills;
	local string Msg;

	if ( SPC.isAdmin )
		return;

	if ( TeamKillActionLevel < 1 || TeamKillAction == "" || TeamKillAction ~= "none" )
		return;

	if ( hasEnded )
	{
		SPC.teamKillActionTaken = false;
		return;
	}

	if ( SPC.teamKillActionTaken )
		return;

	// Don't bother if an admin is in the server.
	if ( !TeamKillActionAdminPresent )
	{
		for( i = 0; i < PlayerList.Length; i++ )
		{
			SPC = PlayerList[i];

			if ( SPC == None )
				continue;

			if ( SPC.isAdmin || SPC.isSuperAdmin )
				return;
		}
	}

    teamkills = SwatPlayerReplicationInfo(SPC.PC.PlayerReplicationInfo).netScoreInfo.GetFriendlyKills();

	if ( teamkills >= TeamKillActionLevel )
	{
		SPC.teamKillActionTaken = true;
		if ( TeamKillAction ~= "kick" )
		{
			SPC.shouldKick = true;
			SPC.kickReason = Lang.FormatLangString( Lang.KickTKString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName );
		}
		else if ( TeamKillAction ~= "kickban" )
		{
			SPC.shouldBan = true;
			SPC.banTime = "";
			SPC.kickReason = Lang.FormatLangString( Lang.KickBanTKString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName );
			SPC.bannersIP = "~AutoTeamKillingBan";
			SPC.banComment = "Banned for teamkilling.";
		}
		else if ( TeamKillAction ~= "forcelesslethal" )
		{
			if ( !SPC.forceLessLethal )
			{
				ForceLessLethal( SPC, Lang.MultipleTKString, false );
				Level.Game.Broadcast(None, Lang.FormatLangString( Lang.ForceLLString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
			}
		}
		else if ( TeamKillAction ~= "forcenoweapons" )
		{
			if ( !SPC.forceLessLethal )
			{
				ForceLessLethal( SPC, Lang.MultipleTKString, true );
				Level.Game.Broadcast(None, Lang.FormatLangString( Lang.ForceNWString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
			}
		}
		else
		{
			Admin.AdminCommand( TeamKillAction@SPC.id, Lang.ServerString, "", , Msg );
			Admin.ShowAdminMsg( Msg, None );
		}
	}
}

function String GetBanTime( string time )
{
	local int i, j, mins, hours, days, months, years;

	i = 0;
	while ( i != -1 )
	{
		j = i;
		i = InStrAfter( time, ":", i+1 );
	}
	if ( j == 0 )
		j = -1;

	mins = Level.Minute + int(Mid( time, j+1 ));
	time = Left( time, j );

	i = 0;
	while ( i != -1 )
	{
		j = i;
		i = InStrAfter( time, ":", i+1 );
	}
	if ( j == 0 )
		j = -1;

	hours = Level.Hour + int(Mid( time, j+1 ));
	time = Left( time, j );

	i = 0;
	while ( i != -1 )
	{
		j = i;
		i = InStrAfter( time, ":", i+1 );
	}
	if ( j == 0 )
		j = -1;

	days = Level.Day + int(Mid( time, j+1 ));
	time = Left( time, j );

	i = 0;
	while ( i != -1 )
	{
		j = i;
		i = InStrAfter( time, ":", i+1 );
	}
	if ( j == 0 )
		j = -1;

	months = Level.Month + int(Mid( time, j+1 ));
	time = Left( time, j );

	i = 0;
	while ( i != -1 )
	{
		j = i;
		i = InStrAfter( time, ":", i );
	}
	if ( j == 0 )
		j = -1;

	years = Level.Year + int(Mid( time, j+1 ));
	time = Left( time, j );

	while ( mins > 59 )
	{
		hours++;
		mins -= 60;
	}
	while ( hours > 23 )
	{
		days++;
		hours -= 24;
	}

	while ( months > 12 )
	{
		years++;
		months -= 11;
	}
	while ( days > daysInMonth[months] )
	{
		days -= daysInMonth[months]-1;
		months++;

		if ( months > 12 )
		{
			months = 1;
			years++;
		}
	}

	return years$":"$months$":"$days$":"$hours$":"$mins;
}

function bool CheckKickOrBan( AMPlayerController SPC )
{
	local string IP, Msg, time;
	local int i;
	local bool foundNewVIP;

	if ( SPC.kicked )
		return false;

	if ( !SPC.shouldKick && !SPC.shouldBan )
		return false;

	if ( !hasEnded )
	{
		if ( SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP )
			foundNewVIP = ChooseNewRandomVIP( SPC.PC );
		else
			foundNewVIP = true;

		if ( foundNewVIP && SwatGamePlayerController(SPC.PC).SwatPlayer != None && SwatGamePlayerController(SPC.PC).SwatPlayer.IsTheVIP() )
			return false;
	}

	if ( SPC.shouldKick )
	{
		if ( SPC.kickReason != "" )
			Level.Game.Broadcast(None, SPC.kickReason, 'Caption');
		SPC.PC.Destroy();
		return true;
	}
	else if ( SPC.shouldBan )
	{
		if ( !SPC.isAdmin )
		{
			IP = SPC.networkAddress;

			if ( SPC.banTime != "" && SPC.banTime != "0" && lower(SPC.banTime) != "none" )
			{
				if ( AccessControl.CheckTempIPPolicy(IP) )
				{
					time = GetBanTime( SPC.banTime );

					i = InStr(IP, ":");
					if ( i != -1 )
						IP = Left(IP, i);
					Log("AMMod.AMGameMod: Adding Temp IP Ban for: "$IP);
					Msg = Lang.FormatLangString( Lang.AddTempBanString, SPC.banner, IP );
					AccessControl.TempIPPolicies[AccessControl.TempIPPolicies.Length] = "DENY,"$IP$","$time$","$SPC.PC.PlayerReplicationInfo.PlayerName$","$SPC.bannersIP$","$SPC.banComment;
					AccessControl.SaveConfig( "", "", false, true );
					if ( FlushVariables )
						AccessControl.FlushConfig();
				}
			}
			else if( AccessControl.CheckIPPolicy(IP) )
			{
				i = InStr(IP, ":");
				if ( i != -1 )
					IP = Left(IP, i);
				Log("AMMod.AMGameMod: Adding IP Ban for: "$IP);
				Msg = Lang.FormatLangString( Lang.AddBanString, SPC.banner, IP );
				AccessControl.IPPolicies[AccessControl.IPPolicies.Length] = "DENY,"$IP$","$SPC.PC.PlayerReplicationInfo.PlayerName$","$SPC.bannersIP$","$SPC.banComment;

                //Send the ban data to KoS Website.
                //ban IP_address Name admin admin_ip
                KZMod.SendStats("ban $ "$IP$" $ "$SPC.PC.PlayerReplicationInfo.PlayerName$" $ "$SPC.banner$" $ "$SPC.bannersIP$" $ "$SPC.banComment);

                AccessControl.SaveConfig( "", "", false, true );
				if ( FlushVariables )
					AccessControl.FlushConfig();
			}

			if ( SPC.kickReason != "" )
				Level.Game.Broadcast(None, SPC.kickReason, 'Caption');
			SPC.PC.Destroy();
		}
		else
			Msg = Lang.CannotBanAdminsString;

		Admin.ShowAdminMsg( Msg, None, true );
		return true;
	}
	return false;
}

function CheckPing( AMPlayerController SPC )
{
	if ( SPC.isAdmin && IgnoreHighPingAdmins )
		return;

	if ( SPC.isAdmin && IgnoreHighPingSubAdmins )
		return;

	if ( SPC.PC == Level.GetLocalPlayerController() )
		return;

	if ( MaxPlayerPing <= 0 || PingKickTime <= 0 || !SPC.seenMOTD )
		return;

	if ( SPC.PC.PlayerReplicationInfo.Ping > MaxPlayerPing )
	{
		if ( SPC.OverPingTime == 0 )
			SPC.OverPingTime = Level.TimeSeconds;

		if ( SPC.PingWarningTime == 0 )
			SPC.PingWarningTime = Level.TimeSeconds;

		if ( Level.TimeSeconds - SPC.OverPingTime > PingKickTime )
		{
			SPC.OverPingTime = 0;
			SPC.shouldKick = true;
			SPC.kickReason = Lang.FormatLangString( Lang.KickPingString, Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName );
			return;
		}

		if ( Level.TimeSeconds - SPC.PingWarningTime > PingWarningInterval )
		{
			Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, Lang.FormatLangString( Lang.PingTooHighString, MaxPlayerPing, int(PingKickTime - (Level.TimeSeconds - SPC.OverPingTime))+1 ), 'Caption');
			SPC.PingWarningTime = Level.TimeSeconds;
		}
	}
	else
	{
		SPC.OverPingTime = 0;
		SPC.PingWarningTime = 0;
	}
}

function CheckTeam( AMPlayerController SPC )
{
	local int playerteam, i, newteamnum, oldteamnum;
	local AMPlayerController OSPC;

	if ( SPC.PC.PlayerReplicationInfo.Team == None )
		return;

	playerteam = NetTeam(SPC.PC.PlayerReplicationInfo.Team).GetTeamNumber();

	if ( playerteam == -1 )
		return;

	if ( SPC.Team == -1 )
		SPC.Team = playerteam;

	if ( SPC.isSuperAdmin )
		SPC.teamForced = true;
	else if ( SPC.isAdmin && !Admin.IsSuperAdminCommand( "switchteam" ) )
		SPC.teamForced = true;

	if ( SPC.Team != playerteam )
	{
		if ( !SPC.teamForced && (hasEnded || !SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP) )
		{
			if ( teamsLocked )
			{
				Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, Lang.TeamsLockedString, 'Caption');
				if ( SPC.PC.Pawn != None )
					SPC.PC.Pawn.Died( None, class'DamageType', SPC.PC.Pawn.Location, vect(0,0,0) );
				SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController( SPC.PC ) );
			}
			else if ( TeamSpread > 0 )
			{
				for ( i = 0; i < PlayerList.Length; i++ )
				{
					OSPC = PlayerList[i];

					if ( OSPC == None || OSPC.PC == None || NetTeam(OSPC.PC.PlayerReplicationInfo.Team) == None )
						continue;

					if ( OSPC.PC.PlayerReplicationInfo.Team == SPC.PC.PlayerReplicationInfo.Team )
						newteamnum++;
					else
						oldteamnum++;
				}
				if ( newteamnum - TeamSpread > oldteamnum )
				{
					Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, Lang.FormatLangString( Lang.MaxTeamSpreadString, TeamSpread ), 'Caption');
					if ( SPC.PC.Pawn != None )
						SPC.PC.Pawn.Died( None, class'DamageType', SPC.PC.Pawn.Location, vect(0,0,0) );
					SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController( SPC.PC ) );
				}
			}
		}

		SPC.teamForced = false;
		SPC.Team = NetTeam(SPC.PC.PlayerReplicationInfo.Team).GetTeamNumber();
	}
}

function CheckName( AMPlayerController SPC )
{
	local string S;
	local int index, i, n;
	local AMPlayerController OSPC;

	S = SPC.PC.PlayerReplicationInfo.PlayerName;

	ReplaceText( S, " ", "_" );

	if ( StrictPlayerNames )
	{
		do
		{
			//if the current character is allowable
			if( InStr( SwatRepo(Level.GetRepo()).GuiConfig.MPNameAllowableCharSet, Mid( S, index, 1 ) ) >= 0 )
				index++; //continue to the next character
			else
    			S = Left( S, index ) $ Right( S, len(S) - (index+1) ); //remove the current character
		} until (index >= Len(S));
	}

    //Cap the Max length = 20 characters
    if( Len(S) > SwatRepo(Level.GetRepo()).GuiConfig.MPNameLength )
        S = Left(S, SwatRepo(Level.GetRepo()).GuiConfig.MPNameLength);

    //empty string is still not a valid name - no change should be made
    if( S == "" || Len(S) < 1 )
        S = "Player";

	if ( UniquePlayerNames && SPC.Name != S )
	{
		n = 1;
		i = 0;
		while ( i < PlayerList.Length )
		{
			OSPC = PlayerList[i];

			if ( OSPC == None || OSPC.PC == None || OSPC == SPC )
				i++;
			else if ( S ~= OSPC.PC.PlayerReplicationInfo.PlayerName )
			{
				n++;
				S = S$n;
				i = 0;
			}
			else
				i++;
		}
	}

	if ( S != SPC.PC.PlayerReplicationInfo.PlayerName )
		Level.Game.ChangeName( SPC.PC, S, true );

	SPC.Name = SPC.PC.PlayerReplicationInfo.PlayerName;
}

function EndSpectate( AMPlayerController SPC )
{
	local string S;

	S = SPC.PC.PlayerReplicationInfo.PlayerName;
	while ( Right( S, 6 ) ~= "(SPEC)" )
		S = Left(S, Len(S)-6);
	while ( Right( S, 6 ) ~= "(VIEW)" )
		S = Left(S, Len(S)-6);

	if ( S == "" )
		S = "Player";

	if ( S != SPC.PC.PlayerReplicationInfo.PlayerName )
		Level.Game.ChangeName( SPC.PC, S, false );

	if ( SPC.wasSpectator )
	{
		SPC.wasSpectator = false;
		Level.Game.Broadcast(None, Lang.FormatLangString( Lang.JoinedGameString, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
	}
}

function Spectate( AMPlayerController SPC )
{
	local string S;
	local Controller CurrentController;
	local PlayerController PC;

	if ( !SPC.wasSpectator )
	{
		SPC.wasSpectator = true;
		Level.Game.Broadcast(None, Lang.FormatLangString( Lang.JoinedSpecString, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
	}

	S = SPC.PC.PlayerReplicationInfo.PlayerName;

	if ( InStr( SwatRepo(Level.GetRepo()).GuiConfig.MPNameAllowableCharSet, "(" ) == -1 )
		SwatRepo(Level.GetRepo()).GuiConfig.MPNameAllowableCharSet = SwatRepo(Level.GetRepo()).GuiConfig.MPNameAllowableCharSet $ "(";
	if ( InStr( SwatRepo(Level.GetRepo()).GuiConfig.MPNameAllowableCharSet, ")" ) == -1 )
		SwatRepo(Level.GetRepo()).GuiConfig.MPNameAllowableCharSet = SwatRepo(Level.GetRepo()).GuiConfig.MPNameAllowableCharSet $ ")";

	while ( Right( S, 6 ) ~= "(SPEC)" )
		S = Left(S, Len(S)-6);
	while ( Right( S, 6 ) ~= "(VIEW)" )
		S = Left(S, Len(S)-6);

	if ( SPC.specMode > 0 && Len(S) + 6 > SwatRepo(Level.GetRepo()).GuiConfig.MPNameLength )
		S = Left(S, SwatRepo(Level.GetRepo()).GuiConfig.MPNameLength-6);

	if ( SPC.specMode == 1 )
		S = S$"(SPEC)";
	else if ( SPC.specMode == 2 )
		S = S$"(VIEW)";

	if ( SPC.PC.PlayerReplicationInfo.PlayerName != S )
		Level.Game.ChangeName( SPC.PC, S, false );

	if ( SPC.PC.IsInState( 'GameEnded' ) || hasEnded )
		return;

	if ( SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP )
	{
		if ( !ChooseNewRandomVIP( SPC.PC ) )
        {
			Admin.ClientCommand( "join", SPC.PC, true );
			return;
		}
	}

	if ( SPC.PC.Pawn != None && (SwatGamePlayerController(SPC.PC).SwatPlayer == None || !SwatGamePlayerController(SPC.PC).SwatPlayer.IsTheVIP()) )
		SPC.PC.Pawn.Died( None, class'DamageType', SPC.PC.Pawn.Location, vect(0,0,0) );

	SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem.bHasEnteredFirstRound = false;

	if ( SPC.specMode == 2 )
	{
		PC = FindNextOtherPlayerOnTeam( SPC.PC );

		CurrentController = Controller(SPC.PC.ViewTarget);

		if ( CurrentController == None )
			if ( Pawn(SPC.PC.ViewTarget) != None )
				CurrentController = Pawn(SPC.PC.ViewTarget).Controller;

		if ( CurrentController != None )
			SPC.CurrentController = CurrentController;
		else if ( IsOtherControllerObservable( SPC.PC, SPC.CurrentController ) )
			SPC.PC.SetViewTarget( SPC.CurrentController );

		if ( PC == None )
		{
			if ( !IsOtherControllerStillObservable(SPC.PC, SPC.CurrentController) )
			{
				if ( !SPC.PC.IsInState( 'ObserveLocation' ) )
				{
					SwatGamePlayerController(SPC.PC).ViewFromLocation( 'DefaultPositionMarker' );
					SwatGamePlayerController(SPC.PC).ClientViewFromLocation( "DefaultPositionMarker" );
				}
			}
		}
		else
		{
			if ( !SPC.PC.IsInState( 'ObserveTeam' ) )
			{
				SwatGamePlayerController(SPC.PC).Restart();
				SwatGamePlayerController(SPC.PC).ForceObserverCam();
			}

			if ( !IsOtherControllerStillObservable(SPC.PC, SPC.CurrentController) )
			{
				SwatGamePlayerController(SPC.PC).ServerViewNextPlayer();
				SPC.CurrentController = Controller(SPC.PC.ViewTarget);
			}
		}
		if ( SPC.PC.ViewTarget != None )
			SPC.PC.SetLocation(SPC.PC.ViewTarget.Location);
	}

if ( SPC.specMode == 1 )
	{
		if ( !SPC.PC.IsInState( 'BaseSpectating' ) )
		{
			SPC.PC.Reset();
			if ( SPC.PC.Pawn != None )
			{
				SPC.PC.SetLocation(SPC.PC.Pawn.Location);
				SPC.PC.UnPossess();
			}
			//bCollideWorld = false;
			SPC.PC.GotoState( 'BaseSpectating' );
			SPC.PC.ClientGotoState( 'BaseSpectating', 'Begin' );
			SPC.PC.ServerSpectateSpeed( 350 );
		}

		SPC.PC.ServerViewSelf();
	}
}

function AddToPlayerList( PlayerController PC )
{
	local int i, space, n;
	local string wishName;
	local AMPlayerController SPC;

	if ( UniquePlayerNames )
	{
		wishName = PC.PlayerReplicationInfo.PlayerName;
		n = 1;
		i = 0;
		while ( i < PlayerList.Length )
		{
			SPC = PlayerList[i];

			if ( SPC == None || SPC.PC == None )
				i++;
			else if ( wishName ~= SPC.PC.PlayerReplicationInfo.PlayerName )
			{
				n++;
				wishName = wishName$n;
				i = 0;
			}
			else
				i++;
		}

		if ( PC.PlayerReplicationInfo.PlayerName != wishName )
			Level.Game.ChangeName( PC, wishName, true );
	}

	//Take the last slot
	space = PlayerList.Length;

	//Or the lowest available if possible
	for ( i = 0; i < PlayerList.Length; i++ )
	{
		if ( PlayerList[i] == None )
		{
			space = i;
			break;
		}
	}

	PlayerList[space] = Spawn( class'AMPlayerController' );
	PlayerList[space].PC = PC;
	PlayerList[space].id = space;
	PlayerList[space].Name = PC.PlayerReplicationInfo.PlayerName;
	PlayerList[space].idleCheck.wasDead = true;
	PlayerList[space].specMode = 1;
	PlayerList[space].networkAddress = PC.GetPlayerNetworkAddress();
	PlayerList[space].joinTime = Level.TimeSeconds;

	// Strip Port
	i = InStr( PlayerList[space].networkAddress, ":" );
	if ( i != -1 )
		PlayerList[space].networkAddress = Left( PlayerList[space].networkAddress, i );

	PlayerList[space].Team = NetTeam(PC.PlayerReplicationInfo.Team).GetTeamNumber();
	if ( Left(LockedDefaultTeam, 2) ~= "sw" && teamsLocked )
		PlayerList[space].Team = 0;
	else if ( Left(LockedDefaultTeam, 2) ~= "su" && teamsLocked )
		PlayerList[space].Team = 1;

	if( Level.GetLocalPlayerController() == PC )
        SwatGamePlayerController(PC).SwatRepoPlayerItem.LastAdminPassword = Admin.SuperAdminPassword;

	Admin.AdminLogin( PC, SwatGamePlayerController(PC).SwatRepoPlayerItem.LastAdminPassword );

	for ( i = SuperAdminIPs.Length-1; i >= 0 ; i-- )
	{
		if ( SuperAdminIPs[i] == PC.GetPlayerNetworkAddress() )
		{
			Admin.AdminLogin( PC, Admin.SuperAdminPassword );
			SuperAdminIPs.Remove( i, 1 );
			return;
		}
	}

	for ( i = AdminIPs.Length-1; i >= 0 ; i-- )
	{
		if ( AdminIPs[i] == PC.GetPlayerNetworkAddress() )
		{
			Admin.AdminLogin( PC, Admin.AdminPassword );
			AdminIPs.Remove( i, 1 );
			return;
		}
	}

	for ( i = SubAdminIPs.Length-1; i >= 0 ; i-- )
	{
		if ( SubAdminIPs[i] == PC.GetPlayerNetworkAddress() )
		{
			PlayerList[space].isSubAdmin = true;
			SwatGamePlayerController(PC).SwatRepoPlayerItem.LastAdminPassword = AccessControl.MaxJoinPassword;
			SubAdminIPs.Remove( i, 1 );
			return;
		}
	}
        // End:0x7DE
        if(((ServerSettings(Level.CurrentServerSettings).RoundNumber == 0) && SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState < GAMESTATE_MidGame) && SwatGamePlayerController(PlayerList[Space].PC).IsAReconnectingClient())
        {
        }
        // End:0x863
        else
        {
        	Admin.ShowAdminMsg( Lang.FormatLangString( Lang.ConnectedString, PlayerList[space].Name, PlayerList[space].networkAddress ), None, true );
        }
}

function PlayerController FindNextOtherPlayerOnTeam( PlayerController PC )
{
    local Controller NewController;
    local Controller CurrentController;

    // Find the current viewtarget's controller
    CurrentController = Controller(PC.ViewTarget);

    if (CurrentController == None)
        // Is current viewtarget a pawn? If so, get the controller for it
        if (Pawn(PC.ViewTarget) != None)
            CurrentController = Pawn(PC.ViewTarget).Controller;

    // If we have a current controller, move to the next one. Otherwise, use
    // the first controller in the level list
    if (CurrentController != None)
        CurrentController = CurrentController.NextController;

    // Search till end of list for new target
    for (NewController = CurrentController; NewController != None; NewController = NewController.NextController)
        if (IsOtherControllerObservable(PC, NewController))
            return PlayerController(NewController);

    // Loop to head of list, and search until FirstController is reached
    for (NewController = Level.ControllerList; NewController != CurrentController; NewController = NewController.NextController)
        if (IsOtherControllerObservable(PC, NewController))
            return PlayerController(NewController);

    return None;
}

function bool IsOtherControllerObservable(Controller C, Controller Other)
{
    return Other.bIsPlayer
        && SwatGamePlayerController(Other) != None
        && SwatGamePlayerController(Other).SwatPlayer != None
        && !SwatGamePlayerController(Other).SwatPlayer.IsTheVIP()                                 //dkaplan: do not view through VIP's helmet cam
        && Other != C
        && PlayerController(Other).IsDead() == false
        && (Level.IsCOOPServer || C.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team);
}

function bool IsOtherControllerStillObservable(Controller C, Controller Other)
{
    return Other != None
		&& Other.bIsPlayer
        && SwatGamePlayerController(Other) != None
        && Other != C
        && (Level.IsCOOPServer || C.PlayerReplicationInfo.Team == Other.PlayerReplicationInfo.Team);
}

function int InStrAfter(string Text, string Match, int Pos)
{
	local int i;

	i = InStr(Mid(Text, Pos), Match);
	if(i != -1)
		return i + Pos;

	return -1;
}

function StripColours( out string html )
{
	local int i, j;

	while ( i != -1 )
	{
		i = InStr( html, "[c" );
		if ( i != -1 )
		{
			j = InStrAfter( html, "]", i );
			if ( j != -1 )
				html = Left( html, i ) $ Mid( html, j+1 );
			else
				html = Left( html, i );
		}
	}
}

function FixForHTML( out string html )
{
	ReplaceText( html, "<", "&lt;" );
	ReplaceText( html, ">", "&gt;" );
	ReplaceText( html, "[b]", "" );
	ReplaceText( html, "[B]", "" );
	ReplaceText( html, "[\\b]", "" );
	ReplaceText( html, "[\\B]", "" );
	ReplaceText( html, "[i]", "" );
	ReplaceText( html, "[I]", "" );
	ReplaceText( html, "[\\i]", "" );
	ReplaceText( html, "[\\I]", "" );
	ReplaceText( html, "[u]", "" );
	ReplaceText( html, "[U]", "" );
	ReplaceText( html, "[\\u]", "" );
	ReplaceText( html, "[\\U]", "" );
	ReplaceText( html, "[\\c]", "" );
	ReplaceText( html, "[\\C]", "" );

	StripColours( html );
}

function StripHexFromHTML( out string html )
{
	local int i, hex;

	i = InStr( html, "%" );
	while ( i != -1 )
	{
		hex = GetHexDigit(Mid( html, i+1, 1 ))*16 + GetHexDigit(Mid( html, i+2, 1 ));
		html = Left( html, i )$Chr(hex)$Mid( html, i+3 );
		i = InStr( html, "%" );
	}
}

function FixForHTML2( out string html, string defaultcolour )
{
	local int i, j, k;

	ReplaceText( html, "<", "&lt;" );
	ReplaceText( html, ">", "&gt;" );
	ReplaceText( html, "[B]", "[b]" );
	ReplaceText( html, "[b]", "</b><b>" );
	ReplaceText( html, "[\\B]", "[\\b]" );
	ReplaceText( html, "[\\b]", "</b>" );
	ReplaceText( html, "[I]", "[i]" );
	ReplaceText( html, "[i]", "</i><i>" );
	ReplaceText( html, "[\\I]", "[\\i]" );
	ReplaceText( html, "[\\i]", "</i>" );
	ReplaceText( html, "[U]", "[u]" );
	ReplaceText( html, "[u]", "</u><u>" );
	ReplaceText( html, "[\\U]", "[\\u]" );
	ReplaceText( html, "[\\u]", "</u>" );
	ReplaceText( html, "[C=", "[c=" );
	ReplaceText( html, "[\\C]", "[\\c]" );

	while ( i != -1 )
	{
		i = InStr( html, "[c=" );
		if ( i != -1 )
		{
			j = InStrAfter( html, "]", i );
			if ( j != -1 )
			{
				k++;
				html = Left( html, i ) $ "</font><font color=" $ Mid( html, i+3, 6 ) $ ">" $ Mid( html, j+1 );
			}
			else
				html = Left( html, i );
		}
	}

	i = InStr( html, "[\\c]" );
	while ( i != -1 && k > 0 )
	{
		html = Left( html, i ) $ "</font><font color=" $ defaultcolour $ ">" $ Mid( html, i+4 );
		k--;
		i = InStr( html, "[\\c]" );
	}

	html = html $ "</b></i></u></font>";
}

function int GetHexDigit(string D)
{
	switch(caps(D))
	{
	case "0": return 0;
	case "1": return 1;
	case "2": return 2;
	case "3": return 3;
	case "4": return 4;
	case "5": return 5;
	case "6": return 6;
	case "7": return 7;
	case "8": return 8;
	case "9": return 9;
	case "A": return 10;
	case "B": return 11;
	case "C": return 12;
	case "D": return 13;
	case "E": return 14;
	case "F": return 15;
	}

	return 0;
}

/* Coordinates for Smash & Grab Case Spawn Points
	CaseCoordinates=MP-ABomb,4320,2320,-5
	CaseCoordinates=MP-ArmsDeal,160,-1315,185
	CaseCoordinates=MP-AutoGarage,2365,-165,265
	CaseCoordinates=MP-Casino,1030,-1110,-325
	CaseCoordinates=MP-ConvenienceStore,610,1140,305
	CaseCoordinates=MP-Courthouse,2460,-1845,-145
	CaseCoordinates=MP-DNA,6980,680,570
	CaseCoordinates=MP-FairfaxResidence,5230,-2085,230
	CaseCoordinates=MP-Foodwall,-510,-2045,205
	CaseCoordinates=MP-Hospital,-1080,-1200,-245
	CaseCoordinates=MP-Hotel,-365,455,-480
	CaseCoordinates=MP-JewelryHeist,-3250,-3110,520
	CaseCoordinates=MP-MeatBarn,5,-695,265
	CaseCoordinates=MP-PowerPlant,55,-85,155
	CaseCoordinates=MP-RedLibrary,-1680,1350,205
	CaseCoordinates=MP-Tenement,1405,370,-485
	CaseCoordinates=MP-Training,845,-1210,185
*/

defaultproperties
{
	LockedServerName=""
	IdleAction="kick"
	IdleSubAdminAction="kick"
	IdleAdminAction="forcespec"
	BaseMOTD=""
	MOTD=""
	TeamKillAction="None"
	TeamKillActionLevel=5
	MaxPlayerPing=250
	PingKickTime=0
	PingWarningInterval=10
	IdleActionTime=0
	IdleWarningInterval=10
	InitialIdleWarningInterval=20
	TeamSpread=0
	ShowKickRoomMessage=true
	BroadCastToAllAdmins=true
	TeamKillActionAdminPresent=false
	StrictPlayerNames=true
	UniquePlayerNames=true
	ForceEquipment=false
	IgnoreHighPingAdmins=false
	IgnoreHighPingSubAdmins=false
	FlushVariables=false
	DisableMod=false
	LockMapList=false
	SuspectArrestTime=true
	SuspectCaseTime=true
	LockedGameType="None"
	LockedDefaultTeam="None"
	VIPKillAction="forcelesslethal"
	VIPKillActionKills=1
}
