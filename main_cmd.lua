FOAddon = {};
FOAddon.fully_loaded = false;

local function GetAllRaidMembers(msg)
    if msg == "reset" then
        _G.FallenOathRaidMembers = {}
        print("Reset stored RaidMemebers.")
        return
    end

    _G.FallenOathRaidMembers[msg] = {}
    local members = {}
    local class_names = {}
    for i = 1, MAX_RAID_MEMBERS do
        name, _, _, _, class = GetRaidRosterInfo(i)
        if name ~= nil then
            if members[class] == nil then
                members[class] = {}
                table.insert(class_names, class)
            end
            table.insert(members[class], name)
        end
    end

    table.sort(class_names)
    for _, class_name in ipairs(class_names) do
        _G.FallenOathRaidMembers[msg][class_name] = members[class_name]
        table.sort(_G.FallenOathRaidMembers[msg][class_name])
    end

    print("Updated RaidMemebers, will be saved to file when UI reload or logout.")
end

SLASH_RAIDRECORD1 = "/raid_record"
SLASH_RAIDRECORD2 = "/rr"
SlashCmdList["RAIDRECORD"] = GetAllRaidMembers
