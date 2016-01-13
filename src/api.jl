export DSS

module DSS

import ..DSSCore

export dss, activeclass, bus, capacitors, capcontrols, circuit, cktelement,
       ctrlqueue, element, executive, progress, fuses, generators, properties,
       isource, lines, loads, loadshape, meters, monitors, parser, pdelements, 
       pvsystems, reclosers, regcontrols, relays, sensors, settings, solution,
       swtcontrols, topology, transformers, vsources, xycurves

cmplx(x) = reinterpret(Complex128, x)


gendict(;args...) = Dict{Symbol,Int}(args)


################################################################################
##
## dss
##
################################################################################
function dss(arg::AbstractString) 
    nlines = length(matchall(r"\n", arg)) + 1
    if nlines == 1 && arg != ""
        DSSCore.DSSPut_Command(arg)
    elseif nlines > 1
        for s in split(arg, "\n")
            if s != ""
                DSSCore.DSSPut_Command(s)
            end
        end
    end
end

################################################################################
##
## Generic method definitions of components to allow calling with a Symbol
## as the first argument.
##
################################################################################
dss(x::Symbol, arg...) = dss(Val{x}, arg...)
activeclass(x::Symbol, arg...) = activeclass(Val{x}, arg...)
bus(x::Symbol, arg...) = bus(Val{x}, arg...)
capacitors(x::Symbol, arg...) = capacitors(Val{x}, arg...)
capcontrols(x::Symbol, arg...) = capcontrols(Val{x}, arg...)
circuit(x::Symbol, arg...) = circuit(Val{x}, arg...)
cktelement(x::Symbol, arg...) = cktelement(Val{x}, arg...)
ctrlqueue(x::Symbol, arg...) = ctrlqueue(Val{x}, arg...)
element(x::Symbol, arg...) = element(Val{x}, arg...)
executive(x::Symbol, arg...) = executive(Val{x}, arg...)
progress(x::Symbol, arg...) = progress(Val{x}, arg...)
fuses(x::Symbol, arg...) = fuses(Val{x}, arg...)
generators(x::Symbol, arg...) = generators(Val{x}, arg...)
properties(x::Symbol, arg...) = properties(Val{x}, arg...)
isource(x::Symbol, arg...) = isource(Val{x}, arg...)
lines(x::Symbol, arg...) = lines(Val{x}, arg...)
loads(x::Symbol, arg...) = loads(Val{x}, arg...)
loadshape(x::Symbol, arg...) = loadshape(Val{x}, arg...)
meters(x::Symbol, arg...) = meters(Val{x}, arg...)
monitors(x::Symbol, arg...) = monitors(Val{x}, arg...)
parser(x::Symbol, arg...) = parser(Val{x}, arg...)
pdelements(x::Symbol, arg...) = pdelements(Val{x}, arg...)
pvsystems(x::Symbol, arg...) = pvsystems(Val{x}, arg...)
reclosers(x::Symbol, arg...) = reclosers(Val{x}, arg...)
regcontrols(x::Symbol, arg...) = regcontrols(Val{x}, arg...)
relays(x::Symbol, arg...) = relays(Val{x}, arg...)
sensors(x::Symbol, arg...) = sensors(Val{x}, arg...)
settings(x::Symbol, arg...) = settings(Val{x}, arg...)
solution(x::Symbol, arg...) = solution(Val{x}, arg...)
swtcontrols(x::Symbol, arg...) = swtcontrols(Val{x}, arg...)
topology(x::Symbol, arg...) = topology(Val{x}, arg...)
transformers(x::Symbol, arg...) = transformers(Val{x}, arg...)
vsources(x::Symbol, arg...) = vsources(Val{x}, arg...)
xycurves(x::Symbol, arg...) = xycurves(Val{x}, arg...)


################################################################################
##
## Macro @def and helper functions to make it easier to define these repetitive
##   methods
##
################################################################################

replacef(x, fexp) = x
replacef(x::Symbol, fexp) = x == :_ ? fexp : x 
replacef(x::Expr, fexp) = Expr(x.head, Any[replacef(y, fexp) for y in x.args]...) 
function def_helper(nargs, newf, f, idx, sym, helpstr, fexpr = :(_))
    extraargs = Any[]
    argstr = ""
    if nargs == 1
        argstr = ", arg"
        push!(extraargs, :arg)
    elseif nargs > 1
        argstr = string(", ", ["arg$i, " for i in nargs - 1]..., "arg", nargs)
        append!(extraargs, Any[symbol(string("arg", i)) for i in nargs])
    end
    helpstr = string("`", newf, "(:", sym, argstr, ")` -- ", helpstr)
    freplace = :(DSSCore.$f($idx))
    fexpr = replacef(fexpr, freplace)
    append!(fexpr.args, extraargs)
    newexpr = :($newf(::Type{Val{$(Meta.quot(sym))}}))
    append!(newexpr.args, extraargs)
    esc(quote
        @doc $helpstr -> 
        $newexpr = $fexpr
    end)
end

macro def(args...)
    def_helper(args...)
end

function reshapemat(x)
    N = length(x)
    n = isqrt(N)
    if rem(N, n) != 0
        return x
    else
        return reshape(x, (n, n)) 
    end
end
function reshape2(x)
    N = length(x)
    if rem(N, 2) != 0
        return x
    else
        return reshape(x, (2, N ÷ 2)) 
    end
end

################################################################################
##
## Custom methods with a Symbol for the first argument
##
################################################################################

