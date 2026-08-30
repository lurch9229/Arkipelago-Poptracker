-- this is an example/default implementation for AP autotracking
-- it will use the mappings defined in item_mapping.lua and location_mapping.lua to track items and locations via their ids
-- it will also keep track of the current index of on_item messages in CUR_INDEX
-- addition it will keep track of what items are local items and which one are remote using the globals LOCAL_ITEMS and GLOBAL_ITEMS
-- this is useful since remote items will not reset but local items might
-- if you run into issues when touching A LOT of items/locations here, see the comment about Tracker.AllowDeferredLogicUpdate in autotracking.lua
ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}
TRACKER_GROUPS = {}
TRACKER_GROUPS_ACTIVE = false
INCLUDED_LOCATIONS = {}

-- TAME SANITY MAPPINGS
local TAME_SANITY_IDS = {
    ["Tame: Achatina"]              = 8732001,
    ["Tame: Allosaurus"]            = 8732003,
    ["Tame: Angler"]                = 8732004,
    ["Tame: Ankylosaurus"]          = 8732005,
    ["Tame: Archaeopteryx"]         = 8732006,
    ["Tame: Argentavis"]            = 8732007,
    ["Tame: Arthropleura"]          = 8732008,
    ["Tame: Baryonyx"]              = 8732009,
    ["Tame: Basilosaurus"]          = 8732010,
    ["Tame: Castoroides"]           = 8732011,
    ["Tame: Dung Beetle"]           = 8732012,
    ["Tame: Gigantopithecus"]       = 8732013,
    ["Tame: Bronto"]                = 8732014,
    ["Tame: Carno"]                 = 8732015,
    ["Tame: Chalicotherium"]        = 8732016,
    ["Tame: Compsognathus"]         = 8732017,
    ["Tame: Daeodon"]               = 8732018,
    ["Tame: Dilophosaur"]           = 8732019,
    ["Tame: Dimetrodon"]            = 8732020,
    ["Tame: Dimorphodon"]           = 8732021,
    ["Tame: Diplodocus"]            = 8732022,
    ["Tame: Diplocaulus"]           = 8732023,
    ["Tame: Direbear"]              = 8732024,
    ["Tame: Direwolf"]              = 8732025,
    ["Tame: Dodo"]                  = 8732026,
    ["Tame: Doedicurus"]            = 8732027,
    ["Tame: Ichthyosaurus"]         = 8732028,
    ["Tame: Dunk"]                  = 8732029,
    ["Tame: Electrophorus"]         = 8732030,
    ["Tame: Equus"]                 = 8732031,
    ["Tame: Gallimimus"]            = 8732032,
    ["Tame: Giganotosaurus"]        = 8732033,
    ["Tame: Hesperornis"]           = 8732034,
    ["Tame: Hyaenodon"]             = 8732035,
    ["Tame: Ichthyornis"]           = 8732036,
    ["Tame: Iguanodon"]             = 8732037,
    ["Tame: Kairuku"]               = 8732038,
    ["Tame: Procoptodon"]           = 8732039,
    ["Tame: Kaprosuchus"]           = 8732040,
    ["Tame: Kentrosaurus"]          = 8732041,
    ["Tame: Liopleurodon"]          = 8732043,
    ["Tame: Lystrosaurus"]          = 8732044,
    ["Tame: Mammoth"]               = 8732045,
    ["Tame: Manta"]                 = 8732046,
    ["Tame: Megalodon"]             = 8732047,
    ["Tame: Megalania"]             = 8732049,
    ["Tame: Megalosaurus"]          = 8732050,
    ["Tame: Megatherium"]           = 8732051,
    ["Tame: Microraptor"]           = 8732052,
    ["Tame: Mesopithecus"]          = 8732053,
    ["Tame: Mosasaur"]              = 8732054,
    ["Tame: Moschops"]              = 8732055,
    ["Tame: Otter"]                 = 8732056,
    ["Tame: Oviraptor"]             = 8732057,
    ["Tame: Pachycephalosaurus"]    = 8732058,
    ["Tame: Pachyrhinosaurus"]      = 8732059,
    ["Tame: Parasaur"]              = 8732060,
    ["Tame: Paraceratherium"]       = 8732061,
    ["Tame: Pegomastax"]            = 8732062,
    ["Tame: Pelagornis"]            = 8732063,
    ["Tame: Phiomia"]               = 8732064,
    ["Tame: Plesiosaur"]            = 8732065,
    ["Tame: Pteranodon"]            = 8732066,
    ["Tame: Purlovia"]              = 8732067,
    ["Tame: Quetzal"]               = 8732068,
    ["Tame: Raptor"]                = 8732069,
    ["Tame: Rex"]                   = 8732070,
    ["Tame: Woolly Rhino"]          = 8732071,
    ["Tame: Sabertooth"]            = 8732072,
    ["Tame: Sarcosuchus"]           = 8732073,
    ["Tame: Pulmonoscorpius"]       = 8732074,
    ["Tame: Ovis"]                  = 8732075,
    ["Tame: Araneo"]                = 8732076,
    ["Tame: Spino"]                 = 8732077,
    ["Tame: Megaloceros"]           = 8732078,
    ["Tame: Stegosaurus"]           = 8732079,
    ["Tame: Tapejara"]              = 8732081,
    ["Tame: Terror Bird"]           = 8732082,
    ["Tame: Therizinosaurus"]       = 8732083,
    ["Tame: Thylacoleo"]            = 8732084,
    ["Tame: Titanoboa"]             = 8732086,
    ["Tame: Beelzebufo"]            = 8732087,
    ["Tame: Triceratops"]           = 8732088,
    ["Tame: Troodon"]               = 8732089,
    ["Tame: Carbonemys"]            = 8732090,
    ["Tame: Tusoteuthis"]           = 8732091,
    ["Tame: Yutyrannus"]            = 8732092,
    ["Tame: Onyc"]                  = 8732100,
    ["Tame: Giant Bee"]             = 8732101,
    ["Tame: Rhyniognatha"]          = 8732102,
    ["Tame: Carcharodontosaurus"]   = 8732103,
    ["Tame: Unicorn"]               = 8732104,
    ["Tame: Griffin"]               = 8732105,
    ["Tame: Mantis"]                = 8732106,
    ["Tame: Lymantria"]             = 8732107,
    ["Tame: Rock Elemental"]        = 8732108,
    ["Tame: Thorny Dragon"]         = 8732109,
    ["Tame: Vulture"]               = 8732110,
    ["Tame: Wyvern"]                = 8732111,
    ["Tame: Morellatops"]           = 8732112,
    ["Tame: Jerboa"]                = 8732113,
    ["Tame: Phoenix"]               = 8732114,
}

