--!strict

-- Curve V1.0.0 by wiggle1000
-- Scroll to bottom for license information and copyright notice

local Curve = {};
Curve.__index = Curve;

type CurveImpl = 
	{
		__index : CurveImpl;
		new: (vInitial : Vector3, pInitial : Vector3, gravity : number?) -> Curve;
		Project: (self: Curve, t : number) -> (Vector3, Vector3);
	}
type CurveVars = 
	{
		gravity	 : number; --in meters per second squared
		pInitial : Vector3;
		vInitial : Vector3;
	}

export type Curve = typeof( setmetatable({} :: CurveVars, {} :: CurveImpl));

--- [ Create a new curve object. If gravity is nil, fall back to 9.8 ]
function Curve.new(pInitial : Vector3, vInitial : Vector3, gravity : number?) : Curve
	local self = {};
	-- gravity conversion from classic (20 studs = 1 meter, studs/s^2) system to real life unit (m/s^2)
	-- self.gravity = (gravity or workspace.Gravity) / 20.0;
	
	-- simpler implementation that assumes real world gravity unit
	self.gravity  = gravity or 9.8;
	self.pInitial = pInitial;
	self.vInitial = vInitial;
	return setmetatable(self, Curve);
end

--- [ Projects by t (time) along the curve. ]
--- [Returns]
---  > Position at time t : Vector3
---  > Velocity at time t : Vector3
function Curve:Project(t : number) : (Vector3, Vector3)
	local pos = Vector3.new(
		self.vInitial.X * t,
		self.vInitial.Y * t + (-self.gravity/2) * t * t,
		self.vInitial.Z * t
	);
	local vel = Vector3.new(
		self.vInitial.X,
		-self.gravity * t + self.vInitial.Y,
		self.vInitial.Z
	);
	return pos + self.pInitial, vel;
end

return Curve;



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
