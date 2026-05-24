-- RareTracker-SW Database (pfQuest 15/05/2026)
if not RareTrackerSW_DB then RareTrackerSW_DB = {} end
if not RareTrackerSW_Timers then RareTrackerSW_Timers = {} end

RareTrackerSW_Data = {
  ["Alterac Mountains"] = {
    ["Araga"] = { level = "35", type = "rare", respawn = "21.0 h", x = 0.39, y = 0.912, id = "14222" },
    ["Cranky Benj"] = { level = "32", type = "rare", respawn = "1.3 dias", x = 0.373, y = 0.198, id = "14223" },
    ["Gravis Slipknot"] = { level = "36", type = "rare", respawn = "5.0 h", x = 0.582, y = 0.42, id = "14221" },
    ["Jimmy the Bleeder"] = { level = "23", type = "rare", respawn = "21.0 h", x = 0.475, y = 0.824, id = "14281" },
    ["Lo\'Grosh"] = { level = "39", type = "rare", respawn = "21.0 h", x = 0.521, y = 0.469, id = "2453" },
    ["Skhowl"] = { level = "36", type = "rare", respawn = "10.5 h", x = 0.375, y = 0.685, id = "2452" },
  },
  ["Arathi Highlands"] = {
    ["Geomancer Flintdagger"] = { level = "40", type = "rare", respawn = "16.0 h", x = 0.828, y = 0.322, id = "2609" },
    ["Kovork"] = { level = "36", type = "rare", respawn = "5.0 h", x = 0.337, y = 0.441, id = "2603" },
    ["Lady Zephris"] = { level = "33", type = "rare", respawn = "5.0 h", x = 0.065, y = 0.558, id = "14277" },
    ["Molok the Crusher"] = { level = "39", type = "rare", respawn = "10.5 h", x = 0.538, y = 0.796, id = "2604" },
    ["Nimar the Slayer"] = { level = "37", type = "rare", respawn = "5.0 h", x = 0.646, y = 0.737, id = "2606" },
    ["Singer"] = { level = "34", type = "rare", respawn = "5.0 h", x = 0.323, y = 0.31, id = "2600" },
    ["Witch Doctor Tan'zo"] = { level = "35", type = "rare", respawn = "8.0 h", x = 0.55, y = 0.6, id = "61507" },
    ["Zalas Witherbark"] = { level = "40", type = "rare", respawn = "2.0 dias", x = 0.673, y = 0.809, id = "2605" },
  },
  ["Ashenvale"] = {
    ["Akkrilus"] = { level = "26", type = "rare", respawn = "21.0 h", x = 0.27, y = 0.635, id = "3773" },
    ["Alshirr Banebreath"] = { level = "54", type = "rare", respawn = "5.0 h", x = 0.391, y = 0.168, id = "14340" },
    ["Apothecary Falthis"] = { level = "22", type = "rare", respawn = "4.0 h", x = 0.326, y = 0.22, id = "3735" },
    ["Branch Snapper"] = { level = "25", type = "rare", respawn = "5.5 h", x = 0.455, y = 0.473, id = "10641" },
    ["Eck\'alom"] = { level = "27", type = "rare", respawn = "21.0 h", x = 0.528, y = 0.7, id = "10642" },
    ["Lady Vespia"] = { level = "22", type = "rare", respawn = "4.0 h", x = 0.136, y = 0.247, id = "10559" },
    ["Mist Howler"] = { level = "22", type = "rare", respawn = "8.5 h", x = 0.209, y = 0.369, id = "10644" },
    ["Mugglefin"] = { level = "23", type = "rare", respawn = "8.5 h", x = 0.194, y = 0.427, id = "10643" },
    ["Oakpaw"] = { level = "27", type = "rare", respawn = "10.5 h", x = 0.56, y = 0.628, id = "10640" },
    ["Prince Raze"] = { level = "32", type = "rare", respawn = "5.0 h", x = 0.816, y = 0.485, id = "10647" },
    ["Rorgish Jowl"] = { level = "25", type = "rare", respawn = "4.0 h", x = 0.364, y = 0.363, id = "10639" },
    ["Taerar"] = { level = "63", type = "worldboss", respawn = "—", x = 0.942, y = 0.357, id = "14890" },
    ["Terrowulf Packlord"] = { level = "32", type = "rare", respawn = "21.0 h", x = 0.497, y = 0.395, id = "3792" },
    ["Ursol\'lok"] = { level = "31", type = "rare", respawn = "10.5 h", x = 0.834, y = 0.485, id = "12037" },
  },
  ["Azshara"] = {
    ["Antilos"] = { level = "50", type = "rare", respawn = "1.3 dias", x = 0.166, y = 0.541, id = "6648" },
    ["Azuregos"] = { level = "63", type = "worldboss", respawn = "3 dias", x = 0.568, y = 0.787, id = "6109" },
    ["Gatekeeper Rageroar"] = { level = "49-50", type = "rare", respawn = "10.5 h", x = 0.383, y = 0.321, id = "6651" },
    ["General Fangferror"] = { level = "51", type = "rare", respawn = "10.5 h", x = 0.413, y = 0.54, id = "6650" },
    ["Lady Sesspira"] = { level = "51", type = "rare", respawn = "5.0 h", x = 0.354, y = 0.557, id = "6649" },
    ["Magister Hawkhelm"] = { level = "51-52", type = "rare", respawn = "21.0 h", x = 0.585, y = 0.309, id = "6647" },
    ["Master Feardred"] = { level = "51-52", type = "rare", respawn = "21.0 h", x = 0.617, y = 0.254, id = "6652" },
    ["Maws"] = { level = "63", type = "worldboss", respawn = "—", x = 0.68, y = 0.525, id = "15571" },
    ["Spirit of Azuregos"] = { level = "63", type = "worldboss", respawn = "3 min", x = 0.588, y = 0.831, id = "15481" },
    ["Tarangos"] = { level = "51", type = "rareelite", respawn = "15.0 h", x = 0.55, y = 0.45, id = "81360" },
    ["The Evalcharr"] = { level = "48", type = "rare", respawn = "1.3 dias", x = 0.179, y = 0.656, id = "8660" },
    ["Varo\'then\'s Ghost"] = { level = "48", type = "rare", respawn = "7.5 h", x = 0.132, y = 0.742, id = "6118" },
  },
  ["Badlands"] = {
    ["7:XT"] = { level = "41", type = "rare", respawn = "1.3 dias", x = 0.551, y = 0.836, id = "14224" },
    ["Broken Tooth"] = { level = "37", type = "rare", respawn = "5.0 h", x = 0.44, y = 0.384, id = "2850" },
    ["Rumbler"] = { level = "45", type = "rare", respawn = "5.0 h", x = 0.147, y = 0.893, id = "2752" },
    ["Shadowforge Commander"] = { level = "40", type = "rare", respawn = "10.5 h", x = 0.409, y = 0.291, id = "2744" },
    ["War Golem"] = { level = "36", type = "rare", respawn = "10.5 h", x = 0.524, y = 0.195, id = "2751" },
  },
  ["Blackstone Island"] = {
    ["Fareck"] = { level = "50", type = "rareelite", respawn = "5.0 h", x = 0.483, y = 0.644, id = "80130" },
  },
  ["Blasted Lands"] = {
    ["Akubar the Seer"] = { level = "54", type = "rare", respawn = "5.0 h", x = 0.513, y = 0.531, id = "8298" },
    ["Clack the Reaver"] = { level = "53", type = "rare", respawn = "10.5 h", x = 0.483, y = 0.387, id = "8301" },
    ["Deatheye"] = { level = "49", type = "rare", respawn = "21.0 h", x = 0.441, y = 0.25, id = "8302" },
    ["Dreadscorn"] = { level = "57", type = "rare", respawn = "5.0 h", x = 0.413, y = 0.387, id = "8304" },
    ["Fingat"] = { level = "43", type = "rare", respawn = "10.5 h", x = 0.714, y = 0.15, id = "14446" },
    ["Grunter"] = { level = "50", type = "rare", respawn = "1.3 dias", x = 0.561, y = 0.311, id = "8303" },
    ["Magronos the Unyielding"] = { level = "56", type = "rare", respawn = "21.0 h", x = 0.497, y = 0.405, id = "8297" },
    ["Mojo the Twisted"] = { level = "48", type = "rare", respawn = "5.0 h", x = 0.452, y = 0.16, id = "8296" },
    ["Ravage"] = { level = "51", type = "rare", respawn = "10.5 h", x = 0.611, y = 0.366, id = "8300" },
    ["Spiteflayer"] = { level = "52", type = "rare", respawn = "10.5 h", x = 0.611, y = 0.354, id = "8299" },
    ["Teremus the Devourer"] = { level = "60", type = "worldboss", respawn = "20 h", x = 0.531, y = 0.396, id = "7846" },
    ["Zareth Terrorblade"] = { level = "57", type = "rare", respawn = "15 h", x = 0.551, y = 0.592, id = "49009" },
  },
  ["Burning Steppes"] = {
    ["Blademaster Kargron"] = { level = "59", type = "rare", respawn = "10.5 h", x = 0.45, y = 0.4, id = "81365" },
    ["Deathmaw"] = { level = "53", type = "rare", respawn = "5.0 h", x = 0.866, y = 0.496, id = "10077" },
    ["Gorgon\'och"] = { level = "54", type = "rare", respawn = "21.0 h", x = 0.806, y = 0.413, id = "9604" },
    ["Gruklash"] = { level = "59", type = "rare", respawn = "5.0 h", x = 0.398, y = 0.327, id = "8979" },
    ["Hahk\'Zor"] = { level = "54", type = "rare", respawn = "10.5 h", x = 0.816, y = 0.415, id = "9602" },
    ["Malfunctioning Reaver"] = { level = "56", type = "rare", respawn = "10.5 h", x = 0.77, y = 0.27, id = "8981" },
    ["Terrorspark"] = { level = "55", type = "rare", respawn = "21.0 h", x = 0.467, y = 0.434, id = "10078" },
    ["Thauris Balgarr"] = { level = "57", type = "rare", respawn = "5.0 h", x = 0.539, y = 0.408, id = "8978" },
  },
  ["Darkshore"] = {
    ["Carnivous the Breaker"] = { level = "16", type = "rare", respawn = "2.0 h", x = 0.404, y = 0.565, id = "2186" },
    ["Firecaller Radison"] = { level = "19", type = "rare", respawn = "4.0 h", x = 0.387, y = 0.876, id = "2192" },
    ["Flagglemurk the Cruel"] = { level = "16", type = "rare", respawn = "2.0 h", x = 0.367, y = 0.676, id = "7015" },
    ["Lady Moongazer"] = { level = "17", type = "rare", respawn = "2.5 h", x = 0.429, y = 0.611, id = "2184" },
    ["Lady Vespira"] = { level = "22", type = "rare", respawn = "8.5 h", x = 0.578, y = 0.214, id = "7016" },
    ["Licillin"] = { level = "14", type = "rare", respawn = "1.5 h", x = 0.457, y = 0.364, id = "2191" },
    ["Lord Sinslayer"] = { level = "15-16", type = "rare", respawn = "1.5 h", x = 0.554, y = 0.358, id = "7017" },
    ["Shadowclaw"] = { level = "13", type = "rare", respawn = "1.5 h", x = 0.403, y = 0.405, id = "2175" },
    ["Strider Clutchmother"] = { level = "20", type = "rare", respawn = "5.5 h", x = 0.348, y = 0.873, id = "2172" },
  },
  ["Desolace"] = {
    ["Accursed Slitherblade"] = { level = "38", type = "rare", respawn = "21.0 h", x = 0.422, y = 0.19, id = "14229" },
    ["Cursed Centaur"] = { level = "43", type = "rare", respawn = "7.5 h", x = 0.305, y = 0.607, id = "11688" },
    ["Giggler"] = { level = "34", type = "rare", respawn = "10.5 h", x = 0.613, y = 0.289, id = "14228" },
    ["Hissperak"] = { level = "37", type = "rare", respawn = "10.5 h", x = 0.529, y = 0.501, id = "14227" },
    ["Kaskk"] = { level = "40", type = "rare", respawn = "1.3 dias", x = 0.512, y = 0.861, id = "14226" },
    ["Prince Kellen"] = { level = "33", type = "rare", respawn = "21.0 h", x = 0.789, y = 0.212, id = "14225" },
  },
  ["Dun Morogh"] = {
    ["Bjarn"] = { level = "12", type = "rare", respawn = "1.5 h", x = 0.556, y = 0.585, id = "1130" },
    ["Edan the Howler"] = { level = "9", type = "rare", respawn = "1.0 h", x = 0.39, y = 0.475, id = "1137" },
    ["Gibblewilt"] = { level = "11", type = "rare", respawn = "1.5 h", x = 0.274, y = 0.362, id = "8503" },
    ["Great Father Arctikus"] = { level = "11", type = "rare", respawn = "1.5 h", x = 0.228, y = 0.521, id = "1260" },
    ["Hammerspine"] = { level = "12", type = "rare", respawn = "1.5 h", x = 0.715, y = 0.512, id = "1119" },
    ["M-0L1Y"] = { level = "47", type = "rare", respawn = "15.0 h", x = 0.55, y = 0.55, id = "41295" },
    ["Timber"] = { level = "10", type = "rare", respawn = "1.0 h", x = 0.342, y = 0.418, id = "1132" },
  },
  ["Durotar"] = {
    ["Death Flayer"] = { level = "11", type = "rare", respawn = "1.5 h", x = 0.365, y = 0.497, id = "5823" },
    ["Geolord Mottle"] = { level = "9", type = "rare", respawn = "1.0 h", x = 0.438, y = 0.505, id = "5826" },
    ["Warlord Kolkanis"] = { level = "9", type = "rare", respawn = "1.0 h", x = 0.479, y = 0.774, id = "5808" },
    ["Watch Commander Zalaphil"] = { level = "9", type = "rare", respawn = "1.0 h", x = 0.599, y = 0.59, id = "5809" },
  },
  ["Duskwood"] = {
    ["Commander Felstrom"] = { level = "32", type = "rare", respawn = "5.0 h", x = 0.18, y = 0.379, id = "771" },
    ["Emeriss"] = { level = "63", type = "worldboss", respawn = "—", x = 0.454, y = 0.396, id = "14889" },
    ["Fenros"] = { level = "32", type = "rare", respawn = "5.0 h", x = 0.617, y = 0.368, id = "507" },
    ["Lord Malathrom"] = { level = "31", type = "rare", respawn = "5.0 h", x = 0.211, y = 0.272, id = "503" },
    ["Lupos"] = { level = "23", type = "rare", respawn = "4.0 h", x = 0.149, y = 0.29, id = "521" },
    ["Naraxis"] = { level = "27", type = "rare", respawn = "5.0 h", x = 0.864, y = 0.476, id = "574" },
    ["Nefaru"] = { level = "34", type = "rare", respawn = "5.0 h", x = 0.635, y = 0.837, id = "534" },
  },
  ["Dustwallow Marsh"] = {
    ["Burgle Eye"] = { level = "38", type = "rare", respawn = "5.0 h", x = 0.626, y = 0.19, id = "14230" },
    ["Darkmist Widow"] = { level = "40", type = "rare", respawn = "5.0 h", x = 0.312, y = 0.204, id = "4380" },
    ["Dart"] = { level = "38", type = "rare", respawn = "5.0 h", x = 0.481, y = 0.16, id = "14232" },
    ["Drogoth the Roamer"] = { level = "37", type = "rare", respawn = "5.0 h", x = 0.41, y = 0.219, id = "14231" },
    ["Hayoc"] = { level = "41", type = "rare", respawn = "10.6 h", x = 0.52, y = 0.629, id = "14234" },
    ["Lady Jaina Proudmoore"] = { level = "63", type = "worldboss", respawn = "1 dia", x = 0.663, y = 0.49, id = "4968", faction = "A" },
    ["Lord Angler"] = { level = "44", type = "rare", respawn = "21.0 h", x = 0.547, y = 0.634, id = "14236" },
    ["Malgin Barleybrew"] = { level = "25", type = "rare", respawn = "5.5 h", x = 0.272, y = 0.586, id = "5848" },
    ["Oozeworm"] = { level = "42", type = "rare", respawn = "1.3 dias", x = 0.369, y = 0.621, id = "14237" },
    ["Ripscale"] = { level = "39", type = "rare", respawn = "10.5 h", x = 0.492, y = 0.574, id = "14233" },
    ["The Rot"] = { level = "43", type = "rare", respawn = "21.0 h", x = 0.529, y = 0.574, id = "14235" },
  },
  ["Eastern Plaguelands"] = {
    ["Baron Bloodbane"] = { level = "59", type = "rare", respawn = "5.5 h", x = 0.394, y = 0.27, id = "10819" },
    ["Crusader Larsarius"] = { level = "60", type = "rareelite", respawn = "15.0 h", x = 0.85, y = 0.85, id = "83261" },
    ["Deathspeaker Selendre"] = { level = "56", type = "rare", respawn = "5.0 h", x = 0.857, y = 0.453, id = "10827" },
    ["Duggan Wildhammer"] = { level = "55", type = "rare", respawn = "10.5 h", x = 0.393, y = 0.705, id = "10817" },
    ["Gish the Unmoving"] = { level = "56", type = "rare", respawn = "21.0 h", x = 0.486, y = 0.414, id = "10825" },
    ["Hed\'mush the Rotting"] = { level = "57", type = "rare", respawn = "1.3 dias", x = 0.661, y = 0.502, id = "10821" },
    ["Lord Darkscythe"] = { level = "57", type = "rare", respawn = "21.0 h", x = 0.262, y = 0.328, id = "10826" },
    ["Professor Lysander"] = { level = "59", type = "rare", respawn = "10.5 h", x = 0.6, y = 0.5, id = "41060" },
    ["Ranger Lord Hawkspear"] = { level = "60", type = "rare", respawn = "5.0 h", x = 0.522, y = 0.185, id = "10824" },
    ["Warlord Thresh\'jin"] = { level = "58", type = "rare", respawn = "5.0 h", x = 0.69, y = 0.188, id = "10822" },
    ["Zul\'Brin Warpbranch"] = { level = "59", type = "rare", respawn = "10.5 h", x = 0.722, y = 0.169, id = "10823" },
  },
  ["Elwynn Forest"] = {
    ["Fedfennel"] = { level = "12", type = "rare", respawn = "1.5 h", x = 0.681, y = 0.449, id = "472" },
    ["Gruff Swiftbite"] = { level = "12", type = "rare", respawn = "1.5 h", x = 0.254, y = 0.898, id = "100" },
    ["Morgaine the Sly"] = { level = "10", type = "rare", respawn = "1.0 h", x = 0.308, y = 0.647, id = "99" },
    ["Mother Fang"] = { level = "10", type = "rare", respawn = "1.0 h", x = 0.621, y = 0.481, id = "471" },
    ["Narg the Taskmaster"] = { level = "10", type = "rare", respawn = "1.0 h", x = 0.409, y = 0.775, id = "79" },
    ["Thuros Lightfingers"] = { level = "11", type = "rare", respawn = "1.5 h", x = 0.507, y = 0.831, id = "61" },
  },
  ["Felwood"] = {
    ["Death Howl"] = { level = "49", type = "rare", respawn = "21.0 h", x = 0.5, y = 0.771, id = "14339" },
    ["Mongress"] = { level = "50", type = "rare", respawn = "1.3 dias", x = 0.421, y = 0.752, id = "14344" },
    ["Olm the Wise"] = { level = "52", type = "rare", respawn = "21.0 h", x = 0.502, y = 0.328, id = "14343" },
    ["Ragepaw"] = { level = "51", type = "rare", respawn = "5.0 h", x = 0.477, y = 0.931, id = "14342" },
    ["The Ongar"] = { level = "51", type = "rare", respawn = "1.3 dias", x = 0.422, y = 0.499, id = "14345" },
    ["Xalvic Blackclaw"] = { level = "53", type = "rare", respawn = "10.5 h", x = 0.45, y = 0.55, id = "81370" },
  },
  ["Feralas"] = {
    ["Antilus the Soarer"] = { level = "48", type = "rare", respawn = "15.0 h", x = 0.557, y = 0.74, id = "5347" },
    ["Arash-ethis"] = { level = "49", type = "rare", respawn = "5.0 h", x = 0.448, y = 0.25, id = "5349" },
    ["Bloodroar the Stalker"] = { level = "48", type = "rare", respawn = "15.0 h", x = 0.551, y = 0.578, id = "5346" },
    ["Diamond Head"] = { level = "45", type = "rare", respawn = "10.5 h", x = 0.366, y = 0.514, id = "5345" },
    ["Gnarl Leafbrother"] = { level = "44", type = "rare", respawn = "1.3 dias", x = 0.728, y = 0.584, id = "5354" },
    ["Grug'thok the Seer"] = { level = "47", type = "rareelite", respawn = "10.5 h", x = 0.55, y = 0.45, id = "81380" },
    ["Lady Szallah"] = { level = "46", type = "rare", respawn = "5.0 h", x = 0.282, y = 0.676, id = "5343" },
    ["Lethon"] = { level = "63", type = "worldboss", respawn = "—", x = 0.512, y = 0.109, id = "14888" },
    ["Old Grizzlegut"] = { level = "43", type = "rare", respawn = "1.3 dias", x = 0.595, y = 0.594, id = "5352" },
    ["Qirot"] = { level = "47", type = "rare", respawn = "5.0 h", x = 0.767, y = 0.662, id = "5350" },
    ["Snarler"] = { level = "42", type = "rare", respawn = "5.0 h", x = 0.844, y = 0.383, id = "5356" },
  },
  ["Gillijim's Isle"] = {
    ["Aquitus"] = { level = "54", type = "rare", respawn = "10.5 h", x = 0.45, y = 0.55, id = "61529" },
    ["Embereye"] = { level = "51", type = "rare", respawn = "10.5 h", x = 0.5, y = 0.5, id = "61538" },
    ["Letashaz"] = { level = "55", type = "rare", respawn = "10.5 h", x = 0.55, y = 0.45, id = "61542" },
    ["Nal'rak"] = { level = "55", type = "rareelite", respawn = "20 h", x = 0.487, y = 0.618, id = "93102" },
  },
  ["Hateforge Quarry"] = {
    ["Brood Queen Araxxna"] = { level = "40-42", type = "rare", respawn = "5.0 h", x = 0.361, y = 0.519, id = "61221" },
    ["Duskpelt Stalker"] = { level = "40-42", type = "rare", respawn = "5.0 h", x = 0.431, y = 0.358, id = "61228" },
    ["Tanovan Darkwell"] = { level = "40", type = "rare", respawn = "8.2 h", x = 0.392, y = 0.453, id = "61622" },
  },
  ["Hillsbrad Foothills"] = {
    ["Big Samras"] = { level = "27", type = "rare", respawn = "10.5 h", x = 0.86, y = 0.399, id = "14280" },
    ["Creepthess"] = { level = "24", type = "rare", respawn = "8.5 h", x = 0.386, y = 0.584, id = "14279" },
    ["Ro\'Bark"] = { level = "28", type = "rare", respawn = "5.0 h", x = 0.656, y = 0.6, id = "14278" },
    ["Scargil"] = { level = "30", type = "rare", respawn = "5.0 h", x = 0.291, y = 0.736, id = "14276" },
  },
  ["Lapidis Isle"] = {
    ["Broken Rook"] = { level = "63", type = "rareelite", respawn = "7.0 dias", x = 0.609, y = 0.303, id = "49012" },
    ["Decaying Bishop"] = { level = "63", type = "rareelite", respawn = "7.0 dias", x = 0.618, y = 0.319, id = "49013" },
    ["Magus Valgon"] = { level = "55", type = "rareelite", respawn = "20 h", x = 0.385, y = 0.665, id = "92938" },
    ["Malfunctioning Knight"] = { level = "63", type = "rareelite", respawn = "7.0 dias", x = 0.634, y = 0.351, id = "49014" },
    ["Margon the Mighty"] = { level = "55", type = "rareelite", respawn = "2.0 dias", x = 0.298, y = 0.406, id = "91839" },
    ["Ripjaw"] = { level = "51", type = "rare", respawn = "10.5 h", x = 0.45, y = 0.5, id = "61535" },
    ["Ruk'thok the Pyromancer"] = { level = "51", type = "rare", respawn = "10.5 h", x = 0.5, y = 0.4, id = "61613" },
  },
  ["Loch Modan"] = {
    ["Boss Galgosh"] = { level = "22", type = "rare", respawn = "4.0 h", x = 0.681, y = 0.659, id = "1398" },
    ["Grizlak"] = { level = "15", type = "rare", respawn = "1.5 h", x = 0.346, y = 0.271, id = "1425" },
    ["Large Loch Crocolisk"] = { level = "22", type = "rare", respawn = "5.5 h", x = 0.588, y = 0.309, id = "2476" },
    ["Lord Condar"] = { level = "16", type = "rare", respawn = "4.0 h", x = 0.777, y = 0.749, id = "14268" },
    ["Magosh"] = { level = "21", type = "rare", respawn = "4.0 h", x = 0.701, y = 0.664, id = "1399" },
    ["Shanda the Spinner"] = { level = "19", type = "rare", respawn = "4.0 h", x = 0.781, y = 0.524, id = "14266" },
  },
  ["Mulgore"] = {
    ["Enforcer Emilgund"] = { level = "11", type = "rare", respawn = "1.5 h", x = 0.404, y = 0.157, id = "5787" },
    ["Ghost Howl"] = { level = "12", type = "rare", respawn = "1.5 h", x = 0.373, y = 0.142, id = "3056" },
    ["Mazzranache"] = { level = "9", type = "rare", respawn = "2.5 h", x = 0.504, y = 0.426, id = "3068" },
    ["Snagglespear"] = { level = "9", type = "rare", respawn = "1.0 h", x = 0.484, y = 0.72, id = "5786" },
    ["The Rake"] = { level = "10", type = "rare", respawn = "2.5 h", x = 0.534, y = 0.17, id = "5807" },
  },
  ["Redridge Mountains"] = {
    ["Boulderheart"] = { level = "25", type = "rare", respawn = "8.5 h", x = 0.889, y = 0.668, id = "14273" },
    ["Chatter"] = { level = "23", type = "rare", respawn = "4.0 h", x = 0.531, y = 0.371, id = "616" },
    ["Kazon"] = { level = "27", type = "rare", respawn = "5.0 h", x = 0.359, y = 0.08, id = "584" },
    ["Ribchaser"] = { level = "17", type = "rare", respawn = "2.0 h", x = 0.161, y = 0.653, id = "14271" },
    ["Rohh the Silent"] = { level = "26", type = "rare", respawn = "10.5 h", x = 0.755, y = 0.3, id = "947" },
    ["Seeker Aqualon"] = { level = "21", type = "rare", respawn = "17.0 h", x = 0.601, y = 0.562, id = "14269" },
    ["Snarlflare"] = { level = "18", type = "rare", respawn = "2.0 h", x = 0.425, y = 0.31, id = "14272" },
    ["Squiddic"] = { level = "19", type = "rare", respawn = "2.0 h", x = 0.387, y = 0.563, id = "14270" },
  },
  ["Searing Gorge"] = {
    ["Explorer Ashbeard"] = { level = "49", type = "rare", respawn = "15 h", x = 0.714, y = 0.18, id = "49011" },
    ["Faulty War Golem"] = { level = "46", type = "rare", respawn = "10.5 h", x = 0.459, y = 0.678, id = "8279" },
    ["Rekk\'tilac"] = { level = "48", type = "rare", respawn = "21.0 h", x = 0.619, y = 0.732, id = "8277" },
    ["Scald"] = { level = "49", type = "rare", respawn = "21.0 h", x = 0.512, y = 0.468, id = "8281" },
    ["Shleipnarr"] = { level = "47", type = "rare", respawn = "1.3 dias", x = 0.586, y = 0.566, id = "8280" },
    ["Slave Master Blackheart"] = { level = "50", type = "rare", respawn = "5.0 h", x = 0.424, y = 0.231, id = "8283" },
    ["Smoldar"] = { level = "50", type = "rare", respawn = "10.5 h", x = 0.295, y = 0.624, id = "8278" },
  },
  ["Silithus"] = {
    ["Colossus of Ashi"] = { level = "63", type = "worldboss", respawn = "25 s", x = 0.451, y = 0.253, id = "15742" },
    ["Colossus of Regal"] = { level = "63", type = "worldboss", respawn = "25 s", x = 0.538, y = 0.803, id = "15741" },
    ["Colossus of Zora"] = { level = "63", type = "worldboss", respawn = "25 s", x = 0.257, y = 0.595, id = "15740" },
    ["General Rajaxx"] = { level = "63", type = "worldboss", respawn = "25 s", x = 0.291, y = 0.936, id = "15341" },
    ["Gretheer"] = { level = "57", type = "rare", respawn = "1.3 dias", x = 0.393, y = 0.554, id = "14472" },
    ["Grubthor"] = { level = "58", type = "rare", respawn = "15.0 h", x = 0.444, y = 0.808, id = "14477" },
    ["Huricanian"] = { level = "58", type = "rare", respawn = "5.0 h", x = 0.219, y = 0.167, id = "14478" },
    ["Krellack"] = { level = "56", type = "rare", respawn = "10.5 h", x = 0.632, y = 0.167, id = "14476" },
    ["Lieutenant General Nokhor"] = { level = "63", type = "worldboss", respawn = "15 min", x = 0.551, y = 0.582, id = "15818" },
    ["Qiraji Lieutenant General"] = { level = "63", type = "worldboss", respawn = "15 min", x = 0.551, y = 0.582, id = "15757" },
    ["Twilight Lord Everun"] = { level = "60", type = "rare", respawn = "5.0 h", x = 0.182, y = 0.858, id = "14479" },
  },
  ["Silverpine Forest"] = {
    ["Dalaran Spellscribe"] = { level = "21", type = "rare", respawn = "10.6 h", x = 0.635, y = 0.633, id = "1920" },
    ["Gorefang"] = { level = "13", type = "rare", respawn = "1.5 h", x = 0.595, y = 0.076, id = "12431" },
    ["Old Vicejaw"] = { level = "14", type = "rare", respawn = "1.5 h", x = 0.538, y = 0.519, id = "12432" },
    ["Ravenclaw Regent"] = { level = "22", type = "rare", respawn = "4.0 h", x = 0.576, y = 0.696, id = "2283" },
    ["Rot Hide Bruiser"] = { level = "22", type = "rare", respawn = "5.5 h", x = 0.647, y = 0.23, id = "1944" },
    ["Snarlmane"] = { level = "23", type = "rare", respawn = "4.0 h", x = 0.664, y = 0.25, id = "1948" },
  },
  ["Stonetalon Mountains"] = {
    ["Blazespark"] = { level = "24", type = "rare", respawn = "4.0 h", x = 0.55, y = 0.4, id = "61504" },
    ["Earthcaller Rezengal"] = { level = "17", type = "rare", respawn = "4.0 h", x = 0.635, y = 0.21, id = "61502" },
    ["Pridewing Patriarch"] = { level = "25", type = "rare", respawn = "4.0 h", x = 0.538, y = 0.363, id = "4015" },
    ["Vengeful Ancient"] = { level = "30", type = "rare", respawn = "5.0 h", x = 0.304, y = 0.681, id = "4030" },
  },
  ["Stranglethorn Vale"] = {
    ["Gluggle"] = { level = "37", type = "rare", respawn = "10.5 h", x = 0.333, y = 0.225, id = "14487" },
    ["Kin'Tozo"] = { level = "45", type = "rareelite", respawn = "15.0 h", x = 0.5, y = 0.6, id = "60438" },
    ["Kurmokk"] = { level = "42", type = "rare", respawn = "1.3 dias", x = 0.378, y = 0.612, id = "14491" },
    ["Lord Sakrasis"] = { level = "45", type = "rare", respawn = "5.0 h", x = 0.283, y = 0.626, id = "2541" },
    ["Rippa"] = { level = "44", type = "rare", respawn = "1.3 dias", x = 0.272, y = 0.571, id = "14490" },
    ["Roloch"] = { level = "38", type = "rare", respawn = "21.0 h", x = 0.374, y = 0.312, id = "14488" },
    ["Scale Belly"] = { level = "45", type = "rare", respawn = "5.0 h", x = 0.434, y = 0.457, id = "1552" },
    ["Verifonix"] = { level = "42", type = "rare", respawn = "21.0 h", x = 0.365, y = 0.571, id = "14492" },
  },
  ["Swamp of Sorrows"] = {
    ["Gilmorian"] = { level = "43", type = "rare", respawn = "21.0 h", x = 0.959, y = 0.644, id = "14447" },
    ["Lost One Chieftain"] = { level = "39", type = "rare", respawn = "10.5 h", x = 0.62, y = 0.212, id = "763" },
    ["Lost One Cook"] = { level = "37", type = "rare", respawn = "5.0 h", x = 0.652, y = 0.228, id = "1106" },
    ["Molt Thorn"] = { level = "42", type = "rare", respawn = "21.0 h", x = 0.233, y = 0.492, id = "14448" },
  },
  ["Tanaris"] = {
    ["Anachronos"] = { level = "63", type = "worldboss", respawn = "5 min", x = 0.652, y = 0.5, id = "15192" },
    ["Cyclok the Mad"] = { level = "48", type = "rare", respawn = "1.3 dias", x = 0.413, y = 0.547, id = "8202" },
    ["Greater Firebird"] = { level = "46", type = "rare", respawn = "21.0 h", x = 0.542, y = 0.399, id = "8207" },
    ["Haarka the Ravenous"] = { level = "50", type = "rare", respawn = "21.0 h", x = 0.562, y = 0.739, id = "8205" },
    ["Kregg Keelhaul"] = { level = "47", type = "rare", respawn = "5.0 h", x = 0.732, y = 0.487, id = "8203" },
    ["Lieutenant General Nokhor"] = { level = "63", type = "worldboss", respawn = "15 min", x = 0.335, y = 0.558, id = "15818" },
    ["Murderous Blisterpaw"] = { level = "43", type = "rare", respawn = "1.3 dias", x = 0.474, y = 0.25, id = "8208" },
    ["Omgorn the Lost"] = { level = "50", type = "rare", respawn = "10.5 h", x = 0.387, y = 0.556, id = "8201" },
    ["Qiraji Lieutenant General"] = { level = "63", type = "worldboss", respawn = "15 min", x = 0.335, y = 0.558, id = "15757" },
    ["Soriid the Devourer"] = { level = "50", type = "rare", respawn = "5.0 h", x = 0.341, y = 0.447, id = "8204" },
  },
  ["Teldrassil"] = {
    ["Blackmoss the Fetid"] = { level = "13", type = "rare", respawn = "1.5 h", x = 0.44, y = 0.302, id = "3535" },
    ["Duskstalker"] = { level = "9", type = "rare", respawn = "1.0 h", x = 0.581, y = 0.766, id = "14430" },
    ["Fury Shelda"] = { level = "8", type = "rare", respawn = "1.0 h", x = 0.348, y = 0.349, id = "14431" },
    ["Grimmaw"] = { level = "11", type = "rare", respawn = "1.5 h", x = 0.425, y = 0.795, id = "14429" },
    ["Threggil"] = { level = "6", type = "rare", respawn = "1.0 h", x = 0.514, y = 0.506, id = "14432" },
    ["Uruson"] = { level = "7", type = "rare", respawn = "1.0 h", x = 0.671, y = 0.586, id = "14428" },
  },
  ["The Barrens"] = {
    ["Azzere the Skyblade"] = { level = "25", type = "rare", respawn = "4.0 h", x = 0.448, y = 0.641, id = "5834" },
    ["Brokespear"] = { level = "17", type = "rare", respawn = "2.0 h", x = 0.571, y = 0.412, id = "5838" },
    ["Digger Flameforge"] = { level = "24", type = "rare", respawn = "4.0 h", x = 0.475, y = 0.855, id = "5849" },
    ["Dishu"] = { level = "13", type = "rare", respawn = "1.5 h", x = 0.509, y = 0.182, id = "5865" },
    ["Engineer Whirleygig"] = { level = "19", type = "rare", respawn = "2.0 h", x = 0.562, y = 0.088, id = "5836" },
    ["Foreman Grills"] = { level = "19", type = "rare", respawn = "4.0 h", x = 0.563, y = 0.082, id = "5835" },
    ["Geopriest Gukk\'rok"] = { level = "19", type = "rare", respawn = "2.0 h", x = 0.432, y = 0.521, id = "5863" },
    ["Harb Foulmountain"] = { level = "27", type = "rare", respawn = "5.0 h", x = 0.463, y = 0.968, id = "14426" },
    ["Heggin Stonewhisker"] = { level = "24", type = "rare", respawn = "4.0 h", x = 0.472, y = 0.841, id = "5847" },
    ["Rathorian"] = { level = "15", type = "rare", respawn = "1.5 h", x = 0.48, y = 0.192, id = "3470" },
    ["Silithid Harvester"] = { level = "24", type = "rare", respawn = "1.5 h", x = 0.431, y = 0.701, id = "3253" },
    ["Sludge Beast"] = { level = "19", type = "rare", respawn = "4.0 h", x = 0.564, y = 0.078, id = "3295" },
    ["Snort the Heckler"] = { level = "17", type = "rare", respawn = "2.0 h", x = 0.412, y = 0.222, id = "5829" },
    ["Stonearm"] = { level = "15", type = "rare", respawn = "1.5 h", x = 0.42, y = 0.247, id = "5837" },
    ["Thunderstomp"] = { level = "24", type = "rare", respawn = "4.0 h", x = 0.481, y = 0.798, id = "5832" },
  },
  ["The Hinterlands"] = {
    ["Ironback"] = { level = "51", type = "rare", respawn = "10.5 h", x = 0.815, y = 0.492, id = "8213" },
    ["Jal'akar"] = { level = "50", type = "rareelite", respawn = "15.0 h", x = 0.540, y = 0.342, id = "49010" },
    ["Jalinde Summerdrake"] = { level = "49", type = "rare", respawn = "5.0 h", x = 0.303, y = 0.479, id = "8214" },
    ["Old Cliff Jumper"] = { level = "42", type = "rare", respawn = "10.5 h", x = 0.119, y = 0.537, id = "8211" },
    ["Razortalon"] = { level = "44", type = "rare", respawn = "21.0 h", x = 0.371, y = 0.453, id = "8210" },
    ["Retherokk the Berserker"] = { level = "48", type = "rare", respawn = "5.0 h", x = 0.505, y = 0.641, id = "8216" },
    ["The Reak"] = { level = "49", type = "rare", respawn = "1.3 dias", x = 0.589, y = 0.431, id = "8212" },
    ["Witherheart the Stalker"] = { level = "45", type = "rare", respawn = "10.5 h", x = 0.321, y = 0.727, id = "8218" },
    ["Ysondre"] = { level = "63", type = "worldboss", respawn = "—", x = 0.624, y = 0.239, id = "14887" },
    ["Zul\'arek Hatefowler"] = { level = "43", type = "rare", respawn = "5.0 h", x = 0.324, y = 0.569, id = "8219" },
  },
  ["The Rock of Desolation"] = {
    ["Mephistroth"] = { level = "63", type = "rareelite", respawn = "1 dia", x = 0.521, y = 0.682, id = "93333" },
  },
  ["Thousand Needles"] = {
    ["Achellios the Banished"] = { level = "31", type = "rare", respawn = "5.0 h", x = 0.251, y = 0.372, id = "5933" },
    ["Gibblesnik"] = { level = "28", type = "rare", respawn = "10.5 h", x = 0.556, y = 0.504, id = "14427" },
    ["Silithid Ravager"] = { level = "36", type = "rare", respawn = "7.5 h", x = 0.684, y = 0.823, id = "4132" },
  },
  ["Tirisfal Glades"] = {
    ["Bayne"] = { level = "10", type = "rare", respawn = "1.0 h", x = 0.456, y = 0.475, id = "10356" },
    ["Deeb"] = { level = "12", type = "rare", respawn = "1.5 h", x = 0.633, y = 0.275, id = "1911" },
    ["Farmer Solliden"] = { level = "8", type = "rare", respawn = "1.0 h", x = 0.38, y = 0.496, id = "1936" },
    ["Fellicent\'s Shade"] = { level = "12", type = "rare", respawn = "1.5 h", x = 0.75, y = 0.605, id = "10358" },
    ["Graypaw Alpha"] = { level = "18", type = "rare", respawn = "3.0 h", x = 0.6, y = 0.3, id = "60492" },
    ["Lost Soul"] = { level = "6-7", type = "rare", respawn = "1.0 h", x = 0.446, y = 0.405, id = "1531" },
    ["Muad"] = { level = "10", type = "rare", respawn = "1.0 h", x = 0.365, y = 0.424, id = "1910" },
    ["Ressan the Needler"] = { level = "11", type = "rare", respawn = "1.5 h", x = 0.429, y = 0.676, id = "10357" },
    ["Shade Mage"] = { level = "17", type = "rare", respawn = "3.0 h", x = 0.55, y = 0.4, id = "61500" },
    ["Sri\'skulk"] = { level = "13", type = "rare", respawn = "1.5 h", x = 0.882, y = 0.514, id = "10359" },
    ["Tormented Spirit"] = { level = "8-9", type = "rare", respawn = "1.0 h", x = 0.456, y = 0.316, id = "1533" },
  },
  ["Western Plaguelands"] = {
    ["Foreman Marcrid"] = { level = "58", type = "rare", respawn = "21.0 h", x = 0.49, y = 0.327, id = "1844" },
    ["Foulmane"] = { level = "52", type = "rare", respawn = "10.5 h", x = 0.465, y = 0.523, id = "1847" },
    ["Lord Maldazzar"] = { level = "56", type = "rare", respawn = "5.0 h", x = 0.542, y = 0.804, id = "1848" },
    ["Scarlet Judge"] = { level = "60", type = "rare", respawn = "10.5 h", x = 0.422, y = 0.185, id = "1837" },
    ["Scarlet Smith"] = { level = "59", type = "rare", respawn = "5.0 h", x = 0.436, y = 0.129, id = "1885" },
    ["Stone Fury"] = { level = "37", type = "rare", respawn = "15.0 h", x = 0.436, y = 0.957, id = "2258" },
    ["The Husk"] = { level = "62", type = "rare", respawn = "1.3 dias", x = 0.622, y = 0.363, id = "1851" },
    ["The Wandering Knight"] = { level = "55", type = "rareelite", respawn = "12 h", x = 0.640, y = 0.732, id = "49007" },
  },
  ["Westfall"] = {
    ["Brack"] = { level = "19", type = "rare", respawn = "2.0 h", x = 0.273, y = 0.445, id = "520" },
    ["Foe Reaper 4000"] = { level = "20", type = "rare", respawn = "4.0 h", x = 0.448, y = 0.354, id = "573" },
    ["Leprithus"] = { level = "19", type = "rare", respawn = "2.0 h", x = 0.647, y = 0.667, id = "572" },
    ["Master Digger"] = { level = "15", type = "rare", respawn = "1.5 h", x = 0.465, y = 0.19, id = "1424" },
    ["Sergeant Brashclaw"] = { level = "18", type = "rare", respawn = "2.0 h", x = 0.369, y = 0.319, id = "506" },
    ["Slark"] = { level = "15", type = "rare", respawn = "1.5 h", x = 0.47, y = 0.109, id = "519" },
    ["Vultros"] = { level = "26", type = "rare", respawn = "21.0 h", x = 0.62, y = 0.755, id = "462" },
  },
  ["Wetlands"] = {
    ["Dragonmaw Battlemaster"] = { level = "30", type = "rare", respawn = "7.5 h", x = 0.43, y = 0.437, id = "1037" },
    ["Garneg Charskull"] = { level = "29", type = "rare", respawn = "5.0 h", x = 0.384, y = 0.461, id = "2108" },
    ["Gnawbone"] = { level = "24", type = "rare", respawn = "17.0 h", x = 0.301, y = 0.307, id = "14425" },
    ["Leech Widow"] = { level = "24", type = "rare", respawn = "4.0 h", x = 0.471, y = 0.615, id = "1112" },
    ["Ma\'ruk Wyrmscale"] = { level = "23", type = "rare", respawn = "4.0 h", x = 0.481, y = 0.747, id = "2090" },
    ["Mirelow"] = { level = "25", type = "rare", respawn = "8.5 h", x = 0.223, y = 0.22, id = "14424" },
    ["Prince Nazjak"] = { level = "41", type = "rare", respawn = "1.3 dias", x = 0.288, y = 0.061, id = "2779" },
    ["Razormaw Matriarch"] = { level = "31", type = "rare", respawn = "5.0 h", x = 0.699, y = 0.292, id = "1140" },
    ["Sludginn"] = { level = "30", type = "rare", respawn = "21.0 h", x = 0.126, y = 0.675, id = "14433" },
  },
  ["Winterspring"] = {
    ["Grizzle Snowpaw"] = { level = "59", type = "rare", respawn = "5.0 h", x = 0.669, y = 0.356, id = "10199" },
    ["Mallon The Moontouched"] = { level = "58", type = "rare", respawn = "10.5 h", x = 0.55, y = 0.45, id = "81375" },
    ["Mezzir the Howler"] = { level = "55", type = "rare", respawn = "5.0 h", x = 0.45, y = 0.374, id = "10197" },
    ["Rak\'shiri"] = { level = "57", type = "rare", respawn = "10.5 h", x = 0.511, y = 0.107, id = "10200" },
  },
  ["Un'Goro Crater"] = {
    ["Clutchmother Zavas"] = { level = "54", type = "rare", respawn = "10.5 h", x = 0.487, y = 0.854, id = "6582" },
    ["Ravasaur Matriarch"] = { level = "50", type = "rare", respawn = "15.0 h", x = 0.623, y = 0.659, id = "6581" },
    ["Uhk\'loc"] = { level = "52-53", type = "rare", respawn = "5.0 h", x = 0.685, y = 0.127, id = "6585" },
  },
}