for key_name, id in pairs(TAME_SANITY_IDS) do
    local clean_name = key_name:lower():gsub("tame:%s*", ""):gsub("[%s%-]", "_")
    
    _G["tame_sanity_" .. clean_name .. "_enabled"] = function()
        local ts_obj = Tracker:FindObjectForCode("op_TS")
        if not ts_obj or ts_obj.AcquiredCount == 0 then
            return true
        end
        return INCLUDED_LOCATIONS[id] == true
    end
end

-- NOTE SANITY MAPPINGS
local EXPLORER_NOTE_IDS = {
    dossier_dilophosaur                               = 8740000,
    dossier_titanomyrma                               = 8740001,
    rockwell_note_1                                   = 8740002,
    mei_yin_note_1                                    = 8740003,
    mei_yin_note_2                                    = 8740004,
    nerva_note_1                                      = 8740005,
    dossier_allosaurus                                = 8740006,
    dossier_anglerfish                                = 8740007,
    dossier_ankylosaurus                              = 8740008,
    dossier_archaeopteryx                             = 8740009,
    dossier_argentavis                                = 8740010,
    dossier_arthropleura                              = 8740011,
    dossier_castoroides                               = 8740012,
    dossier_dung_beetle                               = 8740013,
    dossier_beelzebufo                                = 8740014,
    dossier_gigantopithecus                           = 8740015,
    dossier_brontosaurus                              = 8740016,
    dossier_carnotaurus                               = 8740017,
    dossier_chalicotherium                            = 8740018,
    dossier_coelacanth                                = 8740019,
    dossier_compy                                     = 8740020,
    dossier_dimetrodon                                = 8740021,
    dossier_dimorphodon                               = 8740022,
    dossier_diplodocus                                = 8740023,
    dossier_diplocaulus                               = 8740024,
    dossier_dire_bear                                 = 8740025,
    dossier_direwolf                                  = 8740026,
    dossier_dodo                                      = 8740027,
    dossier_doedicurus                                = 8740028,
    dossier_meganeura                                 = 8740029,
    dossier_dunkleosteus                              = 8740030,
    dossier_eurypterid                                = 8740031,
    dossier_gallimimus                                = 8740032,
    dossier_giganotosaurus                            = 8740033,
    dossier_ichthyosaurus                             = 8740034,
    dossier_kairuku                                   = 8740035,
    dossier_kaprosuchus                               = 8740036,
    dossier_leech                                     = 8740037,
    dossier_lystrosaurus                              = 8740038,
    dossier_mammoth                                   = 8740039,
    dossier_manta                                     = 8740040,
    dossier_megaloceros                               = 8740041,
    dossier_megalodon                                 = 8740042,
    dossier_megalosaurus                              = 8740043,
    dossier_mesopithecus                              = 8740044,
    dossier_mosasaurus                                = 8740045,
    dossier_onyc                                      = 8740046,
    dossier_oviraptor                                 = 8740047,
    dossier_pachy                                     = 8740048,
    dossier_paraceratherium                           = 8740049,
    dossier_parasaur                                  = 8740050,
    dossier_pelagornis                                = 8740051,
    dossier_phiomia                                   = 8740052,
    dossier_piranha                                   = 8740053,
    dossier_plesiosaur                                = 8740054,
    dossier_procoptodon                               = 8740055,
    dossier_pteranodon                                = 8740056,
    dossier_quetzal                                   = 8740057,
    dossier_raptor                                    = 8740058,
    dossier_woolly_rhino                              = 8740059,
    dossier_sabertooth                                = 8740060,
    dossier_sabertooth_salmon                         = 8740061,
    dossier_sarco                                     = 8740062,
    dossier_pulmonoscorpius                           = 8740063,
    dossier_araneo                                    = 8740064,
    dossier_spino                                     = 8740065,
    dossier_stegosaurus                               = 8740066,
    dossier_tapejara                                  = 8740067,
    dossier_terror_bird                               = 8740068,
    dossier_titanosaur                                = 8740069,
    dossier_titanoboa                                 = 8740070,
    dossier_rex                                       = 8740071,
    dossier_triceratops                               = 8740072,
    dossier_trilobite                                 = 8740073,
    dossier_carbonemys                                = 8740074,
    helena_note_1                                     = 8740075,
    helena_note_2                                     = 8740076,
    helena_note_3                                     = 8740077,
    helena_note_4                                     = 8740078,
    rockwell_note_2                                   = 8740079,
    rockwell_note_3                                   = 8740080,
    rockwell_note_4                                   = 8740081,
    mei_yin_note_3                                    = 8740082,
    mei_yin_note_4                                    = 8740083,
    nerva_note_2                                      = 8740084,
    nerva_note_3                                      = 8740085,
    nerva_note_4                                      = 8740086,
    hologram_broodmother                              = 8740087,
    hologram_megapithecus                             = 8740088,
    hologram_dragon                                   = 8740089,
    dossier_deathworm                                 = 8740090,
    dossier_mantis                                    = 8740091,
    dossier_jerboa                                    = 8740092,
    dossier_jug_bug                                   = 8740093,
    dossier_moth                                      = 8740094,
    dossier_rock_elemental                            = 8740095,
    dossier_thorny_dragon                             = 8740096,
    dossier_wyvern                                    = 8740097,
    dossier_vulture                                   = 8740098,
    dossier_morellatops                               = 8740099,
    manticore_hologram                                = 8740100,
    raia_tablet_1                                     = 8740101,
    raia_tablet_2                                     = 8740102,
    raia_tablet_3                                     = 8740103,
    raia_tablet_4                                     = 8740104,
    dahkeya_note_1                                    = 8740105,
    dahkeya_note_2                                    = 8740106,
    dahkeya_note_3                                    = 8740107,
    dahkeya_note_4                                    = 8740108,
    helena_note_1_SE                                  = 8740109,
    helena_note_2_SE                                  = 8740110,
    helena_note_3_SE                                  = 8740111,
    helena_note_4_SE                                  = 8740112,
    rockwell_record_1_SE                              = 8740113,
    rockwell_record_2_SE                              = 8740114,
    rockwell_record_3_SE                              = 8740115,
    rockwell_record_4_SE                              = 8740116,
    rockwell_record_5_SE                              = 8740117,
    rockwell_note_5                                   = 8740118,
    dahkeya_note_5                                    = 8740119,
    raia_tablet_5                                     = 8740120,
    nerva_note_5                                      = 8740121,
    helena_note_5_SE                                  = 8740122,
    helena_note_5                                     = 8740123,
    mei_yin_note_5                                    = 8740124,
    mei_yin_note_6                                    = 8740125,
    mei_yin_note_7                                    = 8740126,
    helena_note_6                                     = 8740127,
    helena_note_7                                     = 8740128,
    helena_note_6_SE                                  = 8740129,
    helena_note_7_SE                                  = 8740130,
    nerva_note_6                                      = 8740131,
    nerva_note_7                                      = 8740132,
    raia_tablet_6                                     = 8740133,
    raia_tablet_7                                     = 8740134,
    dahkeya_note_6                                    = 8740135,
    dahkeya_note_7                                    = 8740136,
    rockwell_note_6                                   = 8740137,
    rockwell_note_7                                   = 8740138,
    rockwell_record_6_SE                              = 8740139,
    rockwell_record_7_SE                              = 8740140,
    dossier_achatina                                  = 8740141,
    dossier_moschops                                  = 8740142,
    dossier_pachyrhinosaurus                          = 8740143,
    mei_yin_note_8                                    = 8740144,
    helena_note_8                                     = 8740145,
    nerva_note_8                                      = 8740146,
    rockwell_note_8                                   = 8740147,
    helena_note_8_SE                                  = 8740148,
    raia_tablet_8                                     = 8740149,
    dahkeya_note_8                                    = 8740150,
    rockwell_record_8_SE                              = 8740151,
    mei_yin_note_9                                    = 8740152,
    helena_note_9                                     = 8740153,
    nerva_note_9                                      = 8740154,
    rockwell_note_9                                   = 8740155,
    helena_note_9_SE                                  = 8740156,
    raia_tablet_9                                     = 8740157,
    dahkeya_note_9                                    = 8740158,
    rockwell_record_9_SE                              = 8740159,
    dossier_cnidaria                                  = 8740160,
    dossier_troodon                                   = 8740161,
    dossier_tusoteuthis                               = 8740162,
    dossier_pegomastax                                = 8740163,
    dossier_therizinosaur                             = 8740164,
    mei_yin_note_10                                   = 8740165,
    helena_note_10                                    = 8740166,
    nerva_note_10                                     = 8740167,
    rockwell_note_10                                  = 8740168,
    helena_note_10_SE                                 = 8740169,
    raia_tablet_10                                    = 8740170,
    dahkeya_note_10                                   = 8740171,
    rockwell_record_10_SE                             = 8740172,
    dossier_ovis                                      = 8740173,
    dossier_baryonyx                                  = 8740174,
    dossier_basilosaurus                              = 8740175,
    dossier_purlovia                                  = 8740176,
    rockwell_note_11                                  = 8740177,
    rockwell_note_12                                  = 8740178,
    rockwell_note_13                                  = 8740179,
    rockwell_note_14                                  = 8740180,
    rockwell_note_15                                  = 8740181,
    rockwell_note_16                                  = 8740182,
    rockwell_note_17                                  = 8740183,
    rockwell_note_18                                  = 8740184,
    helena_note_11                                    = 8740185,
    helena_note_12                                    = 8740186,
    helena_note_13                                    = 8740187,
    helena_note_14                                    = 8740188,
    helena_note_15                                    = 8740189,
    helena_note_16                                    = 8740190,
    helena_note_17                                    = 8740191,
    helena_note_18                                    = 8740192,
    mei_yin_note_11                                   = 8740193,
    mei_yin_note_12                                   = 8740194,
    mei_yin_note_13                                   = 8740195,
    mei_yin_note_14                                   = 8740196,
    mei_yin_note_15                                   = 8740197,
    mei_yin_note_16                                   = 8740198,
    mei_yin_note_17                                   = 8740199,
    mei_yin_note_18                                   = 8740200,
    nerva_note_11                                     = 8740201,
    nerva_note_12                                     = 8740202,
    nerva_note_13                                     = 8740203,
    nerva_note_14                                     = 8740204,
    nerva_note_15                                     = 8740205,
    nerva_note_16                                     = 8740206,
    nerva_note_17                                     = 8740207,
    nerva_note_18                                     = 8740208,
    helena_note_11_SE                                 = 8740209,
    helena_note_12_SE                                 = 8740210,
    helena_note_13_SE                                 = 8740211,
    helena_note_14_SE                                 = 8740212,
    helena_note_15_SE                                 = 8740213,
    helena_note_16_SE                                 = 8740214,
    helena_note_17_SE                                 = 8740215,
    helena_note_18_SE                                 = 8740216,
    dahkeya_note_11                                   = 8740217,
    dahkeya_note_12                                   = 8740218,
    dahkeya_note_13                                   = 8740219,
    dahkeya_note_14                                   = 8740220,
    dahkeya_note_15                                   = 8740221,
    dahkeya_note_16                                   = 8740222,
    dahkeya_note_17                                   = 8740223,
    dahkeya_note_18                                   = 8740224,
    rockwell_record_11_SE                             = 8740225,
    rockwell_record_12_SE                             = 8740226,
    rockwell_record_13_SE                             = 8740227,
    rockwell_record_14_SE                             = 8740228,
    rockwell_record_15_SE                             = 8740229,
    rockwell_record_16_SE                             = 8740230,
    rockwell_record_17_SE                             = 8740231,
    rockwell_record_18_SE                             = 8740232,
    dossier_ammonite                                  = 8740233,
    dossier_electrophorus                             = 8740234,
    dossier_microraptor                               = 8740235,
    dossier_thylacoleo                                = 8740236,
    dossier_equus                                     = 8740237,
    dossier_leedsichthys                              = 8740238,
    dossier_ichthyornis                               = 8740239,
    dossier_iguanodon                                 = 8740240,
    rockwell_note_19                                  = 8740241,
    rockwell_note_20                                  = 8740242,
    rockwell_note_21                                  = 8740243,
    rockwell_note_22                                  = 8740244,
    rockwell_note_23                                  = 8740245,
    rockwell_note_24                                  = 8740246,
    rockwell_note_25                                  = 8740247,
    rockwell_note_26                                  = 8740248,
    helena_note_19                                    = 8740249,
    helena_note_20                                    = 8740250,
    helena_note_21                                    = 8740251,
    helena_note_22                                    = 8740252,
    helena_note_23                                    = 8740253,
    helena_note_24                                    = 8740254,
    helena_note_25                                    = 8740255,
    helena_note_26                                    = 8740256,
    mei_yin_note_19                                   = 8740257,
    mei_yin_note_20                                   = 8740258,
    mei_yin_note_21                                   = 8740259,
    mei_yin_note_22                                   = 8740260,
    mei_yin_note_23                                   = 8740261,
    mei_yin_note_24                                   = 8740262,
    mei_yin_note_25                                   = 8740263,
    mei_yin_note_26                                   = 8740264,
    nerva_note_19                                     = 8740265,
    nerva_note_20                                     = 8740266,
    nerva_note_21                                     = 8740267,
    nerva_note_22                                     = 8740268,
    nerva_note_23                                     = 8740269,
    nerva_note_24                                     = 8740270,
    nerva_note_25                                     = 8740271,
    nerva_note_26                                     = 8740272,
    raia_tablet_11                                    = 8740273,
    raia_tablet_12                                    = 8740274,
    raia_tablet_13                                    = 8740275,
    raia_tablet_14                                    = 8740276,
    raia_tablet_15                                    = 8740277,
    raia_tablet_16                                    = 8740278,
    raia_tablet_17                                    = 8740279,
    raia_tablet_18                                    = 8740280,
    dossier_giant_bee                                 = 8740281,
    dossier_daeodon                                   = 8740282,
    dossier_kentrosaurus                              = 8740283,
    dossier_liopleurodon                              = 8740284,
    helena_note_27                                    = 8740285,
    helena_note_28                                    = 8740286,
    helena_note_29                                    = 8740287,
    mei_yin_note_27                                   = 8740288,
    mei_yin_note_28                                   = 8740289,
    mei_yin_note_29                                   = 8740290,
    mei_yin_note_30                                   = 8740291,
    nerva_note_27                                     = 8740292,
    nerva_note_28                                     = 8740293,
    nerva_note_29                                     = 8740294,
    nerva_note_30                                     = 8740295,
    rockwell_note_27                                  = 8740296,
    rockwell_note_28                                  = 8740297,
    dossier_hyaenodon                                 = 8740298,
    dossier_megalania                                 = 8740299,
    dossier_yutyrannus                                = 8740300,
    dossier_megatherium                               = 8740301,
    dossier_hesperornis                               = 8740302,
    dahkeya_note_19                                   = 8740303,
    dahkeya_note_20                                   = 8740304,
    dahkeya_note_21                                   = 8740305,
    dahkeya_note_22                                   = 8740306,
    dahkeya_note_23                                   = 8740307,
    dahkeya_note_24                                   = 8740308,
    dahkeya_note_25                                   = 8740309,
    dahkeya_note_26                                   = 8740310,
    dahkeya_note_27                                   = 8740311,
    dahkeya_note_28                                   = 8740312,
    dahkeya_note_29                                   = 8740313,
    dahkeya_note_30                                   = 8740314,
    helena_note_19_SE                                 = 8740315,
    helena_note_20_SE                                 = 8740316,
    helena_note_21_SE                                 = 8740317,
    helena_note_22_SE                                 = 8740318,
    helena_note_23_SE                                 = 8740319,
    helena_note_24_SE                                 = 8740320,
    helena_note_25_SE                                 = 8740321,
    helena_note_26_SE                                 = 8740322,
    helena_note_27_SE                                 = 8740323,
    helena_note_28_SE                                 = 8740324,
    helena_note_29_SE                                 = 8740325,
    helena_note_30_SE                                 = 8740326,
    rockwell_record_19_SE                             = 8740327,
    rockwell_record_20_SE                             = 8740328,
    rockwell_record_21_SE                             = 8740329,
    rockwell_record_22_SE                             = 8740330,
    rockwell_record_23_SE                             = 8740331,
    rockwell_record_24_SE                             = 8740332,
    rockwell_record_25_SE                             = 8740333,
    rockwell_record_26_SE                             = 8740334,
    rockwell_record_27_SE                             = 8740335,
    rockwell_record_28_SE                             = 8740336,
    rockwell_record_29_SE                             = 8740337,
    rockwell_record_30_SE                             = 8740338,
    raia_tablet_19                                    = 8740339,
    raia_tablet_20                                    = 8740340,
    raia_tablet_21                                    = 8740341,
    raia_tablet_22                                    = 8740342,
    raia_tablet_23                                    = 8740343,
    raia_tablet_24                                    = 8740344,
    raia_tablet_25                                    = 8740345,
    raia_tablet_26                                    = 8740346,
    raia_tablet_27                                    = 8740347,
    raia_tablet_28                                    = 8740348,
    raia_tablet_29                                    = 8740349,
    raia_tablet_30                                    = 8740350,
    rockwell_note_29                                  = 8740351,
    helena_note_30                                    = 8740352,
    hologram_overseer                                 = 8740353,
    mei_yin_note_31                                   = 8740354,
    dossier_otter                                     = 8740355,
    dossier_phoenix                                   = 8740356,
    ascendant_note_1                                  = 8740508,
    ascendant_note_2                                  = 8740509,
    ascendant_note_4                                  = 8740511,
    ascendant_note_5                                  = 8740512,
    ascendant_note_7                                  = 8740514,
    ascendant_note_8                                  = 8740515,
    ascendant_note_10                                 = 8740517,
    ascendant_note_11                                 = 8740518,
    ascendant_note_13                                 = 8740520,
    ascendant_note_14                                 = 8740521,
    dossier_griffin                                   = 8741221,
    dossier_carcharodontosaurus                       = 8741230,
    dossier_rhyniognatha                              = 8741231,
}

