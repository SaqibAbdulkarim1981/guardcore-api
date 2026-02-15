# GuardCore Reports Module - Implementation Complete

## Date: February 14, 2026

## Overview
Successfully implemented comprehensive reporting functionality for the GuardCore Back-Office Engine with print capabilities.

## Features Implemented

### 1. Reports Menu Screen
- **Location**: `lib/screens/reports_menu_screen.dart`
- **Features**:
  - Modern gradient UI matching GuardCore design
  - Three report type cards:
    - Attendance Report (Green)
    - Activity Report (Blue)
    - Incident Report (Orange)
  - Hover effects and smooth animations
  - Easy navigation to specific report types

### 2. Attendance Report Screen
- **Location**: `lib/screens/attendance_report_screen.dart`
- **Features**:
  - **Guard Selection**: Dropdown populated with all guards from database
  - **Date Range Filters**: 
    - From Date picker
    - To Date picker
    - Default: Last 30 days
  - **Report Generation**: 
    - Fetches attendance data from cloud API
    - Processes check-in/check-out pairs
    - Calculates work hours automatically
  - **Data Display**:
    - Professional data table with columns:
      - S.No. (Serial Number)
      - Check In Date/Time (dd/MM/yyyy HH:mm format)
      - Check Out Date/Time (dd/MM/yyyy HH:mm format)
      - Hours Worked (X hrs Y mins)
    - Total Work Hours summary at bottom
  - **Print Functionality**:
    - PDF generation using `printing` package
    - Professional report layout
    - Report header with:
      - GuardCore branding
      - Guard name
      - Report period
      - Generation timestamp
    - Print preview dialog
    - Direct print or save to PDF

### 3. Backend API Enhancements
- **File Modified**: `SecurityGuardApi/Controllers/AttendanceController.cs`
- **Changes**:
  - Enhanced `GET /api/Attendance` endpoint
  - Enhanced `GET /api/Attendance/user/{userId}` endpoint
  - Both now return enriched data including:
    - User Name
    - Location Name
    - All original attendance fields
- **Benefit**: Frontend doesn't need to make multiple API calls

### 4. Flutter Models & Services
- **New Model**: `lib/models/attendance.dart`
  - `Attendance` class for raw API data
  - `AttendanceRecord` class for processed check-in/check-out pairs
  - Duration calculation methods
  - Formatted duration display
- **API Service Updates**: `lib/services/api_service.dart`
  - `fetchAllAttendance()` - Get all attendance records
  - `fetchUserAttendance(int userId)` - Get specific guard attendance

### 5. Dashboard Integration
- **File Modified**: `lib/screens/dashboard.dart`
- **Changes**:
  - Replaced "Incident Reports" tile with "Reports"
  - Updated icon to `Icons.assessment_outlined`
  - Routes to new reports menu (`/reports-menu`)

### 6. Routing Configuration
- **File Modified**: `lib/main.dart`
- **New Routes Added**:
  - `/reports-menu` → ReportsMenuScreen
  - `/attendance-report` → AttendanceReportScreen
  - `/activity-report` → ActivityReportScreen
  - `/incident-report` → IncidentReportScreen

### 7. Dependencies Added
- **File Modified**: `pubspec.yaml`
- **New Packages**:
  - `printing: ^5.12.0` - PDF preview and printing
  - `pdf: ^3.10.8` - PDF document generation
  - `intl: ^0.19.0` - Date/time formatting

## Technical Details

### Attendance Processing Logic
The system processes raw check-in/check-out records into meaningful work sessions:
1. Fetches all attendance records for selected guard
2. Filters by date range
3. Sorts chronologically
4. Pairs check-ins with following check-outs
5. Calculates duration for each session
6. Sums total work hours

### Date/Time Formatting
- Display Format: `dd/MM/yyyy HH:mm`
- Database Format: ISO 8601 (UTC timestamps)
- Automatic timezone handling

### Print Report Layout
- Page Format: A4
- Margins: 32 pixels all sides
- Header Section:
  - Title: "GuardCore Attendance Report"
  - Guard Name
  - Report Period
  - Generation Date/Time
