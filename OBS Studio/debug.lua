obs = obslua

function log_hotkey_data(hotkey_data)
    local count = obs.obs_data_array_count(hotkey_data)
    obs.script_log(obs.LOG_INFO, "Hotkey data count: " .. count)
    
    for i = 0, count - 1 do
        local item = obs.obs_data_array_item(hotkey_data, i)
        local item_str = obs.obs_data_get_json(item)
        obs.script_log(obs.LOG_INFO, "Hotkey data item " .. i .. ": " .. item_str)
        obs.obs_data_release(item)
    end
end