for name, id in pairs(EXPLORER_NOTE_IDS) do
    _G["explorer_note_" .. name .. "_enabled"] = function()
        local en_obj = Tracker:FindObjectForCode("op_NS")
        if not en_obj or en_obj.AcquiredCount == 0 then
            return true
        end
        return INCLUDED_LOCATIONS[id] == true
    end
end

-- FOOD SANITY MAPPINGS
local FOOD_SANITY_IDS = {
    raw_meat_100                  = 8757213,
    raw_meat_200                  = 8757372,
    raw_meat_500                  = 8757373,
    raw_prime_meat_20             = 8757374,
    raw_prime_meat_50             = 8757231,
    citronal_10                   = 8757300,
    citronal_20                   = 8757393,
    citronal_30                   = 8757394,
    longrass_10                   = 8757301,
    longrass_20                   = 8757395,
    longrass_30                   = 8757396,
    rockarrot_10                  = 8757302,
    rockarrot_20                  = 8757397,
    rockarrot_30                  = 8757398,
    savoroot_10                   = 8757303,
    savoroot_20                   = 8757399,
    savoroot_30                   = 8757400,
    cooked_meat_20                = 8757304,
    cooked_meat_50                = 8757378,
    cooked_meat_100               = 8757379,
    cooked_meat_200               = 8757380,
    cooked_meat_500               = 8757381,
    cooked_meat_jerky_5           = 8757305,
    cooked_meat_jerky_10          = 8757389,
    cooked_prime_meat_10          = 8757382,
    cooked_prime_meat_20          = 8757306,
    cooked_prime_meat_50          = 8757383,
    prime_meat_jerky_5            = 8757307,
    prime_meat_jerky_10           = 8757390,
    cooked_fish_meat_20           = 8757308,
    cooked_fish_meat_50           = 8757384,
    cooked_fish_meat_100          = 8757385,
    cooked_fish_meat_200          = 8757386,
    cooked_prime_fish_meat_10     = 8757387,
    cooked_prime_fish_meat_20     = 8757309,
    cooked_prime_fish_meat_50     = 8757388,
    giant_bee_honey_3             = 8757310,
    giant_bee_honey_10            = 8757401,
    rare_flower_20                = 8757402,
    rare_flower_50                = 8757311,
    rare_mushroom_50              = 8757312,
    rare_mushroom_20              = 8757403,
    plant_species_x_seed_20       = 8757313,
    cactus_sap_100                = 8757320,
    plant_species_y_seed_20       = 8757332,
    raw_fish_meat_100             = 8757358,
    raw_fish_meat_200             = 8757375,
    raw_fish_meat_500             = 8757376,
    raw_prime_fish_meat_20        = 8757377,
    raw_prime_fish_meat_50        = 8757359,
}

