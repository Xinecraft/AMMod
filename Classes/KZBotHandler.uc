class KZBotHandler extends SwatGame.SwatMutator;

var AMGameMod AGM;
var KZMod KZMod;
var float lastBotSpeechTime;
var array<PathNode> PathNodeList;

function BeginPlay()
{
    local PathNode ThePathNode;
    local int i, A;
    local bool Found;

    // End:0x73
    foreach AllActors(class'PathNode', ThePathNode)
    {
        Found = false;

        for (A = 0; A < PathNodeList.Length ; A++)
        {
            if(PathNodeList[A] == ThePathNode)
            {
                Found = true;
            }
        }

        if(!Found)
        {
            PathNodeList[i] = ThePathNode;
        }
    }
}

function CheckBots(float MyDelta)
{
    //local AMPlayerController SPC, APC;
    local AMPlayerController APC;
    local FiredWeapon ActiveItem;
    local int i, X;
    //local Vector B;

    // End:0x3C
    if(AGM.hasEnded)
    {
        return;
    }

    CheckArrests();

    i = 0;
    for ( X = 0; X < AGM.PlayerList.Length ; X++)
    {
        APC = AGM.PlayerList[X];

        //if(NetPlayer(APC.PC.Pawn).IsTased())
        //{
        //NetPlayer(Bot.PC.Pawn).SetForceCrouchState(true);
        //SwatGamePlayerController(Bot.PC).MoveAutonomous(MyDelta, false, true, false, false, false, false, EDoubleClickDir.DCLICK_None , vect(0.0, 0.0, 0.0), rot(0, 0, 0));

        //SwatGamePlayerController(APC.PC).MoveAutonomous(MyDelta, false, false, false, false, false, false, EDoubleClickDir.DCLICK_None , vect(0.0, 0.0, 0.0), rot(0, 0, 0));
        //}

        // End:0xA7
        if((APC == none) || APC.PC == none)
        {
            continue;
        }
        // End:0xE7
        if((SwatGamePlayerController(APC.PC) == none) || SwatGamePlayerController(APC.PC).SwatRepoPlayerItem == none)
        {
            continue;
        }
        // End:0x11D
        if(!APC.isBot || APC.PC.Pawn == none)
        {
            continue;
        }
        // End:0x174
        if(NetPlayer(APC.PC.Pawn).IsArrested() || NetPlayer(APC.PC.Pawn).IsNonlethaled())
        {
            SwatGamePlayerController(APC.PC).MoveAutonomous(MyDelta, false, false, false, false, false, false, EDoubleClickDir.DCLICK_None , vect(0.0, 0.0, 0.0), rot(0, 0, 0));
            continue;
        }

        BotFindTarget(APC);
        // End:0x1A4
        if(APC.enemyPlayer == none)
        {
            APC.enemySighted = false;
        }
        // End:0x2A7
        if(APC.enemySighted)
        {
            SwatGamePlayerController(APC.PC).MoveAutonomous(MyDelta, false, true, false, false, false, false, EDoubleClickDir.DCLICK_None , Normal(vector(APC.PC.Pawn.GetAimRotation())), APC.PC.Pawn.Rotation);
            SwatPlayer(APC.PC.Pawn).AnimSetAimActor(APC.enemyPlayer.Pawn);
            APC.PC.Pawn.ClientSetRotation(APC.PC.Pawn.GetAimRotation());
        }
        // End:0x2B7
        else
        {
            BotMoveToPoint(APC, MyDelta);
        }
        BotSpeech(APC);
        ActiveItem = FiredWeapon(NetPlayer(APC.PC.Pawn).GetActiveItem());
        // End:0x301
        if(ActiveItem == none)
        {
            continue;
        }
        // End:0x35C
        if(ActiveItem.NeedsReload() && ActiveItem.CanReload())
        {
            SwatPlayer(APC.PC.Pawn).ServerRequestReload(ActiveItem.GetSlot());
        }
        // End:0x3CB
        if(APC.enemySighted && (Level.TimeSeconds - APC.lastShotFiredTime) > RandRange(0.250, 0.50))
        {
            BotFireWeapon(APC);
            APC.lastShotFiredTime = Level.TimeSeconds;
        }
        i++;
    }
}

