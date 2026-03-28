-- SNAKE.lua
setTextSize(2)
local snake = {{x=15, y=10}, {x=14, y=10}, {x=13, y=10}}
local dx, dy = 1, 0
local fx, fy = 20, 10
local score = 0
local canTurn = true
local CELL = 16
local gameOver = false

-- Initial setup
cls(0)

while not gameOver do
    -- 1. Input Handling
    if canTurn then
        if isKeyDown(0x1A) and dy == 0 then dx, dy = 0, -1 canTurn = false -- W
        elseif isKeyDown(0x16) and dy == 0 then dx, dy = 0, 1 canTurn = false -- S
        elseif keyCheck == 0x04 and dx == 0 then dx, dy = -1, 0 canTurn = false -- A (Fixed variable name)
        elseif isKeyDown(0x04) and dx == 0 then dx, dy = -1, 0 canTurn = false -- A
        elseif isKeyDown(0x07) and dx == 0 then dx, dy = 1, 0 canTurn = false -- D
        end
    end

    local head = {x = snake[1].x + dx, y = snake[1].y + dy}

    -- 2. Logic & Collision
    -- Wall Collision
    if head.x < 0 or head.x >= 30 or head.y < 0 or head.y >= 20 then 
        gameOver = true 
    end
    
    -- Self Collision
    if not gameOver then
        for i, v in ipairs(snake) do
            if head.x == v.x and head.y == v.y then 
                gameOver = true
                break
            end
        end
    end

    if not gameOver then
        -- Dirty Rect: Erase tail
        local tail = snake[#snake]
        fillRect(tail.x * CELL, tail.y * CELL, CELL - 1, CELL - 1, 0)

        table.insert(snake, 1, head)

        -- Food Collision
        if head.x == fx and head.y == fy then
            score = score + 10
            playSound(1500, 20)
            fx, fy = math.random(0, 29), math.random(0, 19)
        else
            table.remove(snake)
        end

        -- 3. Rendering
        -- New Head (White)
        fillRect(head.x * CELL, head.y * CELL, CELL - 1, CELL - 1, 0xFFFF)
        -- Update previous head to Body (Green)
        if #snake > 1 then
            fillRect(snake[2].x * CELL, snake[2].y * CELL, CELL - 1, CELL - 1, 0x07E0)
        end
        -- Food (Red)
        fillRect(fx * CELL, fy * CELL, CELL - 1, CELL - 1, 0xF800)

        -- UI: Clear score area first to prevent overlapping text
        fillRect(5, 5, 120, 10, 0) 
        setTextSize(2)
        printAt(5, 5, "SCORE: " .. score, 0xFFFF)
        
        canTurn = true
    end

    -- ESC Key to exit mid-game
    if isKeyDown(0x29) then break end
    
    delay(100)
end

-- --- S3 ULTIMATE GAME OVER SCREEN ---
if gameOver then
    playSound(150, 500)
    cls(0)
    
    setTextSize(5)
    printAt(100, 60, "GAME OVER", 0xF800)
    
    setTextSize(3)
    printAt(130, 140, "Score: " .. score, 0xFFFF)
    
    delay(1000) 
    
    setTextSize(2)
    printAt(100, 240, "RELEASE BUTTON...", 0x07FF)
    
    -- Gate: Wait for Enter release
    while isKeyDown(0x28) do delay(10) end
    
    fillRect(100, 240, 300, 30, 0)
    printAt(110, 240, "PRESS ENTER TO RETURN", 0x07FF)
    
    -- Gate: Wait for Enter press
    while not isKeyDown(0x28) do delay(10) end
    
    playSound(1200, 50)
    delay(300)
end