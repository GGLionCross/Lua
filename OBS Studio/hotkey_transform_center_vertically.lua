obs = obslua

-- Called when hotkey is pressed
function center_vertically_pressed(pressed)
    if pressed then
        obs.script_log(obs.LOG_INFO, "Center Vertically hotkey pressed!")
        center_vertically()
    end
end

-- Function to get the currently selected scene item
function get_selected_scene_item(scene)
    local scene_items = obs.obs_scene_enum_items(scene)
    local selected_item = nil
    local item_count = 0
    
    for _, scene_item in ipairs(scene_items) do
        item_count = item_count + 1
        if obs.obs_sceneitem_selected(scene_item) then
            selected_item = scene_item
            break
        end
    end
    
    obs.sceneitem_list_release(scene_items)
    return selected_item
end

-- Center a scene item vertically
function center_vertically()
    -- Get the preview scene
    local source = obs.obs_frontend_get_current_preview_scene()
    
    -- Get the current scene (that is LIVE)
    -- local source = obs.obs_frontend_get_current_scene()

    -- Log the scene name
    local scene_name = obs.obs_source_get_name(source)
    obs.script_log(obs.LOG_INFO, "Current scene: \"" .. scene_name .. "\"")

    local scene = obs.obs_scene_from_source(source)
    
    -- Get the currently selected scene item
    local scene_item = get_selected_scene_item(scene)
    
    if not scene_item then
        obs.script_log(obs.LOG_WARNING, "No scene item selected.")
        obs.obs_source_release(source)
        return
    end
    
    -- Get the source of the scene item
    local item_source = obs.obs_sceneitem_get_source(scene_item)
    
    -- Get the base height of the source
    local base_height = obs.obs_source_get_height(item_source)
    
    -- Get the scale of the scene item
    local scale = obs.vec2()
    obs.obs_sceneitem_get_scale(scene_item, scale)
    
    -- Calculate the actual height of the scene item
    local item_height = base_height * scale.y
    
    -- Get the scene dimensions
    local scene_height = obs.obs_source_get_height(source)
    
    -- Calculate the vertical center position
    local new_y = (scene_height - item_height) / 2
    
    -- Set the scene item's position to the calculated center
    local pos = obs.vec2()
    obs.obs_sceneitem_get_pos(scene_item, pos) -- Get current position of scene item
    pos.y = new_y
    obs.obs_sceneitem_set_pos(scene_item, pos)
    
    -- Release the source reference
    obs.obs_source_release(source)
end

-- Global variable to store the hotkey ID
hotkey_id = obs.OBS_INVALID_HOTKEY_ID

-- Script properties
function script_properties()
    local props = obs.obs_properties_create()
    return props
end

-- Script defaults
function script_defaults(settings)
    -- No direct way to set default key bindings in script_defaults
end

-- Script load
function script_load(settings)
    -- Register the hotkey
    hotkey_id = obs.obs_hotkey_register_frontend("hotkey_transform_center_vertically", "Center Vertically", center_vertically_pressed)

    -- Load saved hotkey or set default
    local hotkey_data = obs.obs_data_get_array(settings, "hotkey_transform_center_vertically")
    if obs.obs_data_array_count(hotkey_data) == 0 then
        -- No hotkey set, create default hotkey {"control": true, "key": "OBS_KEY_G"}
        local default_hotkey_data = obs.obs_data_array_create()
        local hotkey_item = obs.obs_data_create()
        obs.obs_data_set_bool(hotkey_item, "control", true)
        obs.obs_data_set_string(hotkey_item, "key", "OBS_KEY_G")
        obs.obs_data_array_push_back(default_hotkey_data, hotkey_item)
        obs.obs_data_release(hotkey_item)
        obs.obs_data_set_default_array(settings, "hotkey_transform_center_vertically", default_hotkey_data)
        obs.obs_data_array_release(default_hotkey_data)
        hotkey_data = obs.obs_data_get_array(settings, "hotkey_transform_center_vertically")
    end
    obs.script_log(obs.LOG_INFO, hotkey_data)
    obs.obs_hotkey_load(hotkey_id, hotkey_data)
    obs.obs_data_array_release(hotkey_data)
end

-- Script save
function script_save(settings)
    -- Save the hotkey configuration
    local hotkey_data = obs.obs_hotkey_save(hotkey_id)
    obs.obs_data_set_array(settings, "hotkey_transform_center_vertically", hotkey_data)
    obs.obs_data_array_release(hotkey_data)
end

-- Script unload
function script_unload()
    -- Unregister the hotkey
    obs.obs_hotkey_unregister(hotkey_id)
end