function BotMoveToPoint(AMPlayerController Bot, float MyDelta)
{
    local Vector MoveToLocation;
    local SwatDoor Door;


    foreach RadiusActors(class'SwatDoor', Door, 30.0, Bot.PC.Pawn.Location)
    {
        // End:0xB9
        if(Door != none && Door.CanInteract() && !Door.IsOpen())
        {
            Door.Interact(Bot.PC.Pawn, true);
        }
    }
    FindPlayerToGoTo(Bot);
    // End:0x137
    if(Bot.FindPlayer != none)
    {
        MoveToLocation = NextPathLocationToGoTo(Bot, Bot.PC.Pawn.Location, Bot.FindPlayer.PC.Pawn.Location);
    }
    // End:0x170
    else
    {
        //log(("[bot " $ string(Bot.Id)) $ "]no close player found");
    }
    // End:0x2FE
    if(!NetPlayer(Bot.PC.Pawn).IsTased())
    {
        log(("[bot " $ string(Bot.Id)) $ "] is NOT tased and moving!");
        // End:0x2A0
        if(MoveToLocation != vect(0.0, 0.0, 0.0))
        {
            SwatPlayer(Bot.PC.Pawn).AnimSetAimPoint(MoveToLocation + vect(0.0, 0.0, 20.0));
            Bot.PC.Pawn.ClientSetRotation(Bot.PC.Pawn.GetAimRotation());
            SwatGamePlayerController(Bot.PC).MoveAutonomous(MyDelta, true, false, false, false, false, false, EDoubleClickDir.DCLICK_None , Normal(vector(Bot.PC.Pawn.GetAimRotation())), Bot.PC.Pawn.Rotation);
        }
        // End:0x2FB
        else
        {
            // End:0x2FB
            if(MoveToLocation == vect(0.0, 0.0, 0.0))
            {
                SwatGamePlayerController(Bot.PC).MoveAutonomous(MyDelta, false, false, false, false, false, false, EDoubleClickDir.DCLICK_None , vect(0.0, 0.0, 0.0), rot(0, 0, 0));
            }
        }
    }
    else
    {
        log(("[bot " $ string(Bot.Id)) $ "] is tased and STOP!");
        //NetPlayer(Bot.PC.Pawn).SetForceCrouchState(true);
        //SwatGamePlayerController(Bot.PC).MoveAutonomous(MyDelta, false, true, false, false, false, false, EDoubleClickDir.DCLICK_None , vect(0.0, 0.0, 0.0), rot(0, 0, 0));

        SwatGamePlayerController(Bot.PC).MoveAutonomous(MyDelta, false, false, false, false, false, false, EDoubleClickDir.DCLICK_None , vect(0.0, 0.0, 0.0), rot(0, 0, 0));
    }

    // End:0x408
    if(((MoveToLocation != vect(0.0, 0.0, 0.0)) && Bot.FindPlayer != none) && (Level.TimeSeconds - float(Bot.StartPathNodeGoal)) > float(3))
    {
        Bot.PC.Pawn.SetLocation(MoveToLocation);
        log(("[bot " $ string(Bot.Id)) $ "]Reset bot's location to movetolocation.");
    }
    // End:0x460
    if((Level.TimeSeconds - float(Bot.StartRecordingPathNodes)) > float(15))
    {
        Bot.StartRecordingPathNodes = 0;
        Bot.UsedPathNodes.Remove(0, Bot.UsedPathNodes.Length);
    }
}

