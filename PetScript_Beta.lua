--PETSCRIPT BETA--

util.require_natives(1651208000)

local myroot = menu.my_root()
local petroot = myroot

menu.divider(myroot, "PetScript")

local function getgroupsize(group) --thanks to wiriscript for this function--
    local unkPtr, sizePtr = memory.alloc(1), memory.alloc(1)
    PED.GET_GROUP_SIZE(group, unkPtr, sizePtr)
    return memory.read_int(sizePtr)
end

local mygroup = PLAYER.GET_PLAYER_GROUP(players.user())

local dogs <const> = table.freeze({
    "Rottweiler",
    "Husky",
    "Poodle",
    "Pug",
    "Retriever",
    "Westy",
    "Shepherd",
    "Cat_01",
})

local doganimations = {
    "WORLD_DOG_SITTING_ROTTWEILER",
    "WORLD_DOG_SITTING_RETRIEVER",
    "WORLD_DOG_SITTING_SHEPHERD",
    "WORLD_DOG_SITTING_SMALL",
}

local activedogs = {}

local function GenerateNametagOnPed(ped, nametag)
    while ENTITY.DOES_ENTITY_EXIST(ped) or not ENTITY.IS_ENTITY_DEAD() do
        local headpos = PED.GET_PED_BONE_COORDS(ped, 0x796e, 0,0,0)
        GRAPHICS.SET_DRAW_ORIGIN(headpos.x, headpos.y, headpos.z+0.4, 0)

        HUD.SET_TEXT_COLOUR(200,200,200,220)
        HUD.SET_TEXT_SCALE(1, 0.5)
        HUD.SET_TEXT_CENTRE(true)
        HUD.SET_TEXT_FONT(4)
        HUD.SET_TEXT_OUTLINE()

        HUD.BEGIN_TEXT_COMMAND_DISPLAY_TEXT("STRING")
        HUD.ADD_TEXT_COMPONENT_SUBSTRING_PLAYER_NAME(nametag)
        HUD.END_TEXT_COMMAND_DISPLAY_TEXT(0,0,0)
        GRAPHICS.CLEAR_DRAW_ORIGIN()
        util.yield()
    end
end

local activepetroot = menu.list(petroot, "Active Pets", {}, "These are your currently active pets.")

menu.action_slider(petroot, "Spawn a Pet", {}, "Spawns a loyal companion that will follow and defend you.", dogs, function(opt, breeds)
    local hash = util.joaat("A_C_" .. breeds)
    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do
        util.yield()
    end
    local coords = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(players.user_ped(), 0, math.random(1,4), 0)
    if getgroupsize(mygroup) >= 7 then
        util.toast("You have exceeded the maximum number of pets.")
    else
        local dog_ped = entities.create_ped(26, hash, coords, 0)
        activedogs[#activedogs+1] = dog_ped
        PED.SET_PED_AS_GROUP_MEMBER(dog_ped, mygroup)
        PED.SET_PED_AS_GROUP_MEMBER(dog_ped, mygroup)
        PED.SET_PED_NEVER_LEAVES_GROUP(dog_ped, true)
        PED.SET_GROUP_SEPARATION_RANGE(mygroup, 99999)

        local thispetroot = menu.list(activepetroot, breeds, {}, "")
        
        --ANIMAL FUNCTIONS BEGIN--
        
        menu.action(thispetroot, "Set Name", {"setname"}, "", function()
            menu.show_command_box("setname ")
            util.toast("Input pet name.")
        end, function(on_command)
            local nametag = on_command            
            GenerateNametagOnPed(dog_ped, nametag)
        end)

        --DOG SPECIFIC FUNCTIONS--

        if breeds ~= "Cat_01" then

            menu.toggle(thispetroot, "Sit", {}, "Makes your pet sit.", function(on)
                if on then
                    if breeds == "Rottweiler" then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                        TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, doganimations[1], 0, true)
                    elseif breeds == "Retriever" then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                        TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, doganimations[2], 0, true)
                    elseif breeds == "Shepherd" then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                        TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, doganimations[3], 0, true)
                    elseif breeds == "Husky" then
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                        TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, doganimations[3], 0, true)
                    else
                        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                        TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, doganimations[4], 0, true)

                    end
                else
                    TASK.CLEAR_PED_TASKS(dog_ped)
                end
            end)

            --Make Ped Bark

            menu.action(thispetroot, "Bark", {}, "Bark!", function()
                if breeds == "Rottweiler" then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, "WORLD_DOG_BARKING_ROTWEILER", 0, true)
                elseif breeds == "Retriever" then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, "WORLD_DOG_BARKING_RETRIEVER", 0, true)
                elseif breeds == "Shepherd" then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, "WORLD_DOG_BARKING_SHEPHERD", 0, true)
                elseif breeds == "Husky" then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, "WORLD_DOG_BARKING_SHEPHERD", 0, true)
                else
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, "WORLD_DOG_BARKING_SMALL", 0, true)
                end
                util.yield(5000)
                TASK.CLEAR_PED_TASKS(dog_ped)
            end)
        end

        --CAT SPECIFIC FUNCTIONS--

        if breeds == "Cat_01" then 
            menu.toggle(thispetroot, "Lie Down and Chill", {}, "", function(on)
                if on then
                    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(dog_ped)
                    TASK.TASK_START_SCENARIO_IN_PLACE(dog_ped, "WORLD_CAT_SLEEPING_GROUND", 0, true)
                else
                    TASK.CLEAR_PED_TASKS(dog_ped)
                end
            end)
        end

        --DELETE PED
        menu.action(thispetroot, "Delete Pet", {}, "RIP in Peace, my furry friend.", function()
            entities.delete_by_handle(dog_ped)
            menu.delete(thispetroot)
        end)
    end
end)

util.keep_running()

