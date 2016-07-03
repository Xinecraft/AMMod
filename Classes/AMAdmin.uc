class AMAdmin extends SwatGame.SwatAdmin;

const MAX_MAPS = 40;

var AMGameMod					AGM;
var array<PlayerController>		AdminList;					// List of admins
var string						masterbanlist;

struct cmd_v
{
	var string cmd;
	var string params;
	var int numparams;
	var bool donthelp;
};

var array<cmd_v>				cmdList;

var globalconfig bool			AddMasterBans;				// Add bans received from the MBL.
var globalconfig string			AdminPassword;				// Admin Password.
var globalconfig bool			AllowSpectators;			// Allow spectators.
var globalconfig bool			AllowFreeSpectators;		// Allow free roaming spectators.
var globalconfig bool			AutoOpenClientMenu;			// Auto Open Client Mod Menu.
var globalconfig int			MaxSpectators;				// Maximum spectators allowed.
var globalconfig bool			OnlyAdminSpectators;		// Only admins may spectate.
var globalconfig array<string>  SavedMaps;					// Saved map list.
var globalconfig bool			ShowIPBans;					// Show everyone on the server IP bans.
var globalconfig array<string>	SuperAdminCommands;			// List of commands available only to superadmins.
var globalconfig string			SuperAdminPassword;			// Extra access to admin commands.

function BeginPlay()
{
	AddCmd( "getplayers", "", 0 );
	AddCmd( "balanceteams", "", 0 );
	AddCmd( "lockteams", "", 0 );
	AddCmd( "getbans", "", 0 );
	AddCmd( "gettempbans", "", 0 );
	AddCmd( "addban", "ip|range [time] [comment]", 1 );
	AddCmd( "removeban", "ip|range", 1 );
	AddCmd( "help", "[command]", 0 );
	AddCmd( "info", "", 0 );
	AddCmd( "sc", "command", 1 );
	AddCmd( "motd", "message", 1 );
	AddCmd( "saveconfig", "", 0 );
	AddCmd( "ammenu", "key computername", 2, true );
	AddCmd( "restart", "", 0 );
#if SWAT_EXPANSION
	AddCmd( "restoresag", "", 0 );
#endif
	AddCmd( "restoremaps", "", 0 );
	AddCmd( "savemaps", "", 0 );
	AddCmd( "getmaps", "", 0 );
	AddCmd( "getsavedmaps", "", 0 );
	AddCmd( "setmap", "mapindex", 1 );
	AddCmd( "removemap", "mapindex", 1 );
	AddCmd( "addmap", "mapname [mapindex]", 1 );
	AddCmd( "kickban", "id|name [time] [comment]", 1 );
	AddCmd( "kick", "id|name", 1 );
	AddCmd( "makevip", "id|name", 1 );
	AddCmd( "forcename", "id|name newname", 2 );
	AddCmd( "forcelesslethal", "id|name", 1 );
	AddCmd( "switchteam", "id|name", 1 );
	AddCmd( "switchall", "", 0 );
	AddCmd( "lockeddefaultteam", "teamname", 1 );
	AddCmd( "forceleader", "id|name", 1 );
	AddCmd( "addreplacement", "oldclass newclass", 2 );
	AddCmd( "removereplacement", "id|class", 1 );
	AddCmd( "getreplacements", "", 0 );
	AddCmd( "say", "message", 1 );
	AddCmd( "as", "message", 1 );
	AddCmd( "lockmaplist", "", 0 );
	AddCmd( "forcenoweapons", "id|name", 1 );
	AddCmd( "forcespec", "id|name", 1 );
	AddCmd( "forceview", "id|name", 1 );
	AddCmd( "forcejoin", "id|name", 1 );
	AddCmd( "pause", "", 0 );
	AddCmd( "forcemute", "id|name", 1 );
}

function AdminCommand( string S, string KickerName, string KickerIP, optional PlayerController Kicker, optional out string Msg )
{
	local AMPlayerController KSPC;
	local int lowestscore;
	local string cmd;
	local array<string> params;
	local cmd_v cmd_var;
	local int i, j;

	lowestscore = 999;

	if ( Kicker != None )
		KSPC = AGM.GetAMPlayerController(Kicker);

	cmd = lower(S);

	i = InStr( cmd, " " );
	if ( i != -1 )
	{
		cmd = Left( cmd, i );
		S = Mid( S, i+1 );

		i = InStr( S, " " );
		while ( i != -1 )
		{
			if ( Mid( S, j, i-j ) != "" )
				params[params.Length] = Mid( S, j, i-j );

			i++;
			j = i;
			i = AGM.InStrAfter( S, " ", i );
		}
		params[params.Length] = Mid( S, j );
	}

	for ( i = 0; i < cmdList.Length; i++ )
	{
		if ( cmd == cmdList[i].cmd )
		{
			cmd_var = cmdList[i];
			break;
		}
	}

	if ( i == cmdList.Length )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.UnrecognisedACString, cmd );
		return;
	}

	if ( params.Length < cmd_var.numparams )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.UsageString, cmd, cmd_var.params );
		return;
	}

	if ( Kicker != None && !KSPC.isSuperAdmin && IsSuperAdminCommand( cmd ) )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.SuperAdminString );
		return;
	}

	AGM.BroadcastHandler.Chat( "AdminCommand: "$KickerName$" ("$KickerIP$"): "$cmd );

	switch (cmd)
    {
		case "getplayers":
			Msg = GetPlayers_AC();
			break;
		case "balanceteams":
			Msg = BalanceTeams_AC( KickerName );
			break;
		case "lockteams":
			Msg = LockTeams_AC( KickerName );
			break;
		case "getbans":
			Msg = GetBans_AC();
			break;
		case "gettempbans":
			Msg = GetTempBans_AC();
			break;
		case "addban":
			Msg = AddBan_AC( params[0], KickerName, KickerIP, params[1], Mid(S, len(params[0])+len(params[1])+2) );
			break;
		case "removeban":
			Msg = RemoveBan_AC( params[0], KickerName );
			break;
		case "help":
			Msg = Help_AC( params[0] );
			break;
		case "info":
			Msg = Info_AC();
			break;
		case "sc":
			Msg = ServerCommand_AC( S, KickerName, KickerIP );
			break;
		case "motd":
			Msg = MOTD_AC( S, KickerName );
			break;
		case "saveconfig":
            Msg = SaveConfig_AC( KickerName );
			break;
		case "ammenu":
            Msg = AMMenu_AC( Kicker, params[0], params[1] );
			break;
		case "restart":
			Msg = Restart_AC( KickerName );
			break;
#if SWAT_EXPANSION
		case "restoresag":
			Msg = RestoreSAG_AC( KickerName );
			break;
#endif
		case "restoremaps":
			Msg = RestoreMaps_AC();
			break;
		case "savemaps":
            Msg = SaveMaps_AC( KickerName );
			break;
		case "getmaps":
            Msg = GetMaps_AC();
			break;
		case "getsavedmaps":
            Msg = GetSavedMaps_AC();
			break;
		case "setmap":
			Msg = SetMap_AC( S, KickerName );
			break;
		case "removemap":
            Msg = RemoveMap_AC( S );
			break;
		case "addmap":
            Msg = AddMap_AC( S );
			break;
		case "kickban":
            Msg = KickBan_AC( params[0], KickerName, KickerIP, params[1], Mid(S, len(params[0])+len(params[1])+2) );
			break;
		case "kick":
            Msg = Kick_AC( params[0], KickerName );
			break;
		case "makevip":
			Msg = MakeVIP_AC( params[0], KickerName );
			break;
		case "forcename":
			Msg = ForceName_AC( params[0], params[1], KickerName );
			break;
		case "forcelesslethal":
			Msg = ForceLessLethal_AC( params[0], KickerName );
			break;
		case "switchteam":
			Msg = SwitchTeam_AC( params[0], KickerName );
			break;
		case "switchall":
			Msg = SwitchAll_AC( KickerName );
			break;
		case "lockeddefaultteam":
			Msg = LockedDefaultTeam_AC( params[0] );
			break;
#if SWAT_EXPANSION
		case "forceleader":
			Msg = ForceLeader_AC( params[0], KickerName );
			break;
#endif
		case "addreplacement":
			Msg = AddReplacement_AC( S );
			break;
		case "removereplacement":
			Msg = RemoveReplacement_AC( S );
			break;
		case "getreplacements":
			Msg = GetReplacements_AC();
			break;
		case "say":
			Msg = Say_AC( S, KickerName );
			break;
		case "as":
			Msg = AdminSay_AC( KickerName, S );
			break;
		case "lockmaplist":
			Msg = LockMapList_AC( KickerName );
			break;
		case "forcenoweapons":
			Msg = ForceNoWeapons_AC( params[0], KickerName );
			break;
		case "forcespec":
			Msg = ForceSpec_AC( params[0], KickerName );
			break;
		case "forceview":
			Msg = ForceView_AC( params[0], KickerName );
			break;
		case "forcejoin":
			Msg = ForceJoin_AC( params[0], KickerName );
			break;
		case "pause":
			Msg = Pause_AC( Kicker );
			break;
		case "forcemute":
			Msg = ForceMute_AC( params[0], KickerName );
			break;
		default:
			Msg = AGM.Lang.FormatLangString( AGM.Lang.UnrecognisedACString, cmd );
			break;
	}

	return;
}

