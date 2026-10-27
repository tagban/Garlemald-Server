-- Class paths for monster classes gamedata left empty, so they can spawn
-- (an empty classPath is fatal to the client). Monster class ids read
-- 2 / kind / family (3 digits) / variant (2 digits): a family with known
-- paths lends each class its closest-named sibling's script; the rest map
-- to the client script folder their monsters belong to. Every script named
-- here exists in the 1.23b client (client/script/.../monster).
-- Generated; only rows still empty are touched.

-- Ahriman, Akoman, Akoman's daewa, All-seeing Eye
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Ahriman/AhrimanStandard'
    WHERE classPath = '' AND id IN (2101701, 2101702, 2101704, 2101705, 2101706, 2101708, 2101709, 2101710, 2101711, 2101712, 2101713, 2101714, 2101715, 2201701, 2201702, 2201703, 2201704, 2201705, 2201706, 2201707, 2201708, 2301701, 2301702);

-- Apkallu, Fledgling apkallu
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Apkallu/ApkalluStandard'
    WHERE classPath = '' AND id IN (2102902, 2102905, 2102906, 2102907, 2102908, 2202901, 2202902);

-- Ajattara, Basilisk, Butcher basilisk, Desert peiste
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Basilisk/BasiliskStandard'
    WHERE classPath = '' AND id IN (2100702, 2100703, 2100704, 2100706, 2100707, 2100708, 2100710, 2100711, 2100712, 2100714, 2100715, 2100716, 2100718, 2100719, 2100720, 2100721, 2100722, 2200701, 2200702, 2200703, 2200704, 2200705, 2200706, 2200707, 2200708, 2200709, 2200710, 2200711, 2300701, 2300702);

-- Bat, Befuddled bat, Black bat, Cave bat
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Bat/BatNormalStandard'
    WHERE classPath = '' AND id IN (2104101, 2104104, 2104105, 2104106, 2104107, 2104109, 2104110, 2104111, 2104112, 2104113, 2204101, 2204102, 2204103, 2204104, 2204105, 2204106, 2204107, 2204108, 2204109, 2304101);

-- Blood-eyed buzzard, Buzzard, Canyon condor, Chasm condor
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Bird/BirdNormalStandard'
    WHERE classPath = '' AND id IN (2101201, 2101202, 2101203, 2101204, 2101205, 2101206, 2101207, 2101208, 2101209, 2101210, 2101211, 2101212, 2101213, 2101214, 2201201, 2201202, 2201203, 2201204, 2201205, 2201206, 2201207, 2201208, 2201209);

-- Cellar puk, Curious pteroc, Deepground puk, Ill-tempered pteroc
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Bird/BirdStandard'
    WHERE classPath = '' AND id IN (2100101, 2100102, 2100103, 2100104, 2100105, 2100106, 2100107, 2100108, 2100109, 2100110, 2100111, 2100112, 2100113, 2100114, 2100115, 2100116, 2100117, 2100118, 2100119, 2100120, 2100121, 2200101, 2200102, 2200103, 2200104, 2200105, 2200106, 2200107, 2200108, 2200109, 2200110, 2200111, 2200112, 2200113, 2200114, 2300101);

-- Headsman's Axe, Headsman's Hex, Headsman's Lance, Ixali boldwing
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Birdman/BirdmanStandard'
    WHERE classPath = '' AND id IN (2106401, 2106402, 2106403, 2106404, 2106405, 2106406, 2106407, 2106408, 2106409, 2106410, 2106411, 2106412, 2106413, 2106414, 2106415, 2106416, 2106417, 2106418, 2106419, 2106420, 2106421, 2106422, 2106423, 2106424, 2106425, 2106426, 2106427, 2106428, 2106429, 2106430, 2106431, 2106432, 2106433, 2106434, 2106435, 2106436, 2106437, 2106438, 2106439, 2106440, 2106441, 2106442, 2106443, 2106444, 2106445, 2106446, 2106447, 2106448, 2106449, 2106450, 2106451, 2106452, 2106453, 2106454, 2106455, 2106456, 2106457, 2106458, 2106459, 2106460, 2106461, 2106462, 2106463, 2106464, 2106465, 2106466, 2106467, 2106468, 2106469, 2106470, 2106471, 2106472, 2106473, 2206401, 2206402, 2206403, 2206404, 2206405, 2206406, 2206407, 2206408, 2206409, 2206410, 2206411, 2206412, 2206413, 2206414, 2206415, 2206416, 2206417, 2206418, 2206419, 2206420, 2206421, 2206422, 2206423, 2206424, 2206425, 2206426, 2206427, 2206428, 2206429, 2206430, 2206431, 2206432, 2206433, 2206434, 2206435, 2206436, 2206437, 2206438, 2206439);

