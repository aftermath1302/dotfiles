--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful


hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})


hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

-- SwayNC blur
hl.layer_rule({
    name = "swaync-control-center-blur",
    match = {
        namespace = "swaync-control-center",
    },
    blur = true,
})

hl.layer_rule({
    name = "swaync-notification-blur",
    match = {
        namespace = "swaync-notification-window",
    },
    blur = true,
})


-- Only blur sufficiently opaque areas
hl.layer_rule({
    name = "swaync-control-center-ignorealpha",
    match = {
        namespace = "swaync-control-center",
    },
    ignore_alpha = 0.5,
})

hl.layer_rule({
    name = "swaync-notification-ignorealpha",
    match = {
        namespace = "swaync-notification-window",
    },
    ignore_alpha = 0.5,
})