function string AMMenu_AC( PlayerController Kicker, string keytext, string comptext )
{
	local AMPlayerController SPC;
	local PlayerController PC;
	local string Msg, text;
	local int i;

	if ( Kicker == None )
		return "";

	SPC = AGM.GetAMPlayerController(Kicker);

	if ( SPC == None )
		return "";

	Msg = "[c=ffff00]- BeginPlayers -";
	Level.Game.BroadcastHandler.BroadcastText(None, Kicker, Msg, 'Caption');

	for( i = 0; i < AGM.PlayerList.Length; i++ )
	{
		if ( AGM.PlayerList[i] == None || AGM.PlayerList[i].PC == None || AGM.PlayerList[i].PC.PlayerReplicationInfo.PlayerName == "" )
			continue;

		SPC = AGM.PlayerList[i];
		PC = AGM.PlayerList[i].PC;
		Msg = "[c=ffff00]- PL -"$i;

		if ( SwatGamePlayerController(PC).ThisPlayerIsTheVIP )
			Msg = Msg@"[c=00ff00]";
		else if ( NetTeam(PC.PlayerReplicationInfo.Team).GetTeamNumber() == 1 )
			Msg = Msg@"[c=ff0000]";
		else
			Msg = Msg@"[c=0000ff]";

		if ( SPC.isSuperAdmin )
			text = "[c=ffffff](SA)";
		else if ( SPC.isAdmin )
			text = "[c=ffffff](A)";
		else if ( SPC.isSubAdmin )
			text = "[c=ffffff](M)";
		else
			text = "";

		Msg = Msg$PC.PlayerReplicationInfo.PlayerName$text$"[c=ffff00]"@SwatGameInfo(Level.Game).GetPlayerScore(PC)@SPC.networkAddress;
		Level.Game.BroadcastHandler.BroadcastText(None, Kicker, Msg, 'Caption');
	}

	Msg = "[c=ffff00]- EndPlayers -";
	Level.Game.BroadcastHandler.BroadcastText(None, Kicker, Msg, 'Caption');
	Msg = "";

	return "";
}

function string Info_AC()
{
	local string Msg;

	Msg = AGM.Lang.FormatLangString( AGM.Lang.ModVersionString, MOD_VERSION$MOD_VERSION_SUFFIX );
	Msg = Msg$  "\n"$AGM.Lang.FormatLangString( AGM.Lang.LatestVersionString, AGM.latestversion );
	Msg = Msg$  "\n"$AGM.Lang.FormatLangString( AGM.Lang.ComputerString, Level.ComputerName );

	if ( AGM.KeyMsg != "" )
		Msg = Msg$	"\n[b]AMMod.AMLink[\\b]: "$AGM.KeyMsg;

	return Msg;
}

function SetAdminPassword( string Password )
{
}

function bool CheckPassword( string Password, string CheckPassword )
{
	if ( Password == CheckPassword && CheckPassword != "" )
		return true;

	return false;
}

function AdminLogin( PlayerController PC, string Password )
{
	local AMPlayerController SPC;

	if ( PC == Level.GetLocalPlayerController() )
		Password = SuperAdminPassword;

    if ( !CheckPassword( Password, AdminPassword ) && !CheckPassword( Password, SuperAdminPassword ) )
		return;

	SPC = AGM.GetAMPlayerController(PC);
	if ( SPC == None )
		return;

	if ( !IsAdmin( PC ) )
		AdminList[ AdminList.Length ] = PC;

	SPC.isAdmin = true;

	if ( Password == SuperAdminPassword )
		SPC.isSuperAdmin = true;

    if( SwatPlayerReplicationInfo(PC.PlayerReplicationInfo) != None )
		if ( SPC.isSuperAdmin || !IsSuperAdminCommand( "updatesettings" ) )
	        SwatPlayerReplicationInfo(PC.PlayerReplicationInfo).SetAdmin( true );

    if( SwatGamePlayerController(PC) != None )
        SwatGamePlayerController(PC).SwatRepoPlayerItem.LastAdminPassword = Password;

	if ( SPC.seenMOTD && AutoOpenClientMenu )
		SPC.PC.ClientOpenMenu( "AMClient.AMHook", "AMHook" );
}

function bool IsAdmin( PlayerController PC )
{
    local int i;
	local bool retval;

	retval = false;

    for( i = AdminList.Length-1; i >= 0 ; i-- )
	{
		if ( AdminList[i] == None )
			AdminList.Remove( i, 1 );
		else if ( AdminList[i] == PC )
            retval = true;
	}

    return retval;
}

function Kick( PlayerController PC, String PlayerName )
{
	local AMPlayerController KSPC;
	local string Msg;

	if ( Left(PlayerName, 3) ~= "cc " )
	{
		ClientCommand( Mid( PlayerName, 3 ), PC, false );
		return;
	}

	KSPC = AGM.GetAMPlayerController(PC);
	if ( KSPC == None )
		return;

    if( !KSPC.isAdmin )
        return;

	if ( Left( PlayerName, 3 ) ~= "ac " )
	{
		AdminCommand( Mid( PlayerName, 3 ), PC.PlayerReplicationInfo.PlayerName, KSPC.networkAddress, PC, Msg );
		ShowAdminMsg( Msg, PC );
		return;
	}

    KickPlayer( PC, PlayerName );
}

function KickPlayer( PlayerController Kicker, string S )
{
	local PlayerController P, PC;
	local AMPlayerController SPC, KSPC;
	local int lowestscore;
	local string Msg;

	KSPC = AGM.GetAMPlayerController(Kicker);

	if ( KSPC == None )
		return;

	if ( !KSPC.isAdmin )
		return;

	if ( !KSPC.isSuperAdmin && IsSuperAdminCommand( "kick" ) )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.SuperAdminString );
		ShowAdminMsg( Msg, Kicker );
		return;
	}

	lowestscore = 999;

	ForEach DynamicActors(class'PlayerController', PC)
	{
		SPC = AGM.GetAMPlayerController( PC );

		if ( SPC == None )
			continue;

		if ( PC.PlayerReplicationInfo.PlayerName ~= S && NetConnection(PC.Player) != None )
		{
			if( SwatGameInfo(Level.Game).GetPlayerScore( PC ) < lowestscore && (!SPC.isAdmin || P == None) )
			{
				P = PC;
				lowestscore = SwatGameInfo(Level.Game).GetPlayerScore( P );
			}
		}
	}

	if ( P != None )
	{
		SPC = AGM.GetAMPlayerController( P );
		SPC.shouldKick = true;
		SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickString, Kicker.PlayerReplicationInfo.PlayerName, P.PlayerReplicationInfo.PlayerName );
	}
}

function KickBan( PlayerController Kicker, string PlayerName )
{
	local PlayerController P, PC;
	local AMPlayerController SPC, KSPC;
	local int lowestscore, i;
	local string Msg, time, comment;

	i = InStr( PlayerName, " " );

	if ( i != -1 )
	{
		time = Mid( PlayerName, i+1 );
		PlayerName = Left(PlayerName, i);
	}

	i = InStr( time, " " );

	if ( i != -1 )
	{
		comment = Mid( time, i+1 );
		time = Left(time, i);
	}

	KSPC = AGM.GetAMPlayerController(Kicker);

	if ( KSPC == None )
		return;

	if ( !KSPC.isAdmin )
		return;

	if ( !KSPC.isSuperAdmin && IsSuperAdminCommand( "kickban" ) )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.SuperAdminString );
		ShowAdminMsg( Msg, Kicker );
		return;
	}

	lowestscore = 999;

	ForEach DynamicActors(class'PlayerController', PC)
	{
		SPC = AGM.GetAMPlayerController(PC);
		if ( SPC == None )
			continue;

		if ( PC.PlayerReplicationInfo.PlayerName ~= PlayerName && NetConnection(PC.Player) != None )
		{
			if( SwatGameInfo(Level.Game).GetPlayerScore( PC ) < lowestscore && (!SPC.isAdmin || P == None) )
			{
				P = PC;
				lowestscore = SwatGameInfo(Level.Game).GetPlayerScore( P );
			}
		}
	}

	if ( P != None )
	{
		if ( P != None )
		{
			SPC = AGM.GetAMPlayerController( P );
			SPC.shouldBan = true;
			SPC.banTime = time;
			SPC.banner = Kicker.PlayerReplicationInfo.PlayerName;
			SPC.bannersIP = Kicker.PlayerReplicationInfo.PlayerName$","$KSPC.networkAddress;
			SPC.banComment = comment;
			SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickBanString, Kicker.PlayerReplicationInfo.PlayerName, P.PlayerReplicationInfo.PlayerName );
		}
	}
}

