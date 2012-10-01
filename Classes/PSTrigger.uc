class PSTrigger extends Trigger
	placeable;

var bool bEnable;
var() int MapIndex;
var int TransitionMapIndex;

var() StaticMeshComponent TeleporterBaseMesh;
var ParticleSystemComponent PortalEffect;
var MaterialInterface PortalMaterial;
var MaterialInstanceConstant PortalMaterialInstance;
var repnotify bool bShow;

replication
{
	// Variables the server should send ALL clients.
	if( bNetDirty )
		bShow;
}

simulated event ReplicatedEvent(name VarName)
{
	if(VarName == 'bShow')
	{
		ShowPortal(bShow);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local PSPawn PSP;
	local PSPlayerReplicationInfo PSPRI;
	local PSGameReplicationInfo PSGRI;
	local PSGame Game;
	local Vector NewLoc;
	local PlayerStart Target;

	if(bEnable)
	{
		PSP = PSPawn(Other);

		PSPlayerController(PSP.Controller).AddXP(100);

		if(PSP != none)
		{
			PSPRI = PSPlayerReplicationInfo(PSP.PlayerReplicationInfo);
			PSGRI = PSGameReplicationInfo(WorldInfo.GRI);
			Game = PSGame(WorldInfo.Game);

			PSPRI.CurrentMapindex = PSGRI.CurrentMapIndex;
			
			Target = Game.ChooseTransitionPlayerStart(PSP.Controller, TransitionMapIndex, PSP.Controller.GetTeamNum());
			NewLoc = Target.Location;

			PSP.SetLocation(NewLoc);
			PSP.SetRotation(Target.Rotation);
		}

		PSP.StartTeleportCountdown();
		//WorldInfo.Game.Broadcast(self,'Teleport');
	}

}

simulated function EnablePortal()
{
	bEnable = true;
	ShowPortal(false);
}

simulated function DisablePortal()
{
	bEnable = false;
	ShowPortal(true);
}

simulated function ShowPortal(bool bNShow)
{
	bShow = bNShow;
	SetHidden(bShow);
}

DefaultProperties
{
	TransitionMapIndex = -1

	bEnable = false
	bShow = true
	bAlwaysRelevant = true

	RemoteRole=ROLE_SimulatedProxy
	NetPriority=+00002.000000
	bUpdateSimulatedPosition=true

	Components.Remove(sprite)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'Pickups.Base_Powerup.Mesh.S_Pickups_Base_Powerup01'
		Translation=(X=0.0,Y=0.0,Z=-30.0)
		CollideActors=true
		BlockActors=true
		CastShadow=true
		bCastDynamicShadow=false
		bForceDirectLightMap=true
		LightingChannels=(BSP=TRUE,Dynamic=FALSE,Static=TRUE,CompositeDynamic=TRUE)
		Scale=1.25
		BlockNonZeroExtent=false
	End Object
 	Components.Add(StaticMeshComponent0)
 	TeleporterBaseMesh=StaticMeshComponent0

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
		Translation=(X=0.0,Y=0.0,Z=-40.0)
		Template=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Base_Idle'
	End Object
	Components.Add(ParticleSystemComponent0)

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent1
		Template=ParticleSystem'Pickups.Base_Teleporter.Effects.P_Pickups_Teleporter_Idle'
	End Object
	Components.Add(ParticleSystemComponent1)
	PortalEffect=ParticleSystemComponent1
	PortalMaterial=MaterialInterface'Pickups.Base_Teleporter.Material.M_T_Pickups_Teleporter_Portal_Destination'

}
