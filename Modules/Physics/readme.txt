# ⚡ Electrical Framework Submodules

This directory houses the **Electrical Engineering & Drive Systems** subsystem of the PureBasic Framework (`PbFw`). It contains high-precision, production-ready modules optimized for industrial machinery design, control cabinet compliance, three-phase grid analysis, and automated electrical drive trains.

## 📁 Directory Structure

📁 Electrical
├── 📄 PbFw_Module_VDE.pb             --> Module "VDE" (Installation Regulations)
├── 📄 PbFw_Module_ThreePhase.pb      --> Module "E3P" (Electrical 3-Phase Systems)
└── 📄 PbFw_Module_ElectricalDrive.pb --> Module "EDRV" (Electrical Drive Systems)

---

## 🔍 Module Overview & Core Features

### 1. `VDE` — Electrical Installation & Compliance
Implements statutory regulations and engineering safety lookups according to **DIN VDE 0298-4** and **DIN VDE 0100-410**. It features highly optimized internal `DataSection` architectures for zero runtime performance footprints.
*   **Current Capacity Database:** Integrated Lapp T12-1 base values ranging from `0.08 mm²` up to `500 mm²` across standard installation categories.
*   **Environmental & Packing Derating:** Quick lookups for temperature correction factors and cable bundling accumulation reduction rules (Table 12-6).
*   **Voltage Drop Calculator:** Exact metric scaling for percentage losses and absolute limits across Single-Phase AC and Three-Phase systems.
*   **Max Permissible Lengths:** Solves back from standard limits (e.g., VDE 3.0% drop rule) to find safe maximum structural path lengths.
*   **Breaker Tripping Conditions:** Computes required short-circuit current ($I_k$) and maximum allowed loop impedance ($Z_s$) to guarantee mandatory `0.4-second` automatic disconnection limits for B, C, and D trip curve characteristics.

### 2. `E3P` — Three-Phase Grid Mechanics
Provides advanced mathematical profiling for industrial balanced and unbalanced alternating current power distribution.
*   **Power Analytics:** Instantaneous multi-vector separation of **Active Power** ($W$), **Apparent Power** ($VA$), and **Reactive Power** ($var$).
*   **Unbalanced Load Metrics:** Summation modeling for asymmetrical phases alongside exact phase-to-neutral vector translations.
*   **Neutral Conductor Current:** Calculates structural return flow currents ($I_N$) in star configurations to prevent neutral conductor line overloading.
*   **Power Factor Optimization:** Calculates required reactive power capabilities ($Q_c$) for automated plant capacitor banks to step-up poor lag metrics to targeted industrial power factors.

### 3. `EDRV` — Electrical Drive Systems & Automation
A holistic automation pipeline model tracking energies seamlessly from VFD (variable frequency drive) configurations down to linear physical conveyor velocities.
*   **Nameplate Analytics:** Instantly derives structural nominal motor torques ($M_n$) and native operating efficiencies ($\eta$) directly from machine plate specs ($kW$, $RPM$, $A$, $\cos\varphi$).
*   **VFD Modulation:** Converts driving electrical output frequencies ($Hz$) straight to synchronous engine shaft speeds and vice versa.
*   **Extended VFD Control (87Hz / 95Hz Curves):** Advanced mapping logic calculating structural U/f voltage boosts and extended constant torque plateaus before entering destructive field weakening modes.
*   **Transmission Sizing:** Interlocking gear ratio calculations mapping input/output speeds alongside efficiency mechanical loss factors.
*   **Linear Conveyor Motions:** Flexible multi-unit conversion scaling roller rotations ($RPM$) seamlessly to belt velocities—fully supporting custom unit flags for both **Meters per second ($m/s$)** and **Meters per minute ($m/min$)**.

---

## 💡 Integration Example

The power of this framework lies in the seamless, logical interaction between the global unit conversion macros (`UC`), fluid/grid parameters, and drive system metrics:

```purebasic
; ==============================================================================
;  Example: Automated Conveyor Sizing with VDE Cross-Section Compliance Check
; ==============================================================================
X_TargetVelocity.d = 45.0 ; The factory line requires 45 m/min
X_RollerDiameter.d = 0.2  ; 200mm driving pulley
X_GearboxRatio.d   = 15.0 ; 15:1 planetary gearbox reduction

; 1. Calculate mechanical automation profile (Reverse engineering)
Define RequiredRollerRpm.d = EDRV::GetRpmFromLinearVelocity(X_TargetVelocity, X_RollerDiameter, EDRV::#EDRV_Unit_Mmin)
Define RequiredMotorRpm.d  = EDRV::GetMotorRpmFromOutput(RequiredRollerRpm, X_GearboxRatio)
Define RequiredVfdFreq.d   = EDRV::GetFrequencyFromRequiredRpm(RequiredRollerRpm, 2, X_GearboxRatio) ; 4-pole motor

; 2. Profile electrical load assuming a 5.5 kW plant drawing at 400V grid, cos phi 0.85
Define RequiredCurrentA.d  = E3P::GetCurrentFromActivePower(5500.0, 400.0, 0.85)

; 3. Cross-reference VDE regulatory safety limitations for a 60-meter cable run
Define BaseCapacity.d      = VDE::GetBaseCurrent(2.5, VDE::#VDE_Col_C_MultiInd) ; 2.5 mm² line
Define VoltsDropPercent.d  = VDE::CalcVoltageDrop(400.0, RequiredCurrentA, 60.0, 2.5, #True)
Define MaxSafeLength.d     = VDE::CalcMaxCableLength(400.0, 3.0, RequiredCurrentA, 2.5, #True)

; Outputs show automated compliance state
Debug "VFD Target Output Frequency: " + StrD(RequiredVfdFreq, 2) + " Hz"
Debug "Calculated Line Voltage Drop : " + StrD(VoltsDropPercent, 2) + " %"
Debug "Maximum Safe Length Allowed : " + StrD(MaxSafeLength, 1) + " meters"
```

## 🛠️ Performance & Technical Standards
*   **PureBasic 6.41+ Optimized:** Fully compatible with x86, x64, and modern C-backend compiler engines.
*   **Mathematical Precision:** Standardized entirely on IEEE double-precision floats (`.d`) to systematically eliminate dangerous rounding accumulation errors over long running industrial tracking tasks.
*   **Crash-Proof Architecture:** Structurally guarded via integrated safety clamps against negative numeric roots or hardware-crashing Division-by-Zero (`NaN`) faults.