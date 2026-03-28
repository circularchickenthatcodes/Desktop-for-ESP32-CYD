-- --- TIME BRIDGE ---
local getTime = millis or ticks or function() 
    if os and os.clock then return os.clock() * 1000 end
    return nil 
end

local sprite = {0x18, 0x3C, 0x7E, 0xDB, 0xFF, 0x24, 0x5A, 0xA5}

-- Alien Colors: Purple, Green, Blue, Yellow, Cyan, White
local waveColors = {0xF81F, 0x07E0, 0x001F, 0xFFE0, 0x07FF, 0xFFFF}

local function drawA(x, y, c)
    for i = 1, 8 do
        local r = sprite[i]
        local bitVal = 128 
        for j = 0, 7 do 
            if (r / bitVal) % 2 >= 1 then 
                fillRect(x+(j*2), y+(i*2), 2, 2, c) 
            end 
            bitVal = bitVal / 2
        end
    end
end

-- Game Variables
local px, bullets, enemyBullets, enemies, eDir, eY = 240, {}, {}, {}, 1, 40
local pSpeed = 10 
local pWidth = 24 
local score = 0
local wave = 1
local gameOver = false

-- Timing
local lastMoveTime = getTime() and getTime() or 0
local moveInterval = 600 
local lastShotTime = 0
local shootDelay = 450   
local frameFallback = 0

local function initEnemies()
    enemies = {}
    for r = 0, 2 do 
        for c = 0, 7 do 
            table.insert(enemies, {x=c*45+40, y=r*30, a=true}) 
        end 
    end
end

-- --- UI WIDGETS ---
local function drawUI()
    -- Erase text backgrounds
    fillRect(80, 5, 80, 16, 0)
    fillRect(425, 5, 40, 16, 0)
    setTextSize(2)
    printAt(10, 5, "SCORE: " .. score, 0xFFFF)
    printAt(360, 5, "WAVE: " .. wave, 0xFFFF)
end

local function showGameOver()
    playSound(150, 500)
    
    -- 1. Draw Screen (Matching C++ sizes/colors)
    cls(0)
    setTextSize(5)
    printAt(100, 60, "GAME OVER", 0xF800) -- Red
    
    setTextSize(3)
    printAt(130, 140, "Score: " .. score, 0xFFFF) -- White

    -- Note: Since Lua doesn't have direct access to 'prefs' yet, 
    -- we'll stick to the score display for now.
    
    -- 2. MANDATORY WAIT
    delay(1000) 

    setTextSize(2)
    printAt(100, 240, "RELEASE BUTTON...", 0x07FF) -- Cyan

    -- 3. THE GATE: Wait for user to let go of Enter (0x28)
    -- This prevents the "death shot" from skipping the screen
    while isKeyDown(0x28) do 
        delay(10) 
    end

    -- 4. PROMPT: Wait for NEW press
    fillRect(100, 240, 300, 30, 0) -- Clear the "Release" text
    printAt(110, 240, "PRESS ENTER TO RETURN", 0x07FF)

    while not isKeyDown(0x28) do 
        delay(10) 
    end

    -- 5. CLEANUP
    playSound(1200, 50)
    delay(300) 
end

initEnemies()
fillRect(0, 0, 480, 320, 0)

while not gameOver do
    local now = getTime() and getTime() or frameFallback
    if not getTime() then frameFallback = frameFallback + 10 end

    -- 1. PLAYER INPUT
    local oPx = px
    if isKeyDown(0x04) then px = px - pSpeed elseif isKeyDown(0x07) then px = px + pSpeed end
    px = math.max(10, math.min(480 - pWidth, px))
    
    if oPx ~= px then 
        fillRect(oPx, 300, pWidth, 12, 0) 
        fillRect(px, 300, pWidth, 12, 0x07E0) 
    end

    -- 2. PLAYER SHOOTING (450ms)
    if (isKeyDown(0x1A) or isKeyDown(0x2C)) and #bullets < 3 then
        if now - lastShotTime >= shootDelay then
            table.insert(bullets, {x=px + (pWidth/2) - 1, y=290}) 
            playSound(2000, 10)
            lastShotTime = now 
        end
    end

    -- 3. PLAYER BULLET LOGIC
    for i = #bullets, 1, -1 do
        local b = bullets[i]
        fillRect(b.x, b.y, 3, 8, 0) 
        b.y = b.y - 12
        if b.y < 0 then 
            table.remove(bullets, i) 
        else
            local hit = false
            for _, e in ipairs(enemies) do
                if e.a and b.x > e.x and b.x < e.x+16 and b.y > (e.y+eY) and b.y < (e.y+eY+16) then
                    e.a, hit = false, true
                    score = score + 10
                    fillRect(e.x, e.y+eY, 18, 18, 0) 
                    table.remove(bullets, i)
                    playSound(400, 10) 
                    break
                end
            end
            if not hit then fillRect(b.x, b.y, 3, 8, 0xFFFF) end
        end
    end

    -- 4. ENEMY BULLET LOGIC
    for i = #enemyBullets, 1, -1 do
        local eb = enemyBullets[i]
        fillRect(eb.x, eb.y, 4, 8, 0) 
        eb.y = eb.y + 7 
        if eb.y > 320 then
            table.remove(enemyBullets, i)
        else
            if eb.x > px and eb.x < px + pWidth and eb.y > 300 then
                playSound(100, 100)
                gameOver = true
                break
            else
                fillRect(eb.x, eb.y, 4, 8, 0xF800) 
            end
        end
    end

    -- 5. ALIEN LOGIC
    local activeCount = 0
    for _, e in ipairs(enemies) do if e.a then activeCount = activeCount + 1 end end

    if activeCount == 0 then
        wave = wave + 1
        eY, lastMoveTime = 40, now
        initEnemies()
        fillRect(0, 0, 480, 295, 0) 
    else
        if now - lastMoveTime >= moveInterval then
            for _, e in ipairs(enemies) do
                if e.a then fillRect(e.x, e.y+eY, 18, 18, 0) end
            end

            local edge = false
            for _, e in ipairs(enemies) do
                if e.a and (e.x + (eDir * 16) > 450 or e.x + (eDir * 16) < 10) then 
                    edge = true 
                end
            end

            if edge then 
                eDir = -eDir
                eY = eY + 16 
                if eY + 16 >= 300 then gameOver = true end
            else
                for _, e in ipairs(enemies) do
                    if e.a then 
                        e.x = e.x + (eDir * 16) 
                        if math.random(1, 100) > 92 and #enemyBullets < 4 then
                            table.insert(enemyBullets, {x=e.x+8, y=e.y+eY+16})
                        end
                    end
                end
            end
            lastMoveTime = now 
        end

        local cIdx = (wave - 1) % #waveColors + 1
        local currentColor = waveColors[cIdx]

        for _, e in ipairs(enemies) do 
            if e.a then drawA(e.x, e.y+eY, currentColor) end 
        end
    end

    drawUI() 
    if isKeyDown(0x29) then break end
    delay(5) 
end

showGameOver()
