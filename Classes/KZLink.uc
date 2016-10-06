class KZLink extends IPDrv.TcpLink;

var config string TargetHost; //URL or P address of web server
var config int TargetPort; //port you want to use for the link
var config string path; //path to file you want to request
var string requesttext; //data we will send
var AMGameMod AGM;
var array<string> oldQued;
var config string QueryKey;

event PostBeginPlay()
{
    super.PostBeginPlay();
    SetTimer(120,true);
    //ResolveMe();
}

function Timer()
{
    if (AGM.KZMod.Qued.length <= 0)
    {
        return;
    }
    ResolveMe();
}

function ResolveMe() //removes having to send a host
{
    Resolve(TargetHost);
}

event Resolved( IpAddr Addr )
{
    // The hostname was resolved succefully
    Log("[TcpLinkClient] "$TargetHost$" resolved to "$ IpAddrToString(Addr));

    // Make sure the correct remote port is set, resolving doesn't set
    // the port value of the IpAddr structure
    Addr.Port = TargetPort;

    //dont comment out this log because it rungs the function bindport
    Log("[TcpLinkClient] Bound to port: "$ BindPort() );
    if (!Open(Addr))
    {
        Log("[TcpLinkClient] Open failed");
    }
}

event ResolveFailed()
{
    Log("[TcpLinkClient] Unable to resolve "$TargetHost);
    // You could retry resolving here if you have an alternative
    // remote host.

    //send failed message to scaleform UI
    //JunHud(JunPlayerController(PC).myHUD).JunMovie.CallSetHTML("Failed");
}

event Opened()
{
    local string temp;
    local int i;
    // A connection was established
    //Log("[TcpLinkClient] event opened");
    Log("[TcpLinkClient] Sending simple HTTP query");

    //The HTTP GET request
    //char(13) and char(10) are carrage returns and new lines
       /** SendText("GET /"$path$" HTTP/1.1");
        SendText(chr(13)$chr(10));
        SendText("Host: "$TargetHost);
        SendText(chr(13)$chr(10));
        SendText("Connection: Close");
        SendText(chr(13)$chr(10)$chr(13)$chr(10));*/

        for (i = 0; i < AGM.KZMod.Qued.Length ; i++)
        {
            if(AGM.KZMod.Qued[i] == "")
            {
                AGM.KZMod.Qued.Remove(i, 1);
                -- i;
            }
        }

        // 1> true 123.123.*.* Hunter<3 111.111.21.11 reason
        // 2> banned=123.43.*.1&zishan=false

        //
        for (i = 0; i < AGM.KZMod.Qued.Length ; i++)
        {
            temp = AGM.KZMod.Qued[i];
            temp = FixData(true,temp);

            if (i == 0)
            {
                requesttext = requesttext $ "ban[]=" $ temp;
            }
            else
            {
                requesttext = requesttext $ "&ban[]=" $ temp;
            }
        }
        oldQued = AGM.KZMod.Qued;
        AGM.KZMod.Qued.Remove(0,AGM.KZMod.Qued.length);
        requesttext = requesttext $ "&key=" $ QueryKey;
        log(requesttext);
        SendPost(requesttext);

        requesttext = "";

    Log("[TcpLinkClient] end HTTP query");
}

function success(string HTML)
{
    Destroy();
}

function string GetHeader(string Text)
{
    local int i;
    i = InStr(Text, "\r\n\r\n");
    // End:0x25
    if(i == -1)
    {
        return "";
    }
    return Left(Text, i);
}

function string GetBody(string Text)
{
    local int i;
    i = InStr(Text, "\r\n\r\n");
    // End:0x25
    if(i == -1)
    {
        return "";
    }
    return Mid(Text, i+1);
}

function SendPost(string requesttext)
{
        //requesttext = "value=kinnnggg&submit=10987";
        SendText("POST /"$path$" HTTP/1.1"$chr(13)$chr(10));
        SendText("Host: "$TargetHost$chr(13)$chr(10));
        SendText("User-Agent: HTTPTool/1.0"$Chr(13)$Chr(10));
        SendText("Content-Type: application/x-www-form-urlencoded"$chr(13)$chr(10));
        //we use the length of our requesttext to tell the server
        //how long our content is
        SendText("Content-Length: "$len(requesttext)$Chr(13)$Chr(10));
        SendText("Connection: Close"$Chr(13)$Chr(10));
        SendText(chr(13)$chr(10));
        SendText(requesttext);
        SendText(chr(13)$chr(10)$chr(13)$chr(10));
}

function string FixData(bool ispost, out string Input)
{
    ReplaceText(Input, " ", "%20");
    ReplaceText(Input, "\n", "");
    ReplaceText(Input, "\r", "");
    ReplaceText(Input, " ", "");
    ReplaceText(Input, "#", "");
    ReplaceText(Input, "'", "");
    ReplaceText(Input, "`", "");
    ReplaceText(Input, "\"", "");
    ReplaceText(Input, "\r", "");
    // End:0xB5
    if(ispost)
    {
        ReplaceText(Input, "&", "<k_and_k>");
    }
    return Input;
}

event Closed()
{
    // In this case the remote client should have automatically closed
    // the connection, because we requested it in the HTTP request.
    Log("[TcpLinkClient] event closed");

    // After the connection was closed we could establish a new
    // connection using the same TcpLink instance.
}

event ReceivedText( string Text )
{
    local string body;
    //local array<string> temp;
    // receiving some text, note that the text includes line breaks
    //Log("[TcpLinkClient] ReceivedText:: "$Text);

    body = GetBody(Text);

    log("Body:"$body);

    if (InStr(body,"SUCCESS") == -1)
    {
        AGM.KZMod.Qued = oldQued;
    }


    //we dont want the header info, so we split the string after two new lines
    //Split("Text", chr(13)$chr(10)$chr(13)$chr(10), temp);
   // Log("[TcpLinkClient] SplitText:: " $temp[0]);
    //Log("[TcpLinkClient] SplitText:: " $temp[1]);
}


defaultproperties
{
    TargetHost="knightofsorrow.com"
    TargetPort=80 //default for HTTP
    path = "servertracker/handlebans"
    QueryKey = "123456789";
}
