-- regulates bigreactor based on EIO capacitor charge

local bank = peripheral.wrap("bottom")
local monitor = peripheral.wrap("back")
local outputSide = "right"

monitor.setTextColor(1) --text will be white
monitor.setBackgroundColor(128) --background will be gray
monitor.clear() --paint the background

--percentage math constants
running = false
maxLevel = 98
minLevel = 5
percentage = 0
storedEnergy = 0
maxEnergy = 0
init = true

print("Thresholds:")
print("  * Start: < "..minLevel.."%")
print("  * Stop:  > "..maxLevel.."%")

function start()
    print("* Starting reactor ("..percentage.."% breached "..minLevel.."% threshold)...")
    redstone.setOutput(outputSide, true)
    running = true
end

function stop()
    print("* Stopping reactor ("..percentage.."% exceeded "..maxLevel.."% threshold)...")
    redstone.setOutput(outputSide, false)
    running = false
end

while true do
  storedEnergy = bank.getEnergyStored()
  maxEnergy = bank.getMaxEnergyStored()
  percentage = math.floor(storedEnergy / maxEnergy * 10000) / 100

  -- Control

  if init then
    if percentage < maxLevel then
        start()
    else
        stop()
    end 
    init = false
  end

  if running and (percentage > maxLevel) then
    stop()
  elseif not running and (percentage < minLevel) then
    start()
  end


  -- Update display 

  if running then
    monitor.setCursorPos(7,5)
    monitor.setTextColor(8192) --text will be green
    monitor.write("Reactor: Active")
  else
    monitor.setCursorPos(6, 5)
    monitor.setTextColor(16384) --text will be red
    monitor.write("Reactor: Inactive")
  end

  monitor.setCursorPos(3,2)
  monitor.setTextColor(1)
  monitor.write(percentage.."%")
  sleep(2.5)
  monitor.clear()
end