-- Boar, Buata, Eurylochus, Hog
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Boar/BoarStandard'
    WHERE classPath = '' AND id IN (2101502, 2101504, 2101506, 2101510, 2101511, 2101512, 2101513, 2101514, 2101515, 2201501, 2201502, 2201503, 2201504, 2201505, 2201506, 2201507);

-- Acid bomb, Balloon, Bomb, Bomb baron
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Bomb/BombNormalStandard'
    WHERE classPath = '' AND id IN (2101601, 2101602, 2101603, 2101606, 2101609, 2101610, 2101611, 2101612, 2101613, 2201601, 2201602, 2201603, 2201604, 2201605, 2201606, 2201607, 2201608, 2201609, 2201610, 2201611, 2201612, 2301601);

-- Bark weevil, Weevil, Wood weevil
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Bug/BugStandard'
    WHERE classPath = '' AND id IN (2203901, 2203902, 2203907);

-- Babe snatcher, Carrier ladybug, Gorgebug, Ladybug
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Bug/LadyBugStandard'
    WHERE classPath = '' AND id IN (2203903, 2203904, 2203905, 2203906, 2203908);

-- Desert rose
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Cactus/CactusFlowerStandard'
    WHERE classPath = '' AND id IN (2100913);

-- Cactuar, Cactuar Jaques, Common cactuar, Frightened cactuar
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Cactus/CactusLesserStandard'
    WHERE classPath = '' AND id IN (2100911, 2200901, 2200902, 2200906, 2200907);

-- Sabotender, Sabotender alegre, Sabotender desertor
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Cactus/CactusNormalStandard'
    WHERE classPath = '' AND id IN (2100912, 2200903, 2200904, 2200905, 2200909, 2300901);

-- Buzzing djigga, Carrion chiglet, Carrion chigoe, Chiglet
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Chigoe/ChigoeLesserStandard'
    WHERE classPath = '' AND id IN (2105601, 2105602, 2105604, 2105605, 2105606, 2105608, 2105609, 2105610, 2105611, 2105613, 2105614, 2205601, 2205602, 2205604, 2205605, 2205606, 2205607, 2205608, 2205609, 2205610, 2205611, 2205612, 2205613, 2205614, 2305601);

-- Coeurl, Fang, Lone coeurl, Lynx
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Coeurl/CoeurlLesserStandard'
    WHERE classPath = '' AND id IN (2103201, 2103202, 2103203, 2203201, 2203202, 2203203, 2203204);

-- Thickshell
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Crab/CrabLesserStandard'
    WHERE classPath = '' AND id IN (2107605);

-- Arbor bee swarm, Bee cloud, Bee swarm, Dung midge swarm
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Crowd/CrowdBeeStandard'
    WHERE classPath = '' AND id IN (2105301, 2105302, 2105303, 2105304, 2105305, 2105306, 2105307, 2105308, 2105309, 2105310, 2105311, 2105312, 2105313, 2105314, 2105315, 2205301, 2205302, 2205303, 2205304, 2205305, 2205306, 2205307, 2205308, 2205309, 2205310, 2205311, 2305301);

-- Cadaverous cockatrice, Clever dodo, Cockatrice, Dodo
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Dodo/DodoLesserStandard'
    WHERE classPath = '' AND id IN (2102002, 2102004, 2102006, 2102007, 2102008, 2102011, 2102012, 2102013, 2102014, 2102015, 2102016, 2102017, 2102018, 2202001, 2202002, 2202003, 2202004, 2202005, 2202006, 2202007, 2202008, 2202009, 2202010, 2202011, 2202012, 2202013);

-- Earth elemental, Earth homunculus, Earthbound wrath
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Elemental/EarthelementalStandard'
    WHERE classPath = '' AND id IN (2104901, 2104902, 2104903, 2104904, 2104905, 2104906, 2104907, 2104908, 2204901, 2204902, 2204903, 2204904, 2204905, 2204906, 2204907);

-- Elemental, Spirit of the wood, Water elemental, Woodsent elemental
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Elemental/ElementalStandard'
    WHERE classPath = '' AND id IN (2105101, 2105102, 2105103, 2105104, 2105105, 2105106, 2105201, 2205101, 2205102, 2205103, 2205104, 2205105, 2205106, 2205107, 2205201, 2205202, 2205203);

-- Fire elemental, Fire homunculus, Firebound wrath, Woodsent elemental
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Elemental/FireelementalStandard'
    WHERE classPath = '' AND id IN (2104601, 2104602, 2104603, 2104604, 2104605, 2104606, 2104607, 2204601, 2204602, 2204603, 2204604, 2204605, 2204606, 2204607, 2204608, 2204609, 2204610);

