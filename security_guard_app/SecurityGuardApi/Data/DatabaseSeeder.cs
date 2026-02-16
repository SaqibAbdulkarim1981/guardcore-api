using Microsoft.EntityFrameworkCore;
using SecurityGuardApi.Data;
using SecurityGuardApi.Models;

namespace SecurityGuardApi
{
    public static class DatabaseSeeder
    {
        public static void SeedDatabase(AppDbContext context)
        {
            // Don't call EnsureCreated - it conflicts with migrations
            // Just check if seeding is needed
            
            // Check if admin user already exists
            if (context.Users.Any(u => u.Email == "admin@example.com"))
            {
                Console.WriteLine("✅ Database already seeded. Skipping...");
                return;
            }

            Console.WriteLine("🌱 Seeding database with test data (PostgreSQL)...");

            // Create Admin User
            var adminUser = new User
            {
                Name = "Admin User",
                Email = "admin@example.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("admin123"),
                IsBlocked = false,
                ExpiryDate = DateTime.UtcNow.AddYears(10),
                CreatedAt = DateTime.UtcNow
            };
            context.Users.Add(adminUser);

            // Create Test Guard User
            var guardUser = new User
            {
                Name = "Test Guard",
                Email = "guard@test.com",
                PasswordHash = BCrypt.Net.BCrypt.HashPassword("guard123"),
                IsBlocked = false,
                ExpiryDate = DateTime.UtcNow.AddDays(30),
                CreatedAt = DateTime.UtcNow
            };
            context.Users.Add(guardUser);

            // Create Test Locations
            var location1 = new Location
            {
                Name = "Main Entrance",
                Description = "Building main entrance gate",
                CreatedAt = DateTime.UtcNow
            };
            context.Locations.Add(location1);

            var location2 = new Location
            {
                Name = "Parking Lot",
                Description = "Employee parking area",
                CreatedAt = DateTime.UtcNow
            };
            context.Locations.Add(location2);

            var location3 = new Location
            {
                Name = "Rooftop Access",
                Description = "Rooftop door checkpoint",
                CreatedAt = DateTime.UtcNow
            };
            context.Locations.Add(location3);

            context.SaveChanges();

            // Create Sample Reports (Incident and Activity)
            var report1 = new Report
            {
                UserId = guardUser.Id,
                LocationId = location1.Id,
                Type = "Incident",
                Description = "Suspicious person attempting to enter restricted area without proper identification. Person was escorted out and details recorded.",
                CreatedAt = DateTime.UtcNow.AddDays(-2)
            };
            context.Reports.Add(report1);

            var report2 = new Report
            {
                UserId = guardUser.Id,
                LocationId = location2.Id,
                Type = "Activity",
                Description = "Routine patrol completed. All parking lot lights functional. No security concerns observed.",
                CreatedAt = DateTime.UtcNow.AddDays(-1)
            };
            context.Reports.Add(report2);

            var report3 = new Report
            {
                UserId = guardUser.Id,
                LocationId = location3.Id,
                Type = "Incident",
                Description = "Unauthorized access attempt to rooftop door. Alarm triggered at 02:45 AM. Police notified and responded within 10 minutes.",
                CreatedAt = DateTime.UtcNow.AddHours(-12)
            };
            context.Reports.Add(report3);

            var report4 = new Report
            {
                UserId = guardUser.Id,
                LocationId = location1.Id,
                Type = "Activity",
                Description = "Equipment inspection performed. Fire extinguisher pressure checked and within normal range. Emergency lighting tested successfully.",
                CreatedAt = DateTime.UtcNow.AddHours(-6)
            };
            context.Reports.Add(report4);

            var report5 = new Report
            {
                UserId = guardUser.Id,
                LocationId = location2.Id,
                Type = "Incident",
                Description = "Vehicle break-in reported in parking lot section B. CCTV footage reviewed. License plate recorded: ABC-1234. Police report filed.",
                CreatedAt = DateTime.UtcNow.AddHours(-3)
            };
            context.Reports.Add(report5);

            context.SaveChanges();

            Console.WriteLine("✅ Database seeded successfully!");
            Console.WriteLine("");
            Console.WriteLine("========================================");
            Console.WriteLine("TEST CREDENTIALS");
            Console.WriteLine("========================================");
            Console.WriteLine("");
            Console.WriteLine("👤 ADMIN ACCOUNT (Back-Office App):");
            Console.WriteLine("   Email:    admin@example.com");
            Console.WriteLine("   Password: admin123");
            Console.WriteLine("");
            Console.WriteLine("👤 GUARD ACCOUNT (Mobile App):");
            Console.WriteLine("   Email:    guard@test.com");
            Console.WriteLine("   Password: guard123");
            Console.WriteLine("");
            Console.WriteLine("📍 LOCATIONS CREATED:");
            Console.WriteLine("   • Main Entrance (ID: 1)");
            Console.WriteLine("   • Parking Lot (ID: 2)");
            Console.WriteLine("   • Rooftop Access (ID: 3)");
            Console.WriteLine("");
            Console.WriteLine("📋 REPORTS CREATED:");
            Console.WriteLine("   • 3 Incident Reports");
            Console.WriteLine("   • 2 Activity Reports");
            Console.WriteLine("");
            Console.WriteLine("========================================");
            Console.WriteLine("");
        }
    }
}