-- Mulgore (Turtle WoW)
RareTrackerSW_Data["Mulgore"] = RareTrackerSW_Data["Mulgore"] or {}
RareTrackerSW_Data["Mulgore"]["Concavius"] = { level = "63", type = "rareelite", respawn = "12 h", x = 0.46, y = 0.564, id = "92213" }

-- Desolace (Turtle WoW)
RareTrackerSW_Data["Desolace"] = RareTrackerSW_Data["Desolace"] or {}
RareTrackerSW_Data["Desolace"]["Concavius"] = { level = "63", type = "rareelite", respawn = "12 h", x = 0.818, y = 0.804, id = "92213" }

-- Tanaris (Turtle WoW)
RareTrackerSW_Data["Tanaris"] = RareTrackerSW_Data["Tanaris"] or {}
RareTrackerSW_Data["Tanaris"]["Gozzo"] = { level = "60", type = "worldboss", respawn = "3 dias", x = 0.508, y = 0.266, id = "92210" }

-- Azshara (Turtle WoW)
RareTrackerSW_Data["Azshara"] = RareTrackerSW_Data["Azshara"] or {}
RareTrackerSW_Data["Azshara"]["Liang"] = { level = "60", type = "worldboss", respawn = "3 dias", x = 0.601, y = 0.717, id = "92211" }