-- Ice elemental, Icebound wrath
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Elemental/IceelementalStandard'
    WHERE classPath = '' AND id IN (2104701, 2104702, 2104703, 2104704, 2104705, 2104706, 2204701, 2204702, 2204703, 2204704, 2204705, 2204706, 2204707);

-- Lightning elemental
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Elemental/LightningelementalStandard'
    WHERE classPath = '' AND id IN (2105001, 2105002, 2105003, 2105004, 2105005, 2105006, 2205001, 2205002, 2205003, 2205004, 2205005, 2205006, 2205007);

-- Wind elemental
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Elemental/WindelementalStandard'
    WHERE classPath = '' AND id IN (2104801, 2104802, 2104803, 2104804, 2104805, 2104806, 2204801, 2204802, 2204803, 2204804, 2204805, 2204806, 2204807);

-- Imperial centurion, Imperial guy, Imperial pilus prior, Imperial primus ordinarius
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Empire/EmpireChiefStandard'
    WHERE classPath = '' AND id IN (2107002, 2107003, 2107004, 2207001, 2207003, 2207004, 2207005, 2207006, 2207007, 2207008, 2207009, 2307001, 2307002);

-- Elite bestiarius, Elite eques, Elite funditor, Elite hoplomachus
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Empire/EmpireStandard'
    WHERE classPath = '' AND id IN (2180001, 2180002, 2180003, 2180004, 2180005, 2180006, 2180007, 2180008, 2180009, 2180010, 2180011, 2180012, 2180013, 2180014, 2180015, 2180016, 2180017, 2180018, 2180019, 2180020, 2180021, 2180022, 2180023, 2180024, 2180025, 2180026, 2180027, 2180028, 2180029, 2180030, 2180031, 2180032, 2180033, 2180034, 2180035, 2180036, 2180037, 2180038, 2180039, 2280001, 2280002, 2280003, 2280004, 2280005, 2280006, 2280007, 2280008, 2280009, 2280010, 2280011, 2280012, 2280013, 2280014, 2280015, 2280016, 2280017, 2280018, 2280019, 2280020, 2280021, 2280022, 2280023, 2280024, 2280025, 2280026, 2280027, 2280028, 2280029, 2280030, 2280031, 2280032, 2280033, 2280034, 2280035, 2280036, 2280037, 2280038, 2280039, 2280040, 2280041, 2280042, 2280043, 2280044, 2280045, 2280046, 2280047, 2280048, 2280049, 2280050, 2280051, 2280052, 2280053, 2280054, 2280055, 2280056, 2280057, 2280058, 2280059, 2280060, 2280061, 2280062, 2280063, 2280064, 2280065, 2280066, 2280067, 2280068, 2280069, 2280070, 2380001, 2380002, 2380003, 2380004, 2380005, 2380006, 2380007, 2380008);

-- Evenfall firefly, Firefly, Flickering firefly, Pharosfly
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Firefly/FireflyNormalStandard'
    WHERE classPath = '' AND id IN (2105804, 2105805, 2205801, 2205802, 2205803, 2205804, 2205805);

-- Deepvoid sludge, Figgy pudding, Flan, Petit pudding
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Flan/FlanLesserStandard'
    WHERE classPath = '' AND id IN (2103401, 2103402, 2103403, 2103404, 2103405, 2103406, 2203401, 2203402, 2203403, 2203404, 2203405, 2203406, 2203407, 2203408, 2203409, 2203410, 2203411, 2203412, 2303401);

-- Landtrap, Poison flytrap, Toxic flytrap
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Flower/FlowerPoisonousStandard'
    WHERE classPath = '' AND id IN (2202705, 2202706, 2202708, 2202710);

-- Aloes rosetrap, Alpha roseling, Deadly nightshade, Forest roseling
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Flower/FlowerStandard'
    WHERE classPath = '' AND id IN (2202701, 2202702, 2202703, 2202704, 2202707, 2202709, 2202711, 2202712, 2202713, 2202714, 2202715, 2302701, 2302702, 2302703, 2302704, 2302705);

-- Alpha gnat, Bile gnat, Dung gnat, Gall gnat
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Fly/FlyStandard'
    WHERE classPath = '' AND id IN (2100601, 2100602, 2100603, 2100604, 2100605, 2100606, 2100607, 2100608, 2100609, 2100610, 2100611, 2100612, 2100613, 2100614, 2100615, 2200601, 2200602, 2200603, 2200604, 2200605, 2200606, 2200607, 2200608, 2200609, 2200610, 2200611);

-- Eftstool, Faerie funguar, Forest funguar, Fumbling funguar
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Funguar/FunguarLesserStandard'
    WHERE classPath = '' AND id IN (2105902, 2105904, 2105906, 2105907, 2105908, 2105909, 2105910, 2105911, 2105912, 2105913, 2105914, 2105916, 2105917, 2105918, 2105919, 2205901, 2205902, 2205903, 2205904, 2205905, 2205906, 2205907, 2205908, 2205909, 2305901);

