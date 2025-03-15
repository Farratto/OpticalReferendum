-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals resize update

local MARGINS = 16;
local widgets = {};

function resize(nUsers)
	local nWidth = (MARGINS * 2) + (nUsers * 75);

	parentcontrol.setAnchor("left", "", "center", "absolute", -(nWidth / 2));
	parentcontrol.setAnchoredWidth(nWidth);
end

function update()
	for _, v in pairs(widgets) do
		v.destroy();
	end

	widgets = {};
	local users = User.getActiveUsers();
	local aUsersWithIdentities = {};

	for i = 1, #users do
		if User.getCurrentIdentity(users[i]) ~= nil then
			table.insert(aUsersWithIdentities, users[i]);
		end
	end

	table.sort(aUsersWithIdentities);

	for i = 1, #aUsersWithIdentities do
		local control = createControl("opticalreferendum_entrylist_item");
		control.createControls(User.getCurrentIdentity(aUsersWithIdentities[i]), DB.getValue(getDatabaseNode(), aUsersWithIdentities[i], 1));
		control.setAnchor("top", "", "top", "absolute", MARGINS / 2);
		control.setAnchor("left", "", "left", "absolute", (MARGINS / 2) + ((i - 1) * 75));
		control.setAnchoredHeight(CharacterListManager.PORTRAIT_SIZE);
		control.setAnchoredWidth(CharacterListManager.PORTRAIT_SIZE);

		widgets[i] = control;
	end

	self.resize(#aUsersWithIdentities);
end
