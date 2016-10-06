class KZMod extends SwatGame.SwatMutator implements IInterested_GameEvent_PawnArrested;

var AMGameMod AGM;
var KZSounds KZSounds;
var config bool KillCampers;
var config int campKillTimes;
var config int InitialCampWarningInterval;
var config int CampWarningInterval;
var config int MaxCampTime;
var config int MaxCampBeforeKick;
var config int LongArmsSensitivity;
var config Rotator IdleCampCheckRotation;

var array<string> Qued;

function BeginPlay()
{
    local SwatGameInfo GameInfo;

    KZSounds = Spawn(class'KZSounds');
    KZSounds.KZMod = self;

    GameInfo = SwatGameInfo(Level.Game);
    // End:0x21C
    if((GameInfo != none) && GameInfo.GameEvents != none)
    {
        GameInfo.GameEvents.PawnArrested.Register(self);
    //    GameInfo.GameEvents.MissionStarted.Register(self);
    }
}

function Tick(float Delta)
{
    CheckPlayers();
}

function CheckPlayers()
{
    local int i;
    local AMPlayerController SPC;
    //local FiredWeapon CurrentWeapon;
    //local HandheldEquipment CurrentItem;
    //local DynamicLoadOutSpec LoadOutSpec;

    for (i = AGM.PlayerList.Length - 1; i >= 0 ; i--)
    {
        SPC = AGM.PlayerList[i];
        // End:0x4B
        if(SPC == none)
        {
            continue;
        }
        // End:0xAA
        if(SPC.PC == none || SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem == none || NetConnection(SPC.PC.Player) == none)
        {
            continue;
        }

        CheckIsDead(SPC);

        // End:0x155
        if(KillCampers)
        {
            CheckNormalCamper(SPC);
        }
        //CheckShootingWhileStung(SPC);
    }
}

function CheckIsDead(AMPlayerController SPC)
{
    local SwatGamePlayerController SGPC;

    SGPC = SwatGamePlayerController(SPC.PC);
    SPC.wasDead = SPC.IsDead;
    // End:0x69
    if(SPC.PC.Pawn == none)
    {
        SPC.IsDead = true;
    }
    // End:0xA0
    else
    {
        // End:0x8F
        if(SGPC.IsDead())
        {
            SPC.IsDead = true;
        }
        // End:0xA0
        else
        {
            SPC.IsDead = false;
        }
    }
    // End:0xE2
    if(SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState != 4)
    {
        SPC.IsDead = true;
    }
    // End:0x120
    //if(SPC.wasDead && !SPC.IsDead)
    //{
    //    SPC.ArrestSteal.IsArrested = false;
    //}
    return;
}

