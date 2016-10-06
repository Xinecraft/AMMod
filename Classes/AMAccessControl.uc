class AMAccessControl extends Engine.AccessControl;

import enum EMPMode from Engine.Repo;

#if SWAT_EXPANSION
var globalconfig bool			DisableVoteBans;			// Disable voting bans.
#endif
var globalconfig array<string>	DisallowNames;				// Stop players using the name "Player".
var globalconfig string			GamePassword;				// Password to enter game.
var globalconfig array<string>  IPPolicies;					// Ban List.
var globalconfig array<string>  TempIPPolicies;				// Temp Ban List.
var globalconfig string			MaxJoinPassword;			// Password to enter game.
var globalconfig bool			OnlyAdminsKickForRoom;		// Only admin/superadmin passwords kick for free space.
var globalconfig int			MaxPlayingClients;			// Players in the reserved slots must spectate.
var globalconfig int			ReservedSlots;				// Number of reserved slots.

var AMGameMod AGM;

function BeginPlay()
{
	Super.BeginPlay();

	CleanUpTempIPPolicies();
}

function bool Kick( string S )
{
	local PlayerController P;
	local PlayerController PC;
	local AMPlayerController SPC;
	local int lowestscore;

	lowestscore = 999;

	ForEach DynamicActors(class'PlayerController', PC)
	{
		SPC = AGM.GetAMPlayerController(PC);
		if ( SPC == None || SPC.isAdmin )
			continue;

		if ( PC.PlayerReplicationInfo.PlayerName ~= S && NetConnection(PC.Player) != None )
		{
			if( SwatGameInfo(Level.Game).GetPlayerScore( PC ) < lowestscore )
			{
				P = PC;
				lowestscore = SwatGameInfo(Level.Game).GetPlayerScore( P );
			}
		}
	}

	if ( P!=None )
	{
		SPC = AGM.GetAMPlayerController( P );
		SPC.shouldKick = true;
		SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickString, AGM.Lang.ServerString, P.PlayerReplicationInfo.PlayerName );
	}
	return false;
}

function bool KickBan( string S )
{
#if SWAT_EXPANSION
	local PlayerController P;
	local PlayerController PC;
	local AMPlayerController SPC;
	local int lowestscore;

	lowestscore = 999;

	ForEach DynamicActors(class'PlayerController', PC)
	{
		SPC = AGM.GetAMPlayerController(PC);
		if ( SPC == None || SPC.isAdmin )
			continue;

		if ( PC.PlayerReplicationInfo.PlayerName ~= S && NetConnection(PC.Player) != None )
		{
			if( SwatGameInfo(Level.Game).GetPlayerScore( PC ) < lowestscore )
			{
				P = PC;
				lowestscore = SwatGameInfo(Level.Game).GetPlayerScore( P );
			}
		}
	}

	if ( P!=None )
	{
		SPC = AGM.GetAMPlayerController( P );
		if ( !DisableVoteBans )
		{
			SPC.shouldBan = true;
			SPC.bannersIP = "~VoteBanned";
			SPC.banTime = "1:0";//1 hour ban
			SPC.banComment = "Banned by a vote.";
			SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickBanString, AGM.Lang.ServerString, P.PlayerReplicationInfo.PlayerName );
		}
		else
		{
			SPC.shouldKick = true;
			SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickString, AGM.Lang.ServerString, P.PlayerReplicationInfo.PlayerName );
		}
	}
#endif
	return false;
}

function bool CheckIPPolicy(string Address)
{
	local int i, j, k, LastMatchingPolicy;
	local string Policy, Mask;
	local bool bAcceptAddress, bAcceptPolicy;

	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = true;
	for(i=0; i<IPPolicies.Length; i++)
	{
		j = InStr(IPPolicies[i], ",");
		if( j==-1 )
			continue;

		Policy = Left(IPPolicies[i], j);
		Mask = Mid(IPPolicies[i], j+1);

		k = InStr(Mask, ",");
		if(k!=-1)
			Mask = Left(Mask, k);

		if(Policy ~= "ACCEPT")
			bAcceptPolicy = True;
		else
		if(Policy ~= "DENY")
			bAcceptPolicy = False;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
	}

	if(!bAcceptAddress)
		Log("AMMod.AMAccessControl: Denied connection for "$Address$" with IP policy "$IPPolicies[LastMatchingPolicy]);

	return bAcceptAddress;
}

function CleanUpMasterIPPolicies()
{
	local int i, j;
	local string BanBy;
	local bool save;

	for( i = IPPolicies.Length-1; i >= 0; i-- )
	{
		j = InStr(IPPolicies[i], ",");
		if( j == -1 )
			continue;

		BanBy = Mid(IPPolicies[i], j+1);

		j = InStr(BanBy, ",");
		if( j == -1 )
			continue;

		BanBy = Mid(BanBy, j+1);

		if (BanBy ~= "~MasterBanList")
		{
			save = true;
			IPPolicies.Remove( i, 1 );
		}
	}

	if ( save )
	{
		SaveConfig( "", "", false, true );
		if ( AGM.FlushVariables )
			FlushConfig();
	}
}