@def	0	dss	DSSI	0	NumCircuits	"Number of Circuits currently defined"	
@def	0	dss	DSSI	1	ClearAll	"Clears all circuit definitions"	
@def	0	dss	DSSI	2	ShowPanel	"Shows non‐MDI child form of the Main DSS Edit Form"	
@def	0	dss	DSSI	3	Start	"Validate the user and start OpenDSS; returns true if successful"	
@def	0	dss	DSSI	4	NumClasses	"Number of DSS intrinsic classes"	
@def	0	dss	DSSI	5	NumUserClasses	"Number of user‐defined classes"	
@def	0	dss	DSSI	6	Reset	"Resets DSS Initialization for restarts"	
@def	0	dss	DSSI	7	AllowForms	"Bool flag on the status of allowing forms"	_ == 1
@def	1	dss	DSSI	8	AllowForms	"Bool flag to disable forms (once disabled, can’t be enabled again)"	
@def	0	dss	DSSS	0	NewCircuit	"Make a new circuit"	
@def	0	dss	DSSS	1	Version	"Get version string for OpenDSS"	
@def	0	dss	DSSS	2	DataPath	"Default file path for reports, etc."	
@def	1	dss	DSSS	3	DataPath	"Set the default file path for reports, etc."	
@def	0	dss	DSSS	4	DefaultEditor	"The path name for the default text editor"	
@def	0	dss	DSSV	0	Classes	"List of the names of intrinsic classes"	
@def	0	dss	DSSV	1	UserClasses	"List of the names of user-defined classes"	
@def	0	activeclass	ActiveClassI	0	First	"Sets the first element in the active class to be the active object; if object is a CktElement, ActiveCktElement also points to this element; returns 0 if none"	
@def	0	activeclass	ActiveClassI	1	Next	"Sets the next element in the active class to be the active object; if object is a CktElement, ActiveCktElement also points to this element; returns 0 if no more"	
@def	0	activeclass	ActiveClassI	2	NumElements	"Number of elements in the active class"	
@def	0	activeclass	ActiveClassI	3	Count	"Number of elements in the active class; same as NumElements"	
@def	0	activeclass	ActiveClassS	0	Name	"Name of the active element of the active class"	
@def	1	activeclass	ActiveClassS	1	Name	"Set the name of the active element of the active class"	
@def	0	activeclass	ActiveClassS	2	ActiveClassName	"Name of the active class"	
@def	0	activeclass	ActiveClassV	0	AllNames	"All element names in the active class"	
@def	0	bus	BUSI	0	NumNodes	"Number of nodes"	
@def	0	bus	BUSI	1	ZscRefresh	"Refresh Zsc and Ysc values; execute after a major change in the circuit"	
@def	0	bus	BUSI	2	Coorddefined	"Returns true if the X-Y coordinates are defined for the active bus"	_ == 1
@def	0	bus	BUSI	3	GetUniqueNodeNumber	"Returns a unique node number at the active bus to avoid node collisions and adds it to the node list for the bus"	
@def	0	bus	BUSI	4	N_Customers	"Returns the total number of customers downline from the active bus after reliability calcs"	
@def	0	bus	BUSI	5	SectionID	"Integer ID of the feeder section in which this bus is located"	
@def	0	bus	BUSF	0	kVBase	"Base voltage"	
@def	0	bus	BUSF	1	x	"X coordinate of the bus"	
@def	1	bus	BUSF	2	x	"Set the X coordinate of the bus"	
@def	0	bus	BUSF	3	y	"Y coordinate of the bus"	
@def	1	bus	BUSF	4	y	"Set the Y coordinate of the bus"	
@def	0	bus	BUSF	5	Distance	"""Distance in km that this bus is
from the parent EnergyMeter"""	
@def	0	bus	BUSF	6	Lambda	"Total annual failure rate for active bus after reliability calcs"	
@def	0	bus	BUSF	7	N_interrupts	"Number of interruptions this bus per year"	
@def	0	bus	BUSF	8	Int_Duration	"Average interruption duration, hours"	
@def	0	bus	BUSF	9	Cust_Interrupts	"Annual number of customer-interruptions from this bus"	
@def	0	bus	BUSF	10	Cust_Duration	"Accumulated customer outage durations, hours"	
@def	0	bus	BUSF	11	TotalMiles	"Total length of line downline from this bus, miles"	
@def	0	bus	BUSS	0	Name	"Active bus name; set the active bus by name with `circuit(:SetActiveBus, name)`"	
@def	0	bus	BUSV	0	Voltages	"Bus voltages, complex"	cmplx(_)
@def	0	bus	BUSV	1	SeqVoltages	"Sequence voltages in order of 0, 1, then 2"	
@def	0	bus	BUSV	2	Nodes	"Vector of node numbers defined at the bus in the same order as the voltages"	
@def	0	bus	BUSV	3	Voc	"Open-circuit voltage vector, complex"	cmplx(_)
@def	0	bus	BUSV	4	Isc	"Short-circuit current vector, complex"	cmplx(_)
@def	0	bus	BUSV	5	PuVoltage	"Per-unit voltages at the bus, complex"	cmplx(_)
@def	0	bus	BUSV	6	ZscMatrix	"Short-circuit impedance matrix, complex"	reshapemat(cmplx(_))
@def	0	bus	BUSV	7	Zsc1	"Positive-sequence short-circuit impedance looking into the bus, complex"	cmplx(_)[1]
@def	0	bus	BUSV	8	Zsc0	"Zero-sequence short-circuit impedance looking into the bus, complex"	cmplx(_)[1]
@def	0	bus	BUSV	9	YscMatrix	"Short-circuit admittance matrix, complex"	reshapemat(cmplx(_))
@def	0	bus	BUSV	10	CplxSeqVoltages	"All complex sequence voltages"	cmplx(_)
@def	0	bus	BUSV	11	VLL	"Complex vector of line-to-line voltages for 2- and 3-phase buses; returns -1. for a 1-phase bus; for more than 3 phases, only returns 3 phases"	cmplx(_)
@def	0	bus	BUSV	12	puVLL	"Complex vector of per-unit line-to-line voltages for 2- and 3-phase buses; returns -1. for a 1-phase bus; for more than 3 phases, only returns 3 phases"	cmplx(_)
@def	0	bus	BUSV	13	VMagAngle	"Bus voltage magnitudes with angles"	reshape2(_)
@def	0	bus	BUSV	14	puVmagAngle	"Bus voltage magnitudes (per unit) with angles"	reshape2(_)
@def	0	capacitors	CapacitorsI	0	NumSteps	"Number of steps"	
@def	1	capacitors	CapacitorsI	1	NumSteps	"Set the number of steps"	
@def	0	capacitors	CapacitorsI	2	IsDelta	"Is the connection a delta"	_ == 1
@def	1	capacitors	CapacitorsI	3	IsDelta	"Set connection type; use `arg==true` for delta and `arg==false` for wye"	
@def	0	capacitors	CapacitorsI	4	First	"Sets the first Capacitor active; returns 0 if none"	
@def	0	capacitors	CapacitorsI	5	Next	"Sets the next Capacitor active; returns 0 if no more"	
@def	0	capacitors	CapacitorsI	6	Count	"Number of capacitor objects in the active circuit"	
@def	0	capacitors	CapacitorsI	7	AddStep	"Adds one step of the capacitor if available; if successful, returns 1"	
@def	0	capacitors	CapacitorsI	8	SubtractStep	"Subtracts one step of the capacitor; if no more steps, returns 0"	
@def	0	capacitors	CapacitorsI	9	AvailableSteps	"Number of steps available in the cap bank to be switched ON"	
@def	0	capacitors	CapacitorsI	10	Open	"Open all steps, all phases of the capacitor"	
@def	0	capacitors	CapacitorsI	11	Close	"Close all steps of all phases of the capacitor"	
@def	0	capacitors	CapacitorsF	0	kV	"Bank kV rating; use LL for 2 or 3 phases, or actual can rating for 1 phase"	
@def	1	capacitors	CapacitorsF	1	kV	"Set the bank kV rating; use LL for 2 or 3 phases, or actual can rating for 1 phase"	
@def	0	capacitors	CapacitorsF	2	kvar	"Total bank kvar, distributed equally among phases and steps"	
@def	1	capacitors	CapacitorsF	3	kvar	"Set the total bank kvar, distributed equally among phases and steps"	
@def	0	capacitors	CapacitorsS	0	Name	"The name of the active capacitor"	
@def	1	capacitors	CapacitorsS	1	Name	"Sets the active capacitor by name"	
@def	0	capacitors	CapacitorsV	0	AllNames	"All capacitor names in the circuit"	
@def	0	capacitors	CapacitorsV	1	States	"A vector of  integers [0..numsteps‐1] indicating state of each step; if value is ‐1 an error has occurred."	
@def	0	capcontrols	CapControlsI	0	First	"Sets the first CapControl active; returns 0 if none"	
@def	0	capcontrols	CapControlsI	1	Next	"Sets the next CapControl active; returns 0 if no more"	
@def	0	capcontrols	CapControlsI	2	Mode	"Type of automatic controller; for meaning, see CapControlModes"	
@def	1	capcontrols	CapControlsI	3	Mode	"Set the type of automatic controller; for choices, see CapControlModes"	
@def	0	capcontrols	CapControlsI	4	MonitoredTerm	"Terminal number on the element that PT and CT are connected to"	
@def	1	capcontrols	CapControlsI	5	MonitoredTerm	"Set the terminal number on the element that PT and CT are connected to"	
@def	0	capcontrols	CapControlsI	6	UseVoltOverride	"Bool flag that enables Vmin and Vmax to override the control mode"	_ == 1
@def	1	capcontrols	CapControlsI	7	UseVoltOverride	"Set the Bool flag that enables Vmin and Vmax to override the control mode"	
@def	0	capcontrols	CapControlsI	8	Count	"Number of CapControls in the active circuit"	
@def	0	capcontrols	CapControlsF	0	CTRatio	"Transducer ratio from primary current to control current"	
@def	1	capcontrols	CapControlsF	1	CTRatio	"Set the transducer ratio from primary current to control current"	
@def	0	capcontrols	CapControlsF	2	PTRatio	"Transducer ratio from primary voltage to control voltage"	
@def	1	capcontrols	CapControlsF	3	PTRatio	"Set the transducer ratio from primary voltage to control voltage"	
@def	0	capcontrols	CapControlsF	4	ONSetting	"Threshold to arm or switch on a step; see Mode for units"	
@def	1	capcontrols	CapControlsF	5	ONSetting	"Set the threshold to arm or switch on a step; see Mode for units"	
@def	0	capcontrols	CapControlsF	6	OFFSetting	"Threshold to switch off a step; see the particular CapControlModes option for units"	
@def	1	capcontrols	CapControlsF	7	OFFSetting	"Set the threshold to switch off a step; see the particular CapControlModes option for units"	
@def	0	capcontrols	CapControlsF	8	Vmax	"With VoltOverride, switch off whenever PT voltage exceeds this level"	
@def	1	capcontrols	CapControlsF	9	Vmax	"Set Vmax; with VoltOverride, switch off whenever PT voltage exceeds this level"	
@def	0	capcontrols	CapControlsF	10	Vmin	"With VoltOverride, switch on whenever PT voltage drops below this level"	
@def	1	capcontrols	CapControlsF	11	Vmin	"Set Vmin; with VoltOverride, switch on whenever PT voltage drops below this level"	
@def	0	capcontrols	CapControlsF	12	Delay	"""Time delay [s] to switch on after arming; control may reset before actually
switching"""	
@def	1	capcontrols	CapControlsF	13	Delay	"""Set the time delay [s] to switch on after arming; control may reset before actually
switching"""	
@def	0	capcontrols	CapControlsF	14	DelayOff	"""Time delay [s] before switching off a step; control may reset before actually
switching"""	
@def	1	capcontrols	CapControlsF	15	DelayOff	"""Set the time delay [s] before switching off a step; control may reset before actually
 switching"""	