function CheckNormalCamper(AMPlayerController SPC)
{
    local SwatGamePlayerController SGPC;
    local Vector va, vb;
    local int Kills;

    SGPC = SwatGamePlayerController(SPC.PC);

    // End:0x5C
    if(SPC.PC.Pawn == none)
    {
        SPC.NormalCamper.camperstarttime = int(Level.TimeSeconds);

        SPC.NormalCamper.DoneInitialWarn = false;
        SPC.NormalCamper.TimeLastMsg = int(Level.TimeSeconds);
        return;
    }
    va = SPC.NormalCamper.OldLocation;
    vb = SPC.PC.Pawn.Location;
    // End:0x254
    if(SPC.PC.Pawn == none || SGPC.IsDead() || NetPlayer(SPC.PC.Pawn).IsBeingArrestedNow() || SGPC.SwatPlayer.IsTheVIP() || SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState != 4 || NetPlayer(SPC.PC.Pawn).IsStung() || NetPlayer(SPC.PC.Pawn).IsPepperSprayed() || NetPlayer(SPC.PC.Pawn).IsGassed() || NetPlayer(SPC.PC.Pawn).IsFlashbanged() || NetPlayer(SPC.PC.Pawn).IsTased() || SGPC.IsCuffed())
    {
        SPC.NormalCamper.camperstarttime = int(Level.TimeSeconds);

        SPC.NormalCamper.DoneInitialWarn = false;
        SPC.NormalCamper.TimeLastMsg = int(Level.TimeSeconds);
        return;
    }
    // End:0x7A1
    else
    {
        // End:0x6CC
        if(((va - vb) Dot (va - vb)) < float(50000))
        {
            Kills = SwatPlayerReplicationInfo(SPC.PC.PlayerReplicationInfo).NetScoreInfo.GetEnemyKills();
            // End:0x628
            if((Kills - SPC.NormalCamper.oldkills) >= campKillTimes)
            {
                // End:0x3BE
                if(((Level.TimeSeconds - float(SPC.NormalCamper.TimeLastMsg)) > float(InitialCampWarningInterval)) && SPC.NormalCamper.DoneInitialWarn == false)
                {
                    IdleCampCheckRotation = SPC.PC.Pawn.Rotation;
                    SPC.NormalCamper.DoneInitialWarn = true;
                    SPC.NormalCamper.TimeLastMsg = int(Level.TimeSeconds);
                    AGM.BroadcastHandler.BroadcastText(none, SPC.PC, AGM.Lang.CampWarningString, 'Caption');
                    KZSounds.SendSound(KZSounds.WarningMessageSound, SPC);
                }
                // End:0x494
                else if((Level.TimeSeconds - float(SPC.NormalCamper.TimeLastMsg)) > float(CampWarningInterval) && SPC.NormalCamper.DoneInitialWarn == true && (Level.TimeSeconds - float(SPC.NormalCamper.camperstarttime)) < float(MaxCampTime))
                {
                    SPC.NormalCamper.TimeLastMsg = int(Level.TimeSeconds);
                    AGM.BroadcastHandler.BroadcastText(none, SPC.PC, AGM.Lang.CampWarningString, 'Caption');
                    KZSounds.SendSound(KZSounds.WarningMessageSound, SPC);
                }
                // End:0x625
                if(((Level.TimeSeconds - float(SPC.NormalCamper.camperstarttime)) > float(MaxCampTime)) && SwatRepo(Level.GetRepo()).GuiConfig.SwatGameState == 4)
                {
                    // End:0x625
                    if(SPC.PC.Pawn != none)
                    {
                        if(IdleCampCheckRotation == SPC.PC.Pawn.Rotation)
                        {
                            SPC.NormalCamper.camperstarttime = int(Level.TimeSeconds);
                            SPC.NormalCamper.DoneInitialWarn = false;
                            SPC.NormalCamper.TimeLastMsg = int(Level.TimeSeconds);
                            return;
                        }
                        //++ SPC.MBStatsLocal.campingtimes;
                        ++SPC.campingtimes;
                        if (MaxCampBeforeKick != 0 && SPC.campingtimes > MaxCampBeforeKick)
                        {
                            SPC.campingtimes = 0;
                            SPC.shouldKick = true;
                            SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.CampKickString, AGM.Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName, MaxCampBeforeKick);
                            return;
                        }

                        AGM.BroadcastHandler.Broadcast(none, AGM.Lang.FormatLangString(AGM.Lang.KillCampString, AGM.Lang.ServerString, SPC.PC.PlayerReplicationInfo.PlayerName), 'Caption');
                        SPC.PC.Pawn.Died(none, class'DamageType', SPC.PC.Pawn.Location, vect(0.0, 0.0, 0.0));
                        NetPlayer(SPC.PC.Pawn).Destroy();
                    }
                }
            }
            // End:0x6C9
            else
            {
                // End:0x6C9
                if((Level.TimeSeconds - float(SPC.NormalCamper.camperstarttime)) > float(InitialCampWarningInterval))
                {
                    SPC.NormalCamper.camperstarttime = int((Level.TimeSeconds - float(InitialCampWarningInterval)) - float(2));
                    SPC.NormalCamper.TimeLastMsg = SPC.NormalCamper.camperstarttime;
                    SPC.NormalCamper.DoneInitialWarn = false;
                }
            }
        }
        // End:0x7A1
        else
        {
            SPC.NormalCamper.camperstarttime = int(Level.TimeSeconds);
            SPC.NormalCamper.OldLocation = SPC.PC.Pawn.Location;
            SPC.NormalCamper.DoneInitialWarn = false;
            SPC.NormalCamper.TimeLastMsg = int(Level.TimeSeconds);
            SPC.NormalCamper.oldkills = SwatPlayerReplicationInfo(SPC.PC.PlayerReplicationInfo).NetScoreInfo.GetEnemyKills();
        }
    }
    return;
}


