class PSGameObjective extends UTGameObjective
	placeable;

var() int MapIndex;
var() int Group;

var repnotify PSCarriedObject Key;
var class<PSCarriedObject> KeyType;


function SpawnKey()
{
	if (Role < ROLE_Authority)
		return;


	Key = Spawn(KeyType,self,,Location,Rotation,,);
	Key.MapIndex = MapIndex;

	//if(Key != none)
	//	WorldInfo.Game.Broadcast(self,'Spawn at '$MapIndex);
	//if(Key == none)
	//	WorldInfo.Game.Broadcast(self,'NoKey '$Key);
}

DefaultProperties
{
	bMustBeReachable = false
	KeyType = class'PSCarriedObject'
}