function CleanUpTempIPPolicies()
{
	local int i, j;
	local string Expiry;
	local bool save;

	for( i = TempIPPolicies.Length-1; i >= 0; i-- )
	{
		j = InStr(TempIPPolicies[i], ",");
		if( j == -1 )
			continue;

		Expiry = Mid(TempIPPolicies[i], j+1);

		j = InStr(Expiry, ",");
		if( j == -1 )
			continue;

		Expiry = Mid(Expiry, j+1);

		if ( HasPolicyExpired( Expiry ) )
		{
			save = true;
			TempIPPolicies.Remove( i, 1 );
		}
	}

	if ( save )
	{
		SaveConfig( "", "", false, true );
		if ( AGM.FlushVariables )
			FlushConfig();
	}
}

function bool CheckTempIPPolicy(string Address)
{
	local int i, j, LastMatchingPolicy;
	local string Policy, Mask, Expiry;
	local bool bAcceptAddress, bAcceptPolicy;

	// strip port number
	j = InStr(Address, ":");
	if(j != -1)
		Address = Left(Address, j);

	bAcceptAddress = true;
	for(i=0; i<TempIPPolicies.Length; i++)
	{
		j = InStr(TempIPPolicies[i], ",");
		if( j==-1 )
			continue;

		Policy = Left(TempIPPolicies[i], j);
		Mask = Mid(TempIPPolicies[i], j+1);

		j = InStr(Mask, ",");
		if( j==-1 )
			continue;

		Expiry = Mid(Mask, j+1);
		Mask = Left(Mask, j);

		if ( HasPolicyExpired( Expiry ) )
			continue;

		if(Policy ~= "ACCEPT")
			bAcceptPolicy = true;
		else if(Policy ~= "DENY")
			bAcceptPolicy = false;
		else
			continue;

		j = InStr(Mask, "*");
		if(j != -1)
		{
			if(Left(Mask, j) == Left(Address, j))
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
		else
		{
			if(Mask == Address)
			{
				bAcceptAddress = bAcceptPolicy;
				LastMatchingPolicy = i;
			}
		}
	}

	if(!bAcceptAddress)
		Log("AMMod.AMAccessControl: Denied connection for "$Address$" with Temp IP policy "$TempIPPolicies[LastMatchingPolicy]);

	return bAcceptAddress;
}

function bool HasPolicyExpired( string Expiry )
{
	local int j;
	local bool policyExpired;
	local int ExpiryYear, ExpiryMonth, ExpiryDay, ExpiryHour, ExpiryMinute;

	j = InStr(Expiry, ",");
	if( j!=-1 )
		Expiry = Left(Expiry, j);

	j = InStr(Expiry, ":");
	if( j!=-1 )
	{
		ExpiryYear = int(Left(Expiry, j));
		Expiry = Mid(Expiry, j+1);
	}
	j = InStr(Expiry, ":");
	if( j!=-1 )
	{
		ExpiryMonth = int(Left(Expiry, j));
		Expiry = Mid(Expiry, j+1);
	}
	j = InStr(Expiry, ":");
	if( j!=-1 )
	{
		ExpiryDay = int(Left(Expiry, j));
		Expiry = Mid(Expiry, j+1);
	}
	j = InStr(Expiry, ":");
	if( j!=-1 )
	{
		ExpiryHour = int(Left(Expiry, j));
		Expiry = Mid(Expiry, j+1);
	}
	ExpiryMinute = int(Expiry);

	if ( ExpiryYear < Level.Year )
		policyExpired = true;
	else if ( ExpiryYear > Level.Year )
		policyExpired = false;
	else if ( ExpiryMonth < Level.Month )
		policyExpired = true;
	else if ( ExpiryMonth > Level.Month )
		policyExpired = false;
	else if ( ExpiryDay < Level.Day )
		policyExpired = true;
	else if ( ExpiryDay > Level.Day )
		policyExpired = false;
	else if ( ExpiryHour < Level.Hour )
		policyExpired = true;
	else if ( ExpiryHour > Level.Hour )
		policyExpired = false;
	else if ( ExpiryMinute < Level.Minute )
		policyExpired = true;
	else if ( ExpiryMinute > Level.Minute )
		policyExpired = false;
	else
		policyExpired = true;

	return policyExpired;
}

function bool AtCapacity( bool reserved )
{
	local int MaxPlayerSetting;
    local int CurrentPlayers;

	if ( Level.NetMode == NM_Standalone )
		return false;

	MaxPlayerSetting = ServerSettings(Level.CurrentServerSettings).MaxPlayers;
    CurrentPlayers = SwatRepo(Level.GetRepo()).NumberOfRepoPlayerItems();

	if ( MaxPlayerSetting < 0 )
		return true;

	if ( reserved )
		return ( CurrentPlayers >= MaxPlayerSetting );
	else
        return ( CurrentPlayers >= (MaxPlayerSetting - ReservedSlots) );
}

//
// Accept or reject a player on the server.
// Fails login if you set the Error to a non-empty string.
//
event PreLogin
(
	string Options,
	string Address,
	out string Error,
	out string FailCode,
	bool bSpectator
)

{
	// Do any name or password or name validation here.
	local string InPassword;
	local string InName;
    local int InSwatPlayerID, i;
	local bool admin, superadmin, subadmin, reserved;

#if IG_SHARED // ckline: Unprog security bugfid: https://udn.epicgames.com/lists/showpost.php?list=unprog&id=35587
    // Restrict players with '%' symbols in their options
    if (InStr(Options, "%") >= 0)
    {
		Error = InvalidOptions;
        return;
    }
#endif

    Error="";
	InPassword = Level.Game.ParseOption( Options, "Password" );
	InName     = Left(Level.Game.ParseOption( Options, "Name"), 20);

#if IG_SWAT //dkaplan: dont test at capacity if this is a reconnecting player
    InSwatPlayerID = Level.Game.GetIntOption( Options, "SwatPlayerID", 0 ); // zero means we are
                                                                 // a new connector.
#endif

	superadmin = AGM.Admin.CheckPassword( InPassword, AGM.Admin.SuperAdminPassword );
	admin = AGM.Admin.CheckPassword( InPassword, AGM.Admin.AdminPassword );
	subadmin = AGM.Admin.CheckPassword( caps(InPassword), caps(MaxJoinPassword) );
	reserved = superadmin || admin || subadmin;

	if( (Level.NetMode != NM_Standalone) &&
#if IG_SWAT //dkaplan: dont test at capacity if this is a reconnecting player
	    InSwatPlayerID == 0 &&
#endif
	    AtCapacity( reserved ) )
	{
		if ( !reserved )
			Error = Level.Game.GameMessageClass.Default.MaxedOutMessage;
		else if ( admin || superadmin || !OnlyAdminsKickForRoom )
		{
			if ( !KickFreeRoom( Level.Game.ParseOption(Options, "name"), AGM.Admin.CheckPassword( InPassword, AGM.Admin.AdminPassword ) || AGM.Admin.CheckPassword( InPassword, AGM.Admin.SuperAdminPassword ) ) )
				Error = Level.Game.GameMessageClass.Default.MaxedOutMessage;
		}
		else
			Error = Level.Game.GameMessageClass.Default.MaxedOutMessage;
	}
	else if
	(	GamePassword != "" && lower(GamePassword) != "none" &&
		!AGM.Admin.CheckPassword( caps(InPassword), caps(GamePassword) ) &&
		!reserved	)
	{
		if( InPassword == "" )
		{
			Error = NeedPassword;
			FailCode = "NEEDPW";
		}
		else
		{
			Error = WrongPassword;
			FailCode = "WRONGPW";
		}
	}

	for ( i = 0; i < DisallowNames.Length; i++ )
	{
		if ( DisallowNames[i] ~= InName )
			Error = InvalidOptions;
	}

	if ( !CheckIPPolicy(Address) )
		Error = IPBanned;

	if ( !CheckTempIPPolicy(Address) )
		Error = IPBanned;

	if ( AGM.Admin.CheckPassword( InPassword, AGM.Admin.SuperAdminPassword ) )
		AGM.SuperAdminIPs[AGM.SuperAdminIPs.Length] = Address;
	else if ( AGM.Admin.CheckPassword( InPassword, AGM.Admin.AdminPassword ) )
		AGM.AdminIPs[AGM.AdminIPs.Length] = Address;
	else if ( AGM.Admin.CheckPassword( InPassword, MaxJoinPassword ) )
		AGM.SubAdminIPs[AGM.SubAdminIPs.Length] = Address;
}

/** make room by kicking a player */
function bool KickFreeRoom( string newname, bool isAdmin )
{
    local PlayerController PC, best;
	local AMPlayerController SPC;
    local int i, j;

    j = -1;
    for (i = 0; i < AGM.PlayerList.Length; i++)
    {
		PC = AGM.PlayerList[i].PC;

		if (PC == none) continue;
		if (NetPlayer(PC.Pawn).IsTheVIP()) continue;
		if (AGM.PlayerList[i].isAdmin) continue;
		if (AGM.PlayerList[i].isSubAdmin) continue;

		if (PC.PlayerReplicationInfo.Ping > j)
        {
            j = PC.PlayerReplicationInfo.Ping;
            Best = PC;
        }
    }

    if (best != none)
    {
        log("AMMod.AMAccessControl: Kicking player "$best.PlayerReplicationInfo.PlayerName$" to make room for "$newname );
		SPC = AGM.GetAMPlayerController(Best);
		SPC.shouldKick = true;
		if ( AGM.ShowKickRoomMessage == true || !isAdmin )
			SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickRoomString, AGM.Lang.ServerString, best.PlayerReplicationInfo.PlayerName, newname );
		else
			SPC.kickReason = "";
		return true;
    }
    return false;
}

defaultproperties
{
	MaxJoinPassword=""
	GamePassword=""
	OnlyAdminsKickForRoom=false
	MaxPlayingClients=0
	ReservedSlots=0
}
