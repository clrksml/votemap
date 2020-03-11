if !CLIENT then return end

local size, last, selected = 200, CurTime(), 100
local time, winner, won = CurTime() + 17, false, 0

function DrawMapVote()
	if ScrH() < 840 then
		size = 160
	end
	
	local header = "VOTE FOR NEXT MAP!"
	local pC = #player.GetAll()
	VotePanel = vgui.Create("DFrame2")
	VotePanel:SetSize(300, 300)
	VotePanel:SetDraggable(false)
	VotePanel:MakePopup()
	VotePanel:Center()
	VotePanel:SetMouseInputEnabled(true)
	VotePanel:SetKeyBoardInputEnabled(false)
	VotePanel.Refresh = function()
		if !winner then
			local once = false
			local x, y = (size * -1), 30
			for k, v in SortedPairs(Maps) do
				if k < 4 then
					x = x + (size + 4)
				elseif k > 3 and k < 8 then
					if k == 4 then
						x, y = 4, (size + 34)
						x = 4
					else
						x = x + (size + 4)
					end
				elseif k > 7 and k < 12 then
					if k == 8 then
						x, y = 4, (y + size + 4)
						x = 4
					else
						x = x + (size + 4)
					end
				elseif k > 11 and k < 16 then
					if k == 12 then
						x, y = 4, (y + size + 4)
						x = 4
					else
						x = x + (size + 4)
					end
				end
				
				local CPanel = vgui.Create("DPanel", VotePanel)
				CPanel:SetSize(size, size)
				CPanel:SetPos(x, y)
				CPanel.Paint = function()
				end
				
				local Map = vgui.Create("DImage", CPanel)
				Map:SetSize(size, size)
				Map:SetPos(0, 0)
				if v[2] then
					Map:SetImage("smokemaps/smoke_" .. v[1] .. ".png")
				else
					Map:SetImage("gui/dupe_bg.png")
				end
				
				local TPanel = vgui.Create("DPanel", CPanel)
				TPanel:SetSize(size, size)
				TPanel:SetPos(0, 0)
				TPanel.Paint = function()
					if selected == k then
						surface.SetDrawColor(1, 175, 1, 200)
						surface.DrawRect(0, size - 24, size, 24)
					else
						surface.SetDrawColor(1, 1, 1, 200)
						surface.DrawRect(0, size - 24, size, 24)
					end
				end
				
				local Name = vgui.Create("DLabel", CPanel)
				Name:SetText(v[1])
				Name:SetPos(2, size - 16)
				Name:SetFont("CenterPrintText")
				Name:SetTextColor(Color(255, 255, 255))
				Name:SizeToContents()
				
				local oV = v[3]
				
				surface.SetFont("CenterPrintText")
				local _w, _h = surface.GetTextSize(v[3] .. " / " .. pC)
				
				local Votes = vgui.Create("DLabel", CPanel)
				Votes:SetText(v[3] .. " / " .. pC)
				Votes:SetPos((size - _w) - 2, size - 16)
				Votes:SetFont("CenterPrintText")
				Votes:SetTextColor(Color(255, 255, 255))
				Votes:SizeToContents()
				Votes.Think = function()
					if oV != v[3] then
						oV = v[3]
						Votes:SetText(v[3] .. " / " .. pC)
						
						surface.SetFont("CenterPrintText")
						_w, _h = surface.GetTextSize(v[3] .. " / " .. pC)
						Votes:SetPos((size - _w) - 2, size - 16)
					end
				end
				
				local VoteButton = vgui.Create("DButton", CPanel)
				VoteButton:SetSize(size, size)
				VoteButton:SetPos(0, 0)
				VoteButton:SetText("")
				VoteButton.Paint = function()
				end
				VoteButton.DoClick = function()
					if last <= CurTime() then
						if selected == k then return end
						net.Start("VoteMap")
							net.WriteFloat(k)
						net.SendToServer()
						
						last = CurTime() + 1
						selected = k
						
						surface.PlaySound("buttons/button15.wav")
					end
				end
			end
		else
			size = 256
			header = "Winner!"
			
			local c, x, y = 0, 6, 28
			local CPanel = vgui.Create("DPanel", VotePanel)
			CPanel:SetSize(size, size)
			CPanel:SetPos(x, y)
			CPanel.Paint = function()
			end
			
			local Map = vgui.Create("DImage", CPanel)
			Map:SetSize(size, size)
			Map:SetPos(0, 0)
			if Maps[won][2] then
				Map:SetImage("smokemaps/smoke_" .. Maps[won][1] .. ".png")
			else
				Map:SetImage("gui/dupe_bg.png")
			end
			
			local TPanel = vgui.Create("DPanel", CPanel)
			TPanel:SetSize(size, size)
			TPanel:SetPos(0, 0)
			TPanel.Paint = function()
				surface.SetDrawColor(1, 175, 1, 200)
				surface.DrawRect(0, size - 24, size, 24)
			end
			
			local Name = vgui.Create("DLabel", CPanel)
			Name:SetText(Maps[won][1])
			Name:SetPos(2, size - 16)
			Name:SetFont("CenterPrintText")
			Name:SetTextColor(Color(255, 255, 255))
			Name:SizeToContents()
			
			surface.SetFont("CenterPrintText")
			local _w, _h = surface.GetTextSize(Maps[won][3] .. " / " .. pC)
			
			local Votes = vgui.Create("DLabel", CPanel)
			Votes:SetText(Maps[won][3] .. " / " .. pC)
			Votes:SetPos((size - _w) - 2, size - 16)
			Votes:SetFont("CenterPrintText")
			Votes:SetTextColor(Color(255, 255, 255))
			Votes:SizeToContents()
		end
	end
	
	VotePanel:Refresh()
	VotePanel:SizeToChildren(true, true)
	VotePanel:Center()
	VotePanel.Think = function()
		if pC != #player.GetAll() then
			pC = #player.GetAll()
		end
	end
	VotePanel.Paint = function()
		surface.SetDrawColor(1, 1, 1, 200)
		surface.DrawRect(0, 0, VotePanel:GetWide(), 25)
		
		surface.SetTextPos(4, 2)
		surface.SetFont("Trebuchet24")
		surface.SetTextColor(255, 255, 255, 255)
		surface.DrawText(header)
		
		local w, txt = surface.GetTextSize(math.Round(time - CurTime())) + 4, math.Round(time - CurTime())
		surface.SetTextPos(VotePanel:GetWide() -  w, 4)
		surface.SetFont("Trebuchet18")
		surface.SetTextColor(255, 255, 255, 255)
		surface.DrawText(txt)
	end
end

hook.Add("HUDPaint", "Blur", function()
	if VotePanel then
		surface.SetDrawColor(1, 1, 1, 254)
		surface.DrawRect(0, 0, ScrW(), ScrH())
	end
end)

net.Receive("UpdateMapVote", function( l )
	Maps = {}
	Maps = net.ReadTable()
	
	if VotePanel then
		VotePanel:Clear()
		VotePanel:Refresh()
	end
end)

net.Receive("MapWinner", function( u )
	winner = true
	won = tonumber(net.ReadString())
	time = CurTime() + 2
	title = Maps[won][1]
	
	if VotePanel then
		VotePanel:Close()
		DrawMapVote()
	end
end)

usermessage.Hook("DrawMapVote", function( u )
	time = CurTime() + 15
	DrawMapVote()
end)

concommand.Add("_map", function()
	time = CurTime() + 35
	return DrawMapVote()
end)