-- The Barrens (Turtle WoW)
RareTrackerSW_Data["The Barrens"] = RareTrackerSW_Data["The Barrens"] or {}
RareTrackerSW_Data["The Barrens"]["Jabiry"] = { level = "60", type = "worldboss", respawn = "3 dias", x = 0.487, y = 0.723, id = "92212" }
RareTrackerSW_Data["The Barrens"]["Ambassador Bloodrage"] = { level = "36", type = "rareelite", respawn = "10.5 h",  x = 0.477, y = 0.907, id = "7895" }
RareTrackerSW_Data["The Barrens"]["Captain Gerogg Hammertoe"] = { level = "27", type = "rareelite", respawn = "21.0 h", x = 0.495, y = 0.839, id = "5851" }
RareTrackerSW_Data["The Barrens"]["Elder Mystic Razorsnout"] = { level = "15", type = "rareelite", respawn = "1.5 h", x = 0.592, y = 0.244, id = "3270" }

-- Gilneas (Turtle WoW)
RareTrackerSW_Data["Gilneas"] = RareTrackerSW_Data["Gilneas"] or {}
RareTrackerSW_Data["Gilneas"]["Maltimor's Prototype"] = { level = "43", type = "rare",      respawn = "8.0 h",  x = 0.55, y = 0.40, id = "61573" }

