util.AddNetworkString( "PP.ClientSideCreated" ) -- Sorry not named very well, client side tried to perma prop
util.AddNetworkString( "PP.ClientSideDeleted" ) -- Client side tryed to delete a permaprop.

net.Receive("PP.ClientSideCreated", function(len, ply)

  local ent = net.ReadEntity()

  if not PermaProps then ply:ChatPrint( "ERROR: Lib not found" ) return end
  if not PermaProps.HasPermission( ply, "Save") then return end
  if not ent:IsValid() then ply:ChatPrint( "That is not a valid entity !" ) return end

  if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
  if ent.PermaProps then ply:ChatPrint( "That entity is already permanent !" ) return end
  if ent.PermaProped then return end -- don't want it to return "That entity is already permanent!"

  ent.PermaProped = true -- stops the double perma prop

  local content = PermaProps.PPGetEntTable(ent)
  if not content then return end

  local max = tonumber(sql.QueryValue("SELECT MAX(id) FROM permaprops;"))
  if not max then max = 1 else max = max + 1 end

  local new_ent = PermaProps.PPEntityFromTable(content, max)
  if not new_ent or not new_ent:IsValid() then ply:ChatPrint("new_ent") return end
  PermaProps.SparksEffect( ent )

  PermaProps.SQL.Query( "INSERT INTO permaprops (id, map, content) VALUES(NULL, " .. sql.SQLStr(game.GetMap()) .. ", " .. sql.SQLStr(util.TableToJSON(content)) .. ");")
  ply:ChatPrint("You saved " .. ent:GetClass() .. " with model " .. ent:GetModel() .. " to the database.")

  ent:Remove()

  return true

end)

net.Receive("PP.ClientSideDeleted", function(len, ply)

	local ent = net.ReadEntity()

	if not PermaProps then ply:ChatPrint( "ERROR: Lib not found" ) return end

	if not PermaProps.HasPermission( ply, "Delete") then return end

	if not ent:IsValid() then ply:ChatPrint( "That is not a valid entity !" ) return end
	if ent:IsPlayer() then ply:ChatPrint( "That is a player !" ) return end
	if not ent.PermaProps then ply:ChatPrint( "That is not a PermaProp !" ) return end
	if not ent.PermaProps_ID then ply:ChatPrint( "ERROR: ID not found" ) return end

	PermaProps.SQL.Query( "DELETE FROM permaprops WHERE id = " .. ent.PermaProps_ID .. ";")

	ply:ChatPrint("You erased " .. ent:GetClass() .. " with a model of " .. ent:GetModel() .. " from the database.")

	ent:Remove()

  return true
  
end)