function OnPawnArrested(Pawn Arrestee, Pawn Arrester)
{
    local AMPlayerController SPC, SPCSEC;

    // End:0x4F
    if(LongArmsSensitivity <= 0)
    {
        //log("OnPawn arrested call from Anti Cheat! Long Arm 0");
        return;
    }
    // End:0x6C
    if(AGM.hasEnded)
    {
        //log("OnPawn arrested call from Anti Cheat! Has Ended");
        return;
    }
    SPC = AGM.GetAMPlayerControllerByPawn(Arrester);
    SPCSEC = AGM.GetAMPlayerControllerByPawn(Arrestee);

    // Anti Camp System reset
    SPCSEC.NormalCamper.camperstarttime = int(Level.TimeSeconds);
    SPCSEC.NormalCamper.DoneInitialWarn = false;
    SPCSEC.NormalCamper.TimeLastMsg = int(Level.TimeSeconds);

    // End:0xBF
    if(SPC == none)
    {
        //log("OnPawn arrested call from Anti Cheat! SPC None");
        return;
    }
    // End:0xCC
    if(SPCSEC == none)
    {
        //log("OnPawn arrested call from Anti Cheat! SPCSEC None");
        return;
    }

    if(SPC.Team == SPCSEC.Team)
    {
        SPC.IsAdmin = false;
        //Ban(SPC, "Team-arresting");
        log("Team arrester from Anti Cheat!");
        AGM.BroadcastHandler.Broadcast(none, "[c=ffff00](CHEAT-BUSTER) detected a player arresting team members named "$SPC.PC.PlayerReplicationInfo.PlayerName, 'Caption');
        SPC.shouldKick = true;
        SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickString, "CHEAT-BUSTER", SPC.PC.PlayerReplicationInfo.PlayerName );
    }
    // End:0x286
    //                            6000                            300 + (300 - 2*100)
    if(VDist(SPC.PC.Pawn.Location, SPCSEC.PC.Pawn.Location) > float(300 + (300 - (LongArmsSensitivity * 100))))
    {
        SPC.IsAdmin = false;
        //Ban(SPC, ("Long-arms (arresting) (" $ string(LongArmsSensitivity)) $ ")");
        log("long hands from Anti Cheat!");
        AGM.BroadcastHandler.Broadcast(none, "[c=ffff00](CHEAT-BUSTER) detected a player with long hand named "$SPC.PC.PlayerReplicationInfo.PlayerName, 'Caption');
        SPC.shouldKick = true;
        SPC.kickReason = AGM.Lang.FormatLangString( AGM.Lang.KickString, "CHEAT-BUSTER", SPC.PC.PlayerReplicationInfo.PlayerName );
    }
}

function SendStats(string TheQue)
{
    log("KZMod: Sending ban stats to website");
    // End:0x8F
        // End:0x6E
    Qued[Qued.Length] = TheQue;
}


event Destroyed()
{
    local SwatGameInfo GameInfo;

    MPLog("Anti Cheat:: Destroyed is called!");
    GameInfo = SwatGameInfo(Level.Game);
    // End:0x81
    if((GameInfo != none) && GameInfo.GameEvents != none)
    {
        GameInfo.GameEvents.PawnArrested.UnRegister(self);
    }
}


DefaultProperties
{
    KillCampers=true;
    campKillTimes=0;
    InitialCampWarningInterval=20;
    CampWarningInterval=10;
    MaxCampTime=35;
    MaxCampBeforeKick=10;
    LongArmsSensitivity=3;
}
