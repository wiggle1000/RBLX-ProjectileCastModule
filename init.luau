--!strict
-- ProjectileCast.lua V1.0.0 by wiggle1000
-- Scroll to bottom for license information and copyright notice


local Curve = require(script.Curve);

--- [TYPE] ProjectileCastResult --------------------------------------------------------
--- Returned by a projectile cast. Contains useful additional
--- information like velocity and total distance! Optionally contains
--- a RaycastResult if there has been a collision.

local ProjectileCastResult = {};
ProjectileCastResult.__index = ProjectileCastResult;

type ProjectileCastResultImpl = 
	{
		__index: ProjectileCastResultImpl;
		new: (totalDistance : number, PFinal : Vector3, VFinal : Vector3, LastRayResult : RaycastResult?) -> ProjectileCastResult;
	}
type ProjectileCastResultVars = 
	{
		TotalDistance	: number;
		Velocity		: Vector3;
		Position		: Vector3;
		LastRayResult 	: RaycastResult?;
	}

export type ProjectileCastResult = typeof( setmetatable({} :: ProjectileCastResultVars, {} :: ProjectileCastResultImpl));

function ProjectileCastResult.new(TotalDistance : number, PFinal : Vector3, VFinal : Vector3, LastRayResult : RaycastResult?) : ProjectileCastResult
	local self = {};
	self.TotalDistance = TotalDistance;
	self.Velocity = VFinal;
	self.Position = PFinal;
	self.LastRayResult = LastRayResult;
	return setmetatable(self, ProjectileCastResult);
end


--- [TYPE] ProjectileCast --------------------------------------------------------
--- The main operation of this module. Create an instance of this class to
--- cast or enumerate through a projectile cast!

local ProjectileCast = {};
ProjectileCast.__index = ProjectileCast;

type ProjectileCastImpl = 
	{
		__index: ProjectileCastImpl;
		new: (position : Vector3, velocity : Vector3, precision : number, isHighFidelity:boolean, maxDist : number?, rayParams : RaycastParams?, gravity : number?) -> ProjectileCast;
		Step: (self : ProjectileCast, precisionOverride : number?) -> (boolean, ProjectileCastResult);
		Cast: (self : ProjectileCast) -> (boolean, ProjectileCastResult);
		DoProjection: (position : Vector3, velocity : Vector3, precision : number, isHighFidelity:boolean, maxDist : number?, rayParams : RaycastParams?, gravity : number?) -> (boolean, ProjectileCastResult);
	}
type ProjectileCastVars = 
	{
		precision	 : number;  --approx. studs between raycasts
		highFidelity : boolean; --if true, use a more accurate from-to calculation. helps with larger gaps between checks (higher precision)
		cTime		 : number;  --current simulation time
		cDist		 : number;  --approx total distance traveled
		maxDist		 : number;  --will give up if this distance is reached
		rayParams 	 : RaycastParams?; --used when raycasting
		curve		 : Curve.Curve;
	}

export type ProjectileCast = typeof( setmetatable({} :: ProjectileCastVars, {} :: ProjectileCastImpl));

function ProjectileCast.new(position : Vector3, velocity : Vector3, precision : number, isHighFidelity:boolean, maxDist : number?, rayParams : RaycastParams?, gravity : number?) : ProjectileCast
	local self = {};
	self.highFidelity = isHighFidelity;
	self.precision = precision / 100.0;
	self.cTime = 0;
	self.cDist = 0;
	self.maxDist = maxDist or 100;
	self.rayParams = rayParams;
	self.curve = Curve.new(position, velocity, gravity or workspace.Gravity);
	return setmetatable(self, ProjectileCast);
end

--- [ Single step the simulation, with optional precision override ]
--- Manually calling this can be useful for slower projectiles,
--- where objects may move around while the projectile is moving
--- [Returns] 
---  > is collided? : boolean
---  > result		: ProjectileCastResult
--- [NOTE] The LastRayResult property of the result will be nil unless a collision has occured
function ProjectileCast:Step(precisionOverride : number?) : (boolean, ProjectileCastResult)
	local len = (precisionOverride or self.precision);
	local pos:Vector3, vel:Vector3 = self.curve:Project(self.cTime);
	local toNext : Vector3 = vel * len;
	if(self.highFidelity)then
		local posNext:Vector3, velNext:Vector3 = self.curve:Project(self.cTime + len);
		toNext = posNext - pos;
	end
	local rayResult : RaycastResult? = workspace:Raycast(pos, toNext, self.rayParams);
	if(rayResult)then
		self.cDist += rayResult.Distance;
		return true, ProjectileCastResult.new(self.cDist, pos, vel, rayResult);
	end
	self.cDist += toNext.Magnitude;
	self.cTime += len;
	return false, ProjectileCastResult.new(self.cDist, pos, vel, nil);
end


--- [ Run the entire simulation to its end, using configured precision]
--- Immediately runs all projectile steps until either a collision occurs,
--- or we hit max distance.
--- [Returns] 
---  > did collide? : boolean
---  > result		: ProjectileCastResult
--- [NOTE] The LastRayResult property of the result will be nil unless a collision has occured
function ProjectileCast:Cast() : (boolean, ProjectileCastResult)
	local coll : boolean, r : ProjectileCastResult;
	while (self.cDist < self.maxDist) do
		coll, r = self:Step();
		if(coll)then
			return true, r;
		end
	end
	return false, r;
end

--- [ Run a full simulation to its end without having to handle the object]
--- Creates, uses, and disposes of a ProjectileCast object internally,
--- only giving back those delicious results!
--- [Returns] 
---  > did collide? : boolean
---  > result		: ProjectileCastResult
--- [NOTE] The LastRayResult property of the result will be nil unless a collision has occured
function ProjectileCast.DoProjection(position : Vector3, velocity : Vector3, precision : number, isHighFidelity:boolean, maxDist : number?, rayParams : RaycastParams?, gravity : number?) : (boolean, ProjectileCastResult)
	local pc : ProjectileCast = ProjectileCast.new(position, velocity, precision, isHighFidelity, maxDist, rayParams, gravity);
	return pc:Cast();
end

return ProjectileCast;



-- Copyright 2025 @wiggle1000

-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
-- http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