function int IDtoINT( String S )
{
    local int ID, i;

	for (i = 0; i < Len(S); ++i)
	{
		if ( Asc( Mid(S,i,1) ) < 48 || Asc( Mid(S,i,1) ) > 57)
			return -1;
	}

    ID = int(S);

    //handle invalid ID number
    if( ID < 0 || ID > ServerSettings(Level.CurrentServerSettings).MaxPlayers-1 )
		return -1;

	return ID;
}

function ShowAdminMsg( String Msg, PlayerController Kicker, optional bool toall )
{
	local int length, point, i;
	local PlayerController PC;
	local AMPlayerController SPC;
	local string webtext;

	if ( Msg == "" )
		return;

	if ( AGM.BroadCastToAllAdmins || toall )
	{
		webtext = Msg;

		AGM.FixForHTML2( webtext, "ffff00" );

		webtext = "</font><font color=ffff00>"$webtext;

		if ( webtext != "" )
		{
			if ( AGM.BroadcastHandler.savedwebtext != "" )
				AGM.BroadcastHandler.savedwebtext = webtext$"\n"$AGM.BroadcastHandler.savedwebtext;
			else
				AGM.BroadcastHandler.savedwebtext = webtext;

			if ( AGM.WebAdmin != None )
			{
				for ( i = 0; i < AGM.WebAdmin.Admins.Length; i++ )
				{
					if ( AGM.WebAdmin.Admins[i].console != "" )
						AGM.WebAdmin.Admins[i].console = webtext$"\n"$AGM.WebAdmin.Admins[i].console;
					else
						AGM.WebAdmin.Admins[i].console = AGM.BroadcastHandler.savedwebtext;
				}
			}
		}
	}

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
				i = AGM.InStrAfter(Msg, "\n", i+2);
			}
		}

		if ( point < 1 )
			point = 350;

		if ( AGM.BroadCastToAllAdmins || toall )
		{
			ForEach DynamicActors(class'PlayerController', PC)
			{
				SPC = AGM.GetAMPlayerController(PC);
				if ( SPC == None || !SPC.isAdmin )
					continue;

				Level.Game.BroadcastHandler.BroadcastText(None, PC, "[c=ffff00]"$Left(Msg, point), 'Caption');
			}
		}
		else
		{
			if ( Kicker != None )
				Level.Game.BroadcastHandler.BroadcastText(None, Kicker, "[c=ffff00]"$Left(Msg, point), 'Caption');
		}

		AGM.BroadcastHandler.Chat( "AdminMsg: "$Left(Msg, point) );

		Msg = Mid(Msg, point+1);
	}
}

function bool IsSuperAdminCommand( string S )
{
	local int i;

	for ( i = 0; i < SuperAdminCommands.Length; i++ )
	{
		if ( SuperAdminCommands[i] ~= S )
			return true;
	}

	return false;
}

function string GetPlayers_AC()
{
	local int i;
	local string Msg, text;
	local PlayerController PC;
	local AMPlayerController SPC;

	Msg = AGM.Lang.FormatLangString( AGM.Lang.GetPlayersString );

	for( i = 0; i < AGM.PlayerList.Length; i++ )
	{
		if ( AGM.PlayerList[i] == None || AGM.PlayerList[i].PC == None || AGM.PlayerList[i].PC.PlayerReplicationInfo.PlayerName == ""  && !AGM.PlayerList[i].isBot)
			continue;

		SPC = AGM.PlayerList[i];
		PC = AGM.PlayerList[i].PC;
		Msg = Msg$"\n"$i$" - [b]";

		if ( SwatGamePlayerController(PC).ThisPlayerIsTheVIP )
			Msg = Msg@"[c=00ff00]";
		else if ( NetTeam(PC.PlayerReplicationInfo.Team).GetTeamNumber() == 1 )
			Msg = Msg$"[c=ff0000]";
		else
			Msg = Msg$"[c=0000ff]";

		if ( SPC.isSuperAdmin )
			text = "[c=ffffff](SA)";
		else if ( SPC.isAdmin )
			text = "[c=ffffff](A)";
		else if ( SPC.isSubAdmin )
			text = "[c=ffffff](M)";
		else
			text = "";

		Msg = Msg$PC.PlayerReplicationInfo.PlayerName$text$"[c=ffff00][\\b] - "$SwatGameInfo(Level.Game).GetPlayerScore(PC)$" - "$SPC.networkAddress;
	}

	return Msg;
}

function string BalanceTeams_AC( string balancer )
{
	local AMPlayerController SPC;
	local array<AMPlayerController> SwatTeam, SuspectTeam;
	local int i, swatnum, susnum, difference, RandomIndex;
	local string Msg;

	Msg = AGM.Lang.FormatLangString( AGM.Lang.BalanceString, balancer );
	Level.Game.Broadcast(None, Msg, 'Caption');

	for ( i = 0; i < AGM.PlayerList.Length; i++ )
	{
		SPC = AGM.PlayerList[i];

		if ( SPC == None || SPC.PC == None || NetTeam(SPC.PC.PlayerReplicationInfo.Team) == None )
			continue;

		if ( NetTeam(SPC.PC.PlayerReplicationInfo.Team).GetTeamNumber() == 0 )
			SwatTeam[SwatTeam.Length] = SPC;
		else if ( NetTeam(SPC.PC.PlayerReplicationInfo.Team).GetTeamNumber() == 1 )
			SuspectTeam[SuspectTeam.Length] = SPC;
	}

	AGM.CheckGameEnded();

	swatnum = SwatTeam.Length;
	susnum = SuspectTeam.Length;
	if ( swatnum > susnum )
	{
		difference = swatnum - susnum;
		while ( difference > 1 )
		{
			if ( SwatTeam.Length == 0 )
				break;

			RandomIndex = Rand(SwatTeam.Length);

			if ( SwatTeam[RandomIndex].isAdmin || SwatTeam[RandomIndex].isSubAdmin || (SwatGamePlayerController(SwatTeam[RandomIndex].PC).ThisPlayerIsTheVIP && !AGM.hasEnded) )
			{
				SwatTeam.Remove( RandomIndex, 1 );
				continue;
			}

			swatnum--;
			susnum++;
			difference = swatnum - susnum;

			SwatTeam[RandomIndex].teamForced = true;
			Msg = AGM.Lang.FormatLangString( AGM.Lang.MovedTeamString, AGM.Lang.FormatLangString( AGM.Lang.ServerString ), SwatTeam[RandomIndex].PC.PlayerReplicationInfo.PlayerName );
			Level.Game.Broadcast(None, Msg, 'Caption');

			if ( SwatTeam[RandomIndex].PC.Pawn != None )
				SwatTeam[RandomIndex].PC.Pawn.Died( None, class'DamageType', SwatTeam[RandomIndex].PC.Pawn.Location, vect(0,0,0) );
			SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController( SwatTeam[RandomIndex].PC ) );
			SwatTeam.Remove( RandomIndex, 1 );
		}
	}
	else if ( susnum > swatnum )
	{
		difference = susnum - swatnum;
		while ( difference > 1 )
		{
			if ( SuspectTeam.Length == 0 )
				break;

			RandomIndex = Rand(SuspectTeam.Length);

			if ( SuspectTeam[RandomIndex].isAdmin || SuspectTeam[RandomIndex].isSubAdmin || (SwatGamePlayerController(SuspectTeam[RandomIndex].PC).ThisPlayerIsTheVIP && !AGM.hasEnded) )
			{
				SuspectTeam.Remove( RandomIndex, 1 );
				continue;
			}

			swatnum++;
			susnum--;
			difference = susnum - swatnum;

			SuspectTeam[RandomIndex].teamForced = true;
			Msg = AGM.Lang.FormatLangString( AGM.Lang.MovedTeamString, AGM.Lang.FormatLangString( AGM.Lang.ServerString ), SuspectTeam[RandomIndex].PC.PlayerReplicationInfo.PlayerName );
			Level.Game.Broadcast(None, Msg, 'Caption');

			if ( SuspectTeam[RandomIndex].PC.Pawn != None )
				SuspectTeam[RandomIndex].PC.Pawn.Died( None, class'DamageType', SuspectTeam[RandomIndex].PC.Pawn.Location, vect(0,0,0) );
			SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController( SuspectTeam[RandomIndex].PC ) );
			SuspectTeam.Remove( RandomIndex, 1 );
		}
	}

	Msg = AGM.Lang.FormatLangString( AGM.Lang.BalanceAString );
	return Msg;
}