@def	0	capcontrols	CapControlsS	0	Name	"The name of the active CapControl"	
@def	1	capcontrols	CapControlsS	1	Name	"Set the active CapControl by name"	
@def	0	capcontrols	CapControlsS	2	Capacitor	"Name of the Capacitor that is controlled"	
@def	1	capcontrols	CapControlsS	3	Capacitor	"Set the Capacitor (by name) that is controlled"	
@def	0	capcontrols	CapControlsS	4	MonitoredObj	"Full name of the element that PT and CT are connected to"	
@def	1	capcontrols	CapControlsS	5	MonitoredObj	"Set the element (by full name) that PT and CT are connected to"	
@def	0	capcontrols	CapControlsV	0	AllNames	"Names of all CapControls in the circuit"	
@def	0	circuit	CircuitI	0	NumCktElements	"Number of CktElements in the circuit"	
@def	0	circuit	CircuitI	1	NumBuses	"Total number of Buses in the circuit"	
@def	0	circuit	CircuitI	2	NumNodes	"Total number of Nodes in the circuit"	
@def	0	circuit	CircuitI	3	FirstPCElement	"Sets the first enabled Power Conversion (PC) element in the circuit to be active; if not successful returns a 0"	
@def	0	circuit	CircuitI	4	NextPCElement	"Sets the next enabled Power Conversion (PC) element in the circuit to be active; if not successful returns a 0"	
@def	0	circuit	CircuitI	5	FirstPDElement	"Sets the first enabled Power Delivery (PD) element in the circuit to be active; if not successful returns a 0"	
@def	0	circuit	CircuitI	6	NextPDElement	"Sets the next enabled Power Delivery (PD) element in the circuit to be active; if not successful returns a 0"	
@def	0	circuit	CircuitI	7	Sample	"Force all Meters and Monitors to take a sample"	
@def	0	circuit	CircuitI	8	SaveSample	"Force all meters and monitors to save their current buffers"	
@def	1	circuit	CircuitI	9	SetActiveBusi	"Sets the active bus by integer index. The index is 0 based. That is, the first bus has an index of 0. Returns -1 if an error occurs."	
@def	0	circuit	CircuitI	10	FirstElement	"Sets First element of active class to be the Active element in the active circuit. Returns 0 if none."	
@def	0	circuit	CircuitI	11	NextElement	"Sets the next element of the active class to be the active element in the active circuit. Returns 0 if no more elements."	
@def	0	circuit	CircuitI	12	UpdateStorage	"Forces update to all storage classes. Typically done after a solution. Done automatically in intrinsic solution modes."	
@def	0	circuit	CircuitI	13	ParentPDElement	"Sets Parent PD element, if any, to be the active circuit element and returns index>0; Returns 0 if it fails or not applicable."	
@def	0	circuit	CircuitI	14	EndOfTimeStepUpdate	"Calls EndOfTimeStepCleanup in SolutionAlgs"	
@def	0	circuit	CircuitF	0	Capacity	"""Executes the DSS capacity function. Start is the per unit load multiplier for the current year at which to start the search. Increment is the per unit value by which the load increments for each step of the analysis. The program sets the load at the Start value the PRESENT YEAR (including growth) and increments the load until something in the
circuit reports an overload or undervoltage violation. The function returns the total load at which the violation occurs or the peak load for the present year if no violations."""	
@def	0	circuit	CircuitS	0	Name	"Name of the active circuit"	
@def	1	circuit	CircuitS	1	Disable	"Disable a circuit element by name (full name)."	
@def	1	circuit	CircuitS	2	Enable	"Enable a circuit element by name (full name)."	
@def	1	circuit	CircuitS	3	SetActiveElement	""	
@def	1	circuit	CircuitS	4	SetActiveBus	"Sets the active bus by name. Returns a 0 based index of the bus to use for future direct indexing of bus values returned in arrays. Returns -1 if an error occurs."	
@def	1	circuit	CircuitS	5	SetActiveClass	"Sets the active class by name.  Use FirstElement, NextElement to iterate through the class. Returns ‐1 if fails."	
@def	0	circuit	CircuitV	0	Losses	"Watt and var losses in the entire circuit, complex"	cmplx(_)[1]
@def	0	circuit	CircuitV	1	LineLosses	"Watt and var losses in all the Line elements in the circuit, complex"	cmplx(_)[1]
@def	0	circuit	CircuitV	2	SubstationLosses	"Watt and var losses in all the Transformer elements in the circuit that are designated as substations"	cmplx(_)[1]
@def	0	circuit	CircuitV	3	TotalPower	"Returns the total power in kW and kvar supplied to the circuit by all Vsource and Isource objects. Does not include Generator objects. Complex."	cmplx(_)[1]
@def	0	circuit	CircuitV	4	AllBusVolts	"Returns the voltage (complex) for every node in the circuit as a complex vector. The order of the array is the same as AllNodeNames property. The array is constructed bus-by-bus and then by node at each bus. Thus, all nodes from each bus are grouped together."	cmplx(_)
@def	0	circuit	CircuitV	5	AllBusVMag	"Similar to AllBusVolts except magnitude only (in actual volts). Returns the voltage (magnitude) for every node in the circuit as a complex vector."	
@def	0	circuit	CircuitV	6	AllElementNames	"The names of all elements"	
@def	0	circuit	CircuitV	7	AllBusNames	"The names of all buses in the system. See `:AllNodeNames`."	
@def	0	circuit	CircuitV	8	AllElementLosses	"Returns the watt and var losses in each element of the system as a complex vector. Order is the same as AllElementNames."	
@def	0	circuit	CircuitV	9	AllBusMagPu	"Similar to AllBusVmag except that the magnitudes are reported in per unit for all buses with kVBase defined."	
@def	0	circuit	CircuitV	10	AllNodeNames	"Returns the names of all nodes (busname.nodenumber) in the same order as AllBusVolts, AllBusVmag, and AllBusVMagPu"	
@def	0	circuit	CircuitV	11	SystemY	"Return the System Y matrix as a complex (dense) matrix"	cmplx(_)
@def	0	circuit	CircuitV	12	AllBusDistances	"Returns all distances from a bus to its parent EnergyMeter element, which is generally in the substation, as a variant array of doubles. Order corresponds to that of all bus properties."	
@def	0	circuit	CircuitV	13	AllNodeDistances	"Returns the distance from all nodes to the parent energy meter that match the designated phase number. Returns a vector of doubles. Matches the order of AllNodeNamesByPhase, AllNodeVmagByPhase, AllNodeVmagPUByPhase."	
@def	0	circuit	CircuitV	14	AllNodeVmagByPhase	"Returns variant array of doubles represent the voltage magnitudes for each node whose phase designator matches the specified Phase."	
@def	0	circuit	CircuitV	15	AllNodeVmagPUByPhase	"Per unit version of AllNodeVmagByPhase"	
@def	0	circuit	CircuitV	16	AllNodeDistancesByPhase	"Returns the distance from all nodes to the parent energy meter that match the designated phase number. Returns a vector. Matches the order of AllNodeNamesByPhase, AllNodeVmagByPhase, AllNodeVmagPUByPhase."	
@def	0	circuit	CircuitV	17	AllNodeNamesByPhase	"Returns a variant array of strings in order corresponding to AllNodeDistancesByPhase, AllNodeVmagByPhase, AllNodeVmagPUByPhase. Returns only those names whose phase designator matches the specified Phase."	
@def	0	circuit	CircuitV	18	YNodeVArray	"Complex array of actual node voltages in same order as SystemY matrix."	cmplx(_)
@def	0	circuit	CircuitV	19	YNodeOrder	"The names of the nodes in the same order as the Y matrix"	
@def	0	circuit	CircuitV	20	YCurrents	"Vector of doubles containing complex injection currents for the present solution."	cmplx(_)
@def	0	cktelement	CktElementI	0	NumTerminals	"Number of Terminals on this Circuit Element"	
@def	0	cktelement	CktElementI	1	NumConductors	"Number of Conductors per Terminal"	
@def	0	cktelement	CktElementI	2	NumPhases	"Number of phases"	
@def	0	cktelement	CktElementI	3	Open	"Open the specified terminal and phase, if non‐zero.  Else all conductors at terminal."	
@def	0	cktelement	CktElementI	4	Close	"Close the specified terminal and phase, if non‐zero.  Else all conductors at terminal."	
@def	0	cktelement	CktElementI	5	IsOpen	"Bool indicating if the specified terminal and, optionally, phase is open."	_ == 1
@def	0	cktelement	CktElementI	6	NumProperties	"Number of Properties this Circuit Element."	
@def	0	cktelement	CktElementI	7	HasSwitchControl	"Bool indicating whether this element has a SwtControl attached."	_ == 1
@def	0	cktelement	CktElementI	8	HasVoltControl	"This element has a CapControl or RegControl attached."	_ == 1
@def	0	cktelement	CktElementI	9	NumControls	"Number of controls connected to this device. Use to determine valid range for index into Controller array."	
@def	0	cktelement	CktElementI	10	OCPDevIndex	"Index into Controller list of OCP Device controlling this CktElement"	
@def	0	cktelement	CktElementI	11	OCPDevType	"0=None; 1=Fuse; 2=Recloser; 3=Relay;  Type of OCP controller device"	
@def	0	cktelement	CktElementI	12	Enabled	"Element is enabled"	_ == 1
@def	1	cktelement	CktElementI	13	Enabled	"Enable the active circuit element"	
@def	0	cktelement	CktElementF	0	NormalAmps	"Normal ampere rating for PD Elements"	
@def	1	cktelement	CktElementF	1	NormalAmps	"Set the normal ampere rating for PD Elements"	
@def	0	cktelement	CktElementF	2	EmergAmps	"Emergency Ampere Rating for PD elements"	
@def	1	cktelement	CktElementF	3	EmergAmps	"Set the emergency Ampere Rating for PD elements"	
@def	0	cktelement	CktElementF	4	Variablei	"For PCElement, get the value of a variable by integer index."	
@def	0	cktelement	CktElementS	0	Name	"Full Name of Active Circuit Element"	
@def	0	cktelement	CktElementS	1	DisplayName	"Display name of the object (not necessarily unique)"	
@def	1	cktelement	CktElementS	2	DisplayName	"Set the display name of the object (not necessarily unique)"	
@def	0	cktelement	CktElementS	3	GUID	"Globally unique identifier for this object"	
@def	0	cktelement	CktElementS	4	EnergyMeter	"Name of the Energy Meter this element is assigned to"	
@def	0	cktelement	CktElementS	5	Controller	"Full name of the i‐th controller attached to this element. Ex: str = Controller"	
@def	0	cktelement	CktElementV	0	BusNames	"Get  Bus definitions to which each terminal is connected. 0‐based array."	
#@def	1	cktelement	CktElementV	1	BusNames	"Set  Bus definitions to which each terminal is connected. 0‐based array."	
@def	0	cktelement	CktElementV	2	Voltages	"Complex array of voltages at terminals"	cmplx(_)
@def	0	cktelement	CktElementV	3	Currents	"Complex array of currents into each conductor of each terminal"	cmplx(_)
@def	0	cktelement	CktElementV	4	Powers	"Complex array of powers into each conductor of each terminal"	cmplx(_)
@def	0	cktelement	CktElementV	5	Losses	"Total losses in the element: two‐element complex array"	cmplx(_)
@def	0	cktelement	CktElementV	6	PhaseLosses	"Complex array of losses by phase"	cmplx(_)
@def	0	cktelement	CktElementV	7	SeqVoltages	"Double array of symmetrical component voltages at each 3‐phase terminal"	
@def	0	cktelement	CktElementV	8	SeqCurrents	"Double array of symmetrical component currents into each 3‐phase terminal"	
@def	0	cktelement	CktElementV	9	SeqPowers	"Double array of sequence powers into each 3‐phase teminal"	cmplx(_)
@def	0	cktelement	CktElementV	10	AllPropertyNames	"All property names of the active device."	
@def	0	cktelement	CktElementV	11	Residuals	"Residual currents for each terminal: (mag, angle)"	reshape2(_)
@def	0	cktelement	CktElementV	12	YPrim	"YPrim matrix, column order, complex numbers"	reshapemat(cmplx(_))
@def	0	cktelement	CktElementV	13	CplxSeqVoltages	"Complex double array of Sequence Voltage for all terminals of active circuit element."	cmplx(_)
@def	0	cktelement	CktElementV	14	CplxSeqCurrents	"Complex double array of Sequence Currents for all conductors of all terminals of active circuit element."	cmplx(_)
@def	0	cktelement	CktElementV	15	AllVariableNames	"Variant array of strings listing all the published variable names, if a PCElement. Otherwise, null string."	
@def	0	cktelement	CktElementV	16	AllVariableValues	"Values of state variables of active element if PC element."	
@def	0	cktelement	CktElementV	17	NodeOrder	"Node numbers (representing phases, for example)"	
@def	0	cktelement	CktElementV	18	CurrentsMagAng	"Currents in magnitude, angle format as a variant array of doubles."	reshape2(_)
@def	0	cktelement	CktElementV	19	VoltagesMagAng	"Voltages at each conductor in magnitude, angle form as variant array of doubles."	reshape2(_)
@def	0	ctrlqueue	CtrlQueueI	0	ClearQueue	"Clear the control queue."	
@def	0	ctrlqueue	CtrlQueueI	1	Delete	"Delete a control action from the DSS control queue by referencing the handle of the action"	
@def	0	ctrlqueue	CtrlQueueI	2	NumActions	"Number of Actions on the current actionlist (that have been popped off the control queue by CheckControlActions"	
@def	1	ctrlqueue	CtrlQueueI	3	Action	"Set the active action by index"	
@def	0	ctrlqueue	CtrlQueueI	4	ActionCode	"Code for the active action. Long integer code to tell the control device what to do."	
@def	0	ctrlqueue	CtrlQueueI	5	DeviceHandle	"Handle (User defined)"	
@def	0	ctrlqueue	CtrlQueueI	6	Push	"Push a control action onto the DSS control queue by time, action code, and device handle (user defined)."	
@def	0	ctrlqueue	CtrlQueueI	7	Show	"Show the entire control queue in CSV format"	
@def	0	ctrlqueue	CtrlQueueI	8	ClearActions	"Clear the Action list."	
@def	0	ctrlqueue	CtrlQueueI	9	PopAction	"Pops next action off the action list and makes it the active action. Returns zero if none."	
@def	0	element	DSSElementI	0	NumProperties 	"Number of Properties for the active DSS object."	
@def	0	element	DSSElementS	0	Name	"Full Name of Active DSS Object (general element or circuit element)"	
@def	0	element	DSSElementV	0	AllPropertyNames	"The names of all properties for the active DSS object."	
@def	0	executive	DSSExecutiveI	0	NumCommands	"Number of DSS Executive Commands"	
@def	0	executive	DSSExecutiveI	1	NumOptions	"Number of DSS Executive Options"	
@def	1	executive	DSSExecutiveS	0	Command	"Get i‐th command (with i as a string)"	
@def	1	executive	DSSExecutiveS	1	Option	"Get i‐th option (with i as a string)"	
@def	1	executive	DSSExecutiveS	2	CommandHelp	"Get help string for i‐th command (with i as a string)"	
@def	1	executive	DSSExecutiveS	3	OptionHelp	"Get help string for i‐th option (with i as a string)"	
@def	1	executive	DSSExecutiveS	4	OptionValue	"Get present value of i‐th option (with i as a string)"	
@def	0	progress	DSSProgressI	0	PctProgress	"Percent progress to indicate [0..100]"	
@def	0	progress	DSSProgressI	1	Show	"Shows progress form with null caption and progress set to zero."	
@def	0	progress	DSSProgressI	2	Close	"Close the progress form."	
@def	0	progress	DSSProgressS	0	Caption 	"Caption to appear on the bottom of the DSS Progress form."	
@def	0	fuses	FusesI	0	Count	"Number of Fuse elements in the circuit"	
@def	0	fuses	FusesI	1	First	"Set the first Fuse to be the active fuse. Returns 0 if none."	
@def	0	fuses	FusesI	2	Next	"Advance the active Fuse element pointer to the next fuse. Returns 0 if no more fuses."	
@def	0	fuses	FusesI	3	MonitoredTerm	"Terminal number to which the fuse is connected."	
@def	1	fuses	FusesI	4	MonitoredTerm	"Set the terminal number to which the fuse is connected."	
@def	0	fuses	FusesI	5	Open	"Manual opening of fuse"	
@def	0	fuses	FusesI	6	 Close	"Close the fuse back in and reset."	
@def	0	fuses	FusesI	7	IsBlown	"Current state of the fuses. TRUE if any fuse on any phase is blown. Else FALSE."	
@def	0	fuses	FusesI	8	 Idx	"Get/set active fuse by index into the list of fuses. 1 based: 1..count"	
@def	1	fuses	FusesI	9	 Idx	"Set Fuse active by index into the list of fuses. 1..count"	
@def	0	fuses	FusesI	10	NumPhases	"Number of phases, this fuse."	
@def	0	fuses	FusesF	0	RatedCurrent	"Multiplier or actual amps for the TCCcurve object. Defaults to 1.0. Multipliy current values of TCC curve by this to get actual amps."	
@def	1	fuses	FusesF	1	RatedCurrent	"Set the multiplier or actual amps for the TCCcurve object. Defaults to 1.0. Multipliy current values of TCC curve by this to get actual amps."	
@def	0	fuses	FusesS	0	Name	"Get the name of the active Fuse element"	
@def	1	fuses	FusesS	1	Name	"Set the name of the active Fuse element"	
@def	0	fuses	FusesS	2	MonitoredObj	"Full name of the circuit element to which the fuse is connected."	
@def	1	fuses	FusesS	3	MonitoredObj	"Set the full name of the circuit element to which the fuse is connected."	
@def	0	fuses	FusesS	4	SwitchedObj	"Full name of the circuit element switch that the fuse controls. Defaults to the MonitoredObj."	
@def	1	fuses	FusesS	5	SwitchedObj	"Set the full name of the circuit element switch that the fuse controls. Defaults to the MonitoredObj."	
@def	0	fuses	FusesS	6	TCCCurve	"Name of the TCCcurve object that determines fuse blowing."	
@def	1	fuses	FusesS	7	TCCCurve	"Set the name of the TCCcurve object that determines fuse blowing."	
@def	0	fuses	FusesV	0	AllNames	" Names of all Fuses in the circuit"	
@def	0	generators	GeneratorsI	0	First	"Sets first Generator to be active.  Returns 0 if none."	
@def	0	generators	GeneratorsI	1	Next	"Sets next Generator to be active.  Returns 0 if no more."	
@def	0	generators	GeneratorsI	2	ForcedON	"Indicates whether the generator is forced ON regardles of other dispatch criteria."	
@def	1	generators	GeneratorsI	3	ForcedON	"Sets indication whether the generator is forced ON regardles of other dispatch criteria."	
@def	0	generators	GeneratorsI	4	Phases	"Number of phases"	
@def	1	generators	GeneratorsI	5	Phases	"Set the number of phases"	
@def	0	generators	GeneratorsI	6	Count	"Number of Generator Objects in Active Circuit"	
@def	0	generators	GeneratorsI	7	Idx	"Get/Set active Generator by index into generators list.  1..Count"	
@def	1	generators	GeneratorsI	8	Idx	"Set active Generator by index into generators list.  1..Count"	
@def	0	generators	GeneratorsI	9	Model	"Generator model"	
@def	1	generators	GeneratorsI	10	Model	"Set the Generator model"	
@def	0	generators	GeneratorsF	0	kV	"Voltage base for the active generator, kV"	
@def	1	generators	GeneratorsF	1	kV	"Set the voltage base for the active generator, kV"	
@def	0	generators	GeneratorsF	2	kW	"kW output for the active generator. kvar is updated for current power factor."	
@def	1	generators	GeneratorsF	3	kW	"Set the kW output for the active generator. kvar is updated for current power factor."	
@def	0	generators	GeneratorsF	4	kvar	"kvar output for the active generator. Updates power factor based on present kW value."	
@def	1	generators	GeneratorsF	5	kvar	"Set the kvar output for the active generator. Updates power factor based on present kW value."	
@def	0	generators	GeneratorsF	6	PF	"Power factor (pos. = producing vars)"	
@def	1	generators	GeneratorsF	7	PF	"Set the power factor (pos. = producing vars)"	
@def	0	generators	GeneratorsF	8	kVARated	""	
@def	1	generators	GeneratorsF	9	kVARated	""	
@def	0	generators	GeneratorsF	10	Vmaxpu	""	
@def	1	generators	GeneratorsF	11	Vmaxpu	""	
@def	0	generators	GeneratorsF	12	Vminpu	""	
@def	1	generators	GeneratorsF	13	Vminpu	""	
@def	0	generators	GeneratorsS	0	Name	"Active generator name."	
@def	1	generators	GeneratorsS	1	Name	"Sets a generator active by name."	
@def	0	generators	GeneratorsV	0	AllNames	"All generator names"	
@def	0	generators	GeneratorsV	1	RegisterNames	"Array of Names of all generator energy meter registers"	
@def	0	generators	GeneratorsV	2	RegisterValues	"Array of valus in generator energy meter registers."	
@def	0	properties	DSSPropertiesS	0	Name	""	
@def	0	properties	DSSPropertiesS	1	Description	""	
@def	0	properties	DSSPropertiesS	2	Value	""	
@def	1	properties	DSSPropertiesS	3	Value	""	
@def	0	isource	IsourceI	0	Count	""	
@def	0	isource	IsourceI	1	First	""	
@def	0	isource	IsourceI	2	Next	""	
@def	0	isource	IsourceF	0	Amps	""	
@def	1	isource	IsourceF	1	Amps	""	
@def	0	isource	IsourceF	2	AngleDeg	""	
@def	1	isource	IsourceF	3	AngleDeg	""	
@def	0	isource	IsourceF	4	Frequency	""	
@def	1	isource	IsourceF	5	Frequency	""	
@def	0	isource	IsourceS	0	Name	""	
@def	1	isource	IsourceS	1	Name	""	
@def	0	isource	IsourceV	0	AllNames	""	
@def	0	lines	LinesI	0	First	""	
@def	0	lines	LinesI	1	Next	""	
@def	0	lines	LinesI	2	Phases	""	
@def	1	lines	LinesI	3	Phases	""	
@def	0	lines	LinesI	4	NumCust	""	
@def	0	lines	LinesI	5	Parent	""	
@def	0	lines	LinesI	6	Count	""	
@def	0	lines	LinesI	7	Units	""	
@def	1	lines	LinesI	8	Units	""	
@def	0	lines	LinesF	0	Length	""	
@def	1	lines	LinesF	1	Length	""	
@def	0	lines	LinesF	2	R1	""	
@def	1	lines	LinesF	3	R1	""	
@def	0	lines	LinesF	4	X1	""	
@def	1	lines	LinesF	5	X1	""	
@def	0	lines	LinesF	6	R0	""	
@def	1	lines	LinesF	7	R0	""	
@def	0	lines	LinesF	8	X0	""	
@def	1	lines	LinesF	9	X0	""	
@def	0	lines	LinesF	10	C1	""	
@def	1	lines	LinesF	11	C1	""	
@def	0	lines	LinesF	12	C0	""	
@def	1	lines	LinesF	13	C0	""	
@def	0	lines	LinesF	14	NormAmps	""	
@def	1	lines	LinesF	15	NormAmps	""	
@def	0	lines	LinesF	16	EmergAmps	""	
@def	1	lines	LinesF	17	EmergAmps	""	
@def	0	lines	LinesF	18	Rg	""	
@def	1	lines	LinesF	19	Rg	""	
@def	0	lines	LinesF	20	Xg	""	
@def	1	lines	LinesF	21	Xg	""	
@def	0	lines	LinesF	22	Rho	""	
@def	1	lines	LinesF	23	Rho	""	
@def	0	lines	LinesS	0	Name	""	
@def	1	lines	LinesS	1	Name	""	
@def	0	lines	LinesS	2	Bus1	""	
@def	1	lines	LinesS	3	Bus1	""	
@def	0	lines	LinesS	4	Bus2	""	
@def	1	lines	LinesS	5	Bus2	""	
@def	0	lines	LinesS	6	LineCode	""	
@def	1	lines	LinesS	7	LineCode	""	
@def	0	lines	LinesS	8	Geometry	""	
@def	1	lines	LinesS	9	Geometry	""	
@def	0	lines	LinesS	10	Spacing	""	
@def	1	lines	LinesS	11	Spacing	""	
@def	0	lines	LinesV	0	AllNames	""	
@def	0	lines	LinesV	1	RMatrix	""	
#@def	1	lines	LinesV	2	RMatrix	""	
@def	0	lines	LinesV	3	XMatrix	""	
#@def	1	lines	LinesV	4	XMatrix	""	
@def	0	lines	LinesV	5	CMatrix	""	
#@def	1	lines	LinesV	6	CMatrix	""	
@def	0	lines	LinesV	7	Yprim	""	reshapemat(cmplx(_))
#@def	1	lines	LinesV	8	Yprim	""	
@def	0	loads	DSSLoads	0	First	""	
@def	0	loads	DSSLoads	1	Next	""	
@def	0	loads	DSSLoads	2	Idx	""	
@def	1	loads	DSSLoads	3	Idx	""	
@def	0	loads	DSSLoads	4	Count	""	
@def	0	loads	DSSLoads	5	Class	""	
@def	1	loads	DSSLoads	6	Class	""	
@def	0	loads	DSSLoads	7	Model	""	
@def	1	loads	DSSLoads	8	Model	""	
@def	0	loads	DSSLoads	9	NumCust	""	
@def	1	loads	DSSLoads	10	NumCust	""	
@def	0	loads	DSSLoads	11	Status	""	
@def	1	loads	DSSLoads	12	Status	""	
@def	0	loads	DSSLoads	13	IsDelta	""	
@def	1	loads	DSSLoads	14	IsDelta	""	
@def	0	loads	DSSLoadsF	0	kW	""	
@def	1	loads	DSSLoadsF	1	kW	""	
@def	0	loads	DSSLoadsF	2	kV	""	
@def	1	loads	DSSLoadsF	3	kV	""	
@def	0	loads	DSSLoadsF	4	kvar	""	
@def	1	loads	DSSLoadsF	5	kvar	""	
@def	0	loads	DSSLoadsF	6	PF	""	
@def	1	loads	DSSLoadsF	7	PF	""	
@def	0	loads	DSSLoadsF	8	PctMean	""	
@def	1	loads	DSSLoadsF	9	PctMean	""	
@def	0	loads	DSSLoadsF	10	PctStdDev	""	
@def	1	loads	DSSLoadsF	11	PctStdDev	""	
@def	0	loads	DSSLoadsF	12	AllocationFactor	""	
@def	1	loads	DSSLoadsF	13	AllocationFactor	""	
@def	0	loads	DSSLoadsF	14	CFactor	""	
@def	1	loads	DSSLoadsF	15	CFactor	""	
@def	0	loads	DSSLoadsF	16	CVRwatts	""	
@def	1	loads	DSSLoadsF	17	CVRwatts	""	
@def	0	loads	DSSLoadsF	18	CVRvars	""	
@def	1	loads	DSSLoadsF	19	CVRvars	""	
@def	0	loads	DSSLoadsF	20	kVABase	""	
@def	1	loads	DSSLoadsF	21	kVABase	""	
@def	0	loads	DSSLoadsF	22	kWh	""	
@def	1	loads	DSSLoadsF	23	kWh	""	
@def	0	loads	DSSLoadsF	24	kWhDays	""	
@def	1	loads	DSSLoadsF	25	kWhDays	""	
@def	0	loads	DSSLoadsF	26	Rneut	""	
@def	1	loads	DSSLoadsF	27	Rneut	""	
@def	0	loads	DSSLoadsF	28	Vmaxpu	""	
@def	1	loads	DSSLoadsF	29	Vmaxpu	""	
@def	0	loads	DSSLoadsF	30	VminEmerg	""	
@def	1	loads	DSSLoadsF	31	VminEmerg	""	
@def	0	loads	DSSLoadsF	32	VminNorm	""	
@def	1	loads	DSSLoadsF	33	VminNorm	""	
@def	0	loads	DSSLoadsF	34	Vminpu	""	
@def	1	loads	DSSLoadsF	35	Vminpu	""	
@def	0	loads	DSSLoadsF	36	XfkVA	""	
@def	1	loads	DSSLoadsF	37	XfkVA	""	
@def	0	loads	DSSLoadsF	38	Xneut	""	
@def	1	loads	DSSLoadsF	39	Xneut	""	
@def	0	loads	DSSLoadsF	40	puSeriesRL	""	
@def	1	loads	DSSLoadsF	41	puSeriesRL	""	
@def	0	loads	DSSLoadsF	42	RelWeighting	""	
@def	1	loads	DSSLoadsF	43	RelWeighting	""	
@def	0	loads	DSSLoadsS	0	Name	""	
@def	1	loads	DSSLoadsS	1	Name	""	
@def	0	loads	DSSLoadsS	2	CVRCurve	""	
@def	1	loads	DSSLoadsS	3	CVRCurve	""	
@def	0	loads	DSSLoadsS	4	Daily	""	
@def	1	loads	DSSLoadsS	5	Daily	""	
@def	0	loads	DSSLoadsS	6	Duty	""	
@def	1	loads	DSSLoadsS	7	Duty	""	
@def	0	loads	DSSLoadsS	8	Spectrum	""	
@def	1	loads	DSSLoadsS	9	Spectrum	""	
@def	0	loads	DSSLoadsS	10	Yearly	""	
@def	1	loads	DSSLoadsS	11	Yearly	""	
@def	0	loads	DSSLoadsS	12	Growth	""	
@def	1	loads	DSSLoadsS	13	Growth	""	
@def	0	loads	DSSLoadsS	0	AllNames	""	
@def	0	loads	DSSLoadsS	1	ZipV	""	
#@def	1	loads	DSSLoadsS	2	ZipV	""	
@def	0	loadshape	LoadShapeI	0	Count	""	
@def	0	loadshape	LoadShapeI	1	First	""	
@def	0	loadshape	LoadShapeI	2	Next	""	
@def	0	loadshape	LoadShapeI	3	Npts	""	
@def	1	loadshape	LoadShapeI	4	Npts	""	
@def	0	loadshape	LoadShapeI	5	Normalize	""	
@def	0	loadshape	LoadShapeI	6	UseActual	""	
@def	1	loadshape	LoadShapeI	7	UseActual	""	
@def	0	loadshape	LoadShapeF	0	HrInterval	""	
@def	1	loadshape	LoadShapeF	1	HrInterval	""	
@def	0	loadshape	LoadShapeF	2	MinInterval	""	
@def	1	loadshape	LoadShapeF	3	MinInterval	""	
@def	0	loadshape	LoadShapeF	4	PBase	""	
@def	1	loadshape	LoadShapeF	5	PBase	""	
@def	0	loadshape	LoadShapeF	6	QBase	""	
@def	1	loadshape	LoadShapeF	7	QBase	""	
@def	0	loadshape	LoadShapeF	8	SInterval	""	
@def	1	loadshape	LoadShapeF	9	SInterval	""	
@def	0	loadshape	LoadShapeS	0	Name	""	
@def	1	loadshape	LoadShapeS	1	Name	""	
@def	0	loadshape	LoadShapeV	0	PMult	""	
#@def	1	loadshape	LoadShapeV	1	PMult	""	
@def	0	loadshape	LoadShapeV	2	QMult	""	
#@def	1	loadshape	LoadShapeV	3	QMult	""	
@def	0	loadshape	LoadShapeV	4	TimeArray	""	
#@def	1	loadshape	LoadShapeV	5	TimeArray	""	
@def	0	meters	MetersI	0	First	""	
@def	0	meters	MetersI	1	Next	""	
@def	0	meters	MetersI	2	Reset	""	
@def	0	meters	MetersI	3	ResetAll	""	
@def	0	meters	MetersI	4	Sample	""	
@def	0	meters	MetersI	5	Save	""	
@def	0	meters	MetersI	6	MeteredTerminal	""	
@def	1	meters	MetersI	7	MeteredTerminal	""	
@def	0	meters	MetersI	8	DIFilesAreOpen	""	
@def	0	meters	MetersI	9	SampleAll	""	
@def	0	meters	MetersI	10	SaveAll	""	
@def	0	meters	MetersI	11	OpenAllDIFiles	""	
@def	0	meters	MetersI	12	CloseAllDIFiles	""	
@def	0	meters	MetersI	13	CountEndElements	""	
@def	0	meters	MetersI	14	Count	""	
@def	0	meters	MetersI	15	CountBranches	""	
@def	0	meters	MetersI	16	SequenceList	""	
@def	1	meters	MetersI	17	SequenceList	""	
@def	0	meters	MetersI	18	DoReliabilityCalc	""	
@def	0	meters	MetersI	19	SeqListSize	""	
@def	0	meters	MetersI	20	TotalCustomers	""	
@def	0	meters	MetersI	21	NumSections	""	
@def	0	meters	MetersI	22	SetActiveSection	""	
@def	0	meters	MetersI	23	OCPDeviceType	""	
@def	0	meters	MetersI	24	NumSectionCustomers	""	
@def	0	meters	MetersI	25	NumSectionBranches	""	
@def	0	meters	MetersI	26	SectSeqidx	""	
@def	0	meters	MetersI	27	SectTotalCust	""	
@def	0	meters	MetersF	0	SAIFI	""	
@def	0	meters	MetersF	1	SAIFIkW	""	
@def	0	meters	MetersF	2	SAIDI	""	
@def	0	meters	MetersF	3	CustInterrupts	""	
@def	0	meters	MetersF	4	AvgRepairTime	""	
@def	0	meters	MetersF	5	FaultRateXRepairHrs	""	
@def	0	meters	MetersF	6	SumBranchFltRates	""	
@def	0	meters	MetersS	0	Name	""	
@def	1	meters	MetersS	1	Name	""	
@def	0	meters	MetersS	2	MeteredElement	""	
@def	1	meters	MetersS	3	MeteredElement	""	
@def	0	meters	MetersV	0	AllNames	""	
@def	0	meters	MetersV	1	RegisterNames	""	
#@def	1	meters	MetersV	2	RegisterValues	""	
@def	0	meters	MetersV	3	Totals	""	
@def	0	meters	MetersV	4	PeakCurrent	""	
#@def	1	meters	MetersV	5	PeakCurrent	""	
@def	0	meters	MetersV	6	CalcCurrent	""	
#@def	1	meters	MetersV	7	CalcCurrent	""	
@def	0	meters	MetersV	8	AllocFactors	""	
#@def	1	meters	MetersV	9	AllocFactors	""	
@def	0	meters	MetersV	10	AllEndElements	""	
@def	0	meters	MetersV	11	ALlBranchesInZone	""	
@def	0	monitors	MonitorsI	0	First	""	
@def	0	monitors	MonitorsI	1	Next	""	
@def	0	monitors	MonitorsI	2	Reset	""	
@def	0	monitors	MonitorsI	3	ResetAll	""	
@def	0	monitors	MonitorsI	4	Sample	""	
@def	0	monitors	MonitorsI	5	Save	""	
@def	0	monitors	MonitorsI	6	Show	""	
@def	0	monitors	MonitorsI	7	Mode	""	
@def	1	monitors	MonitorsI	8	Mode	""	
@def	0	monitors	MonitorsI	9	SampleCount	""	
@def	0	monitors	MonitorsI	10	SampleAll	""	
@def	0	monitors	MonitorsI	11	SaveAll	""	
@def	0	monitors	MonitorsI	12	Count	""	
@def	0	monitors	MonitorsI	13	Process	""	
@def	0	monitors	MonitorsI	14	ProcessAll	""	
@def	0	monitors	MonitorsI	15	FileVersion	""	
@def	0	monitors	MonitorsI	16	NumChannels	""	
@def	0	monitors	MonitorsI	17	Terminal	""	
@def	1	monitors	MonitorsI	18	Terminal	""	
@def	0	monitors	MonitorsS	0	FileName	""	
@def	0	monitors	MonitorsS	1	Name	""	
@def	0	monitors	MonitorsS	2	Name	""	
@def	0	monitors	MonitorsS	3	Element	""	
@def	0	monitors	MonitorsS	4	Element	""	
@def	0	monitors	MonitorsV	0	AllNames	""	
@def	0	monitors	MonitorsV	1	ByteStream	""	
@def	0	monitors	MonitorsV	2	DblHourS!!	""	
@def	0	monitors	MonitorsV	3	DblHour	""	
@def	0	monitors	MonitorsV	4	DblFreqS!!	""	
@def	0	monitors	MonitorsV	5	DblFreq	""	
@def	0	parser	ParserI	0	IntValue	""	
@def	0	parser	ParserI	1	ResetDelimiters	""	
@def	0	parser	ParserI	2	AutoIncrement	""	
@def	1	parser	ParserI	3	AutoIncrement	""	
@def	0	parser	ParserF	0	DblValue 	""	
@def	0	parser	ParserS	0	CmdString	""	
@def	1	parser	ParserS	1	CmdString	""	
@def	0	parser	ParserS	2	NextParam	""	
@def	0	parser	ParserS	3	StrValue	""	
@def	0	parser	ParserS	4	WhiteSpace	""	
@def	1	parser	ParserS	5	WhiteSpace	""	
@def	0	parser	ParserS	6	BeginQuote	""	
@def	1	parser	ParserS	7	BeginQuote	""	
@def	0	parser	ParserS	8	EndQuote	""	
@def	1	parser	ParserS	9	EndQuote	""	
@def	0	parser	ParserS	10	Delimiters	""	
@def	1	parser	ParserS	11	Delimiters	""	
@def	0	parser	ParserV	0	Vector	""	
@def	0	parser	ParserV	1	Matrix	""	
@def	0	parser	ParserV	2	SymMatrix	""	
@def	0	pdelements	PDElementsI	0	Count	""	
@def	0	pdelements	PDElementsI	1	First	""	
@def	0	pdelements	PDElementsI	2	Next	""	
@def	0	pdelements	PDElementsI	3	IsShunt	""	
@def	0	pdelements	PDElementsI	4	NumCustomers	""	
@def	0	pdelements	PDElementsI	5	TotalCustomers	""	
@def	0	pdelements	PDElementsI	6	ParentPDElement	""	
@def	0	pdelements	PDElementsI	7	FromTerminal	""	
@def	0	pdelements	PDElementsI	8	SectionID	""	
@def	0	pdelements	PDElementsF	0	FaultRate	""	
@def	1	pdelements	PDElementsF	1	FaultRate	""	
@def	0	pdelements	PDElementsF	2	PctPermanent	""	
@def	1	pdelements	PDElementsF	3	PctPermanent	""	
@def	0	pdelements	PDElementsF	4	Lambda	""	
@def	0	pdelements	PDElementsF	5	AccumulatedL	""	
@def	0	pdelements	PDElementsF	6	RepairTime	""	
@def	0	pdelements	PDElementsF	7	TotalMiles	""	
@def	0	pdelements	PDElementsV	0	Name	""	
#@def	1	pdelements	PDElementsV	1	Name	""	
@def	0	pvsystems	PVsystemsI	0	Count	""	
@def	0	pvsystems	PVsystemsI	1	First	""	
@def	0	pvsystems	PVsystemsI	2	Next	""	
@def	0	pvsystems	PVsystemsI	3	Idx	""	
@def	1	pvsystems	PVsystemsI	4	Idx	""	
@def	0	pvsystems	PVsystemsF	0	Irradiance	""	
@def	1	pvsystems	PVsystemsF	1	Irradiance	""	
@def	0	pvsystems	PVsystemsF	2	kW	""	
@def	0	pvsystems	PVsystemsF	3	kvar	""	
@def	1	pvsystems	PVsystemsF	4	kvar	""	
@def	0	pvsystems	PVsystemsF	5	pf	""	
@def	1	pvsystems	PVsystemsF	6	pf	""	
@def	0	reclosers	ReclosersI	0	Count	""	
@def	0	reclosers	ReclosersI	1	First	""	
@def	0	reclosers	ReclosersI	2	Next	""	
@def	0	reclosers	ReclosersI	3	MonitoredTerm	""	
@def	1	reclosers	ReclosersI	4	MonitoredTerm	""	
@def	0	reclosers	ReclosersI	5	SwitchedTerm	""	
@def	1	reclosers	ReclosersI	6	SwitchedTerm	""	
@def	0	reclosers	ReclosersI	7	NumFast	""	
@def	1	reclosers	ReclosersI	8	NumFast	""	
@def	0	reclosers	ReclosersI	9	Shots	""	
@def	1	reclosers	ReclosersI	10	Shots	""	
@def	0	reclosers	ReclosersI	11	Open	""	
@def	0	reclosers	ReclosersI	12	Close	""	
@def	0	reclosers	ReclosersI	13	Idx	""	
@def	1	reclosers	ReclosersI	14	Idx	""	
@def	0	reclosers	ReclosersF	0	PhaseTrip	""	
@def	0	reclosers	ReclosersF	1	PhaseTrip	""	
@def	0	reclosers	ReclosersF	2	PhaseInst	""	
@def	0	reclosers	ReclosersF	3	PhaseInst	""	
@def	0	reclosers	ReclosersF	4	GroundTrip	""	
@def	0	reclosers	ReclosersF	5	GroundTrip	""	
@def	0	reclosers	ReclosersF	6	GroundInst	""	
@def	0	reclosers	ReclosersF	7	GroundInst	""	
@def	0	reclosers	ReclosersS	0	Name	""	
@def	0	reclosers	ReclosersS	1	Name	""	
@def	0	reclosers	ReclosersS	2	MonitoredObj	""	
@def	0	reclosers	ReclosersS	3	MonitoredObj	""	
@def	0	reclosers	ReclosersS	4	SwitchedObj	""	
@def	0	reclosers	ReclosersS	5	SwitchedObj	""	
@def	0	reclosers	ReclosersV	0	AllNames	""	
@def	0	reclosers	ReclosersV	1	RecloseIntervals	""	
@def	0	regcontrols	RegControlsI	0	First	""	
@def	0	regcontrols	RegControlsI	1	Next	""	
@def	0	regcontrols	RegControlsI	2	TapWinding	""	
@def	1	regcontrols	RegControlsI	3	TapWinding	""	
@def	0	regcontrols	RegControlsI	4	Winding	""	
@def	1	regcontrols	RegControlsI	5	Winding	""	
@def	0	regcontrols	RegControlsI	6	IsReversible	""	
@def	1	regcontrols	RegControlsI	7	IsReversible	""	
@def	0	regcontrols	RegControlsI	8	IsInverseTime	""	
@def	1	regcontrols	RegControlsI	9	IsInverseTime	""	
@def	0	regcontrols	RegControlsI	10	MaxTapChange	""	
@def	1	regcontrols	RegControlsI	11	MaxTapChange	""	
@def	0	regcontrols	RegControlsI	12	Count	""	
@def	0	regcontrols	RegControlsF	0	CTPrimary	""	
@def	1	regcontrols	RegControlsF	1	CTPrimary	""	
@def	0	regcontrols	RegControlsF	2	PTRatio	""	
@def	1	regcontrols	RegControlsF	3	PTRatio	""	
@def	0	regcontrols	RegControlsF	4	ForwardR	""	
@def	1	regcontrols	RegControlsF	5	ForwardR	""	
@def	0	regcontrols	RegControlsF	6	ForwardX	""	
@def	1	regcontrols	RegControlsF	7	ForwardX	""	
@def	0	regcontrols	RegControlsF	8	ReverseR	""	
@def	1	regcontrols	RegControlsF	9	ReverseR	""	
@def	0	regcontrols	RegControlsF	10	ReverseX	""	
@def	1	regcontrols	RegControlsF	11	ReverseX	""	
@def	0	regcontrols	RegControlsF	12	Delay	""	
@def	1	regcontrols	RegControlsF	13	Delay	""	
@def	0	regcontrols	RegControlsF	14	TapDelay	""	
@def	1	regcontrols	RegControlsF	15	TapDelay	""	
@def	0	regcontrols	RegControlsF	16	VoltageLimit	""	
@def	1	regcontrols	RegControlsF	17	VoltageLimit	""	
@def	0	regcontrols	RegControlsF	18	ForwardBand	""	
@def	1	regcontrols	RegControlsF	19	ForwardBand	""	
@def	0	regcontrols	RegControlsF	20	ForwardVreg	""	
@def	1	regcontrols	RegControlsF	21	ForwardVreg	""	
@def	0	regcontrols	RegControlsF	22	ReverseBand	""	
@def	1	regcontrols	RegControlsF	23	ReverseBand	""	
@def	0	regcontrols	RegControlsF	24	ReverseVreg	""	
@def	1	regcontrols	RegControlsF	25	ReverseVreg	""	
@def	0	regcontrols	RegControlsS	0	Name	""	
@def	1	regcontrols	RegControlsS	1	Name	""	
@def	0	regcontrols	RegControlsS	2	MonitoredBus	""	
@def	1	regcontrols	RegControlsS	3	MonitoredBus	""	
@def	0	regcontrols	RegControlsS	4	Transformer	""	
@def	1	regcontrols	RegControlsS	5	Transformer	""	
@def	0	regcontrols	RegControlsV	0	AllNames	""	
@def	0	relays	RelaysI	0	Count	""	
@def	0	relays	RelaysI	1	First	""	
@def	0	relays	RelaysI	2	Next	""	
@def	0	relays	RelaysI	3	MonitoredTerm	""	
@def	1	relays	RelaysI	4	MonitoredTerm	""	
@def	0	relays	RelaysI	5	SwitchedTerm	""	
@def	1	relays	RelaysI	6	SwitchedTerm	""	
@def	0	relays	RelaysI	7	Idx	""	
@def	1	relays	RelaysI	8	Idx	""	
@def	0	relays	RelaysS	0	Name	""	
@def	1	relays	RelaysS	1	Name	""	
@def	0	relays	RelaysS	2	MonitoredObj	""	
@def	1	relays	RelaysS	3	MonitoredObj	""	
@def	0	relays	RelaysS	4	SwitchedObj	""	
@def	1	relays	RelaysS	5	SwitchedObj	""	
@def	0	relays	RelaysV	0	AllNames	""	
@def	0	sensors	SensorsI	0	Count	""	
@def	0	sensors	SensorsI	1	First	""	
@def	0	sensors	SensorsI	2	Next	""	
@def	0	sensors	SensorsI	3	IsDelta	""	
@def	1	sensors	SensorsI	4	IsDelta	""	
@def	0	sensors	SensorsI	5	ReverseDelta	""	
@def	1	sensors	SensorsI	6	ReverseDelta	""	
@def	0	sensors	SensorsI	7	MeteredTerminal	""	
@def	0	sensors	SensorsI	8	MeteredTerminal	""	
@def	0	sensors	SensorsI	9	Reset	""	
@def	0	sensors	SensorsI	10	ResetAll	""	
@def	0	sensors	SensorsF	0	PctError	""	
@def	1	sensors	SensorsF	1	PctError	""	
@def	0	sensors	SensorsF	2	Weight	""	
@def	1	sensors	SensorsF	3	Weight	""	
@def	0	sensors	SensorsF	4	kVBase	""	
@def	1	sensors	SensorsF	5	kVBase	""	
@def	0	sensors	SensorsS	0	Name	""	
@def	1	sensors	SensorsS	1	Name	""	
@def	0	sensors	SensorsS	2	MeteredElement	""	
@def	1	sensors	SensorsS	3	MeteredElement	""	
@def	0	sensors	SensorsV	0	AllNames	""	
@def	0	sensors	SensorsV	1	Currents	""	
#@def	1	sensors	SensorsV	2	Currents	""	
@def	0	sensors	SensorsV	3	kvar	""	
#@def	1	sensors	SensorsV	4	kvar	""	
@def	0	sensors	SensorsV	5	kW	""	
#@def	1	sensors	SensorsV	6	kW	""	
@def	0	settings	SettingsI	0	AllowDuplicates	""	
@def	1	settings	SettingsI	1	AllowDuplicates	""	
@def	0	settings	SettingsI	2	ZoneLock	""	
@def	1	settings	SettingsI	3	ZoneLock	""	
@def	0	settings	SettingsI	4	CktModel	""	
@def	1	settings	SettingsI	5	CktModel	""	
@def	0	settings	SettingsI	6	Trapezoidal	""	
@def	1	settings	SettingsI	7	Trapezoidal	""	
@def	0	settings	SettingsF	0	AllocationFactors	""	
@def	0	settings	SettingsF	1	NormVminpu	""	
@def	1	settings	SettingsF	2	NormVminpu	""	
@def	0	settings	SettingsF	3	NormVmaxpu	""	
@def	1	settings	SettingsF	4	NormVmaxpu	""	
@def	0	settings	SettingsF	5	EmergVminpu	""	
@def	1	settings	SettingsF	6	EmergVminpu	""	
@def	0	settings	SettingsF	7	EmergVmaxpu	""	
@def	1	settings	SettingsF	8	EmergVmaxpu	""	
@def	0	settings	SettingsF	9	UEWeight	""	
@def	1	settings	SettingsF	10	UEWeight	""	
@def	0	settings	SettingsF	11	LossWeight	""	
@def	1	settings	SettingsF	12	LossWeight	""	
@def	0	settings	SettingsF	13	PriceSignal	""	
@def	1	settings	SettingsF	14	PriceSignal	""	
@def	0	settings	SettingsS	0	AutoBusList	""	
@def	1	settings	SettingsS	1	AutoBusList	""	
@def	0	settings	SettingsS	2	PriceCurve	""	
@def	1	settings	SettingsS	3	PriceCurve	""	
@def	0	settings	SettingsV	0	UERegs	""	
#@def	1	settings	SettingsV	1	UERegs	""	
@def	0	settings	SettingsV	2	LossRegs	""	
#@def	1	settings	SettingsV	3	LossRegs	""	
@def	0	settings	SettingsV	4	VoltageBases	""	
#@def	1	settings	SettingsV	5	VoltageBases	""	
@def	0	solution	SolutionI	0	Solve	""	
@def	0	solution	SolutionI	1	Mode	""	
@def	1	solution	SolutionI	2	Mode	""	
@def	0	solution	SolutionI	3	Hour	""	
@def	1	solution	SolutionI	4	Hour	""	
@def	0	solution	SolutionI	5	Year	""	
@def	1	solution	SolutionI	6	Year	""	
@def	0	solution	SolutionI	7	Iterations	""	
@def	0	solution	SolutionI	8	MaxIterations	""	
@def	1	solution	SolutionI	9	MaxIterations	""	
@def	0	solution	SolutionI	10	Number	""	
@def	1	solution	SolutionI	11	Number	""	
@def	0	solution	SolutionI	12	Random	""	
@def	1	solution	SolutionI	13	Random	""	
@def	0	solution	SolutionI	14	LoadModel	""	
@def	1	solution	SolutionI	15	LoadModel	""	
@def	0	solution	SolutionI	16	AddType	""	
@def	1	solution	SolutionI	17	AddType	""	
@def	0	solution	SolutionI	18	Algorithm	""	
@def	1	solution	SolutionI	19	Algorithm	""	
@def	0	solution	SolutionI	20	ControlMode	""	
@def	1	solution	SolutionI	21	ControlMode	""	
@def	0	solution	SolutionI	22	ControlIterations	""	
@def	1	solution	SolutionI	23	ControlIterations	""	
@def	0	solution	SolutionI	24	MaxControlIterations	""	
@def	1	solution	SolutionI	25	MaxControlIterations	""	
@def	0	solution	SolutionI	26	SampleDoControlActions	""	
@def	0	solution	SolutionI	27	CheckFaultStatus	""	
@def	0	solution	SolutionI	28	SolveDirect	""	
@def	0	solution	SolutionI	29	SolvePFlow	""	
@def	0	solution	SolutionI	30	SolveNoControl	""	
@def	0	solution	SolutionI	31	SolvePlusControl	""	
@def	0	solution	SolutionI	32	InitSnap	""	
@def	0	solution	SolutionI	33	CheckControls	""	
@def	0	solution	SolutionI	34	SampleControlDevices	""	
@def	0	solution	SolutionI	35	DoControlActions	""	
@def	0	solution	SolutionI	36	BuildYMatrix	""	
@def	0	solution	SolutionI	37	SystemYChanged	""	
@def	0	solution	SolutionI	38	Converged	""	
@def	1	solution	SolutionI	39	Converged	""	
@def	0	solution	SolutionI	40	TotalIterations	""	
@def	0	solution	SolutionI	41	MostIterationsDone	""	
@def	0	solution	SolutionI	42	ControlActionsDone	""	
@def	1	solution	SolutionI	43	ControlActionsDone	""	
@def	0	solution	SolutionI	44	FinishTimeStep	""	
@def	0	solution	SolutionI	45	Cleanup	""	
@def	0	solution	SolutionF	0	Frequency	""	
@def	1	solution	SolutionF	1	Frequency	""	
@def	0	solution	SolutionF	2	Seconds	""	
@def	1	solution	SolutionF	3	Seconds	""	
@def	0	solution	SolutionF	4	StepSize	""	
@def	1	solution	SolutionF	5	StepSize	""	
@def	0	solution	SolutionF	6	LoadMult	""	
@def	1	solution	SolutionF	7	LoadMult	""	
@def	0	solution	SolutionF	8	Convergence	""	
@def	1	solution	SolutionF	9	Convergence	""	
@def	0	solution	SolutionF	10	PctGrowth	""	
@def	1	solution	SolutionF	11	PctGrowth	""	
@def	0	solution	SolutionF	12	GenkW	""	
@def	1	solution	SolutionF	13	GenkW	""	
@def	0	solution	SolutionF	14	GenPF	""	
@def	1	solution	SolutionF	15	GenPF	""	
@def	0	solution	SolutionF	16	Capkvar	""	
@def	1	solution	SolutionF	17	Capkvar	""	
@def	0	solution	SolutionF	18	GenMult	""	
@def	1	solution	SolutionF	19	GenMult	""	
@def	0	solution	SolutionF	20	DblHour	""	
@def	1	solution	SolutionF	21	DblHour	""	
@def	0	solution	SolutionF	22	StepSizeMin	""	
@def	0	solution	SolutionF	23	StepSizeHr	""	
@def	0	solution	SolutionS	0	ModeID	""	
@def	0	solution	SolutionS	1	LDCurve	""	
@def	1	solution	SolutionS	2	LDCurve	""	
@def	0	solution	SolutionS	3	DefaultDaily	""	
@def	1	solution	SolutionS	4	DefaultDaily	""	
@def	0	solution	SolutionS	5	DefaultYearly	""	
@def	1	solution	SolutionS	6	DefaultYearly	""	
@def	0	solution	SolutionV	0	EventLog	""	
@def	0	swtcontrols	SwtControlsI	0	First	""	
@def	0	swtcontrols	SwtControlsI	1	Next	""	
@def	0	swtcontrols	SwtControlsI	2	Action	""	
@def	1	swtcontrols	SwtControlsI	3	Action	""	
@def	0	swtcontrols	SwtControlsI	4	IsLocked	""	
@def	1	swtcontrols	SwtControlsI	5	IsLocked	""	
@def	0	swtcontrols	SwtControlsI	6	SwitchedTerm	""	
@def	1	swtcontrols	SwtControlsI	7	SwitchedTerm	""	
@def	0	swtcontrols	SwtControlsI	8	Count	""	
@def	0	swtcontrols	SwtControlsF	0	Delay	""	
@def	1	swtcontrols	SwtControlsF	1	Delay	""	
@def	0	swtcontrols	SwtControlsS	0	Name	""	
@def	1	swtcontrols	SwtControlsS	1	Name	""	
@def	0	swtcontrols	SwtControlsS	2	SwitchedObj	""	
@def	1	swtcontrols	SwtControlsS	3	SwitchedObj	""	
@def	0	swtcontrols	SwtControlsV	0	AllNames	""	
@def	0	topology	TopologyI	0	NumLoops	""	
@def	0	topology	TopologyI	1	NumIsolatedBranches	""	
@def	0	topology	TopologyI	2	NumIsolatedLoads	""	
@def	0	topology	TopologyI	3	First	""	
@def	0	topology	TopologyI	4	Next	""	
@def	0	topology	TopologyI	5	ActiveBranch	""	
@def	0	topology	TopologyI	6	ForwardBranch	""	
@def	0	topology	TopologyI	7	BackwardBranch	""	
@def	0	topology	TopologyI	8	LoopedBranch	""	
@def	0	topology	TopologyI	9	ParallelBranch	""	
@def	0	topology	TopologyI	10	FirstLoad	""	
@def	0	topology	TopologyI	11	NextLoad	""	
@def	0	topology	TopologyI	12	ActiveLevel	""	
@def	0	topology	TopologyF	0	Delay	""	
@def	1	topology	TopologyF	1	Delay	""	
@def	0	topology	TopologyS	0	BranchName	""	
@def	1	topology	TopologyS	1	BranchName	""	
@def	0	topology	TopologyS	2	BusName	""	
@def	1	topology	TopologyS	3	BusName	""	
@def	0	topology	TopologyV	0	AllLoopedPairs	""	
@def	0	topology	TopologyV	1	AllIsolatedBranches	""	
@def	0	topology	TopologyV	2	AllIsolatedLoads	""	
@def	0	transformers	TransformersI	0	NumWindings	""	
@def	1	transformers	TransformersI	1	NumWindings	""	
@def	0	transformers	TransformersI	2	Wdg	""	
@def	1	transformers	TransformersI	3	Wdg	""	
@def	0	transformers	TransformersI	4	NumTaps	""	
@def	1	transformers	TransformersI	5	NumTaps	""	
@def	0	transformers	TransformersI	6	IsDelta	""	
@def	1	transformers	TransformersI	7	IsDelta	""	
@def	0	transformers	TransformersI	8	First	""	
@def	0	transformers	TransformersI	9	Next	""	
@def	0	transformers	TransformersI	10	Count	""	
@def	0	transformers	TransformersF	0	R	""	
@def	1	transformers	TransformersF	1	R	""	
@def	0	transformers	TransformersF	2	Tap	""	
@def	1	transformers	TransformersF	3	Tap	""	
@def	0	transformers	TransformersF	4	MinTap	""	
@def	1	transformers	TransformersF	5	MinTap	""	
@def	0	transformers	TransformersF	6	MaxTap	""	
@def	1	transformers	TransformersF	7	MaxTap	""	
@def	0	transformers	TransformersF	8	kV	""	
@def	1	transformers	TransformersF	9	kV	""	
@def	0	transformers	TransformersF	10	kVA	""	
@def	1	transformers	TransformersF	11	kVA	""	
@def	0	transformers	TransformersF	12	Xneut	""	
@def	1	transformers	TransformersF	13	Xneut	""	
@def	0	transformers	TransformersF	14	Rneut	""	
@def	1	transformers	TransformersF	15	Rneut	""	
@def	0	transformers	TransformersF	16	Xhl	""	
@def	1	transformers	TransformersF	17	Xhl	""	
@def	0	transformers	TransformersF	18	Xht	""	
@def	1	transformers	TransformersF	19	Xht	""	
@def	0	transformers	TransformersF	20	Xlt	""	
@def	1	transformers	TransformersF	21	Xlt	""	
@def	0	transformers	TransformersS	0	XfmrCode	""	
@def	1	transformers	TransformersS	1	XfmrCode	""	
@def	0	transformers	TransformersS	2	Name	""	
@def	1	transformers	TransformersS	3	Name	""	
@def	0	transformers	TransformersV	0	AllNames	""	
@def	0	vsources	VsourcesI	0	Count	""	
@def	0	vsources	VsourcesI	1	First	""	
@def	0	vsources	VsourcesI	2	Next	""	
@def	0	vsources	VsourcesI	3	Phases	""	
@def	1	vsources	VsourcesI	4	Phases	""	
@def	0	vsources	VsourcesF	0	BasekV	""	
@def	1	vsources	VsourcesF	1	BasekV	""	
@def	0	vsources	VsourcesF	2	PU	""	
@def	1	vsources	VsourcesF	3	PU	""	
@def	0	vsources	VsourcesF	4	AngleDeg	""	
@def	1	vsources	VsourcesF	5	AngleDeg	""	
@def	0	vsources	VsourcesF	6	Frequency	""	
@def	1	vsources	VsourcesF	7	Frequency	""	
@def	0	vsources	VsourcesS	0	Name	""	
@def	1	vsources	VsourcesS	1	Name	""	
@def	0	vsources	VsourcesV	0	AllNames	""	
@def	0	xycurves	XYCurvesI	0	Count	""	
@def	0	xycurves	XYCurvesI	1	First	""	
@def	0	xycurves	XYCurvesI	2	Next	""	
@def	0	xycurves	XYCurvesI	3	Npts	""	
@def	1	xycurves	XYCurvesI	4	Npts	""	
@def	0	xycurves	XYCurvesF	0	X	""	
@def	1	xycurves	XYCurvesF	1	X	""	
@def	0	xycurves	XYCurvesF	2	Y	""	
@def	1	xycurves	XYCurvesF	3	Y	""	
@def	0	xycurves	XYCurvesF	4	XShift	""	
@def	1	xycurves	XYCurvesF	5	XShift	""	
@def	0	xycurves	XYCurvesF	6	YShift	""	
@def	1	xycurves	XYCurvesF	7	YShift	""	
@def	0	xycurves	XYCurvesF	8	XScale	""	
@def	1	xycurves	XYCurvesF	9	XScale	""	
@def	0	xycurves	XYCurvesF	10	YScale	""	
@def	1	xycurves	XYCurvesF	11	YScale	""	
@def	0	xycurves	XYCurvesS	0	Name	""	
@def	1	xycurves	XYCurvesS	1	Name	""	
@def	0	xycurves	XYCurvesV	0	XArray	""	
#@def	1	xycurves	XYCurvesV	1	XArray	""	
@def	0	xycurves	XYCurvesV	2	YArray	""	
#@def	1	xycurves	XYCurvesV	3	YArray	""	