-- Baraquel, Barbatos, Batraal, Deepvoid butcher
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Gargoyle/GargoyleNormalStandard'
    WHERE classPath = '' AND id IN (2103501, 2103502, 2103503, 2103504, 2103505, 2203501, 2203502, 2203503, 2203504, 2203505, 2303501);

-- Alpha toad, Bone nix, Dreamtoad, Gigantoad
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Gigantoad/GigantoadStandard'
    WHERE classPath = '' AND id IN (2103102, 2103104, 2103105, 2103106, 2103107, 2103108, 2103109, 2103110, 2103111, 2103112, 2103113, 2103114, 2103115, 2203101, 2203102, 2203103, 2203104, 2203105, 2203106, 2203107, 2303101, 2303102);

-- 11th Order Patriarch Gu Bu, 59th Order Matriarch Go Zu, Go Zu's sword bearer, Kobold
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Gnole/GnoleStandard'
    WHERE classPath = '' AND id IN (2106601, 2106602, 2106603, 2106604, 2106605, 2106606, 2106607, 2106608, 2106609, 2106610, 2106611, 2106612, 2106613, 2106614, 2106615, 2106616, 2106617, 2106618, 2106619, 2106620, 2106621, 2106622, 2106623, 2106624, 2106625, 2106626, 2106627, 2106628, 2106629, 2106630, 2106631, 2106632, 2106633, 2106634, 2106635, 2106636, 2106637, 2106638, 2106639, 2106640, 2106641, 2106642, 2106643, 2106644, 2106645, 2106646, 2106647, 2106648, 2106649, 2106650, 2106651, 2106652, 2106653, 2106654, 2106655, 2106656, 2106657, 2106658, 2106659, 2106660, 2106661, 2106662, 2106663, 2106664, 2106665, 2106666, 2206601, 2206602, 2206603, 2206604, 2206605, 2206606, 2206607, 2206608, 2206609, 2206610, 2206611, 2206612, 2206613, 2206614, 2206615, 2206616, 2206617, 2206618, 2206619, 2206620, 2206621, 2206622, 2206623, 2206624, 2206625, 2206626, 2206627, 2206628, 2206629);

-- Goblin, Goblin bouncer, Goblin braggadocio, Goblin bushwhacker
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Goblin/GoblinBommerGlaStandard'
    WHERE classPath = '' AND id IN (2110301, 2110302, 2110303, 2110304, 2110306, 2110307, 2110310, 2110313, 2110314, 2210301, 2210302, 2210303);

-- Clay golem, Golem, Lunar golem, Number 126
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Golem/GolemLesserStandard'
    WHERE classPath = '' AND id IN (2108901, 2108902, 2108903, 2108904, 2208901, 2208902, 2208903, 2208904, 2208905, 2208906, 2208907, 2208908);

-- Elder goobbue, Goobbue, Siege goobbue
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Goobbue/GoobbueLesserStandard'
    WHERE classPath = '' AND id IN (2103301, 2103304, 2103305, 2103306, 2103307, 2203302, 2203303);

-- Cloud hippocerf, Downcast hippocerf, Hippocerf, Hippogryph
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Griffin/GriffinStandard'
    WHERE classPath = '' AND id IN (2100401, 2100402, 2100403, 2100404, 2100405, 2100406, 2100407, 2100408, 2100409, 2100410, 2100411, 2100412, 2100413, 2200401, 2200402, 2200403, 2200404, 2200405, 2200406, 2200407, 2300401);

-- Ifrit, Infernal nail
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Ifrit/IfritNormal'
    WHERE classPath = '' AND id IN (2107301, 2107302, 2107303, 2207301, 2207302, 2207304, 2207306, 2207307, 2207308, 2207309, 2207311, 2207312, 2207313, 2207314, 2207315);

-- Alpha imp, Alux, Darkeye devilet, Darkwing devilet
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Imp/ImpStandard'
    WHERE classPath = '' AND id IN (2102601, 2102602, 2102603, 2102604, 2102605, 2102606, 2102607, 2102608, 2102609, 2102610, 2102611, 2102612, 2102613, 2202601, 2202602, 2202603, 2202604, 2202605, 2202606, 2202607, 2202608, 2202609, 2202610, 2202611);

-- Agitated aurelia, Anemone, Aurelia, Carnivorous cassiopeia
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Jellyfish/JellyfishScenarioLimsaLv00'
    WHERE classPath = '' AND id IN (2105401, 2105402, 2105406, 2105407, 2105410, 2105411, 2105412, 2105413, 2105414, 2105415, 2105416, 2205401, 2205402, 2205404, 2205405, 2205406, 2205407, 2205408, 2205409, 2205410, 2205411, 2305401);

