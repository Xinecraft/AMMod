class AMBroadcastHandler extends Engine.BroadcastHandler;

var		globalconfig bool		IgnoreSpammingAdmins;
var		globalconfig bool		IgnoreSpammingSuperAdmins;
var		globalconfig bool		LogChat;			// Save a chat log.
var		globalconfig float		MuteTime;
var		globalconfig float		MaxChatAllowedPeriod;
var		globalconfig int		MaxChatAllowed;

var AMGameMod AGM;
var FileLog ChatLog;

var string savedwebtext;

function BeginPlay()
{
	if ( LogChat )
		ChatLog = Spawn( class 'FileLog' );

	Super.BeginPlay();
}

event Destroyed()
{
	if ( ChatLog != None )
		ChatLog.Destroy();

	Super.Destroy();
}

function SendToWebAdmin( Actor Sender, name Type, string Msg )
{
	local int i;
	local string webtext, StrA, StrB, StrC;

	StrA = AGM.Lang.LangGetFirstField(Msg, "\t");
	StrB = AGM.Lang.LangGetFirstField(Msg, "\t");
	StrC = AGM.Lang.LangGetFirstField(Msg, "\t");

	switch (Type)
	{
		case 'Caption':
			webtext = StrA;
			break;
		case 'ObjectiveShown':
			webtext = AGM.Lang.WANewObjectiveString;
			break;
		case 'MissionCompleted':
			webtext = AGM.Lang.WAMissionCompletedString;
			break;
		case 'MissionFailed':
			webtext = AGM.Lang.WAMissionFailedString;
			break;
		case 'SettingsUpdated':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASettingsUpdatedString, StrA );
			break;
		case 'TeamSay':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WATeamChatMessage, StrA, StrB );
			break;
	    case 'Say':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAGlobalChatMessage, StrA, StrB );
			break;
		case 'StatsValidatedMessage':
			webtext = AGM.Lang.WAStatsValidatedMessage;
			break;
		case 'StatsBadProfileMessage':
			webtext = AGM.Lang.WAStatsBadProfileMessage;
			break;
		case 'SwitchTeams':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASwitchTeamsMessage, StrA );
			break;
		case 'NameChange':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WANameChangeMessage, StrA, StrB );
			break;
		case 'Kick':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAKickMessage, StrA, StrB );
			break;
		case 'KickBan':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WABanMessage, StrA, StrB );
			break;
		case 'CoopLeaderPromoted':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WACOOPMessageLeaderSelected, StrA );
			break;
#if SWAT_EXPANSION
		case 'CoopQMM':
		case 'CoopMessage':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WACoopQMMMessage, StrA );
			break;
		case 'YesVote':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAYesVoteMessage, StrA );
			break;
		case 'NoVote':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WANoVoteMessage, StrA );
			break;
		case 'KickReferendumStarted':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAKickReferendumStartedMessage, StrA, StrB );
			break;
		case 'BanReferendumStarted':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WABanReferendumStartedMessage, StrA, StrB );
			break;
		case 'LeaderReferendumStarted':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WALeaderReferendumStartedMessage, StrA, StrB );
			break;
		case 'MapReferendumStarted':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAMapReferendumStartedMessage, StrA, StrB, SwatRepo(Level.GetRepo()).GuiConfig.GetGameModeName(EMPMode(int(StrC))) );
			break;
		case 'ReferendumAlreadyActive':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAReferendumAlreadyActiveMessage );
			break;
		case 'ReferendumStartCooldown':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAReferendumStartCooldownMessage );
			break;
		case 'PlayerImmuneFromReferendum':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAPlayerImmuneFromReferendumMessage, StrA );
			break;
		case 'ReferendumAgainstAdmin':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAReferendumAgainstAdminMessage );
			break;
		case 'ReferendumsDisabled':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAReferendumsDisabledMessage );
			break;
		case 'LeaderVoteTeamMismatch':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WALeaderVoteTeamMismatchMessage );
			break;
		case 'ReferendumSucceeded':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAReferendumSucceededMessage );
			break;
		case 'ReferendumFailed':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAReferendumFailedMessage );
			break;
