class AMSaGMod extends SwatGame.GameModeMPBase;

#if SWAT_EXPANSION

var bool cannotspawn;
var bool switchedSpawns;
var bool shouldSwitchSpawns;
var SmashAndGrabItemBase gameItem;
var GameModeMPBase BaseClass;
var GameModeSmashAndGrab SAGClass;
var ItemGoalBase IGoal;

var AMGameMod AGM;

function Tick( float Delta )
{
	local SwatMPStartCluster SpawnPoint;
	local vector vec1;

	BaseClass = GameModeMPBase(SwatGameInfo(Level.Game).GetGameMode());
	SAGClass = GameModeSmashAndGrab(BaseClass);

	if ( BaseClass == None || SAGClass == None )
		return;

	SpawnCase();

	if ( AGM.hasEnded || gameItem == None || IGoal == None || SAGClass.gameItem == None )
		return;

	if ( gameItem.Owner != None && SuspectIsInGoal( gameItem.Owner, IGoal ) )
		GameModeSmashAndGrab(SwatGameInfo(Level.Game).GetGameMode()).ItemGoalAchieved(NetPlayer(gameItem.Owner));

	if ( !switchedSpawns )
	{
		if ( shouldSwitchSpawns && gameItem.Owner != None )
		{
			SwitchSpawnPoints( true );
			switchedSpawns = true;
		}
	}

	vec1 = gameItem.Location;
	vec1.z = vec1.z*100;

	//Swat
	if ( !switchedSpawns )
		SpawnPoint = FindBestSpawns(BaseClass.Team0StartClusters, switchedSpawns, false, vec1);
	else
		SpawnPoint = FindBestSpawns(BaseClass.Team0StartClusters, switchedSpawns, false);
	vec1 = SpawnPoint.Location;
	vec1.z = vec1.z*100;

	//Suspect
	FindBestSpawns(BaseClass.Team1StartClusters, switchedSpawns, true, vec1);
}

function SwatMPStartCluster FindBestSpawns( array<SwatMPStartCluster> TeamStartClusters, bool gotCase, bool suspect, optional vector avoid )
{
	local SwatMPStartCluster Best;
    local int i;
	local float CaseDistToExit, DistanceFromCase, DistanceFromExit, BestCaseDist, BestExitDist, AvoidDistance, BestAvoid;
	local vector vec1, vec2, caseloc;

	if ( gameItem.Owner != None )
		caseloc = gameItem.Owner.Location;
	else
		caseloc = gameItem.Location;

	vec1 = caseloc;
	vec1.z = vec1.z*100;
	vec2 = IGoal.Location;
	vec2.z = vec2.z*100;
	CaseDistToExit = VDistSquared( vec1, vec2 );

    for( i = 0; i < TeamStartClusters.Length; i++ )
    {
		TeamStartClusters[i].IsEnabled = false;

		vec1 = TeamStartClusters[i].Location;
		vec1.z = vec1.z*100;
		vec2 = caseloc;
		vec2.z = vec2.z*100;
		DistanceFromCase = VDistSquared( vec1, vec2 );

		vec2 = IGoal.Location;
		vec2.z = vec2.z*100;
		DistanceFromExit = VDistSquared( vec1, vec2 );

		if ( avoid.x == 0 && avoid.y == 0 && avoid.z == 0 )
			AvoidDistance = 2500;
		else
			AvoidDistance = VDistSquared( vec1, avoid );

		if ( AvoidDistance > BestAvoid && BestAvoid < 2500 )
		{
			BestAvoid = AvoidDistance;
			Best = TeamStartClusters[i];
			BestCaseDist = DistanceFromCase;
			BestExitDist = DistanceFromExit;
		}

        if ( DistanceFromCase < BestCaseDist && AvoidDistance >= 2500 )
		{
			if ( suspect )
			{
				//They have not yet picked up the case, put them between the case and the exit, nearest the case
				if ( !gotCase )
				{
					if ( CaseDistToExit > DistanceFromExit )
					{
						Best = TeamStartClusters[i];
						BestCaseDist = DistanceFromCase;
						BestExitDist = DistanceFromExit;
					}
				}
				//They have picked up the case now, put them behind the case and the exit, nearest the case
				//Now just put them nearest the case instead
				else /*if ( DistanceFromExit > CaseDistToExit && BestExitDist > DistanceFromExit )*/
				{
					Best = TeamStartClusters[i];
					BestCaseDist = DistanceFromCase;
					BestExitDist = DistanceFromExit;
				}
			}
			else
			{
				//The suspects have not yet picked up the case, put swat behind the case and the exit, nearest the case
				if ( !gotCase )
				{
					if ( DistanceFromExit > CaseDistToExit && BestExitDist > DistanceFromExit )
					{
						Best = TeamStartClusters[i];
						BestCaseDist = DistanceFromCase;
						BestExitDist = DistanceFromExit;
					}
				}
				//The suspects have picked up the case now, put swat between the case and the exit, nearest the case
				else if ( CaseDistToExit > DistanceFromExit )
				{
					Best = TeamStartClusters[i];
					BestCaseDist = DistanceFromCase;
					BestExitDist = DistanceFromExit;
				}
			}
		}
    }

	Best.IsEnabled = true;

	return Best;
}