-- Bloated burble, Burble, Murble, Phurble
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Kesaranpasaran/KesaranpasaranStandard'
    WHERE classPath = '' AND id IN (2104401, 2104402, 2104403, 2104404, 2104405, 2104406, 2104407, 2204401, 2204402, 2204403, 2204404);

-- Bixie, Chimera
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Khimaira/KhimairaNormalStandard'
    WHERE classPath = '' AND id IN (2108701, 2108702, 2208701, 2308701);

-- Imperial juggernaut
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Killermachine/KillermachineLesserStandard'
    WHERE classPath = '' AND id IN (2102401, 2202401, 2202402);

-- Magitek vanguard, Magitek vanguard F-I, Magitek vanguard H-I
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Killermachine/KillermachineNormalStandard'
    WHERE classPath = '' AND id IN (2109001, 2109002, 2109003, 2109004, 2109005, 2109006, 2209001, 2209002, 2209003, 2209004, 2209005);

-- Audhumbla, Bison, Great buffalo, Greater buffalo
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Kujata/KujataHornedStandard'
    WHERE classPath = '' AND id IN (2100801, 2100802, 2100803, 2100804, 2200801, 2200802, 2200803, 2200804);

-- Dire dormouse, Dormouse, Drunken dormouse
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Lemming/GlirulusStandard'
    WHERE classPath = '' AND id IN (2204012, 2204013, 2204014, 2204015, 2204016, 2204017, 2204021, 2204025);

-- Forest familiar, Lord of Swiftperch, Marmot, Mickle mouse
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Lemming/HareStandard'
    WHERE classPath = '' AND id IN (2104008, 2204004, 2204008, 2204009, 2204011, 2204020, 2204022, 2204023, 2204024, 2204026, 2204027);

-- Tower lemming
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Lemming/LemmingScenarioMrdLv20'
    WHERE classPath = '' AND id IN (2204003);

-- Pack rat, Plague rat, Rat
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Lemming/LemmingStandard'
    WHERE classPath = '' AND id IN (2204001, 2204002, 2204018);

-- Nutbreaker squirrel, Nutcracker squirrel, Squirrel
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Lemming/NuteaterStandard'
    WHERE classPath = '' AND id IN (2204006, 2204007, 2204019);

-- Ashkin walker, Dapper cadaver, Deepvoid pikeman, Deepvoid wizard
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Livingdead/LivingdeadStandard'
    WHERE classPath = '' AND id IN (2101801, 2101802, 2101803, 2101804, 2101805, 2101806, 2101807, 2101808, 2101809, 2101810, 2101811, 2101812, 2101813, 2101814, 2101815, 2101816, 2101817, 2101818, 2101819, 2101820, 2101821, 2101822, 2201801, 2201802, 2201803, 2201804, 2201805, 2201806, 2201807, 2201808, 2201809, 2201810, 2201811);

-- Amalj'aa, Amalj'aa archer, Amalj'aa augur, Amalj'aa bowyer
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Lizardman/LizardmanPugilistStandard'
    WHERE classPath = '' AND id IN (2106509, 2106510, 2106511, 2106512, 2106513, 2106514, 2106516, 2106517, 2106518, 2106519, 2106520, 2106521, 2106522, 2106523, 2106524, 2106525, 2106526, 2106527, 2106528, 2106529, 2106530, 2106531, 2106532, 2106533, 2106534, 2106535, 2106536, 2106538, 2106539, 2106540, 2106542, 2206501, 2206502, 2206503, 2206504, 2206505, 2206506, 2206507, 2206508, 2206509, 2206510, 2206511, 2206512, 2206513, 2206514, 2206515, 2206516, 2206517, 2206518, 2206519, 2206520, 2206521, 2206522, 2206523, 2206524, 2206525, 2206526, 2206527, 2206528, 2206529, 2206530, 2206531, 2206532, 2206533, 2206534, 2206535, 2206536, 2206537, 2206538, 2206539, 2206540, 2206541, 2206542, 2206543, 2206544, 2206545, 2206546, 2206547);

-- Bog yarzon, Cave yarzon, Cliff yarzon, Coliseum yarzon
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Longlegs/LonglegsStandard'
    WHERE classPath = '' AND id IN (2105501, 2105502, 2105503, 2105504, 2105505, 2105506, 2105507, 2105508, 2105509, 2105510, 2105511, 2105512, 2105513, 2105514, 2105515, 2105516, 2105517, 2105518, 2105519, 2105520, 2105521, 2205501, 2205502, 2205503, 2205504, 2205505, 2205506, 2205507, 2205508, 2205509, 2205510, 2205511, 2205512, 2205513, 2205514, 2205515, 2205516, 2205517, 2205518, 2205519, 2205520, 2205521);