-- Tel'abim (Turtle WoW)
RareTrackerSW_Data["Tel'abim"] = RareTrackerSW_Data["Tel'abim"] or {}
RareTrackerSW_Data["Tel'abim"]["Highvale Silverback"] = { level = "58", type = "rare", respawn = "10.5 h", x = 0.55, y = 0.45, id = "61518" }

-- Scarlet Enclave (Turtle WoW)
RareTrackerSW_Data["Scarlet Enclave"] = RareTrackerSW_Data["Scarlet Enclave"] or {}
RareTrackerSW_Data["Scarlet Enclave"]["Admiral Barean Westwind"] = { level = "60", type = "rareelite", respawn = "15.0 h", x = 0.50, y = 0.50, id = "60383" }

-- Hyjal (Turtle WoW)
RareTrackerSW_Data["Hyjal"] = RareTrackerSW_Data["Hyjal"] or {}
RareTrackerSW_Data["Hyjal"]["Shadeflayer Goliath"] = { level = "61", type = "rareelite", respawn = "15.0 h", x = 0.55, y = 0.40, id = "61546" }

-- Searing Gorge (Turtle WoW)
RareTrackerSW_Data["Searing Gorge"] = RareTrackerSW_Data["Searing Gorge"] or {}
RareTrackerSW_Data["Searing Gorge"]["Scarshield Quartermaster"] = { level = "55",  type = "rareelite", respawn = "2 min",   x = 0.433, y = 0.992, id = "9046" }

RareTrackerSW_Data["Tanaris"]["Gozzo"] = { level = "60", type = "worldboss", respawn = "3 dias", x = 0.508, y = 0.266, id = "92210" }
RareTrackerSW_Data["Azshara"]["Liang"] = { level = "60", type = "worldboss", respawn = "3 dias", x = 0.601, y = 0.717, id = "92211" }
RareTrackerSW_Data["The Barrens"]["Jabiry"] = { level = "60", type = "worldboss", respawn = "3 dias", x = 0.487, y = 0.723, id = "92212" }
RareTrackerSW_Data["Blasted Lands"]["Lord Kazzak"]    = { level = "63", type = "worldboss", respawn = "3.0 dias", x = 0.356, y = 0.743, id = "12397" }