for name, id in pairs(FOOD_SANITY_IDS) do
    _G["food_sanity_" .. name .. "_enabled"] = function()
        local fs_obj = Tracker:FindObjectForCode("op_FS")
        if not fs_obj or fs_obj.AcquiredCount == 0 then
            return true
        end
        return INCLUDED_LOCATIONS[id] == true
    end
end

-- DEATH SANITY MAPPINGS
local DEATH_SANITY_IDS = {
    carnivore   = 8759000,
    herbivore   = 8759001,
    alpha       = 8759002,
    cold        = 8759003,
    heat        = 8759004,
    drowning    = 8759005,
    lava        = 8759006,
    falling     = 8759007,
    starvation  = 8759008,
    dehydration = 8759009,
}

for name, id in pairs(DEATH_SANITY_IDS) do
    _G["death_sanity_" .. name .. "_enabled"] = function()
        local ds_obj = Tracker:FindObjectForCode("op_DS")
        if not ds_obj or ds_obj.AcquiredCount == 0 then
            return true
        end
        return INCLUDED_LOCATIONS[id] == true
    end
end

-- resets an item to its initial state
function resetItem(item_code, item_type)
    local obj = Tracker:FindObjectForCode(item_code)
    if obj then
        item_type = item_type or obj.Type
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("resetItem: resetting item %s of type %s", item_code, item_type))
        end
        if item_type == "toggle" or item_type == "toggle_badged" then
            obj.Active = false
        elseif item_type == "progressive" or item_type == "progressive_toggle" then
            obj.CurrentStage = 0
            obj.Active = false
        elseif item_type == "consumable" then
            obj.AcquiredCount = 0
        elseif item_type == "custom" then
            -- your code for your custom lua items goes here
        elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("resetItem: tried to reset static item %s", item_code))
        elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format(
                "resetItem: tried to reset composite_toggle item %s but composite_toggle cannot be accessed via lua." ..
                "Please use the respective left/right toggle item codes instead.", item_code))
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("resetItem: unknown item type %s for code %s", item_type, item_code))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("resetItem: could not find item object for code %s", item_code))
    end
