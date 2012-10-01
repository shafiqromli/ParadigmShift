class PSCarriedObject extends UTCarriedObject;

var() int MapIndex;

var SkeletalMeshComponent KeyMesh;

singular event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	local PSPawn PSP;

	if (!ValidHolder(Other))
		return;

	PSP = PSPawn(Other);

	if(PSPlayerReplicationInfo(PSP.PlayerReplicationInfo).bHasFlag)
		return;	
	
	SetHolder(Pawn(Other).Controller);
}

state Dropped
{
	function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		ClearTimer();//this will not send flag back to a homebase
	}
}

DefaultProperties
{
	bHidden = false
	bHome=True
	bStatic=False
	NetPriority=+00003.000000
	bCollideActors=true

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0048.000000
		CollisionHeight=+0085.000000
		CollideActors=true
	End Object

	Begin Object Class=SkeletalMeshComponent Name=SkelMeshComponent0
		SkeletalMesh=SkeletalMesh'CTF_Flag_IronGuard.Mesh.S_CTF_Flag_IronGuard'
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
 	Components.Add(SkelMeshComponent0)
	KeyMesh = SkelMeshComponent0
	
}