function string LockTeams_AC( string locker )
{
	local string Msg;

	if ( AGM.TeamsLocked )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.UnlockedString, locker );
		Level.Game.Broadcast(None, Msg, 'Caption');
		Msg = AGM.Lang.FormatLangString( AGM.Lang.UnlockedAString );
	}
	else
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.LockedString, locker );
		Level.Game.Broadcast(None, Msg, 'Caption');
		Msg = AGM.Lang.FormatLangString( AGM.Lang.LockedAString );
	}

	AGM.LockTeams();

	return Msg;
}

function string GetBans_AC()
{
	local int i, j;
	local string Msg;
	local array<string> IPArray;

	for ( j = AGM.AccessControl.IPPolicies.Length-1; j >= 0; j-- )
	{
		if( AGM.AccessControl.IPPolicies[j] == "" )
			continue;
		else
		{
			IPArray[IPArray.Length] = AGM.AccessControl.IPPolicies[j];
			if ( IPArray.Length >= 35 )
				break;
		}
	}

	for ( i = IPArray.Length-1; i >= 0; i-- )
	{
		if ( IPArray[i] != "" )
			Msg = Msg$"\n"$IPArray[i];
	}
	if ( Msg == "" )
		Msg = AGM.Lang.FormatLangString( AGM.Lang.NoBanListString );
	else
		Msg = AGM.Lang.FormatLangString( AGM.Lang.BanListString, Msg );

	return Msg;
}

function string GetTempBans_AC()
{
	local int i, j;
	local string Msg;
	local array<string> IPArray;

	for ( j = AGM.AccessControl.TempIPPolicies.Length-1; j >= 0; j-- )
	{
		if( AGM.AccessControl.TempIPPolicies[j] == "" )
			continue;
		else
		{
			IPArray[IPArray.Length] = AGM.AccessControl.TempIPPolicies[j];
			if ( IPArray.Length >= 35 )
				break;
		}
	}

	for ( i = IPArray.Length-1; i >= 0; i-- )
	{
		if ( IPArray[i] != "" )
			Msg = Msg$"\n"$IPArray[i];
	}
	if ( Msg == "" )
		Msg = AGM.Lang.FormatLangString( AGM.Lang.NoTempBanListString );
	else
		Msg = AGM.Lang.FormatLangString( AGM.Lang.TempBanListString, Msg );

	return Msg;
}

function string AddBan_AC( string IP, string banner, string bannerip, string time, string comment )
{
	local string Msg, expirytime, str;
	local int i;

	i = InStr( IP, ":" );

	if ( i != -1 )
		IP = Left( IP, i );

	if ( time != "" && time != "0" && lower(time) != "none" )
	{
		if ( AGM.AccessControl.CheckTempIPPolicy(IP) )
		{
			expirytime = AGM.GetBanTime( time );

			Log("AMMod.AMAdmin: Adding Temp IP Ban for: "$IP);
			AGM.AccessControl.TempIPPolicies[AGM.AccessControl.TempIPPolicies.Length] = "DENY,"$IP$","$expirytime$",~ManualIPBan,"$banner$","$bannerip$","$comment;
			Msg = AGM.Lang.FormatLangString( AGM.Lang.AddTempBanString, banner, IP );
			if ( comment != "" )
				Msg = Msg$" ("$comment$")";

			AGM.AccessControl.SaveConfig( "", "", false, true );
			if ( AGM.FlushVariables )
				AGM.AccessControl.FlushConfig();

			str = AGM.Lang.FormatLangString( AGM.Lang.KickBanString, banner, IP );
			if ( comment != "" )
				str = str$" ("$comment$")";
			if ( ShowIPBans )
				Level.Game.Broadcast(None, str, 'Caption');
			else
				Level.Game.Broadcast(None, banner, 'SettingsUpdated');
		}
		else
			Msg = AGM.Lang.FormatLangString( AGM.Lang.TempBanExistsString, IP );
	}
	else if ( AGM.AccessControl.CheckIPPolicy(IP) )
	{
		Log("AMMod.AMAdmin: Adding IP Ban for: "$IP);
		AGM.AccessControl.IPPolicies[AGM.AccessControl.IPPolicies.Length] = "DENY,"$IP$",~ManualIPBan,"$banner$","$bannerip$","$comment;
		Msg = AGM.Lang.FormatLangString( AGM.Lang.AddBanString, banner, IP );
		if ( comment != "" )
			Msg = Msg$" ("$comment$")";

		AGM.AccessControl.SaveConfig( "", "", false, true );
		if ( AGM.FlushVariables )
			AGM.AccessControl.FlushConfig();

		str = AGM.Lang.FormatLangString( AGM.Lang.KickBanString, banner, IP );
		if ( comment != "" )
			str = str$" ("$comment$")";
		if ( ShowIPBans )
			Level.Game.Broadcast(None, str, 'Caption');
		else
			Level.Game.Broadcast(None, banner, 'SettingsUpdated');
	}
	else
		Msg = AGM.Lang.FormatLangString( AGM.Lang.BanExistsString, IP );

	return Msg;
}

function string RemoveBan_AC( string IP, string remover )
{
	local int i, j, k;
	local string Msg, Mask;
	local bool banRemoved;

	for ( j = 0; j < AGM.AccessControl.IPPolicies.Length; j++ )
	{
		i = InStr( AGM.AccessControl.IPPolicies[j], "," );
		if ( i == -1 )
			continue;
		Mask = Mid( AGM.AccessControl.IPPolicies[j], i+1 );

		k = InStr( Mask, "," );
		if ( k != -1 )
			Mask = Left( Mask, k );

		if ( Mask == IP )
			break;
	}

	if ( j < AGM.AccessControl.IPPolicies.Length )
	{
		Log("AMMod.AMAdmin: Removing IP Ban rule for: "$IP);
		AGM.AccessControl.IPPolicies.Remove( j, 1 );
		banRemoved = true;
	}

	for ( j = 0; j < AGM.AccessControl.TempIPPolicies.Length; j++ )
	{
		i = InStr( AGM.AccessControl.TempIPPolicies[j], "," );
		if ( i == -1 )
			continue;
		Mask = Mid( AGM.AccessControl.TempIPPolicies[j], i+1 );

		k = InStr( Mask, "," );
		if ( k != -1 )
			Mask = Left( Mask, k );

		if ( Mask == IP )
			break;
	}

	if ( j < AGM.AccessControl.TempIPPolicies.Length )
	{
		Log("AMMod.AMAdmin: Removing Temp IP Ban rule for: "$IP);
		AGM.AccessControl.TempIPPolicies.Remove( j, 1 );
		banRemoved = true;
	}

	if ( banRemoved )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.RemoveBanString, remover, IP );
		AGM.AccessControl.SaveConfig( "", "", false, true );
		if ( AGM.FlushVariables )
			AGM.AccessControl.FlushConfig();
		Level.Game.Broadcast( None, remover, 'SettingsUpdated' );
	}
	else
		Msg = AGM.Lang.FormatLangString( AGM.Lang.CouldNotFindBanString, IP );

	return Msg;
}

function string ServerCommand_AC( string command, string executer, string KickerIP )
{
	local string Msg, Result, localip;
	local int i;

	if ( InStr( caps(command), "SET AMMOD.AMADMIN ADMINPASSWORD" ) != -1
		|| InStr( caps(command), "GET AMMOD.AMADMIN ADMINPASSWORD" ) != -1
		|| InStr( caps(command), "SET AMMOD.AMADMIN SUPERADMINPASSWORD" ) != -1
		|| InStr( caps(command), "GET AMMOD.AMADMIN SUPERADMINPASSWORD" ) != -1
		|| InStr( caps(command), "SET AMMOD.AMWEBADMINLISTENER WEBADMINUSERS" ) != -1
		|| InStr( caps(command), "GET AMMOD.AMWEBADMINLISTENER WEBADMINUSERS" ) != -1 )
	{
		localip = AGM.WebAdmin.GetLocalAddress();

		i = InStr( localip, ":" );
		if ( i != -1 )
			localip = Left( localip, i );

		log( "Checking server command ip address ("$KickerIP$") with local server ip address ("$localip$") for restricted command ("$command$")." );
		if ( KickerIP != localip )
		{
			Msg = AGM.Lang.FormatLangString( AGM.Lang.AccessRestrictedString );
			return Msg;
		}
	}

	Msg = AGM.Lang.FormatLangString( AGM.Lang.ExecuteString, executer, command );
	Result = ConsoleCommand(command);
	if ( Result != "" )
		Msg = Msg$"\n"$AGM.Lang.FormatLangString( AGM.Lang.ExecuteResultString, Result );

	return Msg;
}

