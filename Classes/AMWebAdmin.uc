class AMWebAdmin extends IPDrv.TCPLink;

#define MAX_CONSOLE_LINES 50

var AMWebAdminListener Listener;

var string cookie;
var string header;
var string content;
var string user;
var string console;

var string rtext;

function BeginPlay()
{
	if ( Listener == None )
		Destroy();
}

event ReceivedText( string Text )
{
	local int pos;
	local string pw, outname, outcon;

	if ( rtext != "" )
	{
		text = rtext$text;
		rtext = "";
	}

	pos = InStr( text, "\r\n\r\n" );
	if ( pos != -1 )
	{
		header = Left( text, pos+4 );
		content = Mid( text, pos+4 );
		Listener.AGM.StripHexFromHTML( content );
	}
	else
	{
		rtext = text;
		return;
	}

	GetCookie();

	// Try to restore previous log in
	if ( !Listener.IsAdmin( RemoteAddr, cookie, outname, outcon ) )
	{
		if ( cookie != "" )
		{
			pos = InStr( cookie, "&" );
			if ( pos > -1 )
			{
				user = Left( cookie, pos );
				pw = Mid( cookie, pos+1 );
			}

			if ( Listener.ValidUser( user, pw ) )
				Listener.AddLogin( RemoteAddr, cookie, user, pw );
		}
	}

	if ( Listener.IsAdmin( RemoteAddr, cookie, outname, outcon ) )
	{
		user = outname;
		console = outcon;

		if ( InStr( header, "POST /admin&console=" ) > -1 )
		{
			ConsoleCmd();
			RedirectToCP();
		}
		else if ( InStr( header, "GET /console" ) > -1 )
			SendConsole();
		else if ( InStr( header, "GET /players" ) > -1 )
			SendPlayers();
		else if ( InStr( header, "GET /users" ) > -1 )
			SendUsers();
		else if ( InStr( header, "GET /refresh" ) > -1 )
			SendRefresher();
		else if ( InStr( header, "POST /admin&logout" ) > -1 )
			LogOut();
		else
			SendAdminCP();
	}
	else
	{
		if ( InStr( header, "POST /login HTTP/1.1\r\n" ) != -1 || InStr( header, "POST /login HTTP/1.0\r\n" ) != -1 )
			Login();
		else
			SendAdminLoginPage();
	}
}

function ConsoleCmd()
{
	local int i;
	local string cmd, resp, ipaddress;

	i = InStr( header, "POST /admin&console=" );
	cmd = Mid( header, i+20 );
	i = InStr( cmd, " HTTP/1.1\r\n" );
	if ( i == -1 )
		i = InStr( cmd, " HTTP/1.0\r\n" );
	cmd = Left( cmd, i );

	Listener.AGM.StripHexFromHTML( cmd );

	if ( cmd == "" )
		return;

	ipaddress = IpAddrToString( RemoteAddr );
	i = InStr( ipaddress, ":" );
	if ( i != -1 )
		ipaddress = Left( ipaddress, i );

	Listener.AGM.Admin.AdminCommand( cmd, user$" (WebAdmin)", ipaddress, , resp );
	Listener.AGM.Admin.ShowAdminMsg( resp, None );

	Listener.AGM.FixForHTML2( cmd, "ffffff" );
	if ( resp != "" && !Listener.AGM.BroadcastToAllAdmins )
	{
		Listener.AGM.FixForHTML2( resp, "ffff00" );
		cmd = cmd$"\n</font><font color=ffff00>"$resp$"</font>";
	}

	PrependToConsole( "<font color=ffffff>&gt;"$cmd );
}

function PrependToConsole( string text )
{
	console = Listener.GetConsole( RemoteAddr, cookie );

	if ( console == "" )
		console = text;
	else
		console = text$"\n"$console;

	Listener.UpdateConsole( RemoteAddr, cookie, console );
}

function AppendToConsole( string text )
{
	console = Listener.GetConsole( RemoteAddr, cookie );

	if ( console == "" )
		console = text;
	else
		console = console$"\n"$text;

	Listener.UpdateConsole( RemoteAddr, cookie, console );
}