-- Bandicoot, Diamond-tooth hedgemole, Drybone shrew, Hedgeless hedgemole
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Mole/MoleMoleStandard'
    WHERE classPath = '' AND id IN (2105704, 2105706, 2105709, 2105710, 2105712, 2105714, 2105716, 2105718, 2105719, 2105720, 2105722, 2105723, 2105724, 2105725, 2105726, 2205701, 2205702, 2205703, 2205704, 2205705, 2205706, 2205707, 2205708, 2205709, 2205710, 2205711, 2205712, 2305701);

-- Curious galago, Frightened lemur, Galago, Leaping lemur
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Monkey/MonkeyLesserStandard'
    WHERE classPath = '' AND id IN (2100503, 2100504, 2100506, 2100508, 2100511, 2100512, 2100513, 2100514, 2100515, 2100517, 2100518, 2100519, 2200501, 2200502, 2200503, 2200504, 2200505, 2200506, 2200507, 2200508, 2200509, 2200510, 2200511);

-- Capricious Cassie, Creeping ivy, Miser's Mistress, Morbol
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Morbol/MorbolStandard'
    WHERE classPath = '' AND id IN (2101002, 2101003, 2101004, 2101005, 2101006, 2101007, 2101008, 2101009, 2101010, 2101011, 2201001, 2201002, 2301001);

-- Aetherbound slave, Deepvoid slave, Manipulated ogre, Ogre
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Ogre/OgreLesserStandard'
    WHERE classPath = '' AND id IN (2102505, 2102506, 2102507, 2102508, 2202501, 2202502, 2202503, 2202504, 2202505, 2302501);

-- Arges, Brontes, Coincounter, Steropes
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Ogre/OgreR0D1Raid01'
    WHERE classPath = '' AND id IN (2210701, 2210702, 2210703, 2310701);

-- Angry lead coblyn, Carbonized coblyn, Cavernulous coblyn, Chitinous coblyn
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Orebeetle/OrebeetleLesserStandard'
    WHERE classPath = '' AND id IN (2102102, 2102104, 2102105, 2102106, 2102107, 2102108, 2102110, 2102111, 2102112, 2102113, 2102114, 2102115, 2102116, 2102117, 2102118, 2102119, 2102120, 2102121, 2102122, 2102123, 2102124, 2102125, 2102126, 2102128, 2102129, 2202101, 2202102, 2202103, 2202104, 2202105, 2202106, 2202107, 2202108, 2202109, 2202110, 2202111, 2202112, 2202113, 2202114, 2202115, 2302101);

-- Bloated bogy, Bloody revenant, Bogy, Brine bogy
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Petitghost/PetitghostLesserStandard'
    WHERE classPath = '' AND id IN (2104301, 2104302, 2104303, 2104304, 2104305, 2104307, 2104308, 2104309, 2104310, 2104311, 2104312, 2104313, 2104314, 2104315, 2104316, 2104317, 2104318, 2104319, 2104320, 2104321, 2104322, 2104323, 2104324, 2104325, 2104326, 2104327, 2104328, 2104329, 2204301, 2204302, 2204303, 2204304, 2204305, 2204306, 2204307, 2204308, 2204309, 2204310, 2204311, 2204312, 2204313, 2204314, 2204315, 2204316, 2204317, 2204318, 2304301, 2304302, 2304303, 2304304);

-- Alpgrot orobon, Angler, Big-bellied orobon, Bigmouth orobon
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Piranha/PiranhaSandyStandard'
    WHERE classPath = '' AND id IN (2104502, 2104505, 2104506, 2104507, 2104509, 2104510, 2104511, 2104512, 2104513, 2104514, 2104515, 2104516, 2104517, 2204501, 2204503, 2204504, 2204505, 2204506, 2204507, 2204508, 2204509, 2204510, 2204511, 2304501);

-- Bilge-soaked buccaneer, Black Crow archer, Black Crow cleaver, Black Crow swashbuckler
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Pirate/PirateStandard'
    WHERE classPath = '' AND id IN (2180201, 2180202, 2180203, 2180204, 2180205, 2180206, 2180207, 2180208, 2180209, 2180210, 2180211, 2180212, 2180213, 2180215, 2180216, 2180218, 2180219, 2280201, 2280202, 2280203, 2280204, 2280205, 2280206, 2280207, 2280208, 2280209, 2280210, 2280211, 2280212, 2280213, 2280214, 2280215, 2280216, 2280217, 2280218, 2280219, 2280220, 2280221, 2280222, 2280223, 2280224, 2280225);