function Vector NextPathLocationToGoTo(AMPlayerController Bot, Vector FromLocation, Vector GotoLocation)
{
    local PathNode ThePathNode, ThePathNodeClose;
    local bool nodeFound, foundbestoptionA, foundbestoptionB, foundbestoptionC;
    local int A, numclosepathnodes;

    nodeFound = false;
    // End:0x77
    foreach VisibleActors(class'PathNode', ThePathNodeClose, 30.0, FromLocation)
    {
        // End:0x76
        if(ThePathNodeClose == Bot.PathNodeGoal)
        {
            nodeFound = true;
        }
    }
    // End:0x91
    if(nodeFound)
    {
        Bot.PathNodeGoal = none;
    }
    // End:0x386
    if(Bot.PathNodeGoal == none)
    {
        // End:0x2EF
        foreach VisibleActors(class'PathNode', ThePathNode, 300.0, FromLocation)
        {
            ++ numclosepathnodes;
            nodeFound = false;
            // End:0x100
            foreach VisibleActors(class'PathNode', ThePathNodeClose, 20.0, FromLocation)
            {
                // End:0xFF
                if(ThePathNodeClose == ThePathNode)
                {
                    nodeFound = true;
                }
            }

            for (A = 0; A < Bot.UsedPathNodes.Length ; A++)
            {
                if(Bot.UsedPathNodes[A] == ThePathNode)
                {
                    nodeFound = true;
                }
            }
            // End:0x15E
            if(nodeFound)
            {
                continue;
            }
            // End:0x1EE
            if(((Bot.PathNodeGoal != none) && VDist(ThePathNode.Location, GotoLocation) < VDist(Bot.PathNodeGoal.Location, GotoLocation)) && FastTrace(FromLocation, ThePathNode.Location))
            {
                Bot.PathNodeGoal = ThePathNode;
                foundbestoptionA = true;
                // End:0x2EE
                continue;
            }
            // End:0x270
            if((!foundbestoptionA && Bot.PathNodeGoal != none) && VDist(ThePathNode.Location, GotoLocation) < VDist(Bot.PathNodeGoal.Location, GotoLocation))
            {
                Bot.PathNodeGoal = ThePathNode;
                foundbestoptionB = true;
                // End:0x2EE
                continue;
            }
            // End:0x2B5
            if(!foundbestoptionA && FastTrace(FromLocation, ThePathNode.Location))
            {
                Bot.PathNodeGoal = ThePathNode;
                foundbestoptionC = true;
                // End:0x2EE
                continue;
            }
            // End:0x2EE
            if((!foundbestoptionA && !foundbestoptionB) && !foundbestoptionC)
            {
                Bot.PathNodeGoal = ThePathNode;
            }
        }
        // End:0x307
        if(Bot.PathNodeGoal == none)
        {
        }
        // End:0x386
        else
        {
            Bot.StartPathNodeGoal = int(Level.TimeSeconds);
            Bot.UsedPathNodes[Bot.UsedPathNodes.Length] = Bot.PathNodeGoal;
            // End:0x386
            if(Bot.StartRecordingPathNodes <= 0)
            {
                Bot.StartRecordingPathNodes = int(Level.TimeSeconds);
            }
        }
    }
    // End:0x3AB
    if(Bot.PathNodeGoal == none)
    {
        return vect(0.0, 0.0, 0.0);
    }
    // End:0x3C3
    else
    {
        return Bot.PathNodeGoal.Location;
    }
}

function bool OtherTeamHasAlivePlayers(AMPlayerController Bot)
{
    local AMPlayerController SPC;
    local int i;

    // End:0x28

    for (i = 0; i < AGM.PlayerList.Length ; i++)
    {
        SPC = AGM.PlayerList[i];
        // End:0x70
        if(SPC == none)
        {
            continue;
        }
        // End:0x87
        if(SPC.PC == none)
        {
            continue;
        }
        // End:0xA7
        if(SPC.PC.Pawn == none)
        {
            continue;
        }
        // End:0xC3
        if(SwatGamePlayerController(SPC.PC) == none)
        {
            continue;
        }
        // End:0xE8
        if(SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem == none)
        {
            continue;
        }
        // End:0x10B
        if(SPC.Team != Bot.Team)
        {
            return true;
        }
    }
}