end

-- advances the state of an item
function incrementItem(item_code, item_type, multiplier)
    multiplier = multiplier or 1 -- Fallback to 1 if multiplier is nil
    local obj = Tracker:FindObjectForCode(item_code)
    if obj then
        item_type = item_type or obj.Type
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("incrementItem: code: %s, type %s, multiplier %s", item_code, item_type, tostring(multiplier)))
        end
        if item_type == "toggle" or item_type == "toggle_badged" then
            obj.Active = true
        elseif item_type == "progressive" or item_type == "progressive_toggle" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif item_type == "consumable" then
            local inc = obj.Increment or 1 -- Fallback to 1 if obj.Increment is nil
            obj.AcquiredCount = obj.AcquiredCount + (inc * multiplier)
        elseif item_type == "custom" then
            -- your code for your custom lua items goes here
        elseif item_type == "static" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("incrementItem: tried to increment static item %s", item_code))
        elseif item_type == "composite_toggle" and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format(
                "incrementItem: tried to increment composite_toggle item %s but composite_toggle cannot be access via lua." ..
                "Please use the respective left/right toggle item codes instead.", item_code))
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("incrementItem: unknown item type %s for code %s", item_type, item_code))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("incrementItem: could not find object for code %s", item_code))
    end
end

function incrementMappedItem(item_id)
    local mapping_entry = ITEM_MAPPING[item_id]
    if not mapping_entry then
        return
    end

    for _, item_table in pairs(mapping_entry) do
        if item_table then
            local item_code = item_table[1]
            local item_type = item_table[2]
            local multiplier = item_table[3] or 1
            if item_code then
                incrementItem(item_code, item_type, multiplier)
            end
        end
    end
