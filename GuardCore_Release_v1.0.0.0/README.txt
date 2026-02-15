================================================================================
    GuardCore Back-Office Engine v1.0.0.0
    Windows Release Package
    Build Date: February 14, 2026
================================================================================

SYSTEM REQUIREMENTS:
-------------------
- Windows 10 or higher (64-bit)
- Minimum 4GB RAM
- Internet connection (for cloud database access)
- 100MB free disk space

WHAT'S NEW IN THIS VERSION:
---------------------------
✓ Reports Center with printing functionality
✓ Attendance Report - View and print guard attendance records
✓ Activity Report - Review guard activity logs
✓ Incident Report - View and manage incident reports
✓ Guard Management - Create, edit, and manage security guards
✓ Patrol Points - Configure QR code checkpoint locations
✓ Cloud Database - PostgreSQL on Render.com (always up-to-date)

INSTALLATION INSTRUCTIONS:
-------------------------
1. Extract all files from this folder to a location of your choice
   (e.g., C:\Program Files\GuardCore\)

2. Keep ALL files together in the same folder:
   - security_guard_app.exe (Main application)
   - flutter_windows.dll (Flutter framework)
   - pdfium.dll (PDF generation support)
   - printing_plugin.dll (Print functionality)
   - All other .dll files (Required plugins)
   - data folder (Application assets and configuration)
   - Output folder (Application output files)

3. Double-click security_guard_app.exe to launch the application

4. Login with admin credentials:
   Email: admin@example.com
   Password: admin123

IMPORTANT NOTES:
---------------
→ DO NOT delete the "data" folder - it contains essential app assets
→ DO NOT separate the .exe from the .dll files - they must stay together
→ The application connects to cloud database automatically
→ No local database setup required
→ All data is stored securely in PostgreSQL cloud database

FEATURES GUIDE:
--------------
1. GUARD MANAGEMENT
   - Create new guard accounts
   - Set active days and expiry dates
   - Block/unblock guard access
   - View all guard information

2. PATROL POINTS
   - Create checkpoint locations
   - Generate QR codes for each location
   - Print QR codes for physical placement

3. REPORTS CENTER
   → Attendance Report:
     * Select guard from dropdown
     * Choose date range (From/To dates)
     * View attendance records on screen
     * Print professional PDF report
     * Displays check-in/out times and total work hours
   
   → Activity Report:
     * Coming soon - Guard patrol activity logs
   
   → Incident Report:
     * Coming soon - Incident management and reporting

4. SYSTEM SETTINGS
   - Configure application preferences
   - Manage system parameters

PRINTING REPORTS:
----------------
1. Navigate to Reports Center from dashboard
2. Select "Attendance Report"
3. Choose guard from dropdown list
4. Select date range (default: last 30 days)
5. Click "Generate" to view report
6. Review the report on screen:
   - Serial Number
   - Check In Date/Time
   - Check Out Date/Time
   - Hours Worked
   - Total Work Hours
7. Click "Print Report" button
8. Choose printer or save as PDF
9. Confirm print

CLOUD CONNECTION:
----------------
API Endpoint: https://guardcore-api.onrender.com/api
Database: PostgreSQL on Render.com (Free Tier)
Authentication: JWT Token (7-day expiry)

TROUBLESHOOTING:
---------------
Problem: Application won't start
Solution: Make sure all DLL files are present in the same folder

Problem: "Failed to connect" error
Solution: Check your internet connection and firewall settings

Problem: Login failed
Solution: Verify credentials or contact administrator

Problem: Print preview not showing
Solution: Ensure pdfium.dll and printing_plugin.dll are present

Problem: Missing Flutter assets
Solution: Ensure the "data" folder exists in same directory

SYSTEM ARCHITECTURE:
-------------------
- Frontend: Flutter Desktop (Windows)
- Backend: ASP.NET Core 8.0 Web API
- Database: PostgreSQL 15
- Hosting: Render.com (Cloud)
- Authentication: JWT Tokens
- Security: BCrypt password hashing

FILE STRUCTURE:
--------------
GuardCore_Release_v1.0.0.0/
├── security_guard_app.exe          (Main Application - 13.57 MB)
├── flutter_windows.dll             (Flutter Framework - 17.65 MB)
├── pdfium.dll                      (PDF Engine - 4.53 MB)
├── printing_plugin.dll             (Print Support - 0.14 MB)
├── screen_retriever_plugin.dll     (Screen Info - 0.1 MB)
├── url_launcher_windows_plugin.dll (URL Support - 0.1 MB)
├── window_manager_plugin.dll       (Window Management - 0.14 MB)
├── cloud_firestore_plugin.lib      (Firebase Firestore - 3.74 MB)
├── firebase_auth_plugin.lib        (Firebase Auth - 4.18 MB)
├── firebase_core_plugin.lib        (Firebase Core - 0.93 MB)
├── data/                           (App Assets & Config)
│   ├── flutter_assets/
│   ├── icudtl.dat
│   └── ... (additional resources)
├── Output/                         (Application Output)
└── README.txt                      (This file)

Total Package Size: 60.38 MB

SUPPORT INFORMATION:
-------------------
Version: 1.0.0.0
Build Date: February 14, 2026, 9:30 PM
Build Type: Release (Optimized)

For technical support or issues:
- Review this README file
- Check REPORTS_IMPLEMENTATION.md for detailed feature documentation
- Ensure cloud API is accessible at guardcore-api.onrender.com

DEFAULT CREDENTIALS:
-------------------
Admin Account:
  Email: admin@example.com
  Password: admin123

Guard Test Account:
  Email: guard@test.com
  Password: guard123

SECURITY NOTES:
--------------
⚠ Change default passwords after first login
⚠ Keep your credentials secure
⚠ All data transmissions are encrypted (HTTPS)
⚠ JWT tokens expire after 7 days (automatic re-login required)

LICENSE:
-------
GuardCore Back-Office Engine
© 2026 All Rights Reserved

================================================================================
         Thank you for using GuardCore Back-Office Engine!
================================================================================