#endif
		case 'SwatSuicide':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASwatSuicideMessage, StrA );
			break;
		case 'SuspectsSuicide':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASuspectsSuicideMessage, StrA );
			break;
		case 'SwatTeamKill':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASwatTeamKillMessage, StrA, StrB, GetWeaponFriendlyName(StrC) );
			break;
		case 'SuspectsTeamKill':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASuspectsTeamKillMessage, StrA, StrB, GetWeaponFriendlyName(StrC) );
			break;
		case 'SwatKill':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASwatKillMessage, StrA, StrB, GetWeaponFriendlyName(StrC) );
			break;
		case 'SuspectsKill':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASuspectsKillMessage, StrA, StrB, GetWeaponFriendlyName(StrC) );
			break;
		case 'SwatArrest':
			AGM.OnSuspectArrested( Sender );
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASwatArrestMessage, StrA, StrB );
			break;
		case 'SuspectsArrest':
			AGM.OnSwatArrested( Sender );
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASuspectsArrestMessage, StrA, StrB );
			break;
		case 'PlayerConnect':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAConnectedMessage, StrA );
			break;
		case 'PlayerDisconnect':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WADisconnectedMessage, StrA );
			break;
		case 'CommandGiven':
			webtext = StrA;
			break;
		case 'Stats':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WAStatsMessage, StrA );
			break;
		case 'SmashAndGrabGotItem':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASmashAndGrabGotItemMessage, StrA );
			break;
		case 'SmashAndGrabDroppedItem':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASmashAndGrabDroppedItemMessage, StrA );
			break;
		case 'SmashAndGrabArrestTimeDeduction':
			webtext = AGM.Lang.FormatLangString( AGM.Lang.WASmashAndGrabArrestTimeDeductionMessage, StrA );
			break;
		default:
			return;
	}

	AGM.FixForHTML2( webtext, "000000" ); //Convert bbcode to html in the message

	if ( webtext != "" )
	{
		if ( savedwebtext != "" )
			savedwebtext = webtext$"\n"$savedwebtext;
		else
			savedwebtext = webtext;

		if ( AGM.WebAdmin != None )
		{
			for ( i = 0; i < AGM.WebAdmin.Admins.Length; i++ )
			{
				if ( AGM.WebAdmin.Admins[i].console != "" )
					AGM.WebAdmin.Admins[i].console = webtext$"\n"$AGM.WebAdmin.Admins[i].console;
				else
					AGM.WebAdmin.Admins[i].console = savedwebtext;
			}
		}
	}
}

function string GetWeaponFriendlyName(string ClassName)
{
	local class<DamageType> C;

	C = class<DamageType>(DynamicLoadObject(ClassName, class'Class'));
	if (C != None)
		return C.static.GetFriendlyName();   //this actually calls polymorphically into the DamageType subclass!
	else
		return ClassName;
}

function Chat( string text )
{
	if ( ChatLog != None )
	{
		text = "["$Level.Day$"/"$Level.Month$"/"$Level.Year$" "$Level.Hour$":"$Level.Minute$":"$Level.Second$"]: "$text;
		ChatLog.OpenLog("ChatLog");
		ChatLog.Logf( text );
		ChatLog.CloseLog();
	}
}

function bool BroadcastAllowed( Actor broadcaster, int len, optional name type )
{
	local AMPlayerController SPC;
	local int i, chatsInPeriod;
	local bool retVal;

	retVal = AllowsBroadcast( broadcaster, len );

	if ( PlayerController(broadcaster) != None )
		SPC = AGM.GetAMPlayerController(PlayerController(broadcaster));

	if ( SPC == None )
		return retVal;

	if ( type == 'Say' || type == 'TeamSay' )
	{
		if ( Level.TimeSeconds - SPC.mutedTime > MuteTime )
			SPC.muted = false;

		if ( SPC.muted )
			return false;

		if ( MuteTime > 0.0 && MaxChatAllowed > 0 && MaxChatAllowedPeriod > 0.0
		&& (!SPC.isSuperAdmin || !IgnoreSpammingSuperAdmins)
		&& (!SPC.isAdmin || !IgnoreSpammingAdmins) )
		{
			chatsInPeriod = 1;
			for ( i = SPC.chatTimes.Length-1; i >= 0; i-- )
			{
				if ( Level.TimeSeconds - SPC.chatTimes[i] > MaxChatAllowedPeriod )
					SPC.chatTimes.Remove( i, 1 );
				else
					chatsInPeriod++;
			}

			SPC.chatTimes[SPC.chatTimes.length] = Level.TimeSeconds;

			if ( chatsInPeriod > MaxChatAllowed )
			{
				Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.MutedString, MuteTime ), 'Caption');
				SPC.chatTimes.Remove( 0, SPC.chatTimes.length );
				SPC.mutedTime = Level.TimeSeconds;
				SPC.muted = true;
				return false;
			}
		}
	}

	return retVal;
}

