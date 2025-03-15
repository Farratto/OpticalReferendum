-- Please see the LICENSE.txt file included with this distribution for
-- attribution and copyright information.

-- luacheck: globals createOrUpdateORWindow findORWindow onOOBFinish onOOBInquire onOOBRefresh onOOBVote
-- luacheck: globals onSlashReferendum processGMAction processVote processVoteToggle onIdentityActivation
-- luacheck: globals onIdentityStateChange

OOB_MSGTYPE_OR_FINISH = "OOB_OR_FINISH";
OOB_MSGTYPE_OR_INQUIRE = "OOB_OR_INQUIRE";
OOB_MSGTYPE_OR_REFRESH = "OOB_OR_REFRESH";
OOB_MSGTYPE_OR_VOTE = "OOB_OR_VOTE";

local sNodeKey = "optical_referendum";

function onClose()
	DB.deleteNode(sNodeKey);
end

function onTabletopInit()
	if Session.IsHost then
		Comm.registerSlashHandler("or", OpticalReferendum.onSlashReferendum, "[query]");
		User.onIdentityStateChange = OpticalReferendum.onIdentityStateChange;
		User.onIdentityActivation = OpticalReferendum.onIdentityActivation;
		User.onUserStateChange = OpticalReferendum.onUserStateChange; --luacheck: ignore 122
	end

	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_OR_FINISH, onOOBFinish);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_OR_INQUIRE, onOOBInquire);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_OR_REFRESH, onOOBRefresh);
	OOBManager.registerOOBMsgHandler(OOB_MSGTYPE_OR_VOTE, onOOBVote);
end

function createOrUpdateORWindow()
	local wORWindow = self.findORWindow();

	if wORWindow ~= nil then
		wORWindow.update();
		wORWindow.bringToFront();
	else
		Interface.openWindow("optical_referendum", DB.findNode(sNodeKey));
	end
end

function findORWindow()
	local vNode = DB.findNode(sNodeKey);

	if vNode == nil then
		return nil;
	end

	return Interface.findWindow("optical_referendum", vNode);
end

function onOOBFinish()
	local wORWindow = self.findORWindow();

	if wORWindow ~= nil then
		wORWindow.close();
	end
end

function onOOBInquire()
	self.createOrUpdateORWindow();
end

function onOOBRefresh()
	local vNode = DB.findNode(sNodeKey);

	if vNode ~= nil then
		self.createOrUpdateORWindow();
	end
end

function onOOBVote(tMessage)
	if Session.IsHost then
		local vNode = DB.findNode(sNodeKey);
		DB.setValue(vNode, tMessage.sUsername, "number", tMessage.nState);

		Comm.deliverOOBMessage({ type = OOB_MSGTYPE_OR_REFRESH });
	end
end

function onSlashReferendum(_, sParams)
	Comm.deliverOOBMessage({ type = OOB_MSGTYPE_OR_FINISH });

	local vNode = DB.createNode(sNodeKey);
	DB.deleteChildren(vNode);
	DB.setPublic(vNode, true);
	DB.setValue(vNode, "query", "string", sParams);

	Comm.deliverOOBMessage({ type = OOB_MSGTYPE_OR_INQUIRE });
end

function processGMAction(_)
	DB.deleteNode(sNodeKey);
	Comm.deliverOOBMessage({ type = OOB_MSGTYPE_OR_FINISH });
end

function processVote(sUsername, bAffirmative)
	local message = {};
	message.type = OOB_MSGTYPE_OR_VOTE;
	message.sUsername = sUsername;

	if bAffirmative then
		message.nState = 2;
	else
		message.nState = 3;
	end

	Comm.deliverOOBMessage(message);
end

function processVoteToggle()
	local sUsername = User.getUsername();
	local nCurrentState = DB.getValue(DB.findNode(sNodeKey), sUsername, 1);

	OpticalReferendum.processVote(sUsername, nCurrentState ~= 2);
end

function onIdentityActivation(_, sUser, bActivated)
	if bActivated == false and #User.getActiveIdentities(sUser) == 0 then
		DB.deleteChild(DB.findNode(sNodeKey), sUser);
	end

	Comm.deliverOOBMessage({ type = OOB_MSGTYPE_OR_REFRESH });
end

function onIdentityStateChange(_, _, sStateName)
	if sStateName == "current" then
		Comm.deliverOOBMessage({ type = OOB_MSGTYPE_OR_REFRESH });
	end
end