-- Blue dewflower sylph, Delinquent sylph, Green dewflower sylph, Red dewflower sylph
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Pixie/PixieStandard'
    WHERE classPath = '' AND id IN (2106701, 2106702, 2106703, 2106704, 2106705, 2106706, 2106707, 2106708, 2106709, 2106710, 2106711, 2106712, 2106713, 2106714, 2106715, 2106716, 2106717, 2106718, 2106719, 2106720, 2106721, 2106722, 2106723, 2106724, 2106725, 2106726, 2106727, 2106728, 2106729, 2106730, 2106731, 2206701, 2206702, 2206703, 2206704, 2206705, 2206706, 2206707, 2206708, 2206709, 2206710, 2206711, 2206712, 2206713, 2206714, 2206715);

-- Kikkiroon Irongut, Kokoroon Quickfingers, Longnose Gnognoroon, Qiqirn
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Qiqirn/QiqirnStandard'
    WHERE classPath = '' AND id IN (2106302, 2106303, 2106307, 2106308, 2106309, 2106310, 2106311, 2106312, 2206301, 2206302, 2206303, 2206304, 2206305, 2206306);

-- Anole, Anole familiar, Anole stalker, Grass raptor
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Raptor/RaptorStandard'
    WHERE classPath = '' AND id IN (2100201, 2100202, 2100204, 2100206, 2100208, 2100209, 2100210, 2100212, 2100213, 2100214, 2100215, 2200201, 2200202, 2200203, 2200204, 2200205, 2200206, 2200207, 2200208);

-- Alpha eft, Black eft, Blind eft, Bloodshore eft
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Salamander/SalamanderStandard'
    WHERE classPath = '' AND id IN (2101301, 2101302, 2101303, 2101306, 2101308, 2101309, 2101310, 2101312, 2101314, 2101315, 2101316, 2101319, 2101320, 2101321, 2101322, 2101323, 2201301, 2201302, 2201303, 2201304, 2201305, 2201306, 2201307, 2201308, 2201309, 2301301);

-- Ashdrake, Banescale guivre, Battle drake, Biast
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Scalelizard/ScalelizardStandard'
    WHERE classPath = '' AND id IN (2102201, 2102202, 2102203, 2102204, 2102205, 2102206, 2102207, 2102208, 2102209, 2102210, 2102211, 2102212, 2102213, 2102214, 2102215, 2102216, 2102217, 2102218, 2102219, 2102220, 2102221, 2102222, 2102223, 2102224, 2102225, 2102226, 2102227, 2102228, 2202201, 2202202, 2202203, 2202204, 2202205, 2202206, 2202207, 2202208, 2202209, 2302201);

-- Antelope doe, Antelope stag, Doe, Fevered doe
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Serow/SerowFemaleStandard'
    WHERE classPath = '' AND id IN (2100302, 2100303, 2100304, 2100306, 2100308, 2100310, 2100311, 2100312, 2100313, 2100314, 2100316, 2100317, 2200301, 2200302, 2200303, 2200304, 2200305, 2200306, 2200307, 2200308, 2200309, 2200313, 2200314);

-- Brutal karakul ewe, Brutal karakul ram, Downy Dunstan, Karakul
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Sheep/SheepStandard'
    WHERE classPath = '' AND id IN (2106001, 2106004, 2106005, 2106006, 2106007, 2106008, 2106010, 2106012, 2106013, 2106014, 2106015, 2106016, 2106017, 2106018, 2106019, 2106020, 2106021, 2206001, 2206002, 2206003, 2206004, 2206005, 2206006, 2206007, 2206008, 2206009, 2206010, 2206011, 2206012, 2206013, 2206014, 2206015, 2206016);

-- Deepvoid warrior, Hellsbound warrior, Magicked bones, Purgatory knight
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Skeleton/SkeletonStandard'
    WHERE classPath = '' AND id IN (2101901, 2101902, 2101903, 2101904, 2101905, 2101906, 2101907, 2101908, 2101909, 2101910, 2101911, 2201901, 2201902, 2201903, 2201904, 2201905, 2301901, 2301902);

-- Abacus slug, Bloodsucker, Dart slug, Ghost slug
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Slug/SlugLesserStandard'
    WHERE classPath = '' AND id IN (2104202, 2104203, 2104204, 2104205, 2104206, 2104207, 2104209, 2104211, 2104213, 2104214, 2104215, 2104216, 2104218, 2204201, 2204202, 2204203, 2204204, 2204205, 2204206, 2204207, 2204208, 2204209, 2204210, 2204211, 2204212, 2204213, 2304201, 2304202, 2304203, 2304204, 2304205);

