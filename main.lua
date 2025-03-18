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
    start = {x = 440, y = 400, w = 150, h = 50},
    reset = {x = 620, y = 400, w = 150, h = 50},
    stop_sound = {x = 800, y = 400, w = 150, h = 50}
}

local sounds = {
    work_end = nil,
    break_end = nil,
    button_click = nil
}

function love.load()
    love.window.setMode(1280, 720, {
        resizable = false,
        vsync = true,
        minwidth = 1280,
        minheight = 720
    })

    font = love.graphics.newFont("fonts/JetBrainsMono-Regular.ttf", 48)
    smallFont = love.graphics.newFont("fonts/JetBrainsMono-Regular.ttf", 24)

    sounds.work_end = love.audio.newSource("sounds/work_end.wav", "static")
    sounds.break_end = love.audio.newSource("sounds/break_end.wav", "static")
    sounds.button_click = love.audio.newSource("sounds/click.wav", "static")
    love.window.setTitle("FoxTimer")
end

function love.update(dt)
    if timer.isRunning then
        timer.remaining = timer.remaining - dt
        if timer.remaining <= 0 then
            if timer.isWork then
                timer.isWork = false
                timer.cycles = timer.cycles + 1
                timer.remaining = (timer.cycles % 4 == 0) and timer.long_break_duration or timer.break_duration
                if sounds.work_end then love.audio.play(sounds.work_end) end
            else
                timer.isWork = true
                timer.remaining = timer.work_duration
                if sounds.break_end then love.audio.play(sounds.break_end) end
            end
        end
    end
end

function love.draw()
    love.graphics.clear(245/255, 245/255, 245/255, 1)
    love.graphics.setFont(font)
    love.graphics.setColor(0.2, 0.2, 0.2, 1)

    local minutes = math.floor(timer.remaining / 60)
    local seconds = math.floor(timer.remaining % 60)
    local timeStr = string.format("%02d:%02d", minutes, seconds)

    love.graphics.printf(timer.isWork and "Work Time" or "Break Time", 0, 160, love.graphics.getWidth(), "center")
    love.graphics.printf(timeStr, 0, 240, love.graphics.getWidth(), "center")

    love.graphics.setFont(smallFont)

    local button_colors = {
        {50/255, 130/255, 184/255, 1},
        {184/255, 50/255, 50/255, 1},
        {80/255, 50/255, 184/255, 1}
    }

    for i, button in ipairs({buttons.start, buttons.reset, buttons.stop_sound}) do
        love.graphics.setColor(button_colors[i])
        love.graphics.rectangle("fill", button.x, button.y, button.w, button.h, 10, 10)
        love.graphics.setColor(1, 1, 1, 1)
        local text = (i == 1) and (timer.isRunning and "Pause" or "Start") or (i == 2 and "Reset" or "Stop Sound")
        love.graphics.printf(text, button.x, button.y + 12, button.w, "center")
    end

    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.printf("Completed cycles: " .. timer.cycles, 0, 500, love.graphics.getWidth(), "center")
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if x >= buttons.start.x and x <= buttons.start.x + buttons.start.w and
           y >= buttons.start.y and y <= buttons.start.y + buttons.start.h then
            timer.isRunning = not timer.isRunning
            love.audio.play(sounds.button_click)
        elseif x >= buttons.reset.x and x <= buttons.reset.x + buttons.reset.w and
               y >= buttons.reset.y and y <= buttons.reset.y + buttons.reset.h then
            timer.remaining = timer.work_duration
            timer.isWork = true
            timer.isRunning = false
            love.audio.play(sounds.button_click)
        elseif x >= buttons.stop_sound.x and x <= buttons.stop_sound.x + buttons.stop_sound.w and
               y >= buttons.stop_sound.y and y <= buttons.stop_sound.y + buttons.stop_sound.h then
            love.audio.stop()
            love.audio.play(sounds.button_click)
        end
    end
end