//This switches the spawns for suspects and swat back and forth
//Note: only works for respawns, not initial spawns
function SwitchSpawnPoints( bool switched )
{
	local SwatMPStartCluster ClusterPoint;

	BaseClass.Team0StartClusters.Remove( 0, BaseClass.Team0StartClusters.Length );
	BaseClass.Team1StartClusters.Remove( 0, BaseClass.Team1StartClusters.Length );

	// Cache the start clusters.
	foreach AllActors( class'SwatMPStartCluster', ClusterPoint )
	{
		if ( SAGClass.ValidSpawnClusterForMode( ClusterPoint ) )
		{
			//ensure all clusters are enabled at the start of the round
			ClusterPoint.IsEnabled = true;

			if ( !switched )
			{
				if ( ClusterPoint.ClusterTeam == MPT_Swat )
					BaseClass.Team0StartClusters[BaseClass.Team0StartClusters.Length] = ClusterPoint;
				else
					BaseClass.Team1StartClusters[BaseClass.Team1StartClusters.Length] = ClusterPoint;
			}
			else
			{
				if ( ClusterPoint.ClusterTeam == MPT_Swat )
					BaseClass.Team1StartClusters[BaseClass.Team1StartClusters.Length] = ClusterPoint;
				else
					BaseClass.Team0StartClusters[BaseClass.Team0StartClusters.Length] = ClusterPoint;
			}
		}
	}
}

function vector GetCaseSpawnLocation()
{
	local int i, j, k;
	local vector vec;
	local SwatMPStartCluster ClusterPoint;

	vec.x = 0;
	vec.y = 0;
	vec.z = 0;

	if ( !cannotspawn )
	{
		for ( i = 0; i < AGM.CaseCoordinates.Length; i++ )
		{
			j = InStr( AGM.CaseCoordinates[i], "," );

			if ( j != -1 )
			{
				if ( lower(Left( AGM.CaseCoordinates[i], j )) != lower(Level.Outer.Name) )
					continue;

				j++;
				k = AGM.InStrAfter( AGM.CaseCoordinates[i], ",", j );

				if ( k != -1 )
				{
					vec.x = float( Mid( AGM.CaseCoordinates[i], j, k-j ) );

					k++;
					j = AGM.InStrAfter( AGM.CaseCoordinates[i], ",", k );

					if ( j != -1 )
					{
						vec.y = float( Mid( AGM.CaseCoordinates[i], k, j-k ) );

						j++;
						if ( len(AGM.CaseCoordinates[i]) > j )
						{
							vec.z = float( Mid( AGM.CaseCoordinates[i], j ) );

							log( "AMMod.AMSaGMod: Found CaseCoordinates for "$Level.Outer.Name$" in ini ("$vec.x@vec.y@vec.z$")" );
							return vec;
						}
					}
				}
			}
		}
	}

	foreach AllActors( class 'SwatMPStartCluster', ClusterPoint )
	{
		if ( ClusterPoint.ClusterTeam != MPT_Swat )
			continue;

		vec = ClusterPoint.Location;
		if ( !ClusterPoint.NeverFirstSpawnInSAGRound )
			break;
	}

	if ( !cannotspawn )
		log( "AMMod.AMSaGMod: Did not find CaseCoordinates for "$Level.Outer.Name$" in ini - using SWAT spawn default ("$vec.x@vec.y@vec.z$")" );
	else
		log( "AMMod.AMSaGMod: Previous case spawning coordinates for "$Level.Outer.Name$" were invalid - attempting to use SWAT spawn default ("$vec.x@vec.y@vec.z$")" );

	return vec;
}