-- Alpha miteling, Antares, Banemite, Bastard mite
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Spider/SpiderChildStandard'
    WHERE classPath = '' AND id IN (2101103, 2101104, 2101105, 2101106, 2101107, 2101108, 2101109, 2101110, 2101111, 2101113, 2101114, 2101115, 2101116, 2101117, 2101118, 2101119, 2101120, 2107603, 2107604, 2107607, 2107608, 2107609, 2107610, 2107612, 2107615, 2107616, 2107617, 2107618, 2107619, 2107620, 2107621, 2107622, 2107623, 2107624, 2201101, 2201102, 2201103, 2201104, 2201105, 2201106, 2201107, 2201108, 2201109, 2201110, 2201111, 2201112, 2201113, 2201114, 2201115, 2207601, 2207602, 2207603, 2207604, 2207605, 2207606, 2207607, 2207608, 2207609, 2207610, 2207611, 2207612, 2207613, 2301101, 2301102, 2301103, 2301104, 2301105, 2301106, 2301107, 2301108, 2301109, 2301110, 2301111);

-- Coerthas spriggan, Golem tender, Spindiggle, Spiteful
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Sprite/SpritePurpleLesserStandard'
    WHERE classPath = '' AND id IN (2106201, 2106202, 2106203, 2106204, 2106205, 2106206, 2106207, 2106209, 2106213, 2106216, 2106217, 2106218, 2106219, 2106220, 2106221, 2106222, 2106223, 2106224, 2106225, 2206201, 2206202, 2206203, 2206204, 2206205, 2206206, 2206207, 2206208, 2206209, 2206210, 2206211, 2206212, 2206213, 2206214, 2206215, 2206216);

-- Antling, Antling digger, Antling drone, Antling forager
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Termite/TermiteStandard'
    WHERE classPath = '' AND id IN (2103001, 2103002, 2103003, 2103004, 2103005, 2103006, 2103007, 2103008, 2103009, 2103010, 2103011, 2103012, 2103013, 2203001, 2203002, 2203003, 2203004, 2203005, 2203006, 2203007, 2203008, 2203009, 2203010, 2203011, 2303001, 2303002, 2303003, 2303004, 2303005, 2303006, 2303007);

-- Great Elm, Great Oak, Guardian of the grove, Treant
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Treant/TreantLesserStandard'
    WHERE classPath = '' AND id IN (2102801, 2102802, 2102803, 2102804, 2102805, 2102806, 2102807, 2102808, 2102809, 2202801, 2202802, 2202803, 2202804, 2202805);

-- Lunar fragment, Nael deus Darnus, Nael van Darnus
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/WhiteGeneral/WhiteGeneralNormal'
    WHERE classPath = '' AND id IN (2210901, 2210902, 2210903, 2210904, 2210905, 2210906, 2210907, 2210908, 2210909, 2210910, 2210911, 2210912, 2210913);

-- Alchemist's tinder, Friar's lantern, Gaoler's lantern, Gloom lurker
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/WillOTheWisp/WillOTheWispStandard'
    WHERE classPath = '' AND id IN (2109901, 2109902, 2109903, 2109904, 2109905, 2109906, 2109907, 2109908, 2109909, 2109910, 2109911, 2109912, 2109913, 2109914, 2109915, 2110001, 2110002, 2110003, 2110004, 2110005, 2209901, 2209902, 2209903, 2209904, 2209905, 2209906, 2209907, 2209908, 2210001, 2210002, 2210003, 2210004, 2309901);

-- Wyvern
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Winglizard/WinglizardStandard'
    WHERE classPath = '' AND id IN (2103801, 2103802, 2203801, 2203802);

-- Alpha coywolf, Alpha dreadwolf, Angry mongrel, Bardi
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Wolf/WolfStandard'
    WHERE classPath = '' AND id IN (2101402, 2101404, 2101405, 2101406, 2101407, 2101408, 2101410, 2101411, 2101412, 2101413, 2101414, 2101415, 2101416, 2101417, 2101418, 2101419, 2101420, 2101421, 2101422, 2101423, 2101425, 2101426, 2101427, 2101428, 2101429, 2101430, 2101431, 2109801, 2201401, 2201402, 2201403, 2201405, 2201406, 2201408, 2201409, 2201410, 2201411, 2201412, 2201413, 2201414, 2201415, 2201416, 2201417, 2201418, 2201419, 2201420, 2201421, 2201422, 2201423, 2201424, 2201425, 2201426, 2201427, 2201428, 2201429, 2201430, 2209801);

-- Aldgoat nanny, Enraged nannygoat, Longhorn nannygoat, Nannygoat
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Yak/YakFemaleStandard'
    WHERE classPath = '' AND id IN (2102313, 2102317, 2102318, 2102319, 2202307, 2202308, 2202312);

-- Aldgoat billy, Billygoat, Elder longhorn, Longhorn billygoat
UPDATE gamedata_actor_class SET classPath = '/Chara/Npc/Monster/Yak/YakMaleStandard'
    WHERE classPath = '' AND id IN (2102309, 2102310, 2102312, 2102314, 2102315, 2102316, 2202309, 2202310, 2202311);