function FindPlayerToGoTo(AMPlayerController Bot, optional bool FindInSameTeam)
{
    local AMPlayerController SPC;
    local int i;
    local AMPlayerController FirstFindPlayer;


    if(Bot.enemySighted)
    {
        return;
    }
    // End:0xB3
    if((((OtherTeamHasAlivePlayers(Bot)) && !FindInSameTeam) && !SwatGamePlayerController(Bot.PC).ThisPlayerIsTheVIP) && !SwatPlayerReplicationInfo(Bot.PC.PlayerReplicationInfo).bIsTheVIP)
    {
        FindInSameTeam = false;
    }
    // End:0xBB
    else
    {
        FindInSameTeam = true;
    }
    FirstFindPlayer = Bot.FindPlayer;
    Bot.FindPlayer = none;

    for (i = 0; i < AGM.PlayerList.Length ; i++)
    {
        SPC = AGM.PlayerList[i];
        // End:0x127
        if(SPC == none)
        {
            continue;
        }
        // End:0x13E
        if(SPC.PC == none)
        {
            continue;
        }
        // End:0x15E
        if(SPC.PC.Pawn == none)
        {
            continue;
        }
        // End:0x17A
        if(SwatGamePlayerController(SPC.PC) == none)
        {
            continue;
        }
        // End:0x19F
        if(SwatGamePlayerController(SPC.PC).SwatRepoPlayerItem == none)
        {
            continue;
        }
        // End:0x1D3
        if(!FindInSameTeam && SPC.Team == Bot.Team)
        {
            continue;
        }
        // End:0x216
        else
        {
            // End:0x216
            if(FindInSameTeam && (SPC.Team != Bot.Team) || SPC.isBot)
            {
                continue;
            }
        }
        // End:0x241
        if(Bot.FindPlayer == none)
        {
            Bot.FindPlayer = SPC;
            continue;
        }
        // End:0x2EF
        if(VDist(SPC.PC.Pawn.Location, Bot.PC.Pawn.Location) < VDist(Bot.FindPlayer.PC.Pawn.Location, Bot.PC.Pawn.Location))
        {
            Bot.FindPlayer = SPC;
        }
    }
}

function BotFireWeapon(AMPlayerController Bot)
{
    return;
    local FiredWeapon ActiveItem;
    local Engine.Actor.ESkeletalRegion SkeletalRegions[7];
    local int i;

    ActiveItem = FiredWeapon(NetPlayer(Bot.PC.Pawn).GetActiveItem());
    // End:0x66
    if(ActiveItem == none)
    {
        return;
    }
    // End:0xA1
    if(ActiveItem.IsEmpty())
    {
        SwatPlayer(Bot.PC.Pawn).BroadcastEmptyFiredToClients();
    }
    // End:0x3C5
    else
    {
        // End:0x3C5
        if(ActiveItem.IsIdle())
        {
            // End:0x1A9
            if(ActiveItem.MuzzleVelocity != float(1000))
            {
                ActiveItem.MuzzleVelocity = 100.0;
                ActiveItem.MaxAimError = 7.0;
                ActiveItem.LargeAimErrorRecoveryRate = 6.0;
                ActiveItem.SmallAimErrorRecoveryRate = 5.50;
                ActiveItem.AimErrorBreakingPoint = 2.750;
                ActiveItem.StandingAimError = 0.10;
                ActiveItem.WalkingAimError = 0.40;
                ActiveItem.RunningAimError = 1.0;
                ActiveItem.CrouchingAimError = 0.10;
                ActiveItem.EquippedAimErrorPenalty = 1.50;
                ActiveItem.FiredAimErrorPenalty = 0.60;
            }
            SwatPlayer(Bot.PC.Pawn).ServerBeginFiringWeapon(ActiveItem.GetSlot());
            // End:0x21D
            if(ActiveItem.CurrentFireMode == 2)
            {
                SwatPlayer(Bot.PC.Pawn).ServerEndFiringWeapon();
            }
            i = Rand(8);
            // End:0x3C5
            if(i >= 3)
            {
                SkeletalRegions[3] = ESkeletalRegion.REGION_LeftArm;
                SkeletalRegions[4] = ESkeletalRegion.REGION_RightArm;
                SkeletalRegions[5] = ESkeletalRegion.REGION_LeftLeg;
                SkeletalRegions[6] = ESkeletalRegion.REGION_RightLeg;
                SkeletalRegions[7] = ESkeletalRegion.REGION_Body_Max;
                // End:0x2C9
                if((VSize(Bot.PC.Pawn.Location - Bot.enemyPlayer.Pawn.Location) > float(1200)) && Rand(10) >= 4)
                {
                    return;
                }
                SwatPlayer(Bot.enemyPlayer.Pawn).OnSkeletalRegionHit(SkeletalRegions[i], vect(0.0, 0.0, 0.0), vect(0.0, 0.0, 0.0), i * 4, ActiveItem.GetDamageType(), Bot.PC.Pawn);
                SwatPlayer(Bot.enemyPlayer.Pawn).TakeDamage(i * 4, Bot.PC.Pawn, Bot.enemyPlayer.Pawn.Location, vect(0.0, 0.0, 0.0), ActiveItem.GetDamageType());
            }
        }
    }
    return;
}

