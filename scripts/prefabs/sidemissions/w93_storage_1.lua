-- Autogenerated lua file by the Spyface tool
-- 'Wimps and posers -- leave the hall! -- ManOwaR
--
-- DO NOT HAND EDIT.
--
local tiles =
{
    {
        x = 6,
        y = 1,
        zone = [[om_holo]],
        variant = 0,
        impass = 1,
        cover = 1,
    },
    {
        x = 6,
        y = 2,
        zone = [[om_holo]],
        variant = 0,
        noiseRadius = 5,
    },
    {
        x = 5,
        y = 1,
        zone = [[om_holo]],
        variant = 0,
        impass = 1,
        cover = 1,
    },
    {
        x = 5,
        y = 2,
        zone = [[om_holo]],
        variant = 0,
        noiseRadius = 5,
    },
    {
        x = 6,
        y = 3,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 5,
        y = 3,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 4,
        y = 3,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 3,
        y = 2,
        zone = [[om_holo]],
        variant = 0,
        noiseRadius = 5,
    },
    {
        x = 4,
        y = 2,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 4,
        y = 1,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 3,
        y = 1,
        zone = [[om_holo]],
        variant = 0,
        dynamic_impass = 1,
    },
    {
        x = 3,
        y = 3,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 2,
        y = 1,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 2,
        y = 2,
        zone = [[om_holo]],
        variant = 0,
        noiseRadius = 5,
    },
    {
        x = 2,
        y = 3,
        zone = [[om_holo]],
        variant = 0,
        impass = 1,
        cover = 1,
    },
    {
        x = 7,
        y = 3,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 7,
        y = 2,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 7,
        y = 1,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 1,
        y = 1,
        zone = [[om_holo]],
        variant = 0,
        impass = 1,
        cover = 1,
    },
    {
        x = 1,
        y = 2,
        zone = [[om_holo]],
        variant = 0,
    },
    {
        x = 1,
        y = 3,
        zone = [[om_holo]],
        variant = 0,
        impass = 1,
        cover = 1,
    },
}
local walls =
{
    {
        x = 7,
        y = 0,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 7,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 6,
        y = 0,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 6,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 5,
        y = 0,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 5,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 4,
        y = 0,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 4,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 3,
        y = 0,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 3,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 2,
        y = 0,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 2,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 1,
        y = 0,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 1,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 1,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 4,
    },
    {
        x = 0,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 0,
    },
    {
        x = 1,
        y = 2,
        wallIndex = [[default_wall]],
        dir = 4,
    },
    {
        x = 0,
        y = 2,
        wallIndex = [[default_wall]],
        dir = 0,
    },
    {
        x = 1,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 4,
    },
    {
        x = 0,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 0,
    },
    {
        x = 1,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 1,
        y = 4,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 2,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 2,
        y = 4,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 3,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 3,
        y = 4,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 4,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 4,
        y = 4,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 5,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 5,
        y = 4,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 6,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 6,
        y = 4,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 7,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 2,
    },
    {
        x = 7,
        y = 4,
        wallIndex = [[default_wall]],
        dir = 6,
    },
    {
        x = 8,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 4,
    },
    {
        x = 7,
        y = 3,
        wallIndex = [[default_wall]],
        dir = 0,
    },
    {
        x = 8,
        y = 2,
        wallIndex = [[default_wall]],
        dir = 4,
    },
    {
        x = 7,
        y = 2,
        wallIndex = [[default_wall]],
        dir = 0,
    },
    {
        x = 8,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 4,
    },
    {
        x = 7,
        y = 1,
        wallIndex = [[default_wall]],
        dir = 0,
    },
}
local units =
{
    {
        maxCount = 1,
        spawnChance = 1,
        {
            {
                x = 3,
                y = 1,
                template = [[guard_locker]],
                unitData =
                {
                    facing = 2,
                    tags =
                    {
                        "w93_storage_1",
                    },
                },
            },
            1,
        },
    },
}
local decos =
{
    {
        x = 1,
        y = 1,
        kanim = [[decor_engineroom_1x1_gear2]],
        facing = 0,
    },
    {
        x = 6,
        y = 1,
        kanim = [[decor_engineroom_2x1_stackedpipes1]],
        facing = 2,
    },
    {
        x = 7,
        y = 1,
        kanim = [[decor_engineroom_1x1_walllight1]],
        facing = 2,
    },
    {
        x = 1,
        y = 1,
        kanim = [[decor_engineroom_1x1_walllight1]],
        facing = 2,
    },
    {
        x = 1,
        y = 3,
        kanim = [[decor_engineroom_1x1_walllight1]],
        facing = 6,
    },
    {
        x = 7,
        y = 3,
        kanim = [[decor_engineroom_1x1_walllight1]],
        facing = 6,
    },
    {
        x = 2,
        y = 2,
        kanim = [[decor_engineroom_2x1_floorpanel1]],
        facing = 6,
    },
    {
        x = 1,
        y = 3,
        kanim = [[decor_engineroom_2x1_gear1]],
        facing = 6,
    },
    {
        x = 6,
        y = 3,
        kanim = [[decor_engineroom_1x1_wallgear1]],
        facing = 6,
    },
    {
        x = 5,
        y = 2,
        kanim = [[decor_engineroom_2x1_floorpanel1]],
        facing = 6,
    },
}
local lights =
{
}
local sounds =
{
}
local export =
{
    cgraph =
    {
        edges =
        {
            {
                id0 = 0,
                x0 = 7,
                y0 = 0,
                id1 = 101,
                x1 = 7,
                y1 = 1,
            },
            {
                id0 = 2,
                x0 = 6,
                y0 = 0,
                id1 = 101,
                x1 = 6,
                y1 = 1,
            },
            {
                id0 = 3,
                x0 = 5,
                y0 = 0,
                id1 = 101,
                x1 = 5,
                y1 = 1,
            },
            {
                id0 = 4,
                x0 = 4,
                y0 = 0,
                id1 = 101,
                x1 = 4,
                y1 = 1,
            },
            {
                id0 = 5,
                x0 = 3,
                y0 = 0,
                id1 = 101,
                x1 = 3,
                y1 = 1,
            },
            {
                id0 = 6,
                x0 = 2,
                y0 = 0,
                id1 = 101,
                x1 = 2,
                y1 = 1,
            },
            {
                id0 = 7,
                x0 = 1,
                y0 = 0,
                id1 = 101,
                x1 = 1,
                y1 = 1,
            },
            {
                id0 = 101,
                x0 = 1,
                y0 = 1,
                id1 = 8,
                x1 = 0,
                y1 = 1,
            },
            {
                id0 = 101,
                x0 = 1,
                y0 = 2,
                id1 = 9,
                x1 = 0,
                y1 = 2,
            },
            {
                id0 = 101,
                x0 = 1,
                y0 = 3,
                id1 = 10,
                x1 = 0,
                y1 = 3,
            },
            {
                id0 = 101,
                x0 = 1,
                y0 = 3,
                id1 = 11,
                x1 = 1,
                y1 = 4,
            },
            {
                id0 = 101,
                x0 = 2,
                y0 = 3,
                id1 = 12,
                x1 = 2,
                y1 = 4,
            },
            {
                id0 = 101,
                x0 = 3,
                y0 = 3,
                id1 = 13,
                x1 = 3,
                y1 = 4,
            },
            {
                id0 = 101,
                x0 = 4,
                y0 = 3,
                id1 = 14,
                x1 = 4,
                y1 = 4,
            },
            {
                id0 = 101,
                x0 = 5,
                y0 = 3,
                id1 = 15,
                x1 = 5,
                y1 = 4,
            },
            {
                id0 = 101,
                x0 = 6,
                y0 = 3,
                id1 = 16,
                x1 = 6,
                y1 = 4,
            },
            {
                id0 = 101,
                x0 = 7,
                y0 = 3,
                id1 = 17,
                x1 = 7,
                y1 = 4,
            },
            {
                id0 = 18,
                x0 = 8,
                y0 = 3,
                id1 = 101,
                x1 = 7,
                y1 = 3,
            },
            {
                id0 = 19,
                x0 = 8,
                y0 = 2,
                id1 = 101,
                x1 = 7,
                y1 = 2,
            },
            {
                id0 = 20,
                x0 = 8,
                y0 = 1,
                id1 = 101,
                x1 = 7,
                y1 = 1,
            },
            {
                id0 = 2,
                x0 = 6,
                y0 = 0,
                id1 = 101,
                x1 = 6,
                y1 = 1,
            },
            {
                id0 = 3,
                x0 = 5,
                y0 = 0,
                id1 = 101,
                x1 = 5,
                y1 = 1,
            },
            {
                id0 = 5,
                x0 = 3,
                y0 = 0,
                id1 = 101,
                x1 = 3,
                y1 = 1,
            },
            {
                id0 = 12,
                x0 = 2,
                y0 = 4,
                id1 = 101,
                x1 = 2,
                y1 = 3,
            },
            {
                id0 = 7,
                x0 = 1,
                y0 = 0,
                id1 = 101,
                x1 = 1,
                y1 = 1,
            },
            {
                id0 = 8,
                x0 = 0,
                y0 = 1,
                id1 = 101,
                x1 = 1,
                y1 = 1,
            },
            {
                id0 = 11,
                x0 = 1,
                y0 = 4,
                id1 = 101,
                x1 = 1,
                y1 = 3,
            },
            {
                id0 = 10,
                x0 = 0,
                y0 = 3,
                id1 = 101,
                x1 = 1,
                y1 = 3,
            },
        },
    },
    width = 7,
    height = 3,
    version = 1,
    tiles = tiles,
    walls = walls,
    units = units,
    decos = decos,
    lights = lights,
    sounds = sounds,
}
return export