function string MOTD_AC( string motd, string setter )
{
	local string Msg;

	if ( motd ~= "none" )
		motd = "";

	AGM.MOTD = motd;
	AGM.SaveConfig( "", "", false, true );
	if ( AGM.FlushVariables )
		AGM.FlushConfig();
	Level.Game.Broadcast( None, setter, 'SettingsUpdated' );

	Msg = AGM.Lang.FormatLangString( AGM.Lang.MOTDSetString, motd );

	return Msg;
}

function string LockMapList_AC( string locker )
{
	local string Msg;

	if ( AGM.LockMapList )
		Msg = AGM.Lang.FormatLangString( AGM.Lang.MapListUnlockedString );
	else
		Msg = AGM.Lang.FormatLangString( AGM.Lang.MapListLockedString );

	AGM.LockMapList = !AGM.LockMapList;

	RestoreMaps( true );

	AGM.SaveConfig( "", "", false, true );
	if ( AGM.FlushVariables )
		AGM.FlushConfig();

	Level.Game.Broadcast( None, locker, 'SettingsUpdated' );

	return Msg;
}

function string AdminSay_AC( string sayer, string message )
{
	local string Msg;

	Msg = "[b]"$sayer$"[\\b]: "$message;

	AGM.BroadcastHandler.Chat( "AdminSay: "$sayer$": "$message );

	ShowAdminMsg( Msg, None, true );

	return "";
}

function string SaveConfig_AC( string saver )
{
	local string Msg;

	SaveConfig( "", "", false, true );
	FlushConfig();

	AGM.AccessControl.SaveConfig( "", "", false, true );
	AGM.AccessControl.FlushConfig();

	AGM.SaveConfig( "", "", false, true );
	AGM.FlushConfig();

	AGM.WebAdmin.SaveConfig( "", "", false, true );
	AGM.WebAdmin.FlushConfig();

	Level.CurrentServerSettings.SaveConfig( "", "", false, true );
	Level.CurrentServerSettings.FlushConfig();

	Level.PendingServerSettings.SaveConfig( "", "", false, true );
	Level.PendingServerSettings.FlushConfig();

	Level.Game.Broadcast(None, saver, 'SettingsUpdated');
	Msg = AGM.Lang.FormatLangString( AGM.Lang.ConfigSavedString );

	return Msg;
}

function string Restart_AC( string restarter )
{
	local int i;
	for (i = 0; i < AGM.PlayerList.Length ; i++)
	{
		// End:0x85
        if(AGM.PlayerList[i] == none)
        {
            continue;
        }
        AGM.DestroyBot(AGM.PlayerList[i]);
	}

	ServerSettings(Level.PendingServerSettings).SaveConfig( "", "", false, true );
	if ( AGM.FlushVariables )
		ServerSettings(Level.PendingServerSettings).FlushConfig();
	Level.Game.Broadcast(None, restarter, 'SettingsUpdated');
	ServerSettings(Level.PendingServerSettings).RoundNumber = 0;
	SwatRepo(Level.GetRepo()).SwapServerSettings();
	SwatRepo(Level.GetRepo()).ClearRoundsWon();
	SwatRepo(Level.GetRepo()).NetSwitchLevels( false );

	return "";
}

#if SWAT_EXPANSION
function string RestoreSAG_AC( string restorer )
{
	ServerSettings(Level.PendingServerSettings).GameType = MPM_SmashAndGrab;

	RestoreMaps( true );

	Level.Game.Broadcast(None, restorer, 'SettingsUpdated');
	ServerSettings(Level.PendingServerSettings).RoundNumber = 0;
	SwatRepo(Level.GetRepo()).SwapServerSettings();
	SwatRepo(Level.GetRepo()).ClearRoundsWon();
	SwatRepo(Level.GetRepo()).NetSwitchLevels( true );

	return "";
}
#endif

function RestoreMaps( bool save )
{
	local int i;
    local MapRotation MapRotation;

	ClearMaps();

	for ( i = 0; i < SavedMaps.Length; i++ )
		ServerSettings(Level.PendingServerSettings).Maps[i] = SavedMaps[i];

	ServerSettings(Level.PendingServerSettings).NumMaps = SavedMaps.Length;

	if ( ServerSettings(Level.PendingServerSettings).MapIndex > ServerSettings(Level.PendingServerSettings).NumMaps )
		ServerSettings(Level.PendingServerSettings).MapIndex = 0;

    MapRotation = SwatRepo(Level.GetRepo()).GuiConfig.MapList[ServerSettings(Level.PendingServerSettings).GameType];

	MapRotation.ClearMaps();

    for( i = 0; i < SavedMaps.Length; i++ )
        MapRotation.Maps[i] = SavedMaps[i];

	if ( save )
	{
		MapRotation.SaveConfig( "", "", false, true );
		ServerSettings(Level.PendingServerSettings).SaveConfig( "", "", false, true );

		if ( AGM.FlushVariables )
		{
			MapRotation.FlushConfig();
			ServerSettings(Level.PendingServerSettings).FlushConfig();
		}
	}
}

function string RestoreMaps_AC()
{
	RestoreMaps( false );

	return AGM.Lang.FormatLangString( AGM.Lang.MapsRestoredString );
}

function string SaveMaps_AC( string saver )
{
	local int i;

	if ( AGM.LockMapList )
		return AGM.Lang.FormatLangString( AGM.Lang.MaplistIsLockedString );

	SavedMaps.Remove( 0, SavedMaps.Length );
	for ( i = 0 ; i < ServerSettings(Level.PendingServerSettings).NumMaps ; i++ )
		if ( ServerSettings(Level.PendingServerSettings).Maps[i] != "" )
			SavedMaps[i] = ServerSettings(Level.PendingServerSettings).Maps[i];

	SaveConfig( "", "", false, true );
	if ( AGM.FlushVariables )
		FlushConfig();
	Level.Game.Broadcast(None, saver, 'SettingsUpdated');

	return AGM.Lang.FormatLangString( AGM.Lang.MapsSavedString );
}

function string GetMaps_AC()
{
	local int i;
	local string Msg;

	Msg = AGM.Lang.FormatLangString( AGM.Lang.GetMapsString );
	for ( i = 0 ; i < ServerSettings(Level.PendingServerSettings).NumMaps; i++ )
		Msg = Msg$"\n"$i$" - "$ServerSettings(Level.PendingServerSettings).Maps[i];

	return Msg;
}

function string GetSavedMaps_AC()
{
	local int i;
	local string Msg;

	Msg = AGM.Lang.FormatLangString( AGM.Lang.GetMapsString );
	for ( i = 0 ; i < SavedMaps.Length; i++ )
		Msg = Msg$"\n"$i$" - "$SavedMaps[i];

	return Msg;
}

function string SetMap_AC( string S, string setter )
{
	local int mapindex, i;
	local string Msg;

	mapindex = 0;

	for (i = 0; i < Len(S); ++i)
	{
		if ( Asc( Mid(S,i,1) ) < 48 || Asc( Mid(S,i,1) ) > 57)
		{
			mapindex = ServerSettings(Level.PendingServerSettings).NumMaps;
			break;
		}
		else if ( i == Len(S)-1 )
			mapindex = int(S);
	}

	if ( mapindex < 0 )
		mapindex = 0;

	if ( mapindex < ServerSettings(Level.PendingServerSettings).NumMaps )
	{
		ServerSettings(Level.PendingServerSettings).MapIndex = mapindex;
		Msg = AGM.Lang.FormatLangString( AGM.Lang.MapSetString, ServerSettings(Level.PendingServerSettings).Maps[mapindex] );

		if ( ServerSettings(Level.PendingServerSettings).MapIndex > ServerSettings(Level.PendingServerSettings).NumMaps )
			ServerSettings(Level.PendingServerSettings).MapIndex = 0;

		ServerSettings(Level.PendingServerSettings).bDirty = true;

		Level.PendingServerSettings.SaveConfig( "", "", false, true );
		if ( AGM.FlushVariables )
			Level.PendingServerSettings.FlushConfig();

		Level.Game.Broadcast(None, setter, 'SettingsUpdated');
	}
	else
		Msg = AGM.Lang.FormatLangString( AGM.Lang.InvalidMapIndexString );

	return Msg;
}

