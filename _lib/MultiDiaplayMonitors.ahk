#Include Extend.ahk

; ======================================================================================================================
; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx
; by 'just me'
; https://autohotkey.com/boards/viewtopic.php?f=6&t=4606
; ======================================================================================================================
GetMonitorCount() => MDMF_Enum().Count

GetMonitorInfo(MonitorNum) {
	for k, v in MDMF_Enum().OwnProps()
		if (v.Num = MonitorNum)
			return v
}

GetPrimaryMonitor() {
	for k, v in MDMF_Enum().OwnProps()
		if (v.Primary)
			return v.Num
}

; ----------------------------------------------------------------------------------------------------------------------
; Name ..........: MDMF - Multiple Display Monitor Functions
; Description ...: Various functions for multiple display monitor environments
; Tested with ...: AHK 1.1.32.00 (A32/U32/U64) and 2.0-a108-a2fa0498 (U32/U64)
; Original Author: just me (https://www.autohotkey.com/boards/viewtopic.php?f=6&t=4606)
; Mod Authors ...: iPhilip, guest3456
; Changes .......: Modified to work with v2.0-a108 and changed 'Count' key to 'TotalCount' to avoid conflicts
; ................ Modified MDMF_Enum() so that it works under both AHK v1 and v2.
; ................ Modified MDMF_EnumProc() to provide Count and Primary keys to the Monitors array.
; ................ Modified MDMF_FromHWND() to allow flag values that determine the function's return value if the
; ................    window does not intersect any display monitor.
; ................ Modified MDMF_FromPoint() to allow the cursor position to be returned ByRef if not specified and
; ................    allow flag values that determine the function's return value if the point is not contained within
; ................    any display monitor.
; ................ Modified MDMF_FromRect() to allow flag values that determine the function's return value if the
; ................    rectangle does not intersect any display monitor.
;................. Modified MDMF_GetInfo() with minor changes.
; ----------------------------------------------------------------------------------------------------------------------
;
; ======================================================================================================================
; Multiple Display Monitors Functions -> msdn.microsoft.com/en-us/library/dd145072(v=vs.85).aspx =======================
; ======================================================================================================================
; Enumerates display monitors and returns an object containing the properties of all monitors or the specified monitor.
; ======================================================================================================================

; ======================================================================================================================
;  Callback function that is called by the MDMF_Enum function.
; ======================================================================================================================

MDMF_Enum(HMON := '') {
	static EnumProcAddr := CallbackCreate(MDMF_EnumProc), Monitors := {}
	Monitors.TotalCount := 0
	if !HMON {
		if !DllCall("User32.dll\EnumDisplayMonitors", "Ptr", 0, "Ptr", 0, "Ptr", EnumProcAddr, "Ptr", ObjPtr(Monitors))
			return false
		else return Monitors
	} else return Monitors.HasProp('HMON') ? Monitors.HMON : false
}

MDMF_EnumProc(HMON, HDC, PRECT, ObjectAddr) {
	Monitors := ObjFromPtrAddRef(ObjectAddr), Monitors.HMON := MDMF_GetInfo(HMON)
	Monitors.TotalCount++
	if Monitors.HMON.Primary
		Monitors.Primary := HMON
	Return true
}

; ======================================================================================================================
; Retrieves the display monitor that has the largest area of intersection with a specified window.
; The following flag values determine the function's return value if the window does not intersect any display monitor:
;    MONITOR_DEFAULTTONULL    = 0 - Returns NULL.
;    MONITOR_DEFAULTTOPRIMARY = 1 - Returns a handle to the primary display monitor.
;    MONITOR_DEFAULTTONEAREST = 2 - Returns a handle to the display monitor that is nearest to the window.
; ======================================================================================================================
MDMF_FromHWND(HWND, Flag := 0) => DllCall("User32.dll\MonitorFromWindow", "Ptr", HWND, "UInt", Flag, "Ptr")

; ======================================================================================================================
; Retrieves the display monitor that contains a specified point.
; If either X or Y is empty, the function will use the current cursor position for this value and return it ByRef.
; The following flag values determine the function's return value if the point is not contained within any
; display monitor:
;    MONITOR_DEFAULTTONULL    = 0 - Returns NULL.
;    MONITOR_DEFAULTTOPRIMARY = 1 - Returns a handle to the primary display monitor.
;    MONITOR_DEFAULTTONEAREST = 2 - Returns a handle to the display monitor that is nearest to the point.
; ======================================================================================================================
MDMF_FromPoint(X := "", Y := "") {
	PT := Buffer(8, 0)
	if X = "" || Y = "" {
		DllCall("User32.dll\GetCursorPos", "Ptr", PT)
		if X = ""
			X := NumGet(PT, 0, "Int")
		if Y = ""
			Y := NumGet(PT, 4, "Int")
	}
	return DllCall("User32.dll\MonitorFromPoint", "Int64", (X & 0xFFFFFFFF) | (Y << 32), "UInt", 0)
}
; ======================================================================================================================
; Retrieves the display monitor that has the largest area of intersection with a specified rectangle.
; Parameters are consistent with the common AHK definition of a rectangle, which is X, Y, W, H instead of
; Left, Top, Right, Bottom.
; The following flag values determine the function's return value if the rectangle does not intersect any
; display monitor:
;    MONITOR_DEFAULTTONULL    = 0 - Returns NULL.
;    MONITOR_DEFAULTTOPRIMARY = 1 - Returns a handle to the primary display monitor.
;    MONITOR_DEFAULTTONEAREST = 2 - Returns a handle to the display monitor that is nearest to the rectangle.
; ======================================================================================================================
MDMF_FromRect(X, Y, W, H) {
	RC := Buffer(16, 0)
	NumPut("Int", X, RC, 0)
	NumPut('Int', Y, RC, 4)
	NumPut("Int", X + W, RC, 8)
	NumPut("Int", Y + H, RC, 12)
	Return DllCall("User32.dll\MonitorFromRect", "Ptr", RC, "UInt", 0)
}
; ======================================================================================================================
; Retrieves information about a display monitor.
; ======================================================================================================================
MDMF_GetInfo(HMON) {
	MIEX := Buffer(40 + (32 << 1))
	NumPut("UInt", MIEX.Size, MIEX, 0)
	If DllCall("User32.dll\GetMonitorInfo", "Ptr", HMON, "Ptr", MIEX)
		Return { Name: (Name := StrGet(MIEX.Ptr + 40, 32))  ; CCHDEVICENAME = 32
			, Num: RegExReplace(Name, ".*(\d+)$", "$1")
			, Left: NumGet(MIEX, 4, "Int")    ; display rectangle
			, Top: NumGet(MIEX, 8, "Int")    ; "
			, Right: NumGet(MIEX, 12, "Int")   ; "
			, Bottom: NumGet(MIEX, 16, "Int")   ; "
			, WALeft: NumGet(MIEX, 20, "Int")   ; work area
			, WATop: NumGet(MIEX, 24, "Int")   ; "
			, WARight: NumGet(MIEX, 28, "Int")   ; "
			, WABottom: NumGet(MIEX, 32, "Int")   ; "
			, Primary: NumGet(MIEX, 36, "UInt") } ; contains a non-zero value for the primary monitor.
	Return false
}