function RedirectToCP()
{
	local string h, c;

	h =		"HTTP/1.1 200 OK\r\n";
	h = h$	"Content-Type: text/html\r\n";
	h = h$	"Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\n";
	h = h$	"Pragma: no-cache\r\n";

	c = "<html><head><script type=text/javascript>self.location.href='/admin';</script></head></html>";

	SendHTML( h, c );

	Close();
}

function LogOut()
{
	local string h;

	h =		"HTTP/1.1 200 OK\r\n";
	h = h$	"Content-Type: text/html\r\n";
	h = h$	"Set-Cookie: WAID=; path=/\r\n";
	h = h$	"Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\n";
	h = h$	"Pragma: no-cache\r\n";

	if ( user != "" )
		log( "AMMod.AMWebAdmin: Web Admin Logout: User: "$user$" from: "$IpAddrToString( RemoteAddr ) );

	Listener.LogOut( RemoteAddr, cookie );

	SendHTML( h, GetAdminLoginHTML() );

	Close();
}

function SendRefresher()
{
	local string h, c;

	h =		"HTTP/1.1 200 OK\r\n";
	h = h$	"Content-Type: text/html\r\n";
	h = h$	"Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\n";
	h = h$	"Pragma: no-cache\r\n";

	c =		"<html><head>";

	c = c$	"<script type=text/javascript>";
	c = c$	"function refresh1() { window.parent.document.getElementById('consolesrc').src = '/console'; setTimeout( 'refresh2()', 1500 ); }";
	c = c$	"function refresh2() { window.parent.document.getElementById('playerssrc').src = '/players'; setTimeout( 'refresh3()', 1500 ); }";
	c = c$	"function refresh3() { window.parent.document.getElementById('userssrc').src = '/users'; setTimeout( 'refresh1()', 1500 ); }";
	c = c$	"</script>";

	c = c$	"</head><body bgcolor=#000000 onload='refresh1();'></body></html>";

	SendHTML( h, c );

	Close();
}

function string SendConsole( optional bool getconsole )
{
	local string h, c;
	local int num, point, total;
	local string temp;

	h =		"HTTP/1.1 200 OK\r\n";
	h = h$	"Content-Type: text/html\r\n";
	h = h$	"Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\n";
	h = h$	"Pragma: no-cache\r\n";

	console = Listener.GetConsole( RemoteAddr, cookie );

	temp = console;
	point = InStr( temp, "\n" );
	while ( point != -1 )
	{
		num++;
		total += point;
		temp = Mid( temp, point+2 );

		if ( num > MAX_CONSOLE_LINES )
		{
			console = Left( console, total );
			Listener.UpdateConsole( RemoteAddr, cookie, console );
			break;
		}

		total += 2;
		point = InStr( temp, "\n" );
	}

	ReplaceText( console, "\n", "<br>" );

	temp = "<font color=ffffff>"$console$"</font>";

	if ( getconsole )
		return temp;

	c =		"<html><head>";

	c = c$	"<script type=text/javascript>function transfertomain() { window.parent.document.getElementById('console').innerHTML = document.getElementById('transfer').innerHTML; }</script>";

	c = c$	"<body bgcolor=#000000 onload='transfertomain();'><span id='transfer'>"$temp$"</span></body></html>";

	SendHTML( h, c );

	Close();
}