function string RemoveMap_AC( string S )
{
	local int mapindex, i;
	local string Msg;

	if ( AGM.LockMapList )
		return AGM.Lang.FormatLangString( AGM.Lang.MaplistIsLockedString );

	mapindex = 0;

	for (i = 0; i < Len(S); i++)
	{
		if ( Asc( Mid(S,i,1) ) < 48 || Asc( Mid(S,i,1) ) > 57)
		{
			mapindex = ServerSettings(Level.PendingServerSettings).NumMaps;
			break;
		}
		else if ( i == Len(S)-1 )
			mapindex = int(S);
	}

	if ( mapindex < 0 )
		mapindex = 0;

	if ( mapindex < ServerSettings(Level.PendingServerSettings).NumMaps )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.MapRemovedString, ServerSettings(Level.PendingServerSettings).Maps[mapindex] );

		ServerSettings(Level.PendingServerSettings).NumMaps--;
		for ( i = mapindex ; i < ServerSettings(Level.PendingServerSettings).NumMaps ; i++ )
			ServerSettings(Level.PendingServerSettings).Maps[i] = ServerSettings(Level.PendingServerSettings).Maps[i+1];

		if ( mapindex < ServerSettings(Level.PendingServerSettings).MapIndex )
			ServerSettings(Level.PendingServerSettings).MapIndex--;

		if ( ServerSettings(Level.PendingServerSettings).MapIndex > ServerSettings(Level.PendingServerSettings).NumMaps )
			ServerSettings(Level.PendingServerSettings).MapIndex = 0;
	}
	else
		Msg = AGM.Lang.FormatLangString( AGM.Lang.InvalidMapIndexString );

	return Msg;
}

function string AddMap_AC( string S )
{
	local int mapindex, i;
	local string IDString, Msg;

	if ( AGM.LockMapList )
		return AGM.Lang.FormatLangString( AGM.Lang.MaplistIsLockedString );

	mapindex = ServerSettings(Level.PendingServerSettings).NumMaps;

	i = InStr(S, " ");
	if ( i != -1 )
	{
		IDString = Mid(S, i+1);
		S = Left(S, i);
	}

	if ( !MapExists( S ) )
		Msg = AGM.Lang.FormatLangString( AGM.Lang.CouldNotFindMapString, S );
	else
	{
		for ( i = 0; i < Len(IDString); i++ )
		{
			if ( Asc( Mid( IDString, i, 1 ) ) < 48 || Asc( Mid( IDString, i, 1) ) > 57 )
			{
				mapindex = ServerSettings(Level.PendingServerSettings).NumMaps;
				break;
			}
			else if ( i == Len(IDString)-1 )
				mapindex = int(IDString);
		}

		if ( mapindex < 0 )
			mapindex = 0;

		Level.PendingServerSettings = Level.PendingServerSettings;

		if ( mapindex >= ServerSettings(Level.PendingServerSettings).NumMaps )
		{
			mapindex = ServerSettings(Level.PendingServerSettings).NumMaps;
			ServerSettings(Level.PendingServerSettings).Maps[mapindex] = S;
			ServerSettings(Level.PendingServerSettings).NumMaps++;
		}
		else
		{
			for ( i = ServerSettings(Level.PendingServerSettings).NumMaps; i >= mapindex; i-- )
				ServerSettings(Level.PendingServerSettings).Maps[i] = ServerSettings(Level.PendingServerSettings).Maps[i-1];
			ServerSettings(Level.PendingServerSettings).Maps[mapindex] = S;
			ServerSettings(Level.PendingServerSettings).NumMaps++;
		}

		if ( mapindex < ServerSettings(Level.PendingServerSettings).MapIndex )
			ServerSettings(Level.PendingServerSettings).MapIndex--;

		Msg = AGM.Lang.FormatLangString( AGM.Lang.MapAddedString, ServerSettings(Level.PendingServerSettings).Maps[mapindex] );

		if ( ServerSettings(Level.PendingServerSettings).MapIndex > ServerSettings(Level.PendingServerSettings).NumMaps )
			ServerSettings(Level.PendingServerSettings).MapIndex = 0;
	}

	return Msg;
}

function string KickBan_AC( string pl, string banner, string bannerip, string time, string comment )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	SPC.shouldBan = true;
	SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickBanString, banner, SPC.PC.PlayerReplicationInfo.PlayerName );
	if ( comment != "" )
		SPC.kickReason = SPC.kickReason$" ("$comment$")";
	SPC.banner = banner;
	SPC.banTime = time;
	SPC.bannersIP = banner$","$bannerip;
	SPC.banComment = comment;
	Msg = AGM.Lang.FormatLangString( AGM.Lang.KickBanAString, banner, SPC.PC.PlayerReplicationInfo.PlayerName );
	if ( comment != "" )
		Msg = Msg$" ("$comment$")";

	return Msg;
}

function string Kick_AC( string pl, string kicker )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	SPC.shouldKick = true;
	SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickString, kicker, SPC.PC.PlayerReplicationInfo.PlayerName );
	Msg = AGM.Lang.FormatLangString( AGM.Lang.KickAString, kicker, SPC.PC.PlayerReplicationInfo.PlayerName );

	return Msg;
}

function string MakeVIP_AC( string pl, string maker )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	AGM.CheckGameEnded();

	if ( !AGM.hasEnded && SPC.isSpectator )
		return Msg;

	if ( !SPC.isSpectator && ServerSettings(Level.CurrentServerSettings).GameType == MPM_VIPEscort )
	{
		AGM.wishVIP = SPC.PC;
		Msg = AGM.Lang.FormatLangString( AGM.Lang.SetVIPString, maker, AGM.wishVIP.PlayerReplicationInfo.PlayerName );
		if ( !AGM.hasEnded )
			Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.ChangedVIPString, maker, AGM.wishVIP.PlayerReplicationInfo.PlayerName ), 'Caption');
	}

	return Msg;
}

function string ForceName_AC( string pl, string newname, string changer )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	if ( SPC.PC.PlayerReplicationInfo.PlayerName != newname )
	{
		Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.ForceNameString, changer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
		Level.Game.ChangeName( SPC.PC, newname, true );
	}

	return Msg;
}

function string ForceLessLethal_AC( string pl, string forcer )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	AGM.CheckGameEnded();

	if ( SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP && !AGM.hasEnded )
		return AGM.Lang.FormatLangString( AGM.Lang.CannotLLVIPString );
	else
	{
		if ( !SPC.forceLessLethal || SPC.noWeapons )
		{
			AGM.ForceLessLethal( SPC, AGM.Lang.FormatLangString( AGM.Lang.PlayerLLString ), false );
			Level.Game.Broadcast( None, AGM.Lang.FormatLangString( AGM.Lang.ForceLLString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption' );
		}
		else
		{
			AGM.RemoveLessLethal( SPC );
			Level.Game.Broadcast( None, AGM.Lang.FormatLangString( AGM.Lang.RemoveLLString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption' );
		}
	}

	return Msg;
}

function string ForceNoWeapons_AC( string pl, string forcer )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	AGM.CheckGameEnded();

	if ( SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP && !AGM.hasEnded )
		return AGM.Lang.FormatLangString( AGM.Lang.CannotNWVIPString );
	else
	{
		if ( !SPC.forceLessLethal || !SPC.noWeapons )
		{
			AGM.ForceLessLethal( SPC, AGM.Lang.PlayerNWString, true );
			Level.Game.Broadcast( None, AGM.Lang.FormatLangString( AGM.Lang.ForceNWString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption' );
		}
		else
		{
			AGM.RemoveLessLethal(SPC);
			Level.Game.Broadcast( None, AGM.Lang.FormatLangString( AGM.Lang.RemoveNWString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption' );
		}
	}

	return Msg;
}

function string ForceSpec_AC( string pl, string forcer )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	AGM.CheckGameEnded();

	if ( SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP && !AGM.hasEnded && !AGM.ChooseNewRandomVIP( SPC.PC ) )
		return AGM.Lang.FormatLangString( AGM.Lang.CouldNotChangeVIPSpecString, SPC.PC.PlayerReplicationInfo.PlayerName );
	else
	{
		ClientCommand( "spec", SPC.PC, true );
		Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.ForceSpecString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
	}

	return Msg;
}

function string ForceView_AC( string pl, string forcer )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	AGM.CheckGameEnded();

	if ( SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP && !AGM.hasEnded && !AGM.ChooseNewRandomVIP( SPC.PC ) )
		return AGM.Lang.FormatLangString( AGM.Lang.CouldNotChangeVIPSpecString, SPC.PC.PlayerReplicationInfo.PlayerName );
	else
	{
		ClientCommand( "view", SPC.PC, true );
		Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.ForceViewString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
	}

	return Msg;
}

function string ForceJoin_AC( string pl, string forcer )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	ClientCommand( "join", SPC.PC, true );
	Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.ForceJoinString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');

	return Msg;
}

function string ForceMute_AC( string pl, string forcer )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	SPC.muted = !SPC.muted;
	if ( SPC.muted )
	{
		SPC.mutedTime = Level.TimeSeconds + 86400;//24 hours ought to do it :D
        Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.ForceMuteString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
	}
	else
        Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.ForceUnMuteString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');

	return Msg;
}

function string SwitchTeam_AC( string pl, string switcher )
{
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	AGM.CheckGameEnded();

	if ( SwatGamePlayerController( SPC.PC ).ThisPlayerIsTheVIP && !AGM.hasEnded )
		return AGM.Lang.FormatLangString( AGM.Lang.CannotSwitchVIPString );
	else
	{
		if ( SPC != None )
			SPC.teamForced = true;
		if ( SPC.PC.Pawn != None )
			SPC.PC.Pawn.Died( None, class'DamageType', SPC.PC.Pawn.Location, vect(0,0,0) );
		Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.ForceSwitchString, switcher, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
		SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController( SPC.PC ) );
	}

	return Msg;
}

function string SwitchAll_AC( string switcher )
{
	local AMPlayerController SPC, RV;
	local int i;
	local string Msg;

	Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.SwitchAllString, switcher ), 'Caption');
	Msg = AGM.Lang.FormatLangString( AGM.Lang.TeamsSwitchedString, switcher );

	AGM.CheckGameEnded();

	for ( i = 0; i < AGM.PlayerList.Length; i++ )
	{
		SPC = AGM.PlayerList[i];

		if ( SPC == None || SPC.PC == None || NetTeam(SPC.PC.PlayerReplicationInfo.Team) == None )
			continue;

		if ( SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP && !AGM.hasEnded )
		{
			RV = SPC;
			continue;
		}

		SPC.teamForced = true;

		if ( SPC.PC.Pawn != None )
			SPC.PC.Pawn.Died( None, class'DamageType', SPC.PC.Pawn.Location, vect(0,0,0) );
		SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController( SPC.PC ) );
	}

	if ( RV != None )
	{
		SPC = RV;
		if ( AGM.ChooseNewRandomVIP( SPC.PC ) )
		{
			if ( SPC.PC.Pawn != None )
				SPC.PC.Pawn.Died( None, class'DamageType', SPC.PC.Pawn.Location, vect(0,0,0) );
			SwatGameInfo(Level.Game).ChangePlayerTeam( SwatGamePlayerController( SPC.PC ) );
		}
	}

	return Msg;
}

