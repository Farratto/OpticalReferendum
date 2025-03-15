-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals processCancel processOK update entrylist

function onInit()
	update();
end

function processCancel()
	if Session.IsHost then
		OpticalReferendum.processGMAction(false);
	else
		OpticalReferendum.processVote(User.getUsername(), false);
	end
end

function processOK()
	if Session.IsHost then
		OpticalReferendum.processGMAction(true);
	else
		OpticalReferendum.processVote(User.getUsername(), true);
	end
end

function update()
	if entrylist then
		entrylist.subwindow.update();
	end

	local sCurrentIdentity = User.getCurrentIdentity();
	local bHasActiveIdentity = Session.IsHost or (sCurrentIdentity ~= nil and sCurrentIdentity ~= "");

	button_ok.setVisible(bHasActiveIdentity);
	button_cancel.setVisible(bHasActiveIdentity);
end
