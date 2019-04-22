property pCloseTimerList, pFlagList, pFlagCloseTimeout, pUpdateCounter, pUpdateInterval, pFlagSetIndex

on construct me 
  pUpdateInterval = 3
  pFlagCloseTimeout = 4
  pFlagList = [:]
  pFlagSetIndex = [:]
  pCloseTimerList = [:]
  receiveUpdate(me.getID())
  return(1)
end

on deconstruct me 
  removeUpdate(me.getID())
  me.reset()
  return(1)
end

on toggle me, tID 
  tID = me.getMatchingFlagId(tID)
  if tID = void() then
    return(0)
  end if
  tObject = me.getaProp(tID)
  if not objectp(tObject) then
    return(0)
  end if
  tObject.toggle(tID)
  me.alignZ()
  return(1)
end

on open me, tID 
  if pCloseTimerList.findPos(tID) then
    pCloseTimerList.deleteProp(tID)
  end if
  i = 1
  repeat while i <= pFlagList.count
    tObject = pFlagList.getAt(i)
    if tID contains pFlagList.getPropAt(i) then
      pCloseTimerList.deleteProp(pFlagList.getPropAt(i))
      tObject.open()
    else
      tObject.close()
    end if
    i = 1 + i
  end repeat
  me.alignZ()
  return(1)
end

on close me, tID 
  if tID = void() then
    i = 1
    repeat while i <= pFlagList.count
      tObject = pFlagList.getAt(i)
      tID = pFlagList.getPropAt(i)
      pCloseTimerList.setaProp(tID, [tObject, pFlagCloseTimeout])
      i = 1 + i
    end repeat
    exit repeat
  end if
  tID = me.getMatchingFlagId(tID)
  tObject = me.getaProp(tID)
  if objectp(tObject) then
    if pCloseTimerList.findPos(tID) = 0 then
      pCloseTimerList.setaProp(tID, [tObject, pFlagCloseTimeout])
    end if
  end if
  return(1)
end

on reset me 
  return(removeAllFlagObjects())
end

on getFlagState me, tID 
  tID = me.getMatchingFlagId(tID)
  tObject = pFlagList.getaProp(tID)
  if tObject = 0 then
    return(0)
  end if
  return(tObject.getState())
end

on alignZ me 
  repeat while pFlagList <= undefined
    tObject = getAt(undefined, undefined)
    tObject.alignZ()
  end repeat
  return(1)
end

on update me 
  pUpdateCounter = pUpdateCounter + 1
  if pUpdateCounter < pUpdateInterval then
    return(1)
  end if
  pUpdateCounter = 0
  if pFlagList.count = 0 then
    return(0)
  end if
  repeat while pFlagList <= undefined
    tObject = getAt(undefined, undefined)
    tObject.update()
  end repeat
  tChanges = 0
  i = 1
  repeat while i <= pCloseTimerList.count
    tItem = pCloseTimerList.getAt(i)
    if tItem.getAt(2) = 0 then
      tObject = tItem.getAt(1)
      tObject.close()
      pCloseTimerList.deleteAt(i)
      tChanges = 1
      next repeat
    end if
    pCloseTimerList.getAt(i).setAt(2, tItem.getAt(2) - 1)
    i = i + 1
  end repeat
  if tChanges then
    me.alignZ()
  end if
  return(1)
end

on setInfoFlag me, tSetID, tID, tWndID, tElemID, tFlagType, tColor, tItemInfo 
  if me.exists(tID) then
    return(1)
  end if
  tWndObj = getWindow(tWndID)
  if tWndObj = 0 then
    return(error(me, "Reference window not found:" && tWndID, #setInfoFlag))
  end if
  tElem = tWndObj.getElement(tElemID)
  if tElem = 0 then
    return(error(me, "Reference element not found in window:" && tWndID && tElemID, #setInfoFlag))
  end if
  tLocV = tWndObj.getProperty(#locY) + tElem.getProperty(#locY) - 7
  tlocz = tWndObj.getProperty(#locZ) + tElem.getProperty(#locY) * 10
  tObject = me.getFlagObject(tSetID, tID, tFlagType, 1)
  tObject.define(tID, tLocV, tlocz, tColor, tFlagType, tItemInfo)
  tObject.createWindows(tObject)
  return(1)
end

on removeFlagSet me, tSetID 
  if pFlagSetIndex.findPos(tSetID) = 0 then
    return(1)
  end if
  tFlagSet = pFlagSetIndex.getaProp(tSetID)
  repeat while tFlagSet <= undefined
    tObjectID = getAt(undefined, tSetID)
    me.Remove(tObjectID)
  end repeat
  pFlagSetIndex.deleteProp(tSetID)
  return(1)
end

on Remove me, tID 
  tID = me.getMatchingFlagId(tID)
  if tID = void() then
    return(0)
  end if
  tObject = pFlagList.getaProp(tID)
  if tObject <> 0 then
    tObject.deconstruct()
  end if
  pFlagList.deleteProp(tID)
  pFlagSetIndex.deleteProp(tID)
  pCloseTimerList.deleteProp(tID)
  return(1)
end

on exists me, tID 
  tID = me.getMatchingFlagId(tID)
  if tID = void() then
    return(0)
  end if
  return(pFlagList.findPos(tID) > 0)
end

on getMatchingFlagId me, tWndID 
  i = 1
  repeat while i <= pFlagList.count
    tItemName = pFlagList.getPropAt(i)
    if tWndID = tItemName or tWndID contains tItemName & "_" then
      return(pFlagList.getPropAt(i))
    end if
    i = 1 + i
  end repeat
  return(0)
end

on getFlagObject me, tSetID, tID, tFlagType, tAddIfMissing 
  if tSetID = void() then
    return(0)
  end if
  if tID = void() then
    return(0)
  end if
  tObject = pFlagList.getaProp(tID)
  if tObject <> 0 then
    return(tObject)
  end if
  if not tAddIfMissing then
    return(0)
  end if
  if memberExists("IG UIFlag" && tFlagType) then
    tObject = createObject(getUniqueID(), ["IG UIFlag Class", "IG UIFlag" && tFlagType])
  else
    tObject = createObject(getUniqueID(), "IG UIFlag Class")
  end if
  if tObject = 0 then
    return(0)
  end if
  pFlagList.setaProp(tID, tObject)
  tSetIndex = pFlagSetIndex.getaProp(tSetID)
  if not listp(tSetIndex) then
    tSetIndex = []
  end if
  tSetIndex.append(tID)
  pFlagSetIndex.setaProp(tSetID, tSetIndex)
  return(tObject)
end

on removeAllFlagObjects me 
  repeat while pFlagList <= undefined
    tObject = getAt(undefined, undefined)
    tObject.deconstruct()
  end repeat
  pFlagList = [:]
  pFlagSetIndex = [:]
  pCloseTimerList = [:]
  return(1)
end

on getWindowWrapper me 
  return(getObject(#ig_window_wrapper))
end