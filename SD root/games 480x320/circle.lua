-- CIRCLE.lua (S3 ULTIMATE - KEYBOARD VERSION)
setTextSize(1)
cls(0)

-- 1. SETUP & SPEED (Matching C++ Difficulty)
local difficulty = 1.0 
local pSpeed = 2.5 + (difficulty * 1.0)
local cSpeed = 0.4 + (difficulty * 0.4)

local score, r = 0, 15
local px, py = 50.0, 50.0
local oldX, oldY = 50, 50

local SCREEN_W, SCREEN_H = 480, 320
local tx = math.random(r, SCREEN_W - r)
local ty = math.random(r, SCREEN_H - r)

local cx, cy = SCREEN_W - 50.0, SCREEN_H - 50.0
local oldCx, oldCy = math.floor(cx), math.floor(cy)

-- Initial draw
circle(tx, ty, r + 2, 0xFFFF, false)

delay(150)

-- --- MAIN GAME LOOP ---
while true do
    -- 2. KEYBOARD INPUT HANDLING
    local moveX, moveY = 0, 0
    
    -- Horizontal: A (0x04) / Left (0x50) | D (0x07) / Right (0x4F)
    if isKeyDown(0x04) or isKeyDown(0x50) then moveX = -1 
    elseif isKeyDown(0x07) or isKeyDown(0x4F) then moveX = 1 end
    
    -- Vertical: W (0x1A) / Up (0x52) | S (0x16) / Down (0x51)
    if isKeyDown(0x1A) or isKeyDown(0x52) then moveY = -1 
    elseif isKeyDown(0x16) or isKeyDown(0x51) then moveY = 1 end

    -- Apply Movement
    px = px + (moveX * pSpeed)
    py = py + (moveY * pSpeed)

    -- Constrain to screen
    px = math.max(r, math.min(SCREEN_W - r, px))
    py = math.max(r, math.min(SCREEN_H - r, py))
    local x, y = math.floor(px), math.floor(py)

    -- CHASER AI (Follows the player)
    if cx < x then cx = cx + cSpeed
    elseif cx > x then cx = cx - cSpeed end
    if cy < y then cy = cy + cSpeed
    elseif cy > y then cy = cy - cSpeed end

    -- COLLISION: Player vs Chaser
    if ((x - cx)^2 + (y - cy)^2) < (r * 2)^2 then 
        break 
    end

    -- TARGET COLLECTION
    if ((x - tx)^2 + (y - ty)^2) < (r * 2)^2 then
        score = score + 1
        playSound(1200, 30)
        circle(tx, ty, r + 2, 0x0000, false) 
        tx = math.random(r, SCREEN_W - r)
        ty = math.random(r, SCREEN_H - r)
        circle(tx, ty, r + 2, 0xFFFF, false)
        if score % 5 == 0 then cSpeed = cSpeed + 0.2 end
    end

    -- 3. THE "NO-FLASH" REDRAW LOGIC
    local playerMoved = (x ~= oldX or y ~= oldY)
    local chaserMoved = (math.floor(cx) ~= oldCx or math.floor(cy) ~= oldCy)

    if playerMoved or chaserMoved then
        -- Erase old circles
        if playerMoved then circle(oldX, oldY, r, 0x0000, true) end
        if chaserMoved then circle(oldCx, oldCy, r, 0x0000, true) end
        
        -- ANTI-FLASH: Check if we just erased the target
        local distP = math.sqrt((oldX - tx)^2 + (oldY - ty)^2)
        local distC = math.sqrt((oldCx - tx)^2 + (oldCy - ty)^2)
        if distP < r + 5 or distC < r + 5 then
            circle(tx, ty, r + 2, 0xFFFF, false)
        end

        -- Draw new positions
        circle(x, y, r, 0x07E0, true) -- Player (Green)
        circle(math.floor(cx), math.floor(cy), r, 0xF800, true) -- Chaser (Red)
        
        oldX, oldY = x, y
        oldCx, oldCy = math.floor(cx), math.floor(cy)
    end

    -- EXIT TO OS (ESC KEY)
    if isKeyDown(0x29) then return end
    
    delay(5) 
end

-- --- S3 ULTIMATE GAME OVER SCREEN ---
playSound(150, 500)
cls(0)
setTextSize(5)
printAt(100, 60, "GAME OVER", 0xF800)
setTextSize(3)
printAt(130, 140, "Score: " .. score, 0xFFFF)
delay(1000) 
setTextSize(2)
printAt(100, 240, "RELEASE BUTTON...", 0x07FF)

while isKeyDown(0x28) do delay(10) end -- Wait for Enter release

fillRect(100, 240, 300, 30, 0)
printAt(110, 240, "PRESS ENTER TO RETURN", 0x07FF)

while not isKeyDown(0x28) do delay(10) end -- Wait for new Enter press
playSound(1200, 50)
delay(300)