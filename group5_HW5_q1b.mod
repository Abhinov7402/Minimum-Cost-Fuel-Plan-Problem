#AMPL HW_5 _1a DSA/ISE5113
#Authors  Sai Abhinov Chowdary Katragadda, Yashasvi Mususku,
#         Vivek Satya Sai Veera Venkata Talluri, Vignesh Murugan 
#Date: 03/16/2024
# Problem Description:
# This AMPL script models flight plan decision problem where the objective is to 
# minimize fuel cost by tankering with minimum purchase of 200 gallon constraint
# Reset AMPL environment and specify solver options:
reset;
option solver cplex;
option cplex_options 'sensitivity';

#sets 
set fltplan;   #The flight destinations in order

# parameters

param FuelCost {fltplan}; 				# fuel cost at each destination in dollars
param RampFees {fltplan}; 				# ramp fees at each destination in dollars
param MinGaltoWaivFees {fltplan}; 		# Mininmum fuel purchase in gallons to waive Rampfees
param FuelBurn {fltplan}; 				# Fuel consumed in each trip
param passengers {fltplan};				# defining the number of paasengers

param MaxRampWeight;
param MaxLandingWeight;
param BOW;
param FuelTankCapacity;
param MinLandingFuel;
param ReturnFuelLimit;

param M = FuelTankCapacity - MinLandingFuel;   # Fuel tank Capacity - Min Landing Fuel

# Decision Variables

var x {fltplan} binary;   # airport chosen for filling
var y {fltplan} binary;   # airport ramp fee waive off

var FuelLeft {fltplan} >= 0;
var FuelBefore {fltplan} >= 0;
var FuelAdd {fltplan} >= 0;

var LandingWeight {fltplan} >= 0;
var RampWeight {fltplan} >= 0;
var Cost {fltplan} >= 0;


# Objective_Function

minimize TotFuelCost: sum {i in fltplan} Cost[i];


# Constraints

# 1.fuel filling at airport
subject to FuelFilling {i in fltplan}: FuelBefore[i] = FuelLeft[i] + FuelAdd[i];


# 2.fuel tank capacity limit 
subject to FuelTankLimit {i in fltplan}: FuelBefore[i] <= FuelTankCapacity;


# 3.Emergency Fuel limit
subject to EmergencyFuelLimit {i in fltplan}: FuelLeft[i] >= MinLandingFuel;


# 4.Fuel in Tank before and after Trips constraint
subject to FuelatBegin : FuelLeft['KCID1'] = ReturnFuelLimit;
subject to FuelatEnd: FuelBefore['KCID2'] >= ReturnFuelLimit;

#5. Ramp Fees waive const
subject to RmpFees {i in fltplan}: y[i] <= (FuelAdd[i]/(6.7*MinGaltoWaivFees[i]));

# 6.calculating the Total cost (= fuel + ramp fees)
subject to Total_Cost {i in fltplan}: Cost[i] = RampFees[i] *(1-y[i]) + FuelCost[i]*FuelAdd[i]/6.7;

#7. Limitation on Fuel Purchase
subject to FuelLimit {i in fltplan}: FuelAdd[i] <= M * x[i] ;
subject to Fuelpurch {i in fltplan}: FuelAdd[i] >= 200*6.7*x[i];

# 8.Landing weight at each destination
subject to LWKCID1: LandingWeight['KCID1'] = FuelLeft['KCID1'] + BOW + 200*0;
subject to LWKACK: LandingWeight['KACK'] = FuelLeft['KACK'] + BOW + 200 * passengers['KCID1'] ;
subject to LWKMMU: LandingWeight['KMMU'] = FuelLeft['KMMU'] + BOW + 200 * passengers['KACK'] ;
subject to LWKBNA: LandingWeight['KBNA'] = FuelLeft['KBNA'] + BOW + 200 * passengers['KMMU'] ;
subject to LWKTUL: LandingWeight['KTUL'] = FuelLeft['KTUL'] + BOW + 200 * passengers['KBNA'] ;
subject to LWKCID2: LandingWeight['KCID2'] = FuelLeft['KCID2'] + BOW + 200 * passengers['KTUL'] ;

# 9.Ramp weight at each airport
subject to RWKCID1: RampWeight['KCID1'] = FuelLeft['KCID1'] + FuelAdd['KCID1'] + BOW + 200 * 0 ;
subject to RWKACK: RampWeight['KACK'] = FuelLeft['KACK'] + FuelAdd['KACK'] + BOW + 200 * passengers['KACK']  ;
subject to RWKMMU: RampWeight['KMMU'] = FuelLeft['KMMU'] + FuelAdd['KMMU'] + BOW + 200 * passengers['KMMU'] ;
subject to RWKBNA: RampWeight['KBNA'] = FuelLeft['KBNA'] + FuelAdd['KBNA'] + BOW + 200 * passengers['KBNA'] ;
subject to RWKTUL: RampWeight['KTUL'] = FuelLeft['KTUL'] + FuelAdd['KTUL'] + BOW + 200 * passengers['KTUL'];
subject to RWKCID2: RampWeight['KCID2'] = FuelLeft['KCID2'] + FuelAdd['KCID2'] + BOW + 200 * passengers['KCID2'];

# 10.maximum landing weight constraint
subject to MaxLW {i in fltplan}: LandingWeight[i] <= MaxLandingWeight;

# 11.maximum ramping weight constraint
subject to MaxRW {i in fltplan}: RampWeight[i] <= MaxRampWeight;

# 12.fuel consumption in each leg
subject to Leg1_KACK: FuelLeft['KACK'] = FuelBefore['KCID1']-FuelBurn['KCID1'];
subject to Leg2_KMMU: FuelLeft['KMMU'] = FuelBefore['KACK']-FuelBurn['KACK'];
subject to Leg3_KBNA: FuelLeft['KBNA'] = FuelBefore['KMMU']-FuelBurn['KMMU'];
subject to Leg4_KTUL: FuelLeft['KTUL'] = FuelBefore['KBNA']-FuelBurn['KBNA'];
subject to Leg5_KCID2: FuelLeft['KCID2'] = FuelBefore['KTUL']-FuelBurn['KTUL'];

# 13.Atleast 200 gallons of gas need to be bought if we are to buy gas

#Commands----------------------------------------------------------------------------------------------------    
data group5_HW5_q1a.dat;
solve;

display TotFuelCost;
display x,y, FuelLeft, FuelBefore, FuelAdd;
 
