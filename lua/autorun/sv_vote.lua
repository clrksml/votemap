if !SERVER then return end

AddCSLuaFile("lua/autorun/dframe2.lua")
AddCSLuaFile("lua/autorun/cl_vote.lua")

Map, Maps = {}, {}

// [key (0-15)] = { map name, has map image }
// Example: Map[0] = { "ttt_minecraft_b5", true }
Map[0] = { "ttt_minecraft_b5" }
Map[1] = { "ttt_lost_temple_v2" }
Map[2] = { "ttt_rooftops_a2_f1" }
Map[3] = { "ttt_roy_the_ship" }
Map[4] = { "ttt_whitehouse_b2" }
Map[5] = { "ttt_crummycradle_a4" }
Map[6] = { "de_dolls"}
Map[7] = { "ttt_vessel" }
Map[8] = { "cs_drugbust" }
Map[9] = { "ttt_airbus_b3" }
Map[10] = { "ttt_alt_borders_b13"}
Map[11] = { "ttt_apehouse"}
Map[12] = { "ttt_bank_b3"}
Map[13] = { "ttt_trappycottage_b2"}
Map[14] = { "ttt_stadium_v2"}
Map[15] = { "ttt_67thway_v3" }

util.AddNetworkString("UpdateMapVote")
util.AddNetworkString("MapWinner")
util.AddNetworkString("UpdateMapVote")
util.AddNetworkString("VoteMap")

local num = 0
for k, v in RandomPairs(Map) do
	if table.Count(Maps) >= 16 then return end
	Maps[num] = {}
	Maps[num][1] = v[1]
	Maps[num][2] = v[2] or false
	Maps[num][3] = 0
	num = num + 1
end

function game.LoadNextMap( )
	local h, c = 0, 0
	for k, v in pairs(Maps) do
		if tonumber(v[3]) >= tonumber(h) then
			h = tonumber(v[3])
			c = k
		end
	end
	
	for k, v in RandomPairs(player.GetAll()) do
		net.Start("MapWinner")
			net.WriteString(c)
		net.Send(v)
		
		if Maps[c][3] <= 0 then
			v:ChatPrint(Maps[c][1] .. " won (appears everyone forgot to vote)!")
		else
			v:ChatPrint(Maps[c][1] .. " won with " .. Maps[c][3] .. "/" .. table.Count(player.GetAll()) .. "!")
		end
		v:ChatPrint("Server changing level to " .. Maps[c][1] .. ".")
	end
	
	timer.Simple(2, function()
		game.ConsoleCommand("changelevel " .. Maps[c][1] .. "\n")
	end)
end

hook.Add("PlayerInitialSpawn", "InitTable", function( p )
	if IsValid(p) and p:IsPlayer() then
		net.Start("UpdateMapVote")
			net.WriteTable(Maps)
		net.Send(p)
	end
end)

hook.Add("TTTEndRound", "VoteMap", function()
	if GetGlobalInt("ttt_rounds_left") <= 0 then
		for k, v in pairs(player.GetAll()) do
			umsg.Start("DrawMapVote", v)
			umsg.End()
		end
	end
end)

net.Receive("VoteMap", function( l, p )
	local num = tonumber(net.ReadFloat())
	k = num
	if !p.Vote then
		p.Vote = num
		Maps[k][3] = Maps[k][3] + 1
		for k, v in pairs(player.GetAll()) do
			if IsValid(v) and v:IsPlayer() then
				net.Start("UpdateMapVote")
					net.WriteTable(Maps)
				net.Send(v)
			end
		end
	elseif p.Vote != num then
		local _k = tonumber(p.Vote)
		p.Vote = num
		
		if Maps[_k][3] >= 1 then
			Maps[_k][3] = Maps[_k][3] - 1
		else
			Maps[_k][3] = 0
		end
		
		Maps[k][3] = Maps[k][3] + 1
		for k, v in pairs(player.GetAll()) do
			if IsValid(v) and v:IsPlayer() then
				net.Start("UpdateMapVote")
					net.WriteTable(Maps)
				net.Send(v)
			end
		end
	end
end)