function string SendPlayers( optional bool getplayers )
{
	local string h, c, t, text, prefix;
	local int i;

	if ( getplayers )
		prefix = "";
	else
		prefix = "window.parent.";

	h =		"HTTP/1.1 200 OK\r\n";
	h = h$	"Content-Type: text/html\r\n";
	h = h$	"Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\n";
	h = h$	"Pragma: no-cache\r\n";

	c =		"<html><head>";

	c = c$	"</head><body>";

	t = t$	"<script type=text/javascript>";

	t = t$	"var checkedid = "$prefix$"document.adminform.selectedplayer.value;";
	t = t$	"for (i="$prefix$"document.getElementById('players').rows.length-1; i >= 0; i--) { "$prefix$"document.getElementById('players').deleteRow(i); }";

	t = t$	"myNewRow = "$prefix$"document.getElementById('players').insertRow( -1 );";
	t = t$	"myNewCell = myNewRow.insertCell( 0 );";
	t = t$	"myNewCell.setAttribute( 'width', '25' );";
	t = t$	"myNewCell = myNewRow.insertCell( 1 );";
	t = t$	"myNewCell.setAttribute( 'width', '50' );";
	t = t$	"myNewCell.innerHTML = '<font color=ffffff><b>"$Listener.AGM.Lang.WAIDString$"</b></font>';";
	t = t$	"myNewCell = myNewRow.insertCell( 2 );";
	t = t$	"myNewCell.setAttribute( 'width', '150' );";
	t = t$	"myNewCell.innerHTML = '<font color=ffffff><b>"$Listener.AGM.Lang.WANameString$"</b></font>';";
	t = t$	"myNewCell = myNewRow.insertCell( 3 );";
	t = t$	"myNewCell.setAttribute( 'width', '75' );";
	t = t$	"myNewCell.innerHTML = '<font color=ffffff><b>"$Listener.AGM.Lang.WAScoreString$"</b></font>';";
	t = t$	"myNewCell = myNewRow.insertCell( 4 );";
	t = t$	"myNewCell.setAttribute( 'width', '75' );";
	t = t$	"myNewCell.innerHTML = '<font color=ffffff><b>"$Listener.AGM.Lang.WAPingString$"</b></font>';";
	t = t$	"myNewCell = myNewRow.insertCell( 5 );";
	t = t$	"myNewCell.setAttribute( 'width', '125' );";
	t = t$	"myNewCell.innerHTML = '<font color=ffffff><b>"$Listener.AGM.Lang.WAIPString$"</b></font>';";

	t = t$	"i = 0; var foundid = false;";

	for ( i = 0; i < Listener.AGM.PlayerList.Length; i++ )
	{
		if ( Listener.AGM.PlayerList[i] == None || Listener.AGM.PlayerList[i].PC == None )
			continue;

		t = t$	"myNewRow = "$prefix$"document.getElementById('players').insertRow( -1 );";
		t = t$	"myNewCell = myNewRow.insertCell( 0 );";
		t = t$	"myNewCell.setAttribute( 'width', '25' );";

		t = t$	"if ( checkedid != '' && checkedid != null && i == checkedid ) { foundid = true; myNewCell.innerHTML = '<input type=radio name=player onclick=document.adminform.selectedplayer.value="$i$" checked=true>'; } else { myNewCell.innerHTML = '<input type=radio name=player onclick=document.adminform.selectedplayer.value="$i$">'; } i++; ";

		t = t$	"myNewCell = myNewRow.insertCell( 1 );";
		t = t$	"myNewCell.setAttribute( 'width', '50' );";
		t = t$	"myNewCell.innerHTML = '<font color=ffffff>"$i$"</font>';";
		t = t$	"myNewCell = myNewRow.insertCell( 2 );";
		t = t$	"myNewCell.setAttribute( 'width', '150' );";
		t = t$	"myNewCell.innerHTML = '<font color=";

		if ( SwatGamePlayerController( Listener.AGM.PlayerList[i].PC ).ThisPlayerIsTheVIP )
			t = t$	"00ff00";
		else if ( SwatGamePlayerController( Listener.AGM.PlayerList[i].PC ).SwatRepoPlayerItem.TeamID == 0 )
			t = t$	"0000ff";
		else
			t = t$	"ff0000";

		text = Listener.AGM.PlayerList[i].PC.PlayerReplicationInfo.PlayerName;
		Listener.AGM.FixForHTML( text );

		if ( Listener.AGM.PlayerList[i].isSuperAdmin )
			text = text$"<font color=ffffff>(SA)";
		else if ( Listener.AGM.PlayerList[i].isAdmin )
			text = text$"<font color=ffffff>(A)";
		else if ( Listener.AGM.PlayerList[i].isSubAdmin )
			text = text$"<font color=ffffff>(M)";

		t = t$	">"$text$"</font>';";
		t = t$	"myNewCell = myNewRow.insertCell( 3 );";
		t = t$	"myNewCell.setAttribute( 'width', '75' );";
		t = t$	"myNewCell.innerHTML = '<font color=ffffff>"$SwatGameInfo(Level.Game).GetPlayerScore( Listener.AGM.PlayerList[i].PC )$"</font>';";
		t = t$	"myNewCell = myNewRow.insertCell( 4 );";
		t = t$	"myNewCell.setAttribute( 'width', '75' );";
		t = t$	"myNewCell.innerHTML = '<font color=ffffff>"$Min( 999, Listener.AGM.PlayerList[i].PC.PlayerReplicationInfo.Ping )$"</font>';";
		t = t$	"myNewCell = myNewRow.insertCell( 5 );";
		t = t$	"myNewCell.setAttribute( 'width', '125' );";
		t = t$	"myNewCell.innerHTML = '<font color=ffffff>"$Listener.AGM.PlayerList[i].networkAddress$"</font>';";
	}

	t = t$	"if ( foundid == false ) { "$prefix$"document.adminform.selectedplayer.value = ''; }";

	t = t$	"</script>";

	if ( getplayers )
		return t;

	c = c$	t;

	c = c$	"</body></html>";

	SendHTML( h, c );

	Close();
}