function BotFindTarget(AMPlayerController Bot)
{
    local AMPlayerController SPC;
    local Vector V, U, Location;
    local int i;
    //local HandheldEquipment CurrentItem, SetToItem, PrimGun;
    //local OfficerLoadOut theLoadOut;
    //local SwatPlayer theSwatPlayer;

    U.X = 0.0;
    U.Y = 0.0;
    V.X = 0.0;
    V.Y = 0.0;
    // End:0x9F
    if(Bot.PC.Pawn.bIsCrouched)
    {
        V.Z = 40.0;
    }
    // End:0xAF
    else
    {
        V.Z = 60.0;
    }
    // End:0x310
    if(Bot.enemySighted)
    {
        // End:0x108
        if((Bot.enemyPlayer == none) || Bot.enemyPlayer.Pawn == none)
        {
            Bot.enemySighted = false;
        }
        // End:0x310
        else
        {
            Bot.FindPlayer = AGM.GetAMPlayerController(Bot.enemyPlayer);
            // End:0x16B
            if(Bot.enemyPlayer.Pawn.bIsCrouched)
            {
                U.Z = 40.0;
            }
            // End:0x17B
            else
            {
                U.Z = 60.0;
            }
            // End:0x299
            if(Bot.enemyPlayer.Pawn.LeanState != 0)
            {
                // End:0x235
                if(SPC.PC.Pawn.LeanState == 1)
                {
                    Location = Bot.enemyPlayer.Pawn.Location + (Normal(vector(Bot.enemyPlayer.Pawn.Rotation) Cross vect(0.0, 0.0, 1.0)) * float(40));
                }
                // End:0x296
                else
                {
                    Location = Bot.enemyPlayer.Pawn.Location + (Normal(vector(Bot.enemyPlayer.Pawn.Rotation) Cross vect(0.0, 0.0, -1.0)) * float(40));
                }
            }
            // End:0x2BF
            else
            {
                Location = Bot.enemyPlayer.Pawn.Location;
            }
            // End:0x30E
            if(!FastTrace(Location + U, Bot.PC.Pawn.Location + V))
            {
                Bot.enemySighted = false;
            }
            // End:0x310
            else
            {

            }
        }
    }

    for (i = 0; i < AGM.PlayerList.Length ; i++)
    {
        SPC = AGM.PlayerList[i];
        // End:0x38D
        if(((SPC == none) || SPC.PC == none) || SPC.PC.Pawn == none)
        {
            continue;
        }
        // End:0x3F3
        if(NetTeam(SPC.PC.PlayerReplicationInfo.Team).GetTeamNumber() == NetTeam(Bot.PC.PlayerReplicationInfo.Team).GetTeamNumber())
        {
            continue;
        }
        // End:0x42A
        if(SPC.PC.Pawn.bIsCrouched)
        {
            U.Z = 40.0;
        }
        // End:0x43A
        else
        {
            U.Z = 60.0;
        }
        // End:0x558
        if(SPC.PC.Pawn.LeanState != 0)
        {
            // End:0x4F4
            if(SPC.PC.Pawn.LeanState == 1)
            {
                Location = SPC.PC.Pawn.Location + (Normal(vector(SPC.PC.Pawn.Rotation) Cross vect(0.0, 0.0, 1.0)) * float(40));
            }
            // End:0x555
            else
            {
                Location = SPC.PC.Pawn.Location + (Normal(vector(SPC.PC.Pawn.Rotation) Cross vect(0.0, 0.0, -1.0)) * float(40));
            }
        }
        // End:0x57E
        else
        {
            Location = SPC.PC.Pawn.Location;
        }
        // End:0x6EB
        if((((((!NetPlayer(SPC.PC.Pawn).IsArrested() && !NetPlayer(SPC.PC.Pawn).IsBeingArrestedNow()) && !NetPlayer(SPC.PC.Pawn).IsTased()) && !SwatGamePlayerController(Bot.PC).ThisPlayerIsTheVIP) && !SwatPlayerReplicationInfo(Bot.PC.PlayerReplicationInfo).bIsTheVIP) && !SwatGamePlayerController(SPC.PC).ThisPlayerIsTheVIP) && !SwatPlayerReplicationInfo(SPC.PC.PlayerReplicationInfo).bIsTheVIP)
        {
            Bot.enemySighted = FastTrace(Location + U, Bot.PC.Pawn.Location + V);
        }
        // End:0x7CB
        if(Bot.enemySighted)
        {
            // End:0x7AB
            if(((vector(Bot.PC.Pawn.Rotation) Dot Normal(Location - Bot.PC.Pawn.Location)) < float(0)) || VSize((Location + U) - (Bot.PC.Pawn.Location + V)) > float(1400))
            {
                Bot.enemySighted = false;
                continue;
            }
            Bot.enemyPlayer = SPC.PC;
            break;
        }
    }
}

