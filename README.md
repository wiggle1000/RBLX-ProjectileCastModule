# ProjectileCast Module
Roblox Module that allows for Projectile-Casting with bullet drop.

## Setup
Place the ModuleScript ProjectileCast.luau (init.luau) where you keep your modules; Curve.luau should be another ModuleScript parented to ProjectileCast.

## Example Usage
```luau
-- Require module (FILL IN LOCATION!)
local ProjectileCast = require(?????.ProjectileCast);

--DON'T DO THIS. Useful in a test place to allow workspace to load in.
task.wait(3);

--vars for projectiles
local startPos : Vector3 = Vector3.zero;
local startVel : Vector3 = Vector3.new(100, 100, 0);
local checkDelta : number = 2;
local useMoreAccurateFormula : boolean = true; --adds a bit more calculation time, but reduces inaccuracy a lot
local maxDistance : number = 500;

local rayParams : RaycastParams = RaycastParams.new();
rayParams.RespectCanCollide = true;

------------------- DO AN INSTANTANEOUS CAST -------------------
print("[TEST: INSTANTANEOUS CAST]");
local pCast : ProjectileCast.ProjectileCast = ProjectileCast.new(startPos, startVel, checkDelta, useMoreAccurateFormula, maxDistance, rayParams);
print("Casting from "..tostring(startPos).." at speed "..tostring(startVel)..".");
local didCollide : boolean, result : ProjectileCast.ProjectileCastResult = pCast:Cast();
if(didCollide and result.LastRayResult)then
  print("Hit! Hit point is "..tostring(result.LastRayResult.Position).." and the distance travelled is "..tostring(result.TotalDistance).."!");
end
------------------- DO AN INSTANTANEOUS CAST (WITH HELPER FUNCTION!) -------------------
print("[TEST: INSTANTANEOUS CAST (HELPER)]");
print("Casting from "..tostring(startPos).." at speed "..tostring(startVel)..".");
local didCollide : boolean, result : ProjectileCast.ProjectileCastResult = ProjectileCast.DoProjection(startPos, startVel, checkDelta, useMoreAccurateFormula, maxDistance, rayParams)
if(didCollide and result.LastRayResult)then
  print("Hit! Hit point is "..tostring(result.LastRayResult.Position).." and the distance travelled is "..tostring(result.TotalDistance).."!");
end
------------------- DO A STEPPED CAST-------------------
print("[TEST: STEPPED CAST]");
local pCast : ProjectileCast.ProjectileCast = ProjectileCast.new(startPos, startVel, checkDelta, useMoreAccurateFormula, maxDistance, rayParams);
print("Casting from "..tostring(startPos).." at speed "..tostring(startVel)..".");
local didCollide : boolean, result : ProjectileCast.ProjectileCastResult;
local flyTime = 0;
local dt = 0.5;
while true do
  didCollide, result = pCast:Step(dt);
  if(didCollide and result.LastRayResult)then
    print("Hit! Hit point is "..tostring(result.LastRayResult.Position).." and the distance travelled is "..tostring(result.TotalDistance).."!");
    break;
  end
  task.wait(dt);
  flyTime += dt;
  if(flyTime >= 5)then
    print ("Hit end of time limit! Most likely nothing was hit.");
    break;
  end
end
```