end

-- apply everything needed from slot_data, called from onClear
function apply_slot_data(slot_data)
    TRACKER_GROUPS = {}
    INCLUDED_LOCATIONS = {}

    function explorer_note_location_enabled(location_id)
        local en_obj = Tracker:FindObjectForCode("op_NS")
        if not en_obj or en_obj.AcquiredCount == 0 then
            return true
        end
        return INCLUDED_LOCATIONS[location_id] == true
    end

    local explorer_notes_val = slot_data['dossier_checks']
    if explorer_notes_val ~= nil then
        local obj = Tracker:FindObjectForCode("op_NS")
        if obj then
            obj.AcquiredCount = tonumber(explorer_notes_val) or 0
        end
    end

    function tame_sanity_location_enabled(location_id)
        local ts_obj = Tracker:FindObjectForCode("op_TS")
        if not ts_obj or ts_obj.AcquiredCount == 0 then
            return true
        end
        return INCLUDED_LOCATIONS[location_id] == true
    end

    function food_sanity_location_enabled(location_id)
        local fs_obj = Tracker:FindObjectForCode("op_FS")
        if not fs_obj or fs_obj.AcquiredCount == 0 then
            return true
        end
        return INCLUDED_LOCATIONS[location_id] == true
    end

    function death_sanity_location_enabled(location_id)
        local ds_obj = Tracker:FindObjectForCode("op_DS")
        if not ds_obj or ds_obj.AcquiredCount == 0 then
            return true
        end
        return INCLUDED_LOCATIONS[location_id] == true
    end

    if type(slot_data["included_locations"]) == "table" then
        for _, location_id in ipairs(slot_data["included_locations"]) do
            local numeric_id = tonumber(location_id)
            if numeric_id then
                INCLUDED_LOCATIONS[numeric_id] = true
            end
        end
    end

    local engrams_per_item = tonumber(slot_data["engrams_per_item"]) or 1
    local tames_per_item = tonumber(slot_data["tames_per_item"]) or 1
    TRACKER_GROUPS_ACTIVE = engrams_per_item > 1 or tames_per_item > 1

    if TRACKER_GROUPS_ACTIVE and type(slot_data["tracker_groups"]) == "table" then
        for representative_id, member_ids in pairs(slot_data["tracker_groups"]) do
            TRACKER_GROUPS[tostring(representative_id)] = member_ids
        end
    end

    local engram_count_obj = Tracker:FindObjectForCode("engram_per_item")
    if engram_count_obj then
        engram_count_obj.AcquiredCount = engrams_per_item
    end

    local tame_count_obj = Tracker:FindObjectForCode("tame_per_item")
    if tame_count_obj then
        tame_count_obj.AcquiredCount = tames_per_item
    end

    if slot_data['bundle_saddles'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_BS")
        if obj then
            obj.Active = (slot_data['bundle_saddles'] == true or slot_data['bundle_saddles'] == 1)
        end
    end

    if slot_data['lock_taming'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_ST")
        if obj then
            obj.Active = (slot_data['lock_taming'] == true or slot_data['lock_taming'] == 1)
        end
    end

    if slot_data['lock_supply_crates'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_SC")
        if obj then
            obj.Active = (slot_data['lock_supply_crates'] == true or slot_data['lock_supply_crates'] == 1)
        end
    end

    if slot_data['death_milestones'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_DM")
        if obj then
            obj.Active = (slot_data['death_milestones'] == true or slot_data['death_milestones'] == 1)
        end
    end

    if slot_data['death_sanity'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_DS")
        if obj then
            obj.AcquiredCount = tonumber(slot_data['death_sanity']) or 0
        end
    end

    if slot_data['food_sanity'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_FS")
        if obj then
            obj.AcquiredCount = tonumber(slot_data['food_sanity']) or 0
        end
    end

    if slot_data['tame_sanity'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_TS")
        if obj then
            obj.AcquiredCount = tonumber(slot_data['tame_sanity']) or 0
        end
    end



    if slot_data['free_starter_engrams'] ~= nil then
        local obj = Tracker:FindObjectForCode("op_FSE")
        if obj then
            local is_active = (slot_data['free_starter_engrams'] == true or slot_data['free_starter_engrams'] == 1)
            obj.Active = is_active
            if is_active then
                local free_starter_items = {
                    "stone_hatchet",
                    "spear",
                    "campfire",
                    "thatch_foundation",
                    "waterskin"
                }
                for _, item_code in ipairs(free_starter_items) do
                    local item_obj = Tracker:FindObjectForCode(item_code)
                    if item_obj then
                        item_obj.Active = true
                    end
                end
            end
        end
    end
end

-- called right after an AP slot is connected
function onClear(slot_data)
    Tracker.BulkUpdate = true
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    CUR_INDEX = -1

    -- reset locations
    for _, mapping_entry in pairs(LOCATION_MAPPING) do
        for _, location_table in ipairs(mapping_entry) do
            if location_table then
                local location_code = location_table[1]
                if location_code then
                    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                        print(string.format("onClear: clearing location %s", location_code))
                    end
                    if location_code:sub(1, 1) == "@" then
                        local obj = Tracker:FindObjectForCode(location_code)
                        if obj then
                            obj.AvailableChestCount = obj.ChestCount
                            if obj.Highlight then
                                obj.Highlight = Highlight.None
                            end
                        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                            print(string.format("onClear: could not find location object for code %s", location_code))
                        end
                    else
                        local item_type = location_table[2]
                        resetItem(location_code, item_type)
                    end
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: skipping location_table with no location_code"))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: skipping empty location_table"))
            end
        end
    end

    -- reset items
    for _, mapping_entry in pairs(ITEM_MAPPING) do
        for _, item_table in ipairs(mapping_entry) do
            if item_table then
                local item_code = item_table[1]
                local item_type = item_table[2]
                if item_code then
                    resetItem(item_code, item_type)
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: skipping item_table with no item_code"))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: skipping empty item_table"))
            end
        end
    end
    
    apply_slot_data(slot_data)
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here
    end
    
    Tracker.BulkUpdate = false
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end

    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index
    local mapping_entry = ITEM_MAPPING[item_id]
    if not mapping_entry then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end

    for _, item_table in pairs(mapping_entry) do
        if item_table then
            local item_code = item_table[1]
            local item_type = item_table[2]
            local multiplier = item_table[3] or 1
            if item_code then
                incrementItem(item_code, item_type, multiplier)

                local bundle_saddles_active = Tracker:FindObjectForCode("op_BS")
                if bundle_saddles_active and bundle_saddles_active.Active then
                    local tame_to_saddle_map = {
                        ["phiomia"] = "phiomia_saddle",
                        ["parasaur"] = "parasaur_saddle",
                        ["ichthyosaurus"] = "ichthyosaurus_saddle",
                        ["pachy"] = "pachy_saddle",
                        ["raptor"] = "raptor_saddle",
                        ["iguanodon"] = "iguanodon_saddle",
                        ["triceratops"] = "triceratops_saddle",
                        ["beelzebufo"] = "beelzebufo_saddle",
                        ["terrorbird"] = "terrorbird_saddle",
                        ["equus"] = "equus_saddle",
                        ["pachyrhinosaurus"] = "pachyrhinosaurus_saddle",
                        ["pulmonoscorpius"] = "pulmonoscorpius_saddle",
                        ["carbonemys"] = "carbonemys_saddle",
                        ["megaloceros"] = "megaloceros_saddle",
                        ["gallimimus"] = "gallimimus_saddle",
                        ["stegosaurus"] = "stegosaurus_saddle",
                        ["doedicurus"] = "doedicurus_saddle",
                        ["manta"] = "manta_saddle",
                        ["paracer"] = "paracer_saddle",
                        ["direbear"] = "direbear_saddle",
                        ["diplodocus"] = "diplodocus_saddle",
                        ["pteranodon"] = "pteranodon_saddle",
                        ["sarco"] = "sarco_saddle",
                        ["ankylosaurus"] = "ankylosaurus_saddle",
                        ["mammoth"] = "mammoth_saddle",
                        ["araneo"] = "araneo_saddle",
                        ["dunkleosteus"] = "dunkleosteus_saddle",
                        ["kaprosuchus"] = "kaprosuchus_saddle",
                        ["pelagornis"] = "pelagornis_saddle",
                        ["baryonyx"] = "baryonyx_saddle",
                        ["sabertooth"] = "sabertooth_saddle",
                        ["woollyrhino"] = "woollyrhino_saddle",
                        ["thylacoleo"] = "thylacoleo_saddle",
                        ["chalicotherium"] = "chalicotherium_saddle",
                        ["carno"] = "carno_saddle",
                        ["tapejara"] = "tapejara_saddle",
                        ["daeodon"] = "daeodon_saddle",
                        ["allosaurus"] = "allosaurus_saddle",
                        ["arthropluera"] = "arthropluera_saddle",
                        ["procoptodon"] = "procoptodon_saddle",
                        ["basilosaurus"] = "basilosaurus_saddle",
                        ["argentavis"] = "argentavis_saddle",
                        ["bronto"] = "bronto_saddle",
                        ["castoroides"] = "castoroides_saddle",
                        ["therizinosaur"] = "therizinosaur_saddle",
                        ["rex"] = "rex_saddle",
                        ["spino"] = "spino_saddle",
                        ["plesiosaur"] = "plesiosaur_saddle",
                        ["quetzal"] = "quetzal_saddle",
                        ["tusoteuthis"] = "tusoteuthis_saddle",
                        ["megalosaurus"] = "megalosaurus_saddle",
                        ["mosasaur"] = "mosasaur_saddle",
                        ["giganotosaurus"] = "giganotosaurus_saddle",
                        ["megatherium"] = "megatherium_saddle",
                        ["yutyrannus"] = "yutyrannus_saddle",
                        ["megalania"] = "megalania_saddle",
                        ["carcharodontosaurus"] = "carcharodontosaurus_saddle",
                        ["rhyniognatha"] = "rhyniognatha_saddle"
                    }

                    if tame_to_saddle_map[item_code] then
                        local corresponding_saddle_code = tame_to_saddle_map[item_code]
                        local saddle_obj = Tracker:FindObjectForCode(corresponding_saddle_code)
                        if saddle_obj then
                            saddle_obj.Active = true
                            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                                print(string.format("Bundle Saddles: Automatically activated %s because player received %s", corresponding_saddle_code, item_code))
                            end
                        end
                    end
                end

                if is_local then
                    LOCAL_ITEMS[item_code] = (LOCAL_ITEMS[item_code] or 0) + 1
                else
                    GLOBAL_ITEMS[item_code] = (GLOBAL_ITEMS[item_code] or 0) + 1
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: skipping item_table with no item_code"))
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: skipping empty item_table"))
        end
    end

    if TRACKER_GROUPS_ACTIVE then
        local grouped_members = TRACKER_GROUPS[tostring(item_id)]
        if grouped_members then
            for _, member_id in ipairs(grouped_members) do
                incrementMappedItem(member_id)
            end
        end
    end

    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions for local item tracking here
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    
    local mapping_entry = LOCATION_MAPPING[location_id]
    if not mapping_entry then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onLocation: could not find location mapping for id %s", location_id))
        end
        return
    end
    
    for _, location_table in pairs(mapping_entry) do
        if location_table then
            local location_code = location_table[1]
            if location_code then
                local obj = Tracker:FindObjectForCode(location_code)
                if obj then
                    if location_code:sub(1, 1) == "@" then
                        obj.AvailableChestCount = obj.AvailableChestCount - 1
                    else
                        local item_type = location_table[2]
                        local multiplier = location_table[3] or 1
                        incrementItem(location_code, item_type, multiplier)
                    end
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onLocation: could not find object for code %s", location_code))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onLocation: skipping location_table with no location_code"))
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onLocation: skipping empty location_table"))
        end
    end
end

Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
Archipelago:AddRetrievedHandler("retrieved handler", onDataStorageUpdate)
Archipelago:AddSetReplyHandler("set reply handler", onDataStorageUpdate)