- Table Section:
  - Bordered table with header row (grey background)
  - Data rows with alternating background (not implemented but can be added)
- Footer Section:
  - Total Work Hours in highlighted box

## API Endpoints Used

### Authentication
- `POST /api/Auth/login` - User authentication

### Users
- `GET /api/Users` - Fetch all guards for dropdown

### Attendance
- `GET /api/Attendance/user/{userId}` - Fetch guard attendance records

## User Workflow

1. **Access Reports**:
   - Login to back-office
   - Click "Reports" tile on dashboard

2. **Generate Attendance Report**:
   - Select "Attendance Report" from reports menu
   - Choose guard from dropdown
   - Select date range (From/To dates)
   - Click "Generate" button

3. **View Report**:
   - Report displays on screen
   - Review attendance data
   - Check total work hours

4. **Print Report**:
   - Click "Print Report" button at bottom
   - OR click print icon in app bar
   - Print preview opens
   - Choose printer or save as PDF
   - Confirm print

## Files Created/Modified

### New Files Created:
1. `lib/models/attendance.dart` - Attendance data models
2. `lib/screens/reports_menu_screen.dart` - Reports hub
3. `lib/screens/attendance_report_screen.dart` - Attendance report with print

### Modified Files:
1. `lib/services/api_service.dart` - Added attendance API methods
2. `lib/screens/dashboard.dart` - Updated menu tile
3. `lib/main.dart` - Added new routes
4. `pubspec.yaml` - Added printing packages
5. `SecurityGuardApi/Controllers/AttendanceController.cs` - Enhanced API responses

## Database Schema Used

### Attendance Table:
- `Id` (int) - Primary key
- `UserId` (int) - Foreign key to Users
- `LocationId` (int) - Foreign key to Locations
- `Type` (string) - "CheckIn" or "CheckOut"
- `Timestamp` (DateTime) - UTC timestamp
- `QRData` (string?) - Original QR code data

## Known Limitations & Future Enhancements

### Current Limitations:
1. Activity Report and Incident Report are placeholder screens (to be implemented)
2. No export to Excel functionality (only PDF)
3. No email report functionality
4. Date range limited to date pickers (no preset ranges like "Last Week", "Last Month")

### Suggested Future Enhancements:
1. Add Activity Report with patrol route compliance
2. Add Incident Report with filtering by severity
3. Add report scheduling (email daily/weekly reports)
4. Add export to Excel/CSV
5. Add graphical charts (bar charts for work hours per day)
6. Add comparison reports (compare multiple guards)
7. Add preset date ranges (Today, Yesterday, This Week, This Month)
8. Add report templates
9. Add custom report builder

## Testing Checklist

- [ ] Backend API deployed to Render successfully
- [ ] Can access reports menu from dashboard
- [ ] Guard dropdown populates with all guards
- [ ] Date pickers work correctly
- [ ] Generate button fetches attendance data
- [ ] Report displays correctly on screen
- [ ] Total work hours calculated correctly
- [ ] Print preview opens successfully
- [ ] PDF generates with correct formatting
- [ ] Can print to physical printer
- [ ] Can save report as PDF file

## Deployment Status

- ✅ Frontend code completed
- ✅ Backend API changes committed and pushed to GitHub
- ⏳ Render.com auto-deployment in progress
- ⏳ Windows application build in progress

## Next Steps

1. Complete Windows build
2. Test reporting functionality
3. Deploy/install updated Windows application
4. Implement Activity Report screen
5. Implement Incident Report screen
6. Test end-to-end with real attendance data

## Notes

- All code follows existing GuardCore design patterns
- UI matches existing color scheme and style
- API changes are backward compatible
- No database migrations required (uses existing tables)
- Cloud database (PostgreSQL on Render) already has attendance data structure

---

**Implementation completed by: GitHub Copilot**
**Date: February 14, 2026**
**Version: GuardCore v1.0.0.0**
