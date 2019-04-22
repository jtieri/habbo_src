property pWriterPlainNormLeft, pWriterListPlainNormLeft, pWriterPlainNormRight, pWriterLinkRight, pGoButtonImages, pJoinButtonImage, pMainWindowId, pWriterPlainBoldLeft

on construct me 
  pMainWindowId = "bb"
  tPlainFontStruct = getStructVariable("struct.font.plain")
  createWriter("bb_plain_norm_left", tPlainFontStruct)
  pWriterPlainNormLeft = getWriter("bb_plain_norm_left")
  pWriterPlainNormLeft.define([#wordWrap:0, #fixedLineSpace:tPlainFontStruct.getAt(#lineHeight)])
  createWriter("bb_list_plain_norm_left", tPlainFontStruct)
  pWriterListPlainNormLeft = getWriter("bb_list_plain_norm_left")
  pWriterListPlainNormLeft.define([#wordWrap:0, #fixedLineSpace:16])
  createWriter("bb_plain_norm_right", tPlainFontStruct)
  pWriterPlainNormRight = getWriter("bb_plain_norm_right")
  pWriterPlainNormRight.setProperty(#alignment, #right)
  pWriterPlainNormRight.define([#wordWrap:0])
  tBoldFontStruct = getStructVariable("struct.font.bold")
  createWriter("bb_plain_bold_left", tBoldFontStruct)
  pWriterPlainBoldLeft = getWriter("bb_plain_bold_left")
  tStruct = getStructVariable("struct.font.link")
  tStruct.setaProp(#fontStyle, [#underline])
  tStruct.setaProp(#font, tBoldFontStruct.getAt(#font))
  createWriter("bb_link_right", tStruct)
  pWriterLinkRight = getWriter("bb_link_right")
  me.renderButtonImages()
  return(1)
end

on deconstruct me 
  removeWriter("bb_plain_norm_left")
  pWriterPlainNormLeft = void()
  removeWriter("bb_plain_norm_right")
  pWriterPlainNormRight = void()
  removeWriter("bb_plain_bold_left")
  pWriterPlainBoldLeft = void()
  removeWriter("bb_link_right")
  pWriterLinkRight = void()
  pGoButtonImages = void()
  pJoinButtonImage = void()
  return(1)
end

on defineWindow me, tID 
  pMainWindowId = tID
  return(1)
end

on renderButtonImages me 
  pGoButtonImages = [:]
  repeat while [#created, #started, #finished] <= undefined
    tstate = getAt(undefined, undefined)
    tGoButtonImage = image(92, 12, 8)
    tImage = pWriterLinkRight.render(getText("gs_button_go_" & tstate))
    tLocH = 80 - tImage.width
    tGoButtonImage.copyPixels(tImage, tImage.rect + rect(tLocH, 0, tLocH, 0), tImage.rect)
    tImage = member(getmemnum("bb_arr")).image
    tGoButtonImage.copyPixels(tImage, tImage.rect + rect(84, 1, 84, 1), tImage.rect)
    pGoButtonImages.addProp(tstate, tGoButtonImage)
  end repeat
  pJoinButtonImage = image(191, 16, 8)
  pJoinButtonImage.fill(1, 1, 193, 16, paletteIndex(86))
  tImage = pWriterLinkRight.render(getText("bb_link_join"))
  tLocH = 176 - tImage.width
  pJoinButtonImage.copyPixels(tImage, tImage.rect + rect(tLocH, 3, tLocH, 3), tImage.rect)
  tImage = member(getmemnum("bb_arr")).image
  pJoinButtonImage.copyPixels(tImage, tImage.rect + rect(180, 4, 180, 4), tImage.rect)
  return(1)
end

on renderTournamentLogo me, tTournamentLogoMemNum 
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  if tTournamentLogoMemNum = 0 then
    return(0)
  end if
  tElem = tWndObj.getElement("bb_logo_tournament")
  if tElem <> 0 then
    tmember = member(tTournamentLogoMemNum)
    if tmember.type = #bitmap and tElem <> 0 then
      tElem.setProperty(#cursor, "cursor.finger")
      tElem.setProperty(#image, tmember.image)
    end if
  end if
  return(1)
end

on renderInstanceList me, tList, tStartIndex, tCount 
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  i = 1
  repeat while i <= tCount
    tIndex = tStartIndex + i - 1
    tElem = tWndObj.getElement("bb_area_gameList" & i)
    if tElem = 0 then
      return(0)
    end if
    if tIndex <= tList.count then
      tItem = tList.getAt(tIndex)
      tText2 = tItem.getAt(#host).getAt(#name)
      tImage = me.getInstanceListItemBg(tItem.getAt(#state))
      tAddOffset = 0
      if variableExists("bb_gamelist_voffset") then
        tAddOffset = getVariable("bb_gamelist_voffset")
      end if
      tTextImg = pWriterPlainBoldLeft.render(tItem.getAt(#name))
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 3 + tAddOffset, 32, 3 + tAddOffset), tTextImg.rect)
      tGoButtonImage = pGoButtonImages.getAt(tItem.getAt(#state))
      if tGoButtonImage <> void() then
        tLocH = tImage.width - tGoButtonImage.width - 5
        tImage.copyPixels(tGoButtonImage, tGoButtonImage.rect + rect(tLocH, 19, tLocH, 19), tGoButtonImage.rect, [#ink:36])
      end if
      tElem.setProperty(#cursor, "cursor.finger")
    else
      tText2 = "---"
      tImage = me.getInstanceListItemBg(#empty)
      tElem.setProperty(#cursor, 0)
    end if
    tAddOffset = 0
    if variableExists("bb_gamelist_sub_voffset") then
      tAddOffset = getVariable("bb_gamelist_sub_voffset")
    end if
    tTextImg = pWriterPlainNormLeft.render(tText2)
    tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 20 + tAddOffset, 32, 20 + tAddOffset), tTextImg.rect)
    tElem.feedImage(tImage)
    i = 1 + i
  end repeat
  return(1)
end

on getInstanceListItemBg me, tstate 
  if tstate = #created then
    tImage1 = member(getmemnum("bb_bg_grn")).image
    tImage2 = member(getmemnum("bb_ico_thumb")).image
    tRegPoint2 = member(getmemnum("bb_ico_thumb")).regPoint
  else
    if tstate = #started then
      tImage1 = member(getmemnum("bb_bg_red")).image
      tImage2 = member(getmemnum("bb_ico_bounce")).image
      tRegPoint2 = member(getmemnum("bb_ico_bounce")).regPoint
    else
      if tstate = #finished then
        tImage1 = member(getmemnum("bb_bg_gry")).image
        tImage2 = member(getmemnum("bb_ico_flag")).image
        tRegPoint2 = member(getmemnum("bb_ico_flag")).regPoint
      else
        if tstate = #empty then
          tImage1 = member(getmemnum("bb_bg_emp")).image
        end if
      end if
    end if
  end if
  tImage = image(191, 33, 8, member(getmemnum("bb_colors Palette")))
  tImage.copyPixels(tImage1, tImage.rect, tImage1.rect)
  if tImage2 <> void() then
    tImage.copyPixels(tImage2, tImage2.rect + rect(3 - tRegPoint2.locH, 4 - tRegPoint2.locV, 3 - tRegPoint2.locH, 4 - tRegPoint2.locV), tImage2.rect, [#ink:8, #maskImage:tImage2.createMatte()])
  end if
  return(tImage)
end

on renderInstanceDetailTop me, tName, tHostName, tstate, tStateStr, tSpecs 
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.getElement("bb_header_gameChsn").setText(tName)
  tImage = image(191, 48, 8, member(getmemnum("bb_colors Palette")))
  if tstate = #created then
    tStateIconMember = member(getmemnum("bb_ico_thumb"))
    tBgImageMember = member(getmemnum("bb_gameinfo_bg_2"))
  else
    if tstate = #started then
      tStateIconMember = member(getmemnum("bb_ico_bounce"))
      tBgImageMember = member(getmemnum("bb_gameinfo_bg_3"))
    else
      if tstate = #finished then
        tStateIconMember = member(getmemnum("bb_ico_flag"))
        tBgImageMember = member(getmemnum("bb_gameinfo_bg_1"))
      end if
    end if
  end if
  if tBgImageMember = void() then
    return(0)
  end if
  tBgImage = tBgImageMember.image
  tImage.copyPixels(tBgImage, tImage.rect, tBgImage.rect)
  tAddOffset = 0
  if variableExists("bb_gamelist_sub_voffset") then
    tAddOffset = getVariable("bb_gamelist_sub_voffset")
  end if
  tTextImg = pWriterPlainNormLeft.render(tHostName)
  tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 4 + tAddOffset, 32, 4 + tAddOffset), tTextImg.rect)
  tTextImg = pWriterPlainNormLeft.render(tStateStr)
  tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 20 + tAddOffset, 32, 20 + tAddOffset), tTextImg.rect)
  tTextImg = pWriterPlainNormLeft.render(tSpecs)
  tImage.copyPixels(tTextImg, tTextImg.rect + rect(32, 36 + tAddOffset, 32, 36 + tAddOffset), tTextImg.rect)
  if tStateIconMember = void() then
    return(0)
  end if
  tStateIcon = tStateIconMember.image
  tStRegpoint = tStateIconMember.regPoint
  tImage.copyPixels(tStateIcon, tStateIcon.rect + rect(3 - tStRegpoint.locH, 4 - tStRegpoint.locV, 3 - tStRegpoint.locH, 4 - tStRegpoint.locV), tStateIcon.rect, [#ink:8, #maskImage:tStateIcon.createMatte()])
  tWndObj.getElement("bb_area_gameInfo").feedImage(tImage)
  return(1)
end

on renderInstanceDetailButton me, tButtonState, tGameState 
  tResult = image(191, 16, 8)
  tBlend = 255
  if tButtonState <> #start then
    if tButtonState = #start_dimmed then
      tBg = member(getmemnum("bb_lnk_px_3")).image
      tText = getText("gs_button_start")
      if tButtonState = #start_dimmed then
        tBlend = 100
        tButtonState = #start
      end if
    else
      if tButtonState = #spectate then
        if tGameState = #started then
          tBg = member(getmemnum("bb_lnk_px_3")).image
        else
          tBg = member(getmemnum("bb_lnk_px_2")).image
        end if
        tText = getText("gs_button_spectate")
      else
        if tButtonState = #spectateInfo then
          tBg = member(getmemnum("bb_lnk_px_2")).image
          tText = getText("gs_text_spectate")
        else
          if tButtonState = #started then
            tBg = member(getmemnum("bb_lnk_px_3")).image
          else
            if tButtonState = #created then
              tBg = member(getmemnum("bb_lnk_px_2")).image
            else
              if tButtonState = #finished then
                tBg = member(getmemnum("bb_lnk_px_1")).image
              end if
            end if
          end if
          tText = ""
        end if
      end if
    end if
    if ilk(tBg) <> #image then
      return(0)
    end if
    tResult.paletteRef = tBg.paletteRef
    tResult.copyPixels(tBg, tResult.rect, tBg.rect)
    tWidth = tResult.width
    if tButtonState = #start or tButtonState = #spectate then
      tImage = pWriterLinkRight.render(tText)
      tLocH = tWidth - tImage.width - 10
      tResult.copyPixels(tImage, tImage.rect + rect(tLocH - 5, 3, tLocH - 5, 3), tImage.rect, [#blendLevel:tBlend])
      tImage = member(getmemnum("bb_arr")).image
      tResult.copyPixels(tImage, tImage.rect + rect(tWidth - 12, 4, tWidth - 12, 4), tImage.rect, [#ink:36, #blendLevel:tBlend])
    else
      if tText <> #empty then
        tImage = pWriterPlainBoldLeft.render(tText)
        tLocH = tWidth / 2 - tImage.width / 2
        tResult.copyPixels(tImage, tImage.rect + rect(tLocH, 3, tLocH, 3), tImage.rect)
      end if
    end if
    tWndObj = getWindow(pMainWindowId)
    if tWndObj = 0 then
      return(0)
    end if
    tElem = tWndObj.getElement("bb_link_gameInfo")
    tElem.feedImage(tResult)
    if tButtonState <> #empty then
      if tButtonState = #spectateInfo then
        tElem.setProperty(#cursor, 0)
      else
        tElem.setProperty(#cursor, "cursor.finger")
      end if
    end if
  end if
end

on renderInstanceDetailTeams me, tParams, tUserName, tHost, tOwnTeam 
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tTeamNum = 1
  repeat while tTeamNum <= tParams.getAt(#numTeams)
    tImage = tWndObj.getElement("bb_area_team" & tTeamNum).getProperty(#buffer)
    if tImage.type <> #bitmap then
      return(0)
    end if
    tImage = tImage.image
    tBallImage = member(getmemnum("bb_ico_ball" & tParams.getAt(#teams).getAt(tTeamNum).getAt(#id))).image
    tImage.copyPixels(tBallImage, tBallImage.rect + rect(5, 6, 5, 6), tBallImage.rect)
    tText = ""
    tPlayers = tParams.getAt(#teams).getAt(tTeamNum).getAt(#players)
    tPlayerNum = 1
    repeat while tPlayerNum <= tPlayers.count
      tText = tText & tPlayers.getAt(tPlayerNum).getAt(#name) & "\r"
      tElem = tWndObj.getElement("bb_kick" & tTeamNum & "_" & tPlayerNum)
      tNotMe = tPlayers.getAt(tPlayerNum).getAt(#name) <> tUserName
      if tElem <> 0 then
        tElem.setProperty(#visible, tHost and tParams.getAt(#state) = #created and tNotMe)
      end if
      tPlayerNum = 1 + tPlayerNum
    end repeat
    tPlayerNum = tPlayers.count + 1
    repeat while tPlayerNum <= 6
      tElem = tWndObj.getElement("bb_kick" & tTeamNum & "_" & tPlayerNum)
      if tElem <> 0 then
        tElem.setProperty(#visible, 0)
      end if
      tPlayerNum = 1 + tPlayerNum
    end repeat
    tAddedOffset = 0
    if variableExists("bb_menu_nameandscore_voffset") then
      tAddedOffset = getVariable("bb_menu_nameandscore_voffset")
    end if
    tTextImg = pWriterListPlainNormLeft.render(tText)
    tImage.copyPixels(tTextImg, tTextImg.rect + rect(30, -3 + tAddedOffset, 30, -3 + tAddedOffset), tTextImg.rect)
    if tParams.getAt(#state) = #finished then
      tText = ""
      tPlayerNum = 1
      repeat while tPlayerNum <= tPlayers.count
        tText = tText & tPlayers.getAt(tPlayerNum).getAt(#score) & "\r"
        tPlayerNum = 1 + tPlayerNum
      end repeat
      pWriterPlainNormRight.define([#fixedLineSpace:16])
      tTextImg = pWriterPlainNormRight.render(tText)
      tOffsetH = 158
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(tOffsetH, -3 + tAddedOffset, tOffsetH, -3 + tAddedOffset), tTextImg.rect)
      tTextImg = pWriterListPlainNormLeft.render(getText("gs_scores_team_" & tParams.getAt(#teams).getAt(tTeamNum).getAt(#id)))
      tOffsetV = tImage.height - 18
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(30, tOffsetV, 30, tOffsetV), tTextImg.rect, [#ink:36])
      tTextImg = pWriterPlainNormRight.render(string(tParams.getAt(#teams).getAt(tTeamNum).getAt(#score)))
      tImage.copyPixels(tTextImg, tTextImg.rect + rect(tOffsetH, tOffsetV, tOffsetH, tOffsetV), tTextImg.rect)
    end if
    tTeamNum = 1 + tTeamNum
  end repeat
  tTeamNum = 1
  repeat while tTeamNum <= 4
    tElem = tWndObj.getElement("bb_link_team" & tTeamNum)
    if tElem <> 0 then
      if tTeamNum = tOwnTeam or tParams.getAt(#state) <> #created then
        tElem.setProperty(#visible, 0)
      else
        tElem.setProperty(#visible, 1)
        tElem.feedImage(pJoinButtonImage)
      end if
    end if
    tTeamNum = 1 + tTeamNum
  end repeat
end

on renderPageNumber me, tPage, tNumPages 
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  tWndObj.getElement("bb_txt_pageNumber").setText(tPage & "/" & tNumPages)
  tElem = tWndObj.getElement("bb_arrow_pageBack")
  if tPage > 1 then
    tElem.setProperty(#blend, 100)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.setProperty(#blend, 30)
    tElem.setProperty(#cursor, 0)
  end if
  tElem = tWndObj.getElement("bb_arrow_pageFwd")
  if tPage < tNumPages then
    tElem.setProperty(#blend, 100)
    tElem.setProperty(#cursor, "cursor.finger")
  else
    tElem.setProperty(#blend, 30)
    tElem.setProperty(#cursor, 0)
  end if
end

on updateRadioButton me, tElement, tListOfOthersElements 
  tOnImg = member(getmemnum("button.radio.on")).image
  tOffImg = member(getmemnum("button.radio.off")).image
  tWndObj = getWindow(pMainWindowId)
  if tWndObj = 0 then
    return(0)
  end if
  if tWndObj.elementExists(tElement) then
    tWndObj.getElement(tElement).setProperty(#image, tOnImg)
  end if
  repeat while tListOfOthersElements <= tListOfOthersElements
    tRadioElement = getAt(tListOfOthersElements, tElement)
    if tWndObj.elementExists(tRadioElement) then
      tWndObj.getElement(tRadioElement).setProperty(#image, tOffImg)
    end if
  end repeat
end