function BotMove(AMPlayerController SPC, AMPlayerController APC, float MyDelta)
{
    local bool crouched, leanleft, leanright, Running;

    Running = true;
    // End:0x87
    if(SPC.PC.Pawn.bIsWalking || SwatPlayer(SPC.PC.Pawn).IsLowerBodyInjured())
    {
        Running = false;
    }
    // End:0xB3
    if(SPC.PC.Pawn.bIsCrouched)
    {
        crouched = true;
    }
    // End:0x11C
    if(SPC.PC.Pawn.LeanState != 0)
    {
        // End:0x114
        if(SPC.PC.Pawn.LeanState == 1)
        {
            leanleft = true;
        }
        // End:0x11C
        else
        {
            leanright = true;
        }
    }
    SwatGamePlayerController(APC.PC).MoveAutonomous(MyDelta, Running, crouched, false, false, leanleft, leanright, EDoubleClickDir.DCLICK_None , SPC.PC.Pawn.Velocity, SPC.PC.Pawn.Rotation);
}

function CheckArrests()
{
    local GameModeMPBase GameModeMPBase;
    local AMPlayerController SPC;
    local bool arrestInProgress;
    local int i;

    for (i = 0; i < AGM.PlayerList.Length ; i++)
    {
        SPC = AGM.PlayerList[i];
        // End:0xA5
        if(((SPC == none) || SPC.PC == none) || SPC.PC.Pawn == none)
        {
           continue;
        }
        // End:0xCF
        if(SPC.PC.GetStateName() == 'QualifyingForUse')
        {
            arrestInProgress = true;
            break;
        }

    }
    // End:0x1C1
    if(arrestInProgress)
    {
        for (i = 0; i < AGM.PlayerList.Length ; i++)
        {
            SPC = AGM.PlayerList[i];
            // End:0x140
            if((SPC == none) || SPC.PC == none)
            {
                continue;
            }
            // End:0x176
            if(!SPC.isBot || SPC.PC.Pawn == none)
            {
                continue;
            }
            SPC.unpossessedPawn = SPC.PC.Pawn;
            SPC.PC.UnPossess();
        }
    }
    // End:0x47A
    else
    {
        for (i = 0; i < AGM.PlayerList.Length ; i++)
        {
            SPC = AGM.PlayerList[i];
            // End:0x21F
            if((SPC == none) || SPC.PC == none)
            {
                continue;
            }
            // End:0x236
            if(!SPC.isBot)
            {
                continue;
            }
            // End:0x470
            if((SPC.PC.Pawn == none) && SPC.unpossessedPawn != none)
            {
                SwatGamePlayerController(SPC.PC).Possess(SPC.unpossessedPawn);
                SPC.unpossessedPawn = none;
                // End:0x470
                if(NetPlayer(SPC.PC.Pawn).IsArrested())
                {
                    SPC.PC.GotoState('BeingCuffed');
                    SwatPawn(SPC.PC.Pawn).OnArrested(SwatPawn(SPC.PC.Pawn).GetArrester());
                    NetPlayer(SPC.PC.Pawn).OnArrestedSwatPawn(SwatPawn(SPC.PC.Pawn).GetArrester());
                    GameModeMPBase = GameModeMPBase(SwatGameInfo(Level.Game).GetGameMode());
                    GameModeMPBase.OnPawnArrested(SPC.PC.Pawn, SwatPawn(SPC.PC.Pawn).GetArrester());
                }
            }
        }
    }
}

