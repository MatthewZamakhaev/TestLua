Game = {}
Game.__index = Game

function Game:new()
    local obj = {
        grid = {},
        colors = {"A", "B", "C", "D", "E", "F"}
    }
    setmetatable(obj, Game)
    obj:init()
    return obj
end


function Game:init()
    for y = 0, 9 do
        self.grid[y] = {}
        for x = 0, 9 do
            self.grid[y][x] = self.colors[math.random(1, #self.colors)]
        end
    end
end

function Game:dump()
    io.write("  0 1 2 3 4 5 6 7 8 9\n")
    io.write("  --------------------\n")
    for y = 0, 9 do
        io.write(y .. "| ")
        for x = 0, 9 do
            io.write(self.grid[y][x] .. " ")
        end
        io.write("\n")
    end
end

function Game:tick()
    local changed = false
    for y = 0, 9 do
        for x = 0, 9 do
            if self:checkMatch(x, y) then
                self:removeMatch(x, y)
                changed = true
            end
        end
    end
    if changed then
        self:drop()
        self:fill()
    end
    return changed
end

function Game:checkMatch(x, y)
    local color = self.grid[y][x]
    if x <= 7 and self.grid[y][x + 1] == color and self.grid[y][x + 2] == color then
        return true
    end
    if y <= 7 and self.grid[y + 1][x] == color and self.grid[y + 2][x] == color then
        return true
    end
    return false
end

function Game:removeMatch(x, y)
    local color = self.grid[y][x]
    if x <= 7 and self.grid[y][x + 1] == color and self.grid[y][x + 2] == color then
        self.grid[y][x], self.grid[y][x + 1], self.grid[y][x + 2] = nil, nil, nil
    end
    if y <= 7 and self.grid[y + 1][x] == color and self.grid[y + 2][x] == color then
        self.grid[y][x], self.grid[y + 1][x], self.grid[y + 2][x] = nil, nil, nil
    end
end

function Game:drop()
    for x = 0, 9 do
        for y = 9, 0, -1 do
            if not self.grid[y][x] then
                for yy = y - 1, 0, -1 do
                    if self.grid[yy][x] then
                        self.grid[y][x] = self.grid[yy][x]
                        self.grid[yy][x] = nil
                        break
                    end
                end
            end
        end
    end
end

function Game:fill()
    for y = 0, 9 do
        for x = 0, 9 do
            if not self.grid[y][x] then
                self.grid[y][x] = self.colors[math.random(1, #self.colors)]
            end
        end
    end
end

function Game:move(fromX, fromY, toX, toY)
    local temp = self.grid[fromY][fromX]
    self.grid[fromY][fromX] = self.grid[toY][toX]
    self.grid[toY][toX] = temp
end

function Game:run()
    while true do
        self:dump()
        io.write("Enter a command (for example, 'm x y d' or 'q' to exit): ")
        local input = io.read()
        if input == "q" then break end

        local cmd, x, y, dir = input:match("(%a) (%d) (%d) (%a)")
        if cmd == "m" then
            x, y = tonumber(x), tonumber(y)
            local dx, dy = 0, 0
            if dir == "l" then dx = -1
            elseif dir == "r" then dx = 1
            elseif dir == "u" then dy = -1
            elseif dir == "d" then dy = 1
            else
                print("Incorrect command!")
                goto continue
            end

            local toX, toY = x + dx, y + dy
            if toX >= 0 and toX <= 9 and toY >= 0 and toY <= 9 then
                self:move(x, y, toX, toY)
                while self:tick() do end
            else
                print("Incorrect movement!")
            end
        else
            print("Incorrect command!")
        end
        ::continue::
    end
end

math.randomseed(os.time())
game = Game:new()
game:run()