function string LockedDefaultTeam_AC( string S )
{
	AGM.LockedDefaultTeam = S;

	return AGM.Lang.FormatLangString( AGM.Lang.LockedDTeamString, S );
}

#if SWAT_EXPANSION
function string ForceLeader_AC( string pl, string forcer )
{
	local GameModeCOOP coop;
	local string Msg;
	local AMPlayerController SPC;

	SPC = GetPlayerFromString( pl, Msg );
	if ( SPC == None )
		return Msg;

	if ( !SPC.isSpectator && (ServerSettings(Level.CurrentServerSettings).GameType == MPM_COOP || ServerSettings(Level.CurrentServerSettings).GameType == MPM_COOPQMM) )
	{
		Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.PromotedString, forcer, SPC.PC.PlayerReplicationInfo.PlayerName ), 'Caption');
		coop = GameModeCOOP(SwatGameInfo(Level.Game).GetGameMode());
		coop.SetLeader( NetTeam(SPC.PC.PlayerReplicationInfo.Team), SwatGamePlayerController(SPC.PC) );
		Msg = AGM.Lang.FormatLangString( AGM.Lang.PromotedAString, SPC.PC.PlayerReplicationInfo.PlayerName );
	}
	else
		Msg = AGM.Lang.FormatLangString( AGM.Lang.CouldNotPromoteString, SPC.PC.PlayerReplicationInfo.PlayerName );

	return Msg;
}
#endif

function string AddReplacement_AC( string S )
{
	local string Msg;

	AGM.ReplaceEquipment[AGM.ReplaceEquipment.Length] = S;
	Msg = AGM.Lang.FormatLangString( AGM.Lang.ReplacementAddedString, S );

	return Msg;
}

function string RemoveReplacement_AC( string S )
{
	local string Msg;
	local int i;

	for ( i = AGM.ReplaceEquipment.Length-1; i >= 0; i-- )
	{
		if ( S == string(i) || S ~= AGM.ReplaceEquipment[i] )
		{
			Msg = AGM.Lang.FormatLangString( AGM.Lang.ReplacementRemovedString, S );
			AGM.ReplaceEquipment.Remove( i , 1 );
		}
	}

	return Msg;
}

function string GetReplacements_AC( )
{
	local string Msg;
	local int i;

	if ( AGM.ReplaceEquipment.Length == 0 )
		Msg = AGM.Lang.FormatLangString( AGM.Lang.NoReplacementsString );
	else
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.ReplacementListString );
		for ( i = 0; i < AGM.ReplaceEquipment.Length; i++ )
			Msg = Msg$"\n"$i$" - "$AGM.ReplaceEquipment[i];
	}

	return Msg;
}

function string Say_AC( string S, string sayer )
{
	local string Msg;

	if ( S == "" )
		return "";

	Msg = "[b]"$sayer$"[\\b]: "$S;

	AGM.BroadcastHandler.Chat( "Say: "$sayer$": "$S );

	Level.Game.Broadcast(None, "[c=00ff00]"$Msg, 'Caption');

	return "";
}

function string Pause_AC( PlayerController PausePlayer )
{
	if ( PausePlayer == None )
		return "You must be in the game to use this command.";

	if ( Level.Pauser == None )
	{
		Level.Pauser = PausePlayer.PlayerReplicationInfo;
		Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.PausedString, PausePlayer.PlayerReplicationInfo.PlayerName ), 'Caption');
	}
	else
	{
		Level.Pauser = None;
		Level.Game.Broadcast(None, AGM.Lang.FormatLangString( AGM.Lang.UnPausedString, PausePlayer.PlayerReplicationInfo.PlayerName ), 'Caption');
	}

	return "";
}

function AddCmd( string cmd, string params, int numparams, optional bool donthelp )
{
	local cmd_v temp;

	temp.cmd = cmd;
	temp.params = params;
	temp.numparams = numparams;
	temp.donthelp = donthelp;

	cmdList[cmdList.Length] = temp;
}

function string Help_AC( string command )
{
	local string Msg;
	local int i;

	if ( command != "" )
	{
		for ( i = 0; i < cmdList.Length; i++ )
			if ( !cmdList[i].donthelp && cmdList[i].cmd ~= command )
				return AGM.Lang.FormatLangString( AGM.Lang.UsageString, cmdList[i].cmd, cmdList[i].params );
	}

	Msg = AGM.Lang.FormatLangString( AGM.Lang.ACCommandsString );
	for ( i = 0; i < cmdList.Length; i++ )
		if ( !cmdList[i].donthelp )
			Msg = Msg$"\n[b]"$cmdList[i].cmd$"[\\b] "$cmdList[i].params;

	return Msg;
}

function ClearMaps()
{
	local int i;

	for( i = 0; i < MAX_MAPS; i++ )
        ServerSettings(Level.PendingServerSettings).Maps[i] = "";

	ServerSettings(Level.PendingServerSettings).NumMaps = 0;
}

function bool MapExists( string mapname )
{
	local string FileName;

    foreach FileMatchingPattern( "*.s4m", FileName )
    {
        //remove the extension
        if(Right(FileName, 4) ~= ".s4m")
			FileName = Left(FileName, Len(FileName) - 4);

        if( mapname ~= FileName )
            return true;
    }
	return false;
}

function int NumSpectators()
{
	local int i, num;
	local AMPlayerController SPC;

	for ( i = 0; i < AGM.PlayerList.Length; i++ )
	{
		SPC = AGM.PlayerList[i];
		if ( SPC == None || SPC.PC == None )
			continue;

		if ( SPC.isSpectator )
			num++;
	}

	return num;
}

