class PSPlayerReplicationInfo extends UTPlayerReplicationInfo;

var int CurrentMapindex;

var int TotalXP;
var int Level;
var int XPGatheredForCurrentLevel;

replication
{
	if(bNetOwner && bNetDirty)
		TotalXP,XPGatheredForCurrentLevel;
	if(bNetDirty)
		Level;
}

DefaultProperties
{
	NetUpdateFrequency = 3.000
}
