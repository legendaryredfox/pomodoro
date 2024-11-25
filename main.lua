-- main.lua
local timer = {
    work_duration = 25 * 60,
    break_duration = 5 * 60,
    long_break_duration = 25 * 60,
    remaining = 25 * 60,
    isWork = true,
    isRunning = false,
    cycles = 0
}

local buttons = {
    start = {x = 490, y = 400, w = 120, h = 50},
    reset = {x = 670, y = 400, w = 120, h = 50},
    stop_sound = {x = 850, y = 400, w = 120, h = 50} -- New stop sound button
}

local sounds = {
    work_end = nil,
    break_end = nil,
    button_click = nil
}

function love.load()
    -- Set window to 720p resolution
    love.window.setMode(1280, 720, {
        resizable = false,
        vsync = true,
        minwidth = 1280,
        minheight = 720
    })
    
    -- Load fonts
    font = love.graphics.newFont(48)
    smallFont = love.graphics.newFont(24)
    
    -- Load sound files
    sounds.work_end = love.audio.newSource("sounds/work_end.wav", "static")
    sounds.break_end = love.audio.newSource("sounds/break_end.wav", "static")
    sounds.button_click = love.audio.newSource("sounds/click.wav", "static")
    love.window.setTitle("FoxTimer")
end

function playSound(sound)
    if sound then
        -- Stop the sound if it's already playing
        sound:stop()
        -- Reset to beginning and play
        sound:seek(0)
        sound:play()
    end
end

function updateTimer(dt)
    if timer.isRunning then
        timer.remaining = timer.remaining - dt
        if timer.remaining <= 0 then
            if timer.isWork then
                timer.isWork = false
                timer.cycles = timer.cycles + 1
                if timer.cycles % 4 == 0 then
                    timer.remaining = timer.long_break_duration
                else
                    timer.remaining = timer.break_duration
                end
                -- Play work end sound
                if sounds.work_end then
                    love.audio.play(sounds.work_end)
                end
            else
                timer.isWork = true
                timer.remaining = timer.work_duration
                -- Play break end sound
                if sounds.break_end then
                    love.audio.play(sounds.break_end)
                end
            end
        end
    end
end

function love.update(dt)
    updateTimer(dt)
end

function love.draw()
    love.graphics.setFont(font)
    
    -- Draw timer
    local minutes = math.floor(timer.remaining / 60)
    local seconds = math.floor(timer.remaining % 60)
    local timeStr = string.format("%02d:%02d", minutes, seconds)
    
    local status = timer.isWork and "Work Time" or "Break Time"
    love.graphics.printf(status, 0, 180, love.graphics.getWidth(), "center")
    love.graphics.printf(timeStr, 0, 280, love.graphics.getWidth(), "center")
    
    -- Draw buttons
    love.graphics.setFont(smallFont)
    
    -- Start/Pause button with rounded corners and fill
    love.graphics.setColor(0.2, 0.6, 0.8, 1)
    love.graphics.rectangle("fill", buttons.start.x, buttons.start.y, buttons.start.w, buttons.start.h, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(timer.isRunning and "Pause" or "Start", 
        buttons.start.x, buttons.start.y + 12, buttons.start.w, "center")
    
    -- Reset button with rounded corners and fill
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", buttons.reset.x, buttons.reset.y, buttons.reset.w, buttons.reset.h, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Reset", buttons.reset.x, buttons.reset.y + 12, buttons.reset.w, "center")
    
    -- Draw stop sound button
    love.graphics.setColor(0.2, 0.2, 0.8, 1)
    love.graphics.rectangle("fill", buttons.stop_sound.x, buttons.stop_sound.y, buttons.stop_sound.w, buttons.stop_sound.h, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Stop Sound", buttons.stop_sound.x, buttons.stop_sound.y + 12, buttons.stop_sound.w, "center")
    
    -- Draw cycles with improved styling
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    love.graphics.printf("Completed cycles: " .. timer.cycles, 
        0, 500, love.graphics.getWidth(), "center")
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Left click
        -- Start/Pause button
        if x >= buttons.start.x and x <= buttons.start.x + buttons.start.w and
           y >= buttons.start.y and y <= buttons.start.y + buttons.start.h then
            timer.isRunning = not timer.isRunning
            playSound(sounds.button_click)
        end
        
        -- Reset button
        if x >= buttons.reset.x and x <= buttons.reset.x + buttons.reset.w and
           y >= buttons.reset.y and y <= buttons.reset.y + buttons.reset.h then
            timer.remaining = timer.work_duration
            timer.isWork = true
            timer.isRunning = false
            playSound(sounds.button_click)
        end
        
        -- Stop sound button
        if x >= buttons.stop_sound.x and x <= buttons.stop_sound.x + buttons.stop_sound.w and
           y >= buttons.stop_sound.y and y <= buttons.stop_sound.y + buttons.stop_sound.h then
            love.audio.stop()
            playSound(sounds.button_click)
        end
    end
end