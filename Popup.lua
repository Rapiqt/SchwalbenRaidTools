local L = SRTLocals;
local f = CreateFrame("Frame");
local timers = {};
f:SetPoint("TOP", 0, -70);
f:SetSize(1000, 300);
f:SetMovable(false);
f:EnableMouse(false);
f:RegisterForDrag("LeftButton");
f:SetFrameLevel(3);
f:SetScript("OnDragStart", f.StartMoving);
f:SetScript("OnDragStop", function(self)
	local point, relativeTo, relativePoint, xOffset, yOffset = self:GetPoint(1);
	SRT_PopupTextPosition = {};
	SRT_PopupTextPosition.point = point;
	SRT_PopupTextPosition.relativeTo = relativeTo;
	SRT_PopupTextPosition.relativePoint = relativePoint;
	SRT_PopupTextPosition.xOffset = xOffset;
	SRT_PopupTextPosition.yOffset = yOffset;
	self:StopMovingOrSizing();
end);
f:Hide();
local fontStrings = {};

local function createFontString(caller)
	if (caller) then
		local text = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge");
		text:SetPoint("TOP", 0, 0);
		text:SetJustifyH("CENTER");
		text:SetJustifyV("CENTER");
		text:SetFont("Fonts/Expressway.TTF", SRT_PopupTextFontSize);
		text:SetShown(false);
		fontStrings[caller] = text;
		return text;
	end
end

local function getAvailableYOffset()
	local availableSpots = {
		[0] = true,
		[50] = true,
		[100] = true,
		[150] = true,
		[200] = true,
	};
	local indexSpots = {
		[1] = 0,
		[2] = 50,
		[3] = 100,
		[4] = 150,
		[5] = 200,
	};
	for caller, fs in pairs(fontStrings) do
		if (fs:IsShown()) then
			local point, relativeTo, relativePoint, xOffset, yOffset = fs:GetPoint();
			availableSpots[yOffset*-1] = false;
		end
	end
	for i, yOffset in ipairs(indexSpots) do
		if (availableSpots[yOffset]) then
			return yOffset*-1;
		end
	end
	return -250;
end

local function hideMainFrame()
	for caller, fs in pairs(fontStrings) do
		if (fs:IsShown()) then
			return false;
		end
	end
	f:Hide();
end

local function hideAllFontStrings()
	for caller, fs in pairs(fontStrings) do
		fs:SetShown(false);
	end
	f:Hide();
end
--text:SetSize(1080,300);

function SRT_PopupUpdateFontSize()
	for caller, fs in pairs(fontStrings) do
		fs:SetFont("Fonts\\Expressway__.TTF", SRT_PopupTextFontSize);
	end
end

function SRT_PopupShow(message, sec, caller)
	if (caller) then
		local fs = fontStrings[caller];
		if (fs == nil) then
			fs = createFontString(caller);
		end
		local timer = timers[caller];
		if (timer) then
			timer:Cancel();
			timers[caller] = nil;
		end
		fs:SetText(message);
		if (not fs:IsShown()) then
			local yOffset = getAvailableYOffset();
			fs:ClearAllPoints();
			fs:SetPoint("TOP", 0, yOffset);
		end
		fs:Show();
		f:Show();
		timers[caller] = C_Timer.NewTimer(sec, function()
			fs:SetShown(false);
			hideMainFrame();
		end);
		return timers[caller];
	end
	return nil;
end
function SRT_PopupUpdate(message, caller)
	if (caller) then
		local fs = fontStrings[caller];
		if (fs) then
			fs:SetText(message);
		end
	end
end
function SRT_PopupMove()
	local fs = fontStrings[L.POPUP_FILE];
	if (fs == nil) then
		fs = createFontString(L.POPUP_FILE);
	end
	hideAllFontStrings();
	fs:SetText("MOVE ME");
	f:SetMovable(true);
	f:EnableMouse(true);
	fs:Show();
	f:Show();
	C_Timer.After(7, function()
		f:Hide();
		fs:SetShown(false);
		f:SetMovable(false);
		f:EnableMouse(false);
	end);
end
function SRT_PopupHide(caller)
	if (caller) then
		local fs = fontStrings[caller];
		if (fs) then
			local timer = timers[caller];
			if (timer) then
				timer:Cancel();
				timers[caller] = nil;
			end
			fs:SetShown(false);
			hideMainFrame();
		end
	end
end

function SRT_PopupSetPosition(point, relativeTo, relativePoint, xOffset, yOffset)
	f:ClearAllPoints();
	f:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
end
function SRT_PopupIsShown(caller)
	if (caller) then
		local fs = fontStrings[caller];
		if (fs) then
			return fs:IsShown();
		end
	end
	return nil;
end
function SRT_PopupGetText(caller)
	if (caller) then
		local fs = fontStrings[caller];
		if (fs) then
			return fs:GetText();
		end
	end
	return nil;
end