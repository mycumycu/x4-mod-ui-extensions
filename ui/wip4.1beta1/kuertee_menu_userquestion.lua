local config = {
	width = 400,
	layer = 3,
	saveOptionVersion = 1,
}
function newFuncs.cleanup()
	local menu = userQuestionMenu
	oldFuncs.cleanup ()
	if callbacks ["cleanup_end"] then
		for _, callback in ipairs (callbacks ["cleanup_end"]) do
			callback ()
		end
	end
end
function newFuncs.createInfoFrame()
	local menu = userQuestionMenu

	-- remove old data
	Helper.clearDataForRefresh(menu, config.infoLayer)

	-- kuertee start: callback
	local frameProperties
	if callbacks ["createInfoFrame_custom_frame_properties"] then
		for _, callback in ipairs (callbacks ["createInfoFrame_custom_frame_properties"]) do
			frameProperties = callback (config)
			if frameProperties then break end
		end
		-- Lib.Print_Table (frameProperties)
	end
	if not frameProperties then
	-- kuertee end: callback
		frameProperties = {
			standardButtons = {},
			width = Helper.scaleX(config.width) + 6 * Helper.borderSize,
			x = (Helper.viewWidth - Helper.scaleX(config.width)) / 2,
			y = Helper.viewHeight / 2,
			layer = config.layer,
			backgroundID = "solid",
			backgroundColor = Helper.color.semitransparent,
			startAnimation = false,
			playerControls = menu.mode == "markashostile",
		}
	-- kuertee start: callback
	end
	-- kuertee end: callback

	menu.infoFrame = Helper.createFrameHandle(menu, frameProperties)

	local tableProperties = {
		width = Helper.scaleX(config.width),
		x = 3 * Helper.borderSize,
		y = 3 * Helper.borderSize,
	}

	local ftable = menu.createTable(menu.infoFrame, tableProperties)

	menu.infoFrame.properties.height = ftable.properties.y + ftable:getVisibleHeight() + 3 * Helper.borderSize
	menu.infoFrame.properties.y = (Helper.viewHeight - menu.infoFrame.properties.height) / 2

	menu.infoFrame:display()
end
function newFuncs.createTable(frame, tableProperties)
	local menu = userQuestionMenu

	-- if menu.mode ~= "custom" then
	if not string.find ("" .. tostring (menu.mode), "custom") then
		return oldFuncs.createTable (frame, tableProperties)
	end

	-- DebugError ("kuertee_menu_userquestion createTable menu.mode " .. tostring (menu.mode))
	-- DebugError ("kuertee_menu_userquestion createTable #callbacks ['createTable_new_custom_table'] " .. tostring (#callbacks ["createTable_new_custom_table"]))
	local ftable
	if menu.mode == "custom" then
		-- kuertee start: re-written custom user question
		local numCols = (menu.mode == "custom") and 5 or 6
		ftable = frame:addTable(numCols, { tabOrder = 1, borderEnabled = true, width = tableProperties.width, x = tableProperties.x, y = tableProperties.y, defaultInteractiveObject = true })
		local leftwidth = 0
		if menu.modeparam[3] ~= nil then
			leftwidth = math.ceil(C.GetTextWidth(menu.modeparam[3][2] or "", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize)))
		end
		local rightwidth = 0
		if menu.modeparam[4] ~= nil  then
			rightwidth = math.ceil(C.GetTextWidth(menu.modeparam[4][2] or "", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize)))
		end
		local minbuttonwidth = 0.2 * tableProperties.width - Helper.borderSize
		local maxbuttonwidth = (tableProperties.width - 4 * Helper.borderSize - 3) / 2
		local buttonwidth = math.max(minbuttonwidth, math.min(maxbuttonwidth, math.max(leftwidth, rightwidth) + 2 * Helper.standardTextOffsetx))
		ftable:setColWidth(2, buttonwidth, false)
		ftable:setColWidth(4, buttonwidth, false)
		local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(numCols):createText(menu.modeparam[1] or "", Helper.headerRowCenteredProperties)
		local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(numCols):createText(menu.modeparam[2] or "", { wordwrap = true })
		local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(numCols):createText("")
		local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		if menu.modeparam[3] then
			row[2]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(menu.modeparam[3][2] or "", { halign = "center" })
			row[2].handlers.onClick = function () return menu.customOption(menu.modeparam[3][1], menu.modeparam[3]) end
		end
		if menu.modeparam[4] then
			row[4]:createButton({ helpOverlayID = "custom_" .. menu.mode .. "_confirm", helpOverlayText = " ", helpOverlayHighlightOnly = true }):setText(menu.modeparam[4][2] or "", { halign = "center" })
			row[4].handlers.onClick = function () return menu.customOption(menu.modeparam[4][1], menu.modeparam[4]) end
		end
		if menu.modeparam[4] and menu.modeparam[6] == "right" then
			ftable:setSelectedCol(4)
		elseif menu.modeparam[3] and menu.modeparam[6] == "left" then
			ftable:setSelectedCol(2)
		elseif menu.modeparam [3] then
			ftable:setSelectedCol(2)
		end
		-- kuertee end: re-written custom user question
	elseif string.find ("" .. tostring (menu.mode), "custom_") then
		-- <open_menu menu="UserQuestionMenu" param="[0, 0, 'custom', [$title, $text, null, ['kATD_on_death_notice_read', {111204, 903}], null, 'right']]" />
		-- local ftable = frame:addTable (numCols, { tabOrder = 1, borderEnabled = true, width = tableProperties.width, x = tableProperties.x, y = tableProperties.y, defaultInteractiveObject = true })
		if callbacks ["createTable_new_custom_table"] then
			for _, callback in ipairs (callbacks ["createTable_new_custom_table"]) do
				ftable = callback (frame, tableProperties, config)
				if ftable then break end
			end
		end
	end
	return ftable
end
function newFuncs.onUpdate()
	local menu = userQuestionMenu
	-- DebugError ("kuertee_menu_userquestion onUpdate")
	-- kuertee start: refresh feature
	-- menu.infoFrame:update()
	if menu.isRefresh == true then
		menu.createInfoFrame ()
		menu.isRefresh = false
	else
		menu.infoFrame:update()
	end
	-- kuertee end: refresh feature
end
