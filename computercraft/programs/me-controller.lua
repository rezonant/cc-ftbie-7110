function condition(cond, t, f)
    if cond then
        return t
    else
        return f
    end
end

function curses(name)
    local curses = {}
    local m = peripheral.wrap(name)
    local cx = 1
    local cy = 1

    m.curses = curses

    curses.fg = function(color)
        m.setTextColor(color)
        return curses
    end

    curses.bg = function(color)
        m.setBackgroundColor(color)
        return curses
    end

    curses.nl = function()
        cy = cy + 1
        cx = 1
        return curses
    end

    curses.write = function(line)
        if line == nil then
            line = "<nil>"
        end 

        m.setCursorPos(cx, cy)
        m.write(line)
        cx = cx + #line
        return curses
    end

    curses.print = function(line)
        curses.write(m, line)
        curses.nl(monitor)
        return curses
    end

    curses.clear = function()
        cx = 1
        cy = 1
        m.clear()
        return curses
    end

    curses.scale = function(scale)
        m.setTextScale(scale)
    end

    return m
end

function shortNumberFormat(number)
    if number > 1000000000 then
        return math.floor(number / 1000000000).."G"
    elseif number > 1000000 then
        return math.floor(number / 1000000).."M"
    elseif number > 1000 then
        return math.floor(number / 1000).."K"
    else
        return ""..number
    end
end

function handleAE(monitor, me)
    avgPowerUsage = me.getAvgPowerUsage()
    idlePowerUsage = me.getIdlePowerUsage()
    energyStored = me.getEnergyStored()
    availableItems = me.getAvailableItems()
    craftingCpus = me.getCraftingCPUs()

    -- rounding
    avgPowerUsage = math.floor(avgPowerUsage * 100) / 100
    idlePowerUsage = math.floor(idlePowerUsage * 100) / 100
    
    print("Status: avg="..avgPowerUsage..", stored="..energyStored..", items="..#availableItems..", cpus="..#craftingCpus.."")

    busyCount = 0
    for id, cpu in pairs(craftingCpus) do
        if cpu.busy then
            busyCount = busyCount + 1
        end
    end

    itemCount = 0
    fluidCount = 0
    craftableCount = 0

    for id, item in pairs(availableItems) do
        if item.is_item then
            itemCount = itemCount + item.size
            if item.is_craftable then
                craftableCount = craftableCount + 1
            end
        elseif item.is_fluid then
            fluidCount = fluidCount + 1
        end
    end

    if idlePowerUsage + 10 < avgPowerUsage then
        systemStatus = 'Working'
    elseif idlePowerUsage > avgPowerUsage then
        systemStatus = 'Power Failure'
    else
        systemStatus = 'Idle'
    end

    monitor.curses  .clear()
                    .write("Status:    ")
                    .fg(condition(
                        avgPowerUsage < idlePowerUsage, 
                        colors.red, 
                        colors.green
                    ))
                    .write(systemStatus).nl()
                    .nl()
                    .fg(colors.white)
                    .write("Energy:    ")
                    .fg(condition(
                        avgPowerUsage < idlePowerUsage, 
                        colors.red, 
                        colors.green
                    ))
                    .write(avgPowerUsage.." RF/t usage").nl()
                    .fg(colors.white)

                    .write("           "..idlePowerUsage.." RF/t idle").nl()
                    .write("           "..shortNumberFormat(energyStored).." RF stored").nl()
                    .write("Storage:   "..shortNumberFormat(#availableItems).." types").nl()
                    .write("           "..shortNumberFormat(itemCount).." items").nl()
                    .write("           "..shortNumberFormat(fluidCount).." fluids").nl()
                    .write("Crafting:  "
                        ..shortNumberFormat(busyCount)
                        .." / "
                        ..shortNumberFormat(#craftingCpus)
                        .." CPUs busy"
                    )

    sleep(2.5)
end

function handlePower(monitor, power)
    monitor.curses  .clear()
                    .write("Power Monitor Here")
end


-- ###########################################################

meName = 'tilecontroller_0'
me = peripheral.wrap(meName)
aeMonitor = curses('monitor_0')
powerMonitor = curses('monitor_1')

print("Starting...")

aeMonitor.curses  .fg(colors.white)
                .bg(colors.black)
                .clear()
                .scale(0.5)
powerMonitor.curses  .fg(colors.white)
                .bg(colors.black)
                .clear()
                .scale(0.5)

print("Started.")

-- ###########################################################

while true do 
    handleAE(aeMonitor, me)
    handlePower(powerMonitor, power)
    sleep(2.5)
end