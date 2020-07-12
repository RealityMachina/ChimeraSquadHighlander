class RMHelpers extends Object config(Game);


var config array<name> AndroidLikeClassesForArmory;

// issue RM 10 - we want to use android upgrades for specific units without wanting to hook into how the rest of the game utilizes androids
// we use this function to change the check in UIArmory_MainMenu and UIArmory_AndroidUpgrades
static function bool IsLikeAndroidForArmory(XComGameState_Unit UnitState, bool IncludeAndroid = false)
{

	if(IncludeAndroid && UnitState.GetSoldierClassTemplateName() == 'SoldierClass_Android')
	{
		return true; // taken from the vanilla check
	}
	
	if(default.AndroidLikeClassesForArmory.Find(UnitState.GetSoldierClassTemplateName()) != INDEX_NONE)
	{
		return true; // this is a unit class that wants to be treated like an android
	}
	
	return false;
}
