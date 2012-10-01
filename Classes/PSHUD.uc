class PSHUD extends UTTeamHUD;

function DrawXP(float X, float Y)
{	
	local string XP;
	local int XPRequire;

	XPRequire = PSPlayerController(Owner).Exp.GetXPRequiredForLevel(PSPlayerReplicationInfo(PSPlayerController(Owner).PlayerReplicationInfo).Level);

	XP = ""$(PSPlayerReplicationInfo(PSPlayerController(Owner).PlayerReplicationInfo).XPGatheredForCurrentLevel);

	//DrawGlowText(XP, X - (250 * ResolutionScale), Y -(4 * ResolutionScale), 58 * ResolutionScale, AmmoPulseTime,true);
	Canvas.SetPos(Canvas.ClipX*0.45,Canvas.ClipY*0.9);
	Canvas.DrawText("LEVEL"@PSPlayerReplicationInfo(PSPlayerController(Owner).PlayerReplicationInfo).Level);
	Canvas.SetPos(Canvas.ClipX*0.45,Canvas.ClipY*0.95);
	Canvas.DrawText(""$XP$"/"$XPRequire);	
}

function DisplayAmmo(UTWeapon Weapon)
{
	local vector2d POS;

	super.DisplayAmmo(Weapon);

	POS = ResolveHudPosition(AmmoPosition,AmmoBGCoords.UL,AmmoBGCoords.VL);

	DrawXP(POS.X,POS.Y);
}


DefaultProperties
{
}