function BotSpeech(AMPlayerController Bot)
{
    local string msg, Name;
    local AMPlayerController SPC;
    local int i, X;

    // End:0x516
    if((Rand(1000) == 54) && (Level.TimeSeconds - lastBotSpeechTime) > float(180))
    {
        i = Rand(15);
        // End:0x132
        if(i > 11)
        {
            for (X = 0; X < AGM.PlayerList.Length ; X++)
            {
                SPC = AGM.PlayerList[X];
                // End:0xFD
                if((((SPC == none) || SPC.PC == none) || SPC.PC.Pawn == none) || SPC.isBot)
                {
                    continue;
                }
                Name = SPC.Name;
                AGM.StripColours(Name);
                break;
            }
        }
        switch(i)
        {
            // End:0x182
            case 0:
                msg = "I feel the need for speed. Road trip on the cyber-highway!";
                // End:0x4D2
                break;
            // End:0x1C8
            case 1:
                msg = "Hehehe, I am the master of your cyber-space nightmares.";
                // End:0x4D2
                break;
            // End:0x21F
            case 2:
                msg = "Oh look, a noob with a pee-shooter. And I'm not talking about your gun.";
                // End:0x4D2
                break;
            // End:0x24B
            case 3:
                msg = "Yeehaa! Let's kick some ass!";
                // End:0x4D2
                break;
            // End:0x281
            case 4:
                msg = "Heh. There's rats in here... big ones.";
                // End:0x4D2
                break;
            // End:0x2C8
            case 5:
                msg = "Okay, kiddies. Pick up all your body parts and get out.";
                // End:0x4D2
                break;
            // End:0x2E8
            case 6:
                msg = "Bwahahahahahaha!";
                // End:0x4D2
                break;
            // End:0x330
            case 7:
                msg = "An endless row of graves...too many to put the names on.";
                // End:0x4D2
                break;
            // End:0x371
            case 8:
                msg = "Give a kid a weapon and he thinks he's a soldier.";
                // End:0x4D2
                break;
            // End:0x39D
            case 9:
                msg = "Today's lesson will be pain.";
                // End:0x4D2
                break;
            // End:0x3B3
            case 10:
                msg = "Grrrr.";
                // End:0x4D2
                break;
            // End:0x3F2
            case 11:
                msg = "Now that we are all here, let the lesson begin.";
                // End:0x4D2
                break;
            // End:0x453
            case 12:
                msg = ("Don't take it personally, " $ Name) $ ", I was doing this when you were in diapers.";
                // End:0x4D2
                break;
            // End:0x491
            case 13:
                msg = ("Does your momma know you're here, " $ Name) $ "?";
                // End:0x4D2
                break;
            // End:0x4CF
            case 14:
                msg = ("I can kick your ass all day long, " $ Name) $ ".";
                // End:0x4D2
                break;
            // End:0xFFFF
            default:
                Level.Game.Broadcast(Bot.PC, msg, 'Say');
                lastBotSpeechTime = Level.TimeSeconds;
            }
            return;
        }
}