################################################################################
##
## Enums and flag variables (implemented as modules)
##
################################################################################

"""
CapControlModes flags - options include:

* `Current` : Current control, ON and OFF settings on CT secondary
* `Voltage` : Voltage control, ON and OFF settings on the PT secondary base
* `KVAR` : kvar control, ON and OFF settings on PT / CT base
* `Time` : Time control ON and OFF settings are seconds from midnight
* `PF` : ON and OFF settings are power factor, negative for leading

Example: 

    capcontrols(:Mode, CapControlModes.KVAR)
"""
baremodule CapControlModes
    const Current = 0
    const Voltage = 1
    const KVAR = 2
    const Time = 3
    const PF = 4
end # baremodule

"""
MonitorModes flags - options include:

* `VI` : Monitor records Voltage and Current at the terminal (Default)
* `Power` : Monitor records kW, kvar or kVA, angle values, etc. at the terminal to which it is connected
* `Taps` : For monitoring Regulator and Transformer taps
* `States` : For monitoring State Variables (for PC Elements only)
* `Sequence` : Reports the monitored quantities as sequence quantities
* `Magnitude` : Reports the monitored quantities in Magnitude Only
* `PosOnly` : Reports the Positive Seq only or avg of all phases

`Sequence`, `Magnitude`, and `PosOnly` are bit-level flags that can be combined
with other flags. It's best to use `&` to test for one of these flags. Use `|` to 
combine flags.

Examples: 

    monitors(:Mode) & MonitorModes.Power
    monitors(:Mode, MonitorModes.Magnitude | MonitorModes.Power)
"""
baremodule MonitorModes
    const VI = 0
    const Power = 1
    const Taps = 2
    const States = 3
    const Sequence = 16
    const Magnitude = 32
    const PosOnly = 64
end # baremodule



end # module