function string SendUsers( optional bool getusers )
{
	local string h, c, temp;
	local int i;

	h =		"HTTP/1.1 200 OK\r\n";
	h = h$	"Content-Type: text/html\r\n";
	h = h$	"Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\n";
	h = h$	"Pragma: no-cache\r\n";

	temp = "<font color=ffffff><h3>"$Listener.AGM.Lang.WAUsersOnlineString;

	for ( i = 0; i < Listener.Admins.Length; i++ )
	{
		if ( Listener.Admins[i].Addr.Addr == RemoteAddr.Addr )
			temp = temp@"<u>"$Listener.Admins[i].name$"</u>";
		else
			temp = temp@Listener.Admins[i].name;
	}

	temp = temp$"</h3>";
	temp = temp$"Gametype: <b>"$SwatGameInfo(Level.Game).GetGameModeName()$"</b>";
	temp = temp$"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Map: <b>"$Level.Title$"</b>";
	temp = temp$"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Round: <b>"$ServerSettings(Level.CurrentServerSettings).RoundNumber+1$"/"$ServerSettings(Level.CurrentServerSettings).NumRounds$"</b>";
	temp = temp$"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Server Name: <b>"$ServerSettings(Level.CurrentServerSettings).ServerName$"</b></font>";


	if ( getusers )
		return temp;

	c =		"<html><head>";

	c = c$	"<script type=text/javascript>function transfertomain() { window.parent.document.getElementById('webusers').innerHTML = document.getElementById('transfer').innerHTML; }</script>";

	c = c$	"<body bgcolor=#000000 onload='transfertomain();'><span id='transfer'>"$temp$"</span></body></html>";

	SendHTML( h, c );

	Close();
}