function bool AllowsBroadcast( actor broadcaster, int Len )
{
	return true;
}

 // dbeswick: broadcast send to Target only
function Broadcast( Actor Sender, coerce string Msg, optional name Type
#if IG_SWAT && SWAT_EXPANSION
				   , optional PlayerController Target
#endif
				   )
{
	local Controller C;
	local PlayerController P;
	local PlayerReplicationInfo PRI;
	local AMPlayerController SPC;

	// see if allowed (limit to prevent spamming)
	if ( !BroadcastAllowed(Sender, Len(Msg), Type) )
		return;

	if ( PlayerController(sender) != None )
		SPC = AGM.GetAMPlayerController(PlayerController(sender));

	if ( SPC != None )
	{
		SPC.lastMessageTime = Level.TimeSeconds;
		SPC.numMessages++;
	}

	if ( Pawn(Sender) != None )
		PRI = Pawn(Sender).PlayerReplicationInfo;
	else if ( Controller(Sender) != None )
		PRI = Controller(Sender).PlayerReplicationInfo;

	if ( PRI != None && (Type == 'Say' || Type == 'TeamSay') )
	{
		Chat( string(Type)$": "$PRI.PlayerName$": "$Msg );
#if	SWAT_EXPANSION
	if ( Target == None )
#endif
		SendToWebAdmin( Sender, Type, PRI.PlayerName$"\t"$Msg );
	}
	else
	{
		Chat( string(Type)$": "$Msg );
#if	SWAT_EXPANSION
	if ( Target == None )
#endif
		SendToWebAdmin( Sender, Type, Msg );
	}

	if ( bPartitionSpectators && (PRI != None) && (PRI.bOnlySpectator || PRI.bOutOfLives) )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			P = PlayerController(C);
#if IG_SWAT && SWAT_EXPANSION // dbeswick: broadcast send to Target only
			if ( (P != None) && (P.PlayerReplicationInfo.bOnlySpectator || P.PlayerReplicationInfo.bOutOfLives) && (Target == None || Target == P) )
#else
			if ( (P != None) && (P.PlayerReplicationInfo.bOnlySpectator || P.PlayerReplicationInfo.bOutOfLives) )
#endif
				BroadcastText(PRI, P, Msg, Type);
		}
	}
	else
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			P = PlayerController(C);
#if IG_SWAT && SWAT_EXPANSION // dbeswick: broadcast send to Target only
			if ( P != None && (Target == None || Target == P) )
#else
			if ( P != None )
#endif
				BroadcastText(PRI, P, Msg, Type);
		}
	}
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
	local Controller C;
	local PlayerController P;
	local PlayerReplicationInfo PRI;
	local AMPlayerController SPC;

	// see if allowed (limit to prevent spamming)
	if ( !BroadcastAllowed(Sender, Len(Msg), Type) )
		return;

	if ( PlayerController(sender) != None )
		SPC = AGM.GetAMPlayerController(PlayerController(sender));

	if ( SPC != None )
	{
		SPC.lastMessageTime = Level.TimeSeconds;
		SPC.numMessages++;
	}

	if ( Sender != None )
		PRI = Sender.PlayerReplicationInfo;

	if ( PRI != None && (Type == 'Say' || Type == 'TeamSay') )
	{
		Chat( string(Type)$": "$PRI.PlayerName$": "$Msg );
		SendToWebAdmin( Sender, Type, PRI.PlayerName$"\t"$Msg );
	}
	else
	{
		Chat( string(Type)$": "$Msg );
		SendToWebAdmin( Sender, Type, Msg );
	}

	//Spectator team chat is sent to other spectators only
	SPC = AGM.GetAMPlayerController( PlayerController(Sender) );
	if ( SPC.isSpectator )
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			P = PlayerController(C);
			SPC = AGM.GetAMPlayerController( P );
			if ( P != None && P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team	&& SPC.isSpectator )
				BroadcastText(Sender.PlayerReplicationInfo, P, Msg, Type);
		}
	}
	else
	{
		for ( C=Level.ControllerList; C!=None; C=C.NextController )
		{
			P = PlayerController(C);
			if ( P != None && P.PlayerReplicationInfo.Team == Sender.PlayerReplicationInfo.Team )
				BroadcastText(Sender.PlayerReplicationInfo, P, Msg, Type);
		}
	}
}

defaultproperties
{
	IgnoreSpammingAdmins=false
	IgnoreSpammingSuperAdmins=false
	LogChat=true
	MuteTime=30.0
	MaxChatAllowedPeriod=5.0
	MaxChatAllowed=3
}