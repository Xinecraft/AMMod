class AMServerQuery extends IPDrv.UDPLink;

var AMGameMod AGM;
var int boundport;
var() globalconfig int ServerQueryListenPort;
var() globalconfig bool TestAllStats;

function BeginPlay()
{
	if ( ServerQueryListenPort == 0 )
	{
		Destroy();
		return;
	}

	boundport = BindPort( ServerQueryListenPort, true );

	if( boundport == 0 )
	{
		warn( "AMServerQuery: Could not bind a port" );
		Destroy();
		return;
	}

    log( "AMMod.AMServerQuery: Listening on "$boundport );
}

event ReceivedText( IpAddr Addr, string Text )
{
	if ( Left( text, 8 ) ~= "\\status\\" )
		SendServerInfo( Addr );
}

function SendServerInfo( IpAddr Addr )
{
	local string data, text, players, scores, pings, teams, pw, stats, kills, tkills, deaths, arrests, arrested, vescaped, vvkill, ivvkill, arvip, unarvip, bombsd, rdcry;
	local int i, num;
	local AMPlayerController SPC;
	local NetScoreInfo NSI;

#if SWAT_EXPANSION
		local string sgcry, sgescp, sgkill;
#endif

	if ( AGM.AccessControl.RequiresPassword() )
		pw = "1";
	else
		pw = "0";

	if ( Level.GetGameSpyManager().bTrackingStats )
		stats = "1";
	else
		stats = "0";

	for ( i = 0; i < AGM.PlayerList.Length; i++ )
	{
		SPC = AGM.PlayerList[i];

		if ( SPC == None || SPC.PC == None )
			continue;

		NSI = SwatPlayerReplicationInfo(SPC.PC.PlayerReplicationInfo).netScoreInfo;

		players = players$	"\\player_"$num$"\\";
		players = players$			SPC.PC.PlayerReplicationInfo.PlayerName;

		scores = scores$	"\\score_"$num$"\\";
		scores = scores$			SwatGameInfo(Level.Game).GetPlayerScore( SPC.PC );

		pings = pings$		"\\ping_"$num$"\\";
		pings = pings$				SPC.PC.PlayerReplicationInfo.Ping;

		teams = teams$		"\\team_"$num$"\\";
		teams = teams$				NetTeam(SPC.PC.PlayerReplicationInfo.Team).GetTeamNumber();

		if ( NSI.GetEnemyKills() != 0 || TestAllStats )
		{
			kills = kills$		"\\kills_"$num$"\\";
			kills = kills$				NSI.GetEnemyKills();
		}

		if ( NSI.GetFriendlyKills() != 0 || TestAllStats )
		{
			tkills = tkills$	"\\tkills_"$num$"\\";
			tkills = tkills$			NSI.GetFriendlyKills();
		}

		if ( NSI.GetTimesDied() != 0 || TestAllStats )
		{
			deaths = deaths$	"\\deaths_"$num$"\\";
			deaths = deaths$			NSI.GetTimesDied();
		}

		if ( NSI.GetArrests() != 0 || TestAllStats )
		{
			arrests = arrests$	"\\arrests_"$num$"\\";
			arrests = arrests$			NSI.GetArrests();
		}

		if ( NSI.GetTimesArrested() != 0 || TestAllStats )
		{
			arrested = arrested$"\\arrested_"$num$"\\";
			arrested = arrested$		NSI.GetTimesArrested();
		}

		if ( NSI.GetVIPPlayerEscaped() != 0 || TestAllStats )
		{
			vescaped = vescaped$"\\vipescaped_"$num$"\\";
			vescaped = vescaped$		NSI.GetVIPPlayerEscaped();
		}

		if ( NSI.GetKilledVIPValid() != 0 || TestAllStats )
		{
			vvkill = vvkill$	"\\validvipkills_"$num$"\\";
			vvkill = vvkill$			NSI.GetKilledVIPValid();
		}

		if ( NSI.GetKilledVIPInvalid() != 0 || TestAllStats )
		{
			ivvkill = ivvkill$	"\\invalidvipkills_"$num$"\\";
			ivvkill = ivvkill$			NSI.GetKilledVIPInvalid();
		}

		if ( NSI.GetArrestedVIP() != 0 || TestAllStats )
		{
			arvip = arvip$	"\\arrestedvip_"$num$"\\";
			arvip = arvip$			NSI.GetArrestedVIP();
		}

		if ( NSI.GetUnarrestedVIP() != 0 || TestAllStats )
		{
			unarvip = unarvip$	"\\unarrestedvip_"$num$"\\";
			unarvip = unarvip$			NSI.GetUnarrestedVIP();
		}

		if ( NSI.GetBombsDiffused() != 0 || TestAllStats )
		{
			bombsd = bombsd$	"\\bombsdiffused_"$num$"\\";
			bombsd = bombsd$			NSI.GetBombsDiffused();
		}

		if ( NSI.GetRDCrybaby() != 0 || TestAllStats )
		{
			rdcry = rdcry$		"\\rdcrybaby_"$num$"\\";
			rdcry = rdcry$			NSI.GetRDCrybaby();
		}

#if SWAT_EXPANSION
		if ( NSI.GetSGCrybaby() != 0 || TestAllStats )
		{
			sgcry = sgcry$		"\\sgcrybaby_"$num$"\\";
			sgcry = sgcry$			NSI.GetSGCrybaby();
		}

		if ( NSI.GetEscapedSG() != 0 || TestAllStats )
		{
			sgescp = sgescp$	"\\escapedcase_"$num$"\\";
			sgescp = sgescp$			NSI.GetEscapedSG();
		}

		if ( NSI.GetKilledSG() != 0 || TestAllStats )
		{
			sgkill = sgkill$	"\\killedcase_"$num$"\\";
			sgkill = sgkill$			NSI.GetKilledSG();
		}
#endif
		num++;
	}

	text = "\\hostname\\";
	text = text$			ServerSettings(Level.CurrentServerSettings).ServerName;
	text = text$	"\\numplayers\\";
	text = text$			SwatGameInfo(Level.Game).NumberOfPlayersForServerBrowser();
	text = text$	"\\maxplayers\\";
	text = text$			ServerSettings(Level.CurrentServerSettings).MaxPlayers;
	text = text$	"\\gametype\\";
	text = text$			SwatGameInfo(Level.Game).GetGameModeName();
	text = text$	"\\gamevariant\\";
	text = text$			Level.ModName;
	text = text$	"\\mapname\\";
	text = text$			Level.Title;
	text = text$	"\\hostport\\";
	text = text$			SwatGameInfo(Level.Game).GetServerPort();
	text = text$	"\\password\\";
	text = text$			pw;
	text = text$	"\\gamever\\";
	text = text$			Level.BuildVersion;
	text = text$	"\\statsenabled\\";
	text = text$			stats;
	text = text$	"\\swatwon\\";
	text = text$			SwatGameInfo(Level.Game).GetTeamFromID(0).NetScoreInfo.GetRoundsWon();
	text = text$	"\\suspectswon\\";
	text = text$			SwatGameInfo(Level.Game).GetTeamFromID(1).NetScoreInfo.GetRoundsWon();
	text = text$	"\\round\\";
	text = text$			ServerSettings(Level.CurrentServerSettings).RoundNumber+1;
	text = text$	"\\numrounds\\";
	text = text$			ServerSettings(Level.CurrentServerSettings).NumRounds;

	text = text$players$scores$pings$teams$kills$tkills$deaths$arrests$arrested$vescaped$vvkill$ivvkill$arvip$unarvip$bombsd$rdcry;

#if SWAT_EXPANSION
	text = text$sgcry$sgescp$sgkill;
#endif

	num = 0;
	data = "\\statusresponse\\"$num;
	i = InStr( text, "\\" );
	while ( i != -1 )
	{
		if ( len(data) < 500 )
		{
			data = data$Left( text, i+1 );
			text = Mid( text, i+1 );

			i = InStr( text, "\\" );
			if ( i != -1 )
			{
				data = data$Left( text, i+1 );
				text = Mid( text, i+1 );

				i = InStr( text, "\\" );
				if ( i != -1 )
				{
					data = data$Left( text, i );
					text = Mid( text, i );
				}
				else
				{
					data = data$text;
					text = "";
				}
			}
		}
		else
		{
			SendText( Addr, data$"\\eof\\" );
			num++;
			data = "\\statusresponse\\"$num;
		}
	}

	data = data$"\\queryid\\AMv1\\final\\\\eof\\";
	SendText( Addr, data );
}

defaultproperties
{
	ServerQueryListenPort=10491
	TestAllStats=false
}