function SendAdminCP( optional bool firstlogin )
{
	local string h, c;

	h =		"HTTP/1.1 200 OK\r\n";
	h = h$	"Content-Type: text/html\r\n";
	if ( firstlogin )
		h = h$	"Set-Cookie: WAID="$cookie$"; path=/\r\n";
	h = h$	"Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\n";
	h = h$	"Pragma: no-cache\r\n";
	c = c$	"<html><head><title>"$Listener.AGM.Lang.WATitleString$"</title>";

	c = c$	"<style type=text/css>.listtable{ background-color: #2E2E2E; color: #FFFFFF; border-color: #B4E4F5; border-width: 1px; border-style: solid; font-size: 11px; font-family: Arial, Helvetica, sans-serif; padding: .10in; } input.button { background-color:#2E2E2E; color:#FFFFFF; border-color:#B4E4F5; border-width: 1px; border-style: solid; font-size: 11px; font-family: Arial, Helvetica, sans-serif; font-weight:bold; }</style>";

	c = c$	"</head><body bgcolor='#000000'><center>";

#if KEYS
	if ( !Listener.AGM.validkey || Listener.ShowHeader )
#endif
		c = c$	Listener.AGM.webadminheader;

	c = c$	"<table><tr><td id='webusers' align=center>"$SendUsers( true )$"</td></tr></table>";
	c = c$	"<iframe name='userssrc' id='userssrc' src='' frameborder=0 width=0 height=0 frameborder=0></iframe>";

	c = c$	"<br><br><form name=adminform method=post><input type=hidden name=selectedplayer><table align=center width=100&#37; bgcolor=#000000 cellpadding=5><tr><td align=center valign=top>";

	c = c$	"<form name=playerform><table width=500 align=center class=listtable id='players'></table></form>";
	c = c$	"<iframe name='playerssrc' id='playerssrc' src='' frameborder=0 width=0 height=0 frameborder=0></iframe>";
	c = c$	SendPlayers( true );

	c = c$	"<script type=text/javascript>";

	c = c$	"function kickbutton_onclick() { document.adminform.action='/admin&console=kick '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	c = c$	"function banbutton_onclick() { document.adminform.action='/admin&console=kickban '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	c = c$	"function fllbutton_onclick() { document.adminform.action='/admin&console=forcelesslethal '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	c = c$	"function fnwbutton_onclick() { document.adminform.action='/admin&console=forcenoweapons '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	c = c$	"function fnabutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WAFNDescString$"', 'newname'); if ( result == null ) return; document.adminform.action='/admin&console=forcename '+document.adminform.selectedplayer.value+' '+result;document.adminform.submit(); }";
#if SWAT_EXPANSION
	if ( ServerSettings(Level.CurrentServerSettings).GameType == MPM_COOP || ServerSettings(Level.CurrentServerSettings).GameType == MPM_COOPQMM )
		c = c$	"function vipbutton_onclick() { document.adminform.action='/admin&console=forceleader '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	else
#endif
		c = c$	"function vipbutton_onclick() { document.adminform.action='/admin&console=makevip '+document.adminform.selectedplayer.value;document.adminform.submit(); }";

	c = c$	"function mutebutton_onclick() { document.adminform.action='/admin&console=forcemute '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	c = c$	"function teambutton_onclick() { document.adminform.action='/admin&console=switchteam '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	c = c$	"function fjbutton_onclick() { document.adminform.action='/admin&console=forcejoin '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	c = c$	"function fsbutton_onclick() { document.adminform.action='/admin&console=forcespec '+document.adminform.selectedplayer.value;document.adminform.submit(); }";
	c = c$	"function fvbutton_onclick() { document.adminform.action='/admin&console=forceview '+document.adminform.selectedplayer.value;document.adminform.submit(); }";

	c = c$	"function addbanbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WAAddBanDescString$"', 'ip|range [time] [comment]'); if ( result == null ) return; document.adminform.action='/admin&console=addban '+result;document.adminform.submit(); }";
	c = c$	"function getbansbutton_onclick() { document.adminform.action='/admin&console=getbans';document.adminform.submit(); }";
	c = c$	"function gettempbansbutton_onclick() { document.adminform.action='/admin&console=gettempbans';document.adminform.submit(); }";
	c = c$	"function removebanbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WARemoveBanDescString$"', 'ip|range'); if ( result == null ) return; document.adminform.action='/admin&console=removeban '+result;document.adminform.submit(); }";

	c = c$	"function addreplacementbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WAAddReplacementDescString$"', 'oldclass newclass'); if ( result == null ) return; document.adminform.action='/admin&console=addreplacement '+result;document.adminform.submit(); }";
	c = c$	"function getreplacementsbutton_onclick() { document.adminform.action='/admin&console=getreplacements';document.adminform.submit(); }";
	c = c$	"function removereplacementbutton_onclick() { result = prompt('"$Listener.AGM.Lang.WARemoveReplacementDescString$"', 'id|name'); if ( result == null ) return; document.adminform.action='/admin&console=removereplacement '+result;document.adminform.submit(); }";

	c = c$	"function balbutton_onclick() { document.adminform.action='/admin&console=balanceteams';document.adminform.submit(); }";
	c = c$	"function lockbutton_onclick() { document.adminform.action='/admin&console=lockteams';document.adminform.submit(); }";
	c = c$	"function lockdbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WALockedDTeamDescString$"', 'None|Swat|Suspects'); if ( result == null ) return; document.adminform.action='/admin&console=lockeddefaultteam '+result;document.adminform.submit(); }";
	c = c$	"function sallbutton_onclick() { document.adminform.action='/admin&console=switchall';document.adminform.submit(); }";

	c = c$	"function adminsaybutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WAAdminSayDescString$"', 'message'); if ( result == null ) return; document.adminform.action='/admin&console=as '+result;document.adminform.submit(); }";
	c = c$	"function helpbutton_onclick() { document.adminform.action='/admin&console=help';document.adminform.submit(); }";
	c = c$	"function infobutton_onclick() { document.adminform.action='/admin&console=info';document.adminform.submit(); }";
	c = c$	"function motdbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WAMOTDDescString$"', 'message'); if ( result == null ) return; document.adminform.action='/admin&console=motd '+result;document.adminform.submit(); }";
	c = c$	"function saveconfigbutton_onclick() { document.adminform.action='/admin&console=saveconfig';document.adminform.submit(); }";
	c = c$	"function saybutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WASayDescString$"', 'message'); if ( result == null ) return; document.adminform.action='/admin&console=say '+result;document.adminform.submit(); }";
	c = c$	"function scbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WASCDescString$"', 'command'); if ( result == null ) return; document.adminform.action='/admin&console=sc '+result;document.adminform.submit(); }";

	c = c$	"function addmapbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WAAddMapDescString$"', 'mapname [mapindex]'); if ( result == null ) return; document.adminform.action='/admin&console=addmap '+result;document.adminform.submit(); }";
	c = c$	"function getmapsbutton_onclick() { document.adminform.action='/admin&console=getmaps';document.adminform.submit(); }";
	c = c$	"function getsavedmapsbutton_onclick() { document.adminform.action='/admin&console=getsavedmaps';document.adminform.submit(); }";
	c = c$	"function lockmaplistbutton_onclick() { document.adminform.action='/admin&console=lockmaplist';document.adminform.submit(); }";
	c = c$	"function removemapbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WARemoveMapDescString$"', 'mapindex'); if ( result == null ) return; document.adminform.action='/admin&console=removemap '+result;document.adminform.submit(); }";
	c = c$	"function restartbutton_onclick() { document.adminform.action='/admin&console=restart';document.adminform.submit(); }";
#if SWAT_EXPANSION
	c = c$	"function restoresagbutton_onclick() { document.adminform.action='/admin&console=restoresag';document.adminform.submit(); }";
#endif
	c = c$	"function restoremapsbutton_onclick() { document.adminform.action='/admin&console=restoremaps';document.adminform.submit(); }";
	c = c$	"function savemapsbutton_onclick() { document.adminform.action='/admin&console=savemaps';document.adminform.submit(); }";
	c = c$	"function setmapbutton_onclick() { var result = prompt('"$Listener.AGM.Lang.WASetMapDescString$"', 'mapindex'); if ( result == null ) return; document.adminform.action='/admin&console=setmap '+result;document.adminform.submit(); }";

	c = c$	"function consolebutton_onclick() { document.consoleform.action='/admin&console='+document.consoleform.consoleinput.value;document.consoleform.submit(); }";
	c = c$	"function consolebutton_onkeypress() { document.consoleform.action='/admin&console='+document.consoleform.consoleinput.value; }";
	c = c$	"function logoutbutton_onclick() { document.adminform.action='/admin&logout';document.adminform.submit(); }";
	c = c$	"</script>";

	c = c$	"<br><input type=button class=button name=kickbutton value='"$Listener.AGM.Lang.WAKickString$"' onClick='kickbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=banbutton value='"$Listener.AGM.Lang.WABanString$"' onClick='banbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=fllbutton value='"$Listener.AGM.Lang.WAFLLString$"' onClick='fllbutton_onclick()'>&nbsp;";

#if SWAT_EXPANSION
	if ( ServerSettings(Level.CurrentServerSettings).GameType == MPM_COOP || ServerSettings(Level.CurrentServerSettings).GameType == MPM_COOPQMM )
		c = c$	"<input type=button class=button name=vipbutton value='"$Listener.AGM.Lang.WAFLString$"' onClick='vipbutton_onclick()'>&nbsp;";
	else
#endif
		if ( ServerSettings(Level.CurrentServerSettings).GameType == MPM_VIPEscort )
			c = c$	"<input type=button class=button name=vipbutton value='"$Listener.AGM.Lang.WAMakeVIPString$"' onClick='vipbutton_onclick()'>&nbsp;";

	c = c$	"<input type=button class=button name=fnwbutton value='"$Listener.AGM.Lang.WAFNWString$"' onClick='fnwbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=fnabutton value='"$Listener.AGM.Lang.WAFNString$"' onClick='fnabutton_onclick()'><br><br>";

	c = c$	"<input type=button class=button name=mutebutton value='"$Listener.AGM.Lang.WAMuteString$"' onClick='mutebutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=teambutton value='"$Listener.AGM.Lang.WASwitchTeamString$"' onClick='teambutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=fjbutton value='"$Listener.AGM.Lang.WAFJoinString$"' onClick='fjbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=fsbutton value='"$Listener.AGM.Lang.WAFSpecString$"' onClick='fsbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=fvbutton value='"$Listener.AGM.Lang.WAFViewString$"' onClick='fvbutton_onclick()'><br><br><br>";

	c = c$	"<input type=button class=button name=addbanbutton value='"$Listener.AGM.Lang.WAAddBanString$"' onClick='addbanbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=getbansbutton value='"$Listener.AGM.Lang.WAGetBansString$"' onClick='getbansbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=gettempbansbutton value='"$Listener.AGM.Lang.WAGetTempBansString$"' onClick='gettempbansbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=removebanbutton value='"$Listener.AGM.Lang.WARemoveBanString$"' onClick='removebanbutton_onclick()'><br><br>";

	c = c$	"<input type=button class=button name=addreplacementbutton value='"$Listener.AGM.Lang.WAAddReplacementString$"' onClick='addreplacementbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=getreplacementsbutton value='"$Listener.AGM.Lang.WAGetReplacementsString$"' onClick='getreplacementsbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=removereplacementbutton value='"$Listener.AGM.Lang.WARemoveReplacementString$"' onClick='removereplacementbutton_onclick()'><br><br>";

	c = c$	"<input type=button class=button name=balbutton value='"$Listener.AGM.Lang.WABalanceString$"' onClick='balbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=lockbutton value='"$Listener.AGM.Lang.WALockTeamsString$"' onClick='lockbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=lockdbutton value='"$Listener.AGM.Lang.WALockedDTeamString$"' onClick='lockdbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=sallbutton value='"$Listener.AGM.Lang.WASwitchAllString$"' onClick='sallbutton_onclick()'><br><br>";

	c = c$	"<input type=button class=button name=adminsaybutton value='"$Listener.AGM.Lang.WAAdminSayString$"' onClick='adminsaybutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=helpbutton value='"$Listener.AGM.Lang.WAHelpString$"' onClick='helpbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=infobutton value='"$Listener.AGM.Lang.WAInfoString$"' onClick='infobutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=motdbutton value='"$Listener.AGM.Lang.WAMOTDString$"' onClick='motdbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=saveconfigbutton value='"$Listener.AGM.Lang.WASaveConfigString$"' onClick='saveconfigbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=saybutton value='"$Listener.AGM.Lang.WASayString$"' onClick='saybutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=scbutton value='"$Listener.AGM.Lang.WASCString$"' onClick='scbutton_onclick()'><br><br>";

	c = c$	"<input type=button class=button name=addmapbutton value='"$Listener.AGM.Lang.WAAddMapString$"' onClick='addmapbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=getmapsbutton value='"$Listener.AGM.Lang.WAGetMapsString$"' onClick='getmapsbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=getsavedmapsbutton value='"$Listener.AGM.Lang.WAGetSMapsString$"' onClick='getsavedmapsbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=lockmaplistbutton value='"$Listener.AGM.Lang.WALockMaplistString$"' onClick='lockmaplistbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=removemapbutton value='"$Listener.AGM.Lang.WARemoveMapString$"' onClick='removemapbutton_onclick()'><br><br>";

	c = c$	"<input type=button class=button name=restartbutton value='"$Listener.AGM.Lang.WARestartString$"' onClick='restartbutton_onclick()'>&nbsp;";
#if SWAT_EXPANSION
	c = c$	"<input type=button class=button name=restoresagbutton value='"$Listener.AGM.Lang.WARestoreSGString$"' onClick='restoresagbutton_onclick()'>&nbsp;";
#endif
	c = c$	"<input type=button class=button name=restoremapsbutton value='"$Listener.AGM.Lang.WARestoreMapsString$"' onClick='restoremapsbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=savemapsbutton value='"$Listener.AGM.Lang.WASaveMapsString$"' onClick='savemapsbutton_onclick()'>&nbsp;";
	c = c$	"<input type=button class=button name=setmapbutton value='"$Listener.AGM.Lang.WASetMapString$"' onClick='setmapbutton_onclick()'><br><br>";

	c = c$	"</td><td align=left valign=top width=500><form name=consoleform method=post>";

	c = c$	"<table class=listtable width=100&#37; height=750><tr><td id='console' valign=top>"$SendConsole( true )$"</td></tr></table>";
	c = c$	"<iframe name='consolesrc' id='consolesrc' src='' frameborder=0 width=0 height=0></iframe>";

	c = c$	"<br><input type=text name=consoleinput class=button size=84 onKeyPress='consolebutton_onkeypress()'>&nbsp;";
	c = c$	"<input type=button class=button name=consolebutton value='Send' onClick='consolebutton_onclick()'>";

	c = c$	"</form></td></tr></table>";

	c = c$	"<br><input type=button class=button name=logoutbutton value='Logout' onClick='logoutbutton_onclick()'>";

	c = c$	"</form>";

#if KEYS
	if ( !Listener.AGM.validkey )
#endif
		c = c$	"<br><br><a href=\"http:\/\/www.gezmods.co.uk/donate.html\"><image src=\"http:\/\/www.gezmods.co.uk/donate_gez.gif\" border=0></a>";

	c = c$	Listener.AGM.webadminfooter;

	c = c$	"<iframe name='refreshsrc' id='refreshsrc' src='/refresh' frameborder=0 width=0 height=0 frameborder=0></iframe>";

	c = c$	"</center></body></html>";

	SendHTML( h, c );

	Close();
}

function Login()
{
	local int pos;
	local int endpos;
	local string pw;

	user = "";
	pos = InStr( content, "user=" );

	if ( pos > -1 )
	{
		endpos = InStr( Mid( content, pos+5 ), "&" );
		if ( endpos == -1 )
            user = Mid( content, pos+5 );
		else
			user = Mid( content, pos+5, endpos );
	}

	pos = InStr( content, "pw=" );

	if ( pos > -1 )
	{
		endpos = InStr( Mid( content, pos+3 ), "\r\n" );
		if ( endpos == -1 )
            pw = Mid( content, pos+3 );
		else
			user = Mid( content, pos+3, endpos );

		if ( Listener.ValidUser( user, pw ) )
		{
			cookie = user$"&"$pw;
			Listener.AddLogin( RemoteAddr, cookie, user, pw );
			SendAdminCP( true );
			return;
		}
	}

	SendAdminLoginPage();
}

function SendHTML( string h, string c )
{
	local string html;

	html = h$"\r\n"$c;
	SendText( html );
}

function GetCookie()
{
	local int cpos;
	local int cend;
	local string h;

	cpos = InStr( header, "Cookie: WAID=" );

	if ( cpos > -1 )
	{
		h = Mid( header, cpos+13 );

		cend = InStr( h, "\r\n" );
		if ( cend > -1 )
			cookie = Left( h, cend );
	}
}

function string GetAdminLoginHTML()
{
	local string c;

	c =		"<html><head><title>SWAT 4 Web Admin</title>";
	c = c$	"<style type=text/css>input.button { background-color:#2E2E2E; color:#FFFFFF; border-color:#B4E4F5; border-width: 1px; border-style: solid; font-size: 11px; font-family: Arial, Helvetica, sans-serif; font-weight:bold; }</style>";
	c = c$	"</head>";

	c = c$	"<body bgcolor=#000000><center>";
	c = c$	"<br><br><form action='/login' method=post>";
	c = c$	"<font color=ffffff>Username: </font><input class=button type=text name=user><br>";
	c = c$	"<font color=ffffff>Password: </font><input class=button type=password name=pw><br><br>";
	c = c$	"<input class=button type=submit value='Log In'></form>";
	c = c$	"</center></body></html>";

	return c;
}

function SendAdminLoginPage()
{
	local string h, c;

	h =		"HTTP/1.1 200 OK\r\n";
	h = h$	"Content-Type: text/html\r\n";
	h = h$	"Cache-Control: no-store, no-cache, must-revalidate, post-check=0, pre-check=0\r\n";
	h = h$	"Pragma: no-cache\r\n";
	c = GetAdminLoginHTML();
	SendHTML( h, c );

	Close();
}

event Closed()
{
	Destroy();
}