function ClientCommand( string S, PlayerController PC, bool force )
{
	local AMPlayerController SPC;
	local bool canspec;
	local string Msg;

	canspec = true;

	SPC = AGM.GetAMPlayerController(PC);

	if ( SPC == None )
		return;

	if ( PC.Pawn != None && !force )
	{
		if ( NetPlayer(PC.Pawn).IsBeingArrestedNow() || NetPlayer(PC.Pawn).IsNonlethaled() )
			canspec = false;
	}

	AGM.CheckGameEnded();

	if ( SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP && !AGM.hasEnded )
	{
		if ( !force || !AGM.ChooseNewRandomVIP( SPC.PC ) )
		{
			if ( PC.Pawn == None )
				canspec = false;
			else if ( NetPlayer(PC.Pawn).IsTheVIP() )
				canspec = false;
		}
	}

	if ( Left(S, 4) ~= "menu" )
	{
		SPC.PC.ClientOpenMenu( "AMClient.AMHook", "AMHook" );
	}
	else if ( Left(S, 4) ~= "binds" )
	{
		SPC.PC.ClientOpenMenu( "BindMod.BindHook", "BindHook" );
	}
	else if ( Left(S, 4) ~= "spec" )
	{
		if ( !AllowSpectators && !force )
		{
			Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.SpecDisabledString ), 'Caption');
			return;
		}

		if ( !AllowFreeSpectators && !force )
		{
			Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.FreeSpecDisabledString ), 'Caption');
			return;
		}

		if ( NumSpectators() > MaxSpectators && MaxSpectators > 0 && !force )
		{
			Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.TooManySpecString ), 'Caption');
			return;
		}

		if ( OnlyAdminSpectators && !SPC.isAdmin && !force )
		{
			Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.OnlyAdminsSpecString ), 'Caption');
			return;
		}

		if ( !SPC.isSuperAdmin && IsSuperAdminCommand( "spec" ) && !force )
		{
			Msg = AGM.Lang.FormatLangString( AGM.Lang.SuperAdminString );
			ShowAdminMsg( Msg, PC );
			return;
		}

		if ( canspec )
		{
			if ( !SPC.PC.IsInState( 'GameEnded' ) && !AGM.hasEnded )
			{
				SwatGamePlayerController(SPC.PC).ViewFromLocation( 'DefaultPositionMarker' );
				SwatGamePlayerController(SPC.PC).ClientViewFromLocation( "DefaultPositionMarker" );
				SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem.bHasEnteredFirstRound = false;
			}
			SPC.CurrentController = None;
			SPC.isSpectator = true;
			SPC.specMode = 1;
		}
	}
	else if ( Left(S, 4) ~= "view" )
	{
		if ( !AllowSpectators && !force )
		{
			Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.SpecDisabledString ), 'Caption');
			return;
		}

		if ( NumSpectators() > MaxSpectators && MaxSpectators > 0 && !force )
		{
			Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.TooManySpecString ), 'Caption');
			return;
		}

		if ( OnlyAdminSpectators && !SPC.isAdmin && !force )
		{
			Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.OnlyAdminsSpecString ), 'Caption');
			return;
		}

		if ( !SPC.isSuperAdmin && IsSuperAdminCommand( "view" ) && !force )
		{
			Msg = AGM.Lang.FormatLangString( AGM.Lang.SuperAdminString );
			ShowAdminMsg( Msg, PC );
			return;
		}

		if ( canspec )
		{
			if ( !SPC.PC.IsInState( 'GameEnded' ) && !AGM.hasEnded )
			{
				SwatGamePlayerController(SPC.PC).ViewFromLocation( 'DefaultPositionMarker' );
				SwatGamePlayerController(SPC.PC).ClientViewFromLocation( "DefaultPositionMarker" );
				SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem.bHasEnteredFirstRound = false;
			}
			SPC.CurrentController = None;
			SPC.isSpectator = true;
			SPC.specMode = 2;
		}
	}
	else if ( Left(S, 4) ~= "join" )
	{
		if ( SPC.isSpectator )
		{
			if ( !SPC.PC.IsInState( 'GameEnded' ) && !AGM.hasEnded )
			{
				SwatGamePlayerController(SPC.PC).ViewFromLocation( 'DefaultPositionMarker' );
				SwatGamePlayerController(SPC.PC).ClientViewFromLocation( "DefaultPositionMarker" );
				SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem.bHasEnteredFirstRound = true;
			}
			SPC.isSpectator = false;
		}
	}
	else if ( Left(S, 4) ~= "help" )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.CCCommandsString );
		Msg = Msg$	"\n[b]menu[\\b]";
		Msg = Msg$	"\n[b]join[\\b]";
		Msg = Msg$	"\n[b]spec[\\b]";
		Msg = Msg$	"\n[b]view[\\b]";
		Msg = Msg$	"\n[b]help[\\b]";
		Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, "[c=ffff00]"$Msg, 'Caption');
	}
	else
		Level.Game.BroadcastHandler.BroadcastText(None, SPC.PC, AGM.Lang.FormatLangString( AGM.Lang.UnRecognisedCCString, S ), 'Caption');
}

function Switch( PlayerController PC, string URL )
{
	local AMPlayerController SPC;
	local string Msg;

	SPC = AGM.GetAMPlayerController(PC);
	if ( SPC == None )
		return;

    if( !SPC.isAdmin )
        return;

	if ( !SPC.isSuperAdmin && IsSuperAdminCommand( "switch" ) )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.SuperAdminString );
		ShowAdminMsg( Msg, PC );
		return;
	}

	Level.ServerTravel( URL, false );
}

function StartGame( PlayerController PC )
{
	local AMPlayerController SPC;
	local string Msg;

	SPC = AGM.GetAMPlayerController(PC);
	if ( SPC == None )
		return;

    if( !SPC.isAdmin )
        return;

	if ( !SPC.isSuperAdmin && IsSuperAdminCommand( "startgame" ) )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.SuperAdminString );
		ShowAdminMsg( Msg, PC );
		return;
	}

	SwatRepo(Level.GetRepo()).AllPlayersReady();
}

function AbortGame( PlayerController PC )
{
	local AMPlayerController SPC;
	local string Msg;

	SPC = AGM.GetAMPlayerController(PC);
	if ( SPC == None )
		return;

    if( !SPC.isAdmin )
        return;

	if ( !SPC.isSuperAdmin && IsSuperAdminCommand( "abortgame" ) )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.SuperAdminString );
		ShowAdminMsg( Msg, PC );
		return;
	}

	SwatGameInfo(Level.Game).GameAbort();
}

function AMPlayerController GetPlayerFromString( string S, out string Msg )
{
	local int i, id;
	local string IDString;
	local PlayerController PC, P;
	local AMPlayerController SPC;

	i = Instr( S, " " );
	if ( i == -1 )
		i = len(S);

	IDString = Left( S, i );

	id = -1;

	if ( IDString != "" )
		id = IDtoINT( IDString );
	if ( id == -1 )
	{
		ForEach DynamicActors(class'PlayerController', P)
			if ( P.PlayerReplicationInfo.PlayerName~=IDString )
				PC = P;
	}
	else if ( AGM.PlayerList.Length > id && AGM.PlayerList[id] != None )
		PC = AGM.PlayerList[id].PC;

	SPC = AGM.GetAMPlayerController( PC );

	if ( SPC == None || SPC.PC == None )
	{
		Msg = AGM.Lang.FormatLangString( AGM.Lang.CouldNotFindPlayerString );
		return None;
	}

	return SPC;
}

function ReceivedMasterBanList()
{
	local int i, j, k;
	local string mask, ip;
	local bool addedip, found;
	local array<string> masterIPs;

	while ( masterbanlist != "" )
	{
		i = InStr( masterbanlist, "," );

		if ( i == -1 )
			i = len(masterbanlist);

		ip = Left( masterbanlist, i );

		masterbanlist = Mid( masterbanlist, i+1 );

		if ( InStr( ip, "." ) == -1 )
			continue;

		masterIPs[masterIPs.Length] = ip;
	}

	for ( i = 0; i < masterIPs.Length; i++ )
	{
		found = false;
		for ( j = 0; j < AGM.AccessControl.IPPolicies.Length; j++ )
		{
			k = InStr( AGM.AccessControl.IPPolicies[j], "," );
			if ( k == -1 )
				continue;
			ip = Mid( AGM.AccessControl.IPPolicies[j], k+1 );
			if ( ip == masterIPs[i] )
			{
				found = true;
				break;
			}
		}
		if ( AddMasterBans && !found )
		{
			AGM.AccessControl.IPPolicies[AGM.AccessControl.IPPolicies.Length] = "DENY,"$masterIPs[i]$",~MasterBanList";
			log( "Added a master ban for: "$masterIPs[i] );
			addedip = true;
		}
	}

	for ( i = AGM.AccessControl.IPPolicies.Length-1; i >= 0 ; i-- )
	{
		found = false;

		k = InStr( AGM.AccessControl.IPPolicies[j], "," );
		if ( k == -1 )
			continue;
		ip = Mid( AGM.AccessControl.IPPolicies[j], k+1 );
		k = AGM.InStr( ip, "," );
		if ( k == -1 )
			continue;
		ip = Left( ip, k );
        mask = Mid( ip, k+1 );

		if ( Left( mask, len("~MasterBanList") ) != "~MasterBanList" )
			continue;

		for ( j = 0; j < masterIPs.Length; j++ )
		{
			if ( ip == masterIPs[j] )
				found = true;
		}

		if ( !found )
		{
			AGM.AccessControl.IPPolicies.Remove( i, 1 );
			log( "Removed a master ban for: "$ip );
			addedip = true;
		}
	}

	if ( addedip )
	{
		AGM.AccessControl.SaveConfig( "", "", false, true );
		if ( AGM.FlushVariables )
			AGM.AccessControl.FlushConfig();
		Level.Game.Broadcast(None, AGM.Lang.ServerString, 'SettingsUpdated');
	}
}

defaultproperties
{
	AutoOpenClientMenu=false
	AddMasterBans=true
	ShowIPBans=true
    AllowSpectators=true
    AllowFreeSpectators=true
	OnlyAdminSpectators=false
	MaxSpectators=0
}
