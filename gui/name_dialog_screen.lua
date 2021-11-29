dependents =
{
    "skins.lua",
}
text_styles =
{
}
skins =
{
}
widgets =
{
    {
        name = [[New Widget]],
        isVisible = true,
        noInput = false,
        anchor = 0,
        rotation = 0,
        x = 0,
        y = 0,
        w = 1,
        h = 1,
        sx = 2,
        sy = 2,
        ctor = [[image]],
        color =
        {
            0,
            0,
            0,
            0.705882370471954,
        },
        images =
        {
            {
                file = [[white.png]],
                name = [[]],
                color =
                {
                    0,
                    0,
                    0,
                    0.705882370471954,
                },
            },
        },
    },
    {
        name = [[pnl]],
        isVisible = true,
        noInput = false,
        anchor = 0,
        rotation = 0,
        x = 0,
        y = -0.01388889,
        w = 0,
        h = 0,
        sx = 1,
        sy = 1,
        ctor = [[group]],
        children =
        {
            {
                name = [[bg]],
                isVisible = true,
                noInput = false,
                anchor = 1,
                rotation = 0,
                x = 0,
                xpx = true,
                y = 92, -- -8,
                ypx = true,
                w = 688,
                wpx = true,
                h = 200, -- 400,
                hpx = true,
                sx = 1,
                sy = 1,
                ctor = [[image]],
                color =
                {
                    0.0784313753247261,
                    0.0784313753247261,
                    0.0784313753247261,
                    0.901960790157318,
                },
                images =
                {
                    {
                        file = [[white.png]],
                        name = [[]],
                        color =
                        {
                            0.0784313753247261,
                            0.0784313753247261,
                            0.0784313753247261,
                            0.901960790157318,
                        },
                    },
                },
            },
            {
                name = [[header box]],
                isVisible = true,
                noInput = false,
                anchor = 1,
                rotation = 0,
                x = 0,
                xpx = true,
                y = 196,
                ypx = true,
                w = 688,
                wpx = true,
                h = 14,
                hpx = true,
                sx = 1,
                sy = 1,
                ctor = [[image]],
                color =
                {
                    0.549019634723663,
                    1,
                    1,
                    1,
                },
                images =
                {
                    {
                        file = [[white.png]],
                        name = [[]],
                        color =
                        {
                            0.549019634723663,
                            1,
                            1,
                            1,
                        },
                    },
                },
            },
            {
                name = [[header]],
                isVisible = true,
                noInput = false,
                anchor = 1,
                rotation = 0,
                x = -63,
                xpx = true,
                y = 155,
                ypx = true,
                w = 400,
                wpx = true,
                h = 54,
                hpx = true,
                sx = 1,
                sy = 1,
                ctor = [[label]],
                halign = MOAITextBox.LEFT_JUSTIFY,
                valign = MOAITextBox.LEFT_JUSTIFY,
                text_style = [[font1_36_r]],
                color =
                {
                    0.549019634723663,
                    1,
                    1,
                    1,
                },
            },
            {
                name = [[header box 2]],
                isVisible = true,
                noInput = false,
                anchor = 1,
                rotation = 0,
                x = 0,
                xpx = true,
                y = 140,
                ypx = true,
                w = 640,
                wpx = true,
                h = 1,
                hpx = true,
                sx = 1,
                sy = 1,
                ctor = [[image]],
                color =
                {
                    0.549019634723663,
                    1,
                    1,
                    1,
                },
                images =
                {
                    {
                        file = [[white.png]],
                        name = [[]],
                        color =
                        {
                            0.549019634723663,
                            1,
                            1,
                            1,
                        },
                    },
                },
            },
            {
                name = [[inputBox]],
                isVisible = true,
                noInput = false,
                anchor = 1,
                rotation = 0,
                x = 1,
                xpx = true,
                y = 102,
                ypx = true,
                w = 560,
                wpx = true,
                h = 38,
                hpx = true,
                sx = 1,
                sy = 1,
                ctor = [[editbox]],
                clickSound = [[SpySociety/HUD/menu/click]],
                hoverSound = [[SpySociety/HUD/menu/rollover]],
                hoverScale = 1,
                halign = MOAITextBox.LEFT_JUSTIFY,
                valign = MOAITextBox.CENTER_JUSTIFY,
                text_style = [[font1_16_r]],
                isMultiline = false,
                maxEditChars = 100,
                offset =
                {
                    x = 20,
                    xpx = true,
                    y = 0,
                    ypx = true,
                },
                color =
                {
                    0.549019634723663,
                    1,
                    1,
                    1,
                },
                images =
                {
                    {
                        file = [[white.png]],
                        name = [[inactive]],
                        color =
                        {
                            0.219607844948769,
                            0.376470595598221,
                            0.376470595598221,
                            1,
                        },
                    },
                    {
                        file = [[white.png]],
                        name = [[hover]],
                        color =
                        {
                            0.39215686917305,
                            0.690196096897125,
                            0.690196096897125,
                            1,
                        },
                    },
                    {
                        file = [[white.png]],
                        name = [[active]],
                        color =
                        {
                            0.39215686917305,
                            0.690196096897125,
                            0.690196096897125,
                            1,
                        },
                    },
                },
            },
            {
                name = [[option1Btn]],
                isVisible = true,
                noInput = false,
                anchor = 1,
                rotation = 0,
                x = 1,
                xpx = true,
                y = 58,
                ypx = true,
                w = 560,
                wpx = true,
                h = 38,
                hpx = true,
                sx = 1,
                sy = 1,
                ctor = [[button]],
                clickSound = [[SpySociety/HUD/menu/click]],
                hoverSound = [[SpySociety/HUD/menu/rollover]],
                hoverScale = 1,
                halign = MOAITextBox.LEFT_JUSTIFY,
                valign = MOAITextBox.CENTER_JUSTIFY,
                text_style = [[font1_16_r]],
                offset =
                {
                    x = 20,
                    xpx = true,
                    y = 0,
                    ypx = true,
                },
                color =
                {
                    0.549019634723663,
                    1,
                    1,
                    1,
                },
                images =
                {
                    {
                        file = [[white.png]],
                        name = [[inactive]],
                        color =
                        {
                            0.219607844948769,
                            0.376470595598221,
                            0.376470595598221,
                            1,
                        },
                    },
                    {
                        file = [[white.png]],
                        name = [[hover]],
                        color =
                        {
                            0.39215686917305,
                            0.690196096897125,
                            0.690196096897125,
                            1,
                        },
                    },
                    {
                        file = [[white.png]],
                        name = [[active]],
                        color =
                        {
                            0.39215686917305,
                            0.690196096897125,
                            0.690196096897125,
                            1,
                        },
                    },
                },
            },
        },
    },
}
transitions =
{
    {
        name = [[activate]],
        dx0 = -0.1,
        dy0 = 0,
        dx1 = 0,
        dy1 = 0,
        duration = 0.5,
    },
    {
        name = [[deactivate]],
        dx0 = 0,
        dy0 = 0,
        dx1 = 0.1,
        dy1 = 0,
        duration = 0.5,
    },
}
properties =
{
    sinksInput = true,
    activateTransition = [[activate_left]],
    deactivateTransition = [[deactivate_right]],
}
return { dependents = dependents, text_styles = text_styles, transitions = transitions, skins = skins, widgets = widgets, properties = properties, currentSkin = nil }
