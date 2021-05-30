local s = Instance.new("Sound")

s.Name = "BGMusic"
s.SoundId = "C:\\WINDOWS\\Media\\town.mid"
s.Volume = 1
s.Looped = true
s.archivable = false

s.Parent = game.Workspace

wait(5)

s:play()
