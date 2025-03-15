-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals createControls onClickDown onHover

local aPollStates = { "poll_empty",  "poll_check", "poll_negative" };
local sIdentityOwner = "";

function createControls(sIdentity, nState)
	sIdentityOwner = sIdentity;

	local portraitWidget = addBitmapWidget("portrait_" .. sIdentity .. "_charlist");
	portraitWidget.setSize(70, 70);

	addBitmapWidget({
		icon = "colorgizmo_bigbtn_color",
		position = "insidebottomright",
		x = -20, y = -20,
		w = 30, h = 30
	});
	addBitmapWidget({
		icon = aPollStates[nState],
		position = "insidebottomright",
		x = -20, y = -20,
		w = 30, h = 30
	});
end

function onClickDown()
	if User.getCurrentIdentity() == sIdentityOwner then
		OpticalReferendum.processVoteToggle();
	end
end

function onHover(state)
	if User.getCurrentIdentity() == sIdentityOwner then
		if state == true then
			setFrame("modstackfocus");
		else
			setFrame(nil);
		end
	end
end