function SpawnCase()
{
	local StaticMesh casemesh;
	local SwatMPStartCluster ClusterPoint;

	if ( SAGClass.gameItem != None )
		return;

	foreach AllActors( class 'SmashAndGrabItemBase', gameItem )
		gameItem.Destroy();

	foreach AllActors( class'SwatMPStartCluster', ClusterPoint )
	{
		ClusterPoint.UseInSmashAndGrab = ClusterPoint.UseInVIPEscort;
		ClusterPoint.NeverFirstSpawnInSAGRound = ClusterPoint.NeverFirstSpawnInVIPRound;
	}

	shouldSwitchSpawns = true;
	switchedSpawns = false;
	SwitchSpawnPoints( false );
	SpawnGoal();

    gameItem = Spawn( class'SmashAndGrabItemBase', , , GetCaseSpawnLocation(), );

	if ( gameItem == None )
	{
		if ( cannotspawn )
		{
			log( "AMMod.AMSaGMod: Could not spawn the case, destroying AMMod.AMSaGMod" );
			Destroy();
		}
		cannotspawn = true;
		return;
	}

	casemesh = StaticMesh(DynamicLoadObject("SwatGear2_sm.briefcase_dropped", class'StaticMesh'));
	gameItem.SetDrawType(DT_StaticMesh);
	gameItem.SetStaticMesh(casemesh);
	gameItem.DroppedMesh = casemesh;
	casemesh = StaticMesh(DynamicLoadObject("SwatGear2_sm.briefcase_held", class'StaticMesh'));
	gameItem.HeldMesh = casemesh;
	gameItem.StartLocation = gameItem.Location;
	gameItem.StartRotation = gameItem.Rotation;
	gameItem.Dropped(gameItem.StartLocation);

	SAGClass.gameItem = gameItem;
}

function SpawnGoal()
{
	local VIPGoalBase VIPGoal;
	local StaticMesh casemesh;
	local bool savedspawn;

	savedspawn = SpawningManager(Level.SpawningManager).HasSpawned;
	SpawningManager(Level.SpawningManager).HasSpawned = false;
	Level.SpawningManager.DoMPSpawning( SwatGameInfo(Level.Game), 'VIPGoalRoster' );
	SpawningManager(Level.SpawningManager).HasSpawned = savedspawn;

	foreach AllActors( class 'VIPGoalBase', VIPGoal )
		break;

	if ( VIPGoal == None )
		return;

	IGoal = Spawn( class'ItemGoalBase', VIPGoal.Owner, VIPGoal.tag, VIPGoal.Location, VIPGoal.Rotation );
	VIPGoal.Destroy();

	casemesh = StaticMesh(DynamicLoadObject("SWATmeshFX_sm.mpVIPexit", class'StaticMesh'));
	IGoal.SetDrawType(DT_StaticMesh);
	IGoal.SetStaticMesh(casemesh);
	IGoal.SetCollisionSize( 75, 22 );
	IGoal.SetCollision( true, false, false );
}

private function bool SuspectIsInGoal( Actor Suspect, ItemGoalBase TheGoal )
{
    local float Distance2D;
    local float CriticalDistance2D;
    local float HeightDifference;
    local float CriticalHeightDifference;

    Distance2D = VSize2D( Suspect.Location - TheGoal.Location );
    CriticalDistance2D = Suspect.CollisionRadius + TheGoal.CollisionRadius;

    HeightDifference = abs( Suspect.Location.Z - TheGoal.Location.Z );
    CriticalHeightDifference = Suspect.CollisionHeight + TheGoal.CollisionHeight;

    return Distance2D < CriticalDistance2D && HeightDifference < CriticalHeightDifference;
}

event Destroyed()
{
	if ( gameItem != None )
		gameItem.Destroy();

	if ( IGoal != None )
		IGoal.Destroy();
}

#endif