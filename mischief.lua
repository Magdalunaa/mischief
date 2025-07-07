local lfs = require 'lfs'

-- set some silly variables
local debug = false
local schedule = true -- makes the script schedule itself
local frequencyRange = {2880, 10080} -- min to max, in minutes

-- array of mischief! comment / uncomment lines to disable / enable a mischief event
mischief = {
	--"mediaplay", -- playerctl
	--"mediaprev", -- playerctl
	--"medianext", -- playerctl
	--"volumedown", -- amixer
	--"volumeup", -- amixer
	--"mute", -- amixer
	--"fullbrightness", -- brightnessctl
	--"nobrightness", -- brightnessctl
	--"meownotification", -- notify-send
	"wtype",
	"swww",
	"plasmawallpaper",
	"networkmanager",
	"openurl",
	"renamefiles",
	"clutterdesktop"
}

-- where is the script?
if string.sub(arg[0], 1, 1) == "/" then
	scriptLocation = arg[0]
else
	scriptLocation = lfs.currentdir() .. "/" .. arg[0]
end

-- scheduler!
if arg[1] == 'schedule' or schedule then
	os.execute('echo "lua ' .. scriptLocation .. '" | at now + ' .. math.random(frequencyRange[1], frequencyRange[2]) .. ' minutes')
end
-- setting up some stuff

local meows = {'~u~', 'prrr', 'mraw', 'nyaa~', 'mew', 'meow', 'nya', 'mreow', 'mew!'}
local urls = {"https://www.youtube.com/watch?v=dQw4w9WgXcQ", "linuxposting.xyz"}

-- random file chooser
-- takes a directory to browse and optionally a file extension to look for
-- returns a filepath
function getRandomFile(directory, extensions)
	randomFileList = {}

	for file in lfs.dir(directory) do
		if file == '.' or file == '..' or string.sub(file, 1, 1) == '.' then goto stop end

		if lfs.attributes(directory .. '/' .. file, 'mode') == 'directory' then
			subdirectory = file

			for file in lfs.dir(directory .. '/' .. subdirectory) do
				if file == '.' or file == '..' or string.sub(file, 1, 1) == '.' then goto stop end

				if extensions then 
					for i=1,#extensions,1 do
						ext = extensions[i]
						if string.sub(file, -4, -1) == ext then
							table.insert(randomFileList, directory .. '/' .. subdirectory .. '/' .. file)
							goto stop
						end
						::stop::
					end
				else
					table.insert(randomFileList, directory .. '/' .. subdirectory .. '/' .. file)
				end

				::stop::
			end
			goto stop
		else
			if extensions then 
				for i=1,#extensions,1 do
					ext = extensions[i]
					if string.sub(file, -4, -1) == ext then
						table.insert(randomFileList, directory .. '/' .. file)
						goto stop
					end
					::stop::
				end
			else
				table.insert(randomFileList, directory .. '/' .. file)
			end
			
		end
		
		::stop::
	end

	return randomFileList[math.random(#randomFileList)]
end

-- garble
function garbleText(text)
	print(text)

	cut = math.random(string.len(text) - 1)

	t1 = string.sub(text, 1, cut - 1)
	t2 = string.sub(text, cut + 1, cut + 1)
	t3 = string.sub(text, cut, cut)
	t4 = string.sub(text, cut + 2, -1)

	garbledText = t1 .. t2 .. t3 .. t4
	return garbledText
end

-- choose a random mischief
if arg[1] == 'schedule' then
	m = 'schedule'
else
	m = mischief[math.random(#mischief)]
end

-- yes this is just a big if statement
if m == 'mediaplay' then
	os.execute('playerctl play-pause')
elseif m == 'mediaprev' then
	os.execute('playerctl previous')
elseif m == 'medianext' then
	os.execute('playerctl next')
elseif m == 'volumedown' then
	os.execute("amixer set 'Master' 20%-")
elseif m == 'volumeup' then
	os.execute("amixer set 'Master' 20%+")
elseif m == 'mute' then
	os.execute("amixer set 'Master' toggle")
elseif m == 'fullbrightness' then
	os.execute('brightnessctl set 100%')
elseif m == 'nobrightness' then
	os.execute('brightnessctl set 0%')
elseif m == 'meownotification' then
	os.execute('notify-send ' .. meows[math.random(#meows)])
elseif m == 'wtype' then
	os.execute('wtype ' .. meows[math.random(#meows)])
elseif m == 'networkmanager' then
	os.execute('nmcli networking off')
elseif m == 'rickroll' then
	os.execute('xdg-open ' .. urls[math.random(#urls)])
elseif m == 'swww' then
	randomWallpaper = getRandomFile(os.getenv('HOME') .. '/Pictures', {'.png', '.jpg', '.gif'})
	os.execute('swww img ' .. randomWallpaper)
elseif m == 'plasmawallpaper' then
	randomWallpaper = getRandomFile(os.getenv('HOME') .. '/Pictures', {'.png', '.jpg'})
	os.execute('plasma-apply-wallpaperimage ' .. randomWallpaper)
elseif m == 'clutterdesktop' then
	file = getRandomFile(os.getenv('HOME'))
	path = os.getenv('HOME') .. '/Desktop/'

	for i=1,string.len(file),1 do
		if string.sub(file, -i, -i) == '/' then
			cut = string.len(file) - i + 2
			goto stop
		end
	end
	::stop::

	cutFile = string.sub(file, cut, -1)
	newFile = path .. cutFile

	print(file)
	print(newFile)

	os.execute('cp -r "' .. file .. '" "' .. newFile .. '"')

elseif m == 'renamefiles' then
	file = getRandomFile(os.getenv('HOME'))
	
	-- i need just the name.. find the last /
	for i=1,string.len(file),1 do
		if string.sub(file, -i, -i) == '/' then
			cut = string.len(file) - i + 2
			goto stop
		end
	end
	::stop::

	cutFile = string.sub(file, cut, -1)
	path = string.sub(file, 1, cut - 1)

	newFile = path .. garbleText(cutFile)

	os.execute('mv "' .. file .. '" "' .. newFile .. '"')
end

if debug then
	os.execute('notify-send "mischief ' .. m .. '"')
end
