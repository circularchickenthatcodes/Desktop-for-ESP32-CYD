local bx, by, vx, vy = 240, 160, 5, 2
local py, botY, pScore, bScore = 130, 130, 0, 0
local oBx, oBy, oPy, oBotY = 240, 160, 130, 130
setTextSize(2)
fillRect(0, 0, 480, 320, 0)

while true do
    oPy, oBotY = py, botY
    if isKeyDown(0x1A) then py = py - 8 end
    if isKeyDown(0x16) then py = py + 8 end
    py = math.max(0, math.min(260, py))

    if vx > 0 then
        if botY < by - 30 then botY = botY + 4 elseif botY > by - 30 then botY = botY - 4 end
    end
    botY = math.max(0, math.min(260, botY))

    oBx, oBy = bx, by
    bx, by = bx + vx, by + vy
    if by <= 0 or by >= 312 then vy = -vy playSound(400, 10) end

    if bx <= 30 and bx >= 20 and by >= py and by <= py + 60 then
        vx, vy = math.abs(vx) + 0.5, (by - (py + 30)) * 0.25
        playSound(600, 15)
    end
    if bx >= 450 and bx <= 460 and by >= botY and by <= botY + 60 then
        vx, vy = -math.abs(vx) - 0.5, (by - (botY + 30)) * 0.25
        playSound(600, 15)
    end

    if bx < 0 or bx > 480 then
        if bx < 0 then bScore = bScore + 1 else pScore = pScore + 1 end
        
        -- Score Update
        fillRect(200, 0, 80, 40, 0)
        printAt(210, 10, pScore .. " - " .. bScore, 0xFFFF)

        -- WIN CONDITION CHECK (First to 10)
        if pScore == 10 or bScore == 10 then
            local msg = (pScore == 10) and "PLAYER WINS!" or "BOT WINS!"
            local col = (pScore == 10) and 0x07E0 or 0xF800
            printAt(180, 160, msg, col)
            playSound(1000, 500)
            delay(2000) -- Wait 2 seconds so they can see they won
            break -- Returns to MENU.lua
        end

        -- Reset Ball
        fillRect(oBx, oBy, 8, 8, 0)
        bx, by, vx, vy = 240, 160, (bx < 0 and 5 or -5), 2
    end

    -- Dirty Rect Rendering
    if oPy ~= py then fillRect(20, oPy, 10, 60, 0) end
    if oBotY ~= botY then fillRect(450, oBotY, 10, 60, 0) end
    fillRect(oBx, oBy, 8, 8, 0)
    fillRect(20, py, 10, 60, 0x07E0)
    fillRect(450, botY, 10, 60, 0xF800)
    fillRect(bx, by, 8, 8, 0xFFFF)

    if isKeyDown(0x29) then break end
    delay(16)
end
