--[[																																																						Sci_Punk
	,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
	[ Sci_Punk's																				]
	]  _______________________       ________________________      _______________________  [
	[ /                        \    /                        \    /                       \ ]
	] |                         \   |                         \   |                       | [
	[ |      _____________       \  |      _____________       \  |      ___________      | ]
	] |.    /             \      |  |.    /             \      |  |.    /           \     | [
	[ |!    |             |      |  |!    |             |      |  |!    |           /_____\ ]
	] |!    |             |      |  |!    |             |      |  |!    |                   [
	[ |!.   |            /      /   |!.   |            /      /   |!.   |         ________  ]
	] |#!   \___________/      /    |#!   \___________/      /    |#!   |        \__      / [
	[ |#!                     /     |#!                     /     |#!   |           |     | ]
	] |#!..  _________      ./      |#!..  ________________/      |#!.. \___________|    .| [
	[ |#!!!.|         \    .!\      |#!!!.|                       |#!!!.                .!| ]
	] |##!!!|          \...!!!\     |##!!!|                       |#!!!!!!...        ...!!| [
	[ \#####/           \######\    \#####/                       \#######################/ ]
	]                                                                                       [
	[																				    Kit ]
	`````````````````````````````````````````````````````````````````````````````````````````

		UPDATE LOG:

			(August 4th, 2020 - Version 2.0)
				- Made tons of optimizations, most systems use modules now
				- Added full 3D rotation and scale support for enemy spawn regions
				- Added new default enemy types for staff and bow using enemies
				- No longer using a janky animation system, now using the Roblox animation system (you may need to read the
				"How to add a custom animation" section to add new animations with the new setup
				- Enemies now show defense above their nametag
				- Staves (staffs?) now use a boxcast system, which allows for more than one target to be damaged at once
				- Spawn regions now have independent maximum enemy values
				- Minimum and maximum values for gold, xp, and rank have been unified
				- Walkspeed and health are now read from the humanoid object of the enemy rather than a value
				- Added mobile and controller support for strong attacks
				- Bows now require arrows and staffs now require mana to use
				- The drop system now supports armor drops and various stats like "Arrows" in the player stats folder; by default,
				there are types for items, armor, and stats.
				- Health and mana potions can now be sold in shops, along with other kinds of non-weapon items
				- Added attributes; you get one point per rank. The default attributes are Vitality, Mythicality, Power, and Haste.
				Their caps are controlled by the corresponding values in ServerSettings. Vitality increases health, mythicality increases
				the mana cap, power makes strong damage more likely, and haste increases walk speed.
				- Added level cap
				- Added mana fountain to the default starter area
				- Added sound effects to the menus
				- Added a bunch of new visual effects such as xp collection and xp bar flickering
				- Added a lot of settings to ServerSettings to provide more control
				- Added a quest system! I recommend taking a look at the new default kit to get a better understand of how it works.
				To add a quest, duplicate an already existing quest to use as a template. First, modify the folder name of the quest,
				description value, and quest type values. Then, depending on the quest type, add requirements.
					- DefeatEnemies quests need NumberValues as requirements; the name of each value is the enemy name, and the value is the amount needed to defeat.
					- ObtainItems quests need models with the names of items that you need to obtain.
					- TouchOrb quests need a single ObjectValue that has the value set to an object to touch for completion. The name of the value doesn't matter.
				To add rewards, insert a folder with the name of what you want to be given, such as "Gold" or "Forest Bow" - You can specify what type
				of item you want using a StringValue inside the folder named "Type" - Default supported types are Stat, Armor, and Item.
				If your item is of type Item, then you can specify the amount using a NumberValue in the folder named "Amount"
			
		**END OF UPDATE LOG**

	**NOTE: THIS SYSTEM DOES NOT COME WITH ANTI CHEAT FOR THINGS SUCH AS TELEPORTATION, FLYING, OR OTHER RELATED CLIENT EXPLOITS**
	>ALSO: If you are working with this kit in a place that has not been published OR doesn't have studio API access, loading and
	saving will not work; this means everything will not function due to the load requirement. Please make sure that your place is
	uploaded and the studio has API access.
	>ANOTHER NOTE: Animations will not work by default! If you want to use the animations I made for the kit instead of making your
	own, you will need to use the animation editor plugin to export all of the animations in ReplicatedStorage.AnimationFiles
	and set the AnimationId values of all animations in the ReplicatedStorage.Animations folder manually.
	
	with that out of the way...
	
	Welcome to Sci_Punk's RPG Kit! Most of this kit was developed live on my Twitch channel Sci_PunkDev so feel free to
	take a look at how it was made if you are interested.
	The first thing you'll want to know is the way everything is structured. Here's a brief description of how the server side
	is organized:
	
	[RPGSystem in ServerScriptService]
	
	- Initialize utility functions for enemy AI
	  The enemy AI is determined by the EnemyType value in an enemy's Stats folder.
	- Initialize players and their items, loading and saving systems
	
	- Loop that always runs through every enemy
		+ Spawn enemies if there are less enemies than the enemy cap
		+ Run through all enemies to run AI functions such as following, attacking, and animating
	
	[Remotes in Workspace]
	Every remote can be treated individually, you probably won't need to modify these if you are just using the kit as a utility.

	[Modules in ReplicatedStorage]
	Where most game functionality is stored and ran

	//And now the client side://
	
	[RPGClient in StarterPlayerScripts]
	
	- Initialize functions and systems for an adaptive environment, item usage system, client remotes, and GUI
	- Set up renderstep function for GUI
	
	[Shop scripts]
	
	- These are automatic; to add or remove items from shops, modify the contents of the ShopItems folder
	
	That's the basic structure of the systems. Nearly everything is automated, so you don't have to know how to code to add
	simple things like new weapons or enemies. HOWEVER, new features for weapons or EnemyTypes do require some coding knowledge.
	Luckily, I have presets built in already to help if needed.
	
	The next important information is all about additions!
	
	//HOW TO ADD A WEAPON//
	
	1. You need a weapon model! This can be a mesh, meshpart, union, or even a part.
	2. You need the actual tool itself, I prefer duplicating a weapon that already exists and modifying it to fit your desires.
	3. If you're using a SpecialMesh, then you'll want to have a part called "Handle" inside of the tool and put the mesh inside of it.
	   Some of the preset weapons already have a handle. Make sure to resize the actual handle to a fitting size.
	   If you're using a Union, then all you'll need to do is name the union "Handle" and put it inside of the tool.
	   If you're using something made of parts, consider making everything one union or suffer the wrath of welds.
	4. The weapon model is done at this point, but there are specific requirements for some preset weapon types that I included just as
	   an example; for staves (plural of staff) you will need an effect inside of the handle. You can duplicate an already existing effect
	   and edit it to your liking if you wish. Bows also need this effect. However, staves need something called "Fire" as well, just like
	   an effect; this is the particle effect used for what comes out of the staff itself.
	5. If you didn't use an already existing weapon as a base, you'll need to copy all of the values inside of a weapon OF THE SAME TYPE
	   and put it inside the one you're working on. These values are what determine how the weapon functions.
	6. That's the weapon! The last step is to put it in ReplicatedStorage.Items
	**If you want to add this as a weapon drop, insert a folder in an enemy's Stats named "Drops", insert another folder in that folder
	with the name of an item in ReplcaitedStorage.Items, and then insert a NumberValue called "DropChance" inside that. This chance
	should be a number greater than zero and less than one hundred. It is a percentage**
	
	//HOW TO ADD AN ENEMY//
	
	1. You need a rig; this can be obtained with the built-in Rig Builder plugin or by duplicating an already existing enemy.
	2. Make sure the humanoid inside the rig is named "EnemyHumanoid"
	3. Make sure nothing in the enemy is anchored! (Especially the HumanoidRootPart)
	4. It needs a Stats folder! The easiest way to get one would be to duplicate one from an already existing enemy.
	5. Adjust the stats as needed. The rank value in Stats is purely visual and has no effect on the enemy itself.
	
	//HOW TO ADD AN ENEMYTYPE//
	
	This one requires at least a little bit of scripting, although you could copy an already existing EnemyType in the code and use it as
	a template.
	
	1. In ReplicatedStorage, you should find a folder named "EnemyTypes"
	2. Duplicate an already existing EnemyType and name it something new; this is by far the easiest method and would save time creating a
	bunch of values.
	3. Adjust the values as needed; for Animation values, you'll need to click on the "Value" row in the properties menu and select an
	animation in ReplicatedStorage.Animations for it to work. If you are making a custom animation, use the How-To section below.
	4. Now that you have the stats set up for your new EnemyType, enter the ReplicatedStorage.Modules.EnemyFunctions.Attacks script. 
	The follow system is automated based on your stats that you made in the last step. Make a new function in the module using the same syntax
	that the rest of the functions use, but name the function the same thing that you named your EnemyType. The "Regular" EnemyType is the default
	EnemyType I made for Goblins.
	5. With your new function for the new EnemyType, you have total control over what the enemy does when it attacks. Refer to the rest of the
	EnemyTypes that were pre-made for assistance.
	
	//HOW TO ADD A CUSTOM ANIMATION//
	
	1. Make an animation in the animation editor or find one you already made.
	2. Export it to the roblox website.
	3. Find the animation on the website and copy the id from the link to the animation. The id should be a long number.
	4. Find or create an animation object in ReplicatedStorage.Animations and paste the id into its AnimationId property.
	4b. If you want to change enemy animations for walking and idling, change their EnemyType folder values for WalkAnimation and IdleAnimation.
	4c. If you want to add or change attack animations, refer to the How-To for EnemyTypes above.
	
	//HOW TO ADD AN AREA//
	
	1. Duplicate an already existing area and give it a unique name.
	2. You can either build a new map for the area or change an already existing map. If you are making a new map, delete everything in the "Map"
	folder inside the area and put all of your beautiful new content in that folder. If you're using an already existing map, make sure to select
	the area folder and use the move tool to put it somewhere out of the way. The area will automatically unload when you aren't in it, so don't
	worry about being able to see other areas.
	**Note: You will also need a Spawn. It should already be in the folder, but you may need to move it.**
	3. Change the Music value if you wish. To add a new song for the music value, navigate to the
	SoundService.Music sound group and add a new Sound. Once you have a song inside of the folder, name it something unique, set the
	"SoundGroup" property to the Music sound group, and set the Music value of the area to that name. Make sure the "Looped" property of the song
	is set to true.
	4. You might notice a folder named LightingSettings; the values in that folder determine the lighting when you are in the area. If you want to
	set these yourself, play around with the Lighting and Lighting.ColorCorrection properties. Once you're happy with them, set all of
	the values in the LightingSettings folder to their respective properties that you just changed. You may have the studio lighting look however
	you want due to the system being automatic with adaptive lighting.
	5. SpawnRegions are bounds for enemy spawn zones. Set up the SpawnRegions; each SpawnRegion must be an anchored part with no collision. Their
	transparency is automatically set to 1 once the server has started running. Once you have some regions set up, make folders inside of each of them named
	"EnemiesToSpawnHere" and insert Models into them with enemy names that you want to spawn in that region. If that's too much, then feel free to
	duplicate an already existing SpawnRegion and use it as a template.
	6. The area is done, but you probably want a portal for it too. Duplicate an already existing portal and put it somewhere nice. Now, set the
	RequiredRank value to the Rank you want players to reach before entering; for the AreaToTeleportTo, you'll need to actually click on the area
	you want to link the portal to in the explorer after clicking on the value.
	
	//HOW TO ADD A SHOP & ITEMS//
	
	1. Duplicate an already existing shop in StarterGui.GameUI.Menus (Not the pawn shop)
	2. Name it something nice
	3. Change the Title TextLabel to something of your choice; it must represent the menu you're using.
	4. Modify the contents of the ShopItems folder. You can either copy already existing items or create new items using the following guide:
		<SHOP ITEMS>
		- Insert a folder into ShopItems and make sure the name corresponds to something in ReplicatedStorage.Items OR ReplicatedStorage.Armor
		- Inside the new item you've created, insert a StringValue named "Description" - this will serve as your item description, so set the value
		of it to something informational about the item.
		- Inside of the item, insert a StringValue named "ItemType" - the default accepted values are "Weapon" and "Armor"
		The ItemType value changes where the system looks for the item; "Weapon" looks in ReplicatedStorage.Items and "Armor" looks in
		ReplicatedStorage.Armor
		- Finally, insert a Color3Value inside the item named "TextColor" - This can be any color you want
	5. You have a new shop, but no way to open it. To do this, there is a MenuTriggers folder in workspace; this folder is full of spheres that
	open menus when you come in contact with them. They turn invisible once the server starts running. Duplicate an already existing trigger and
	move it to where you want the menu to open, feel free to resize it. Lastly, set the name of the trigger to the exact menu name you set earlier.
	
	//HOW TO ADD ARMOR//
	
	1. Duplicate an already existing HumanoidDescription in ReplicatedStorage.Armor and name it something unique
	2. Find a bundle/package in the Roblox catalog/avatar shop and scroll down to see the items included.
	3. Copy the link to the Left Leg; you'll need the number part that's embedded inside of the link. This is what you'll be setting the "LeftLeg"
	property of the armor to. Do the same thing with the links for the Left Leg, Right Arm, Right Leg, and Torso.
	4. Your armor is now a part of the system! Now to add it to a shop, duplicate an already existing shop item and name it the armor name. Set the
	ItemType of that item to "Armor"
	
--]]