on define(me, tSprite)
  pSprite = tSprite
  me.reset()
  return(1)
  exit
end

on reset(me)
  tTrainSpeed = random(30) + 15
  pSprite.loc = point(603, 373)
  pOffset = [-2, -1]
  createTimeout("TrainTimer", tTrainSpeed, #updateTrain, me.getID(), void(), 0)
  exit
end

on updateTrain(me)
  if visualizerExists("entry_view") then
    if pSprite.locH > 100 then
      pSprite.loc = pSprite.loc + pOffset
    else
      if timeoutExists("TrainTimer") then
        removeTimeout("TrainTimer")
        me.waiter()
      end if
    end if
  end if
  exit
end

on waiter(me)
  me.delay(5000, #reset)
  exit
end