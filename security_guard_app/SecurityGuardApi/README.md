# SecurityGuardApi

Minimal ASP.NET Core Web API for the Security Guard app.

Quick start:
1. Install .NET 8 SDK.
2. Create the project folder and paste files.
3. From project root run:
   ```bash
   dotnet restore
   dotnet tool install --global dotnet-ef
   dotnet ef migrations add Init
   dotnet ef database update
   dotnet run
   ```
4. Open https://localhost:5001/swagger for API docs.

Default admin credentials come from `appsettings.json` (`Admin:Email` / `Admin:Password`). Change `Jwt:Key` before production.
