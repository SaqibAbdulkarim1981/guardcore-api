using Microsoft.EntityFrameworkCore;
using SecurityGuardApi.Data;
using SecurityGuardApi.Models;

namespace SecurityGuardApi
{
    public static class DatabaseSeeder
    {
        public static void SeedDatabase(AppDbContext context)
        {
            // Ensure database is created
            context.Database.EnsureCreated();

            // Check if admin user already exists
            if (context.Users.Any(u => u.Email == "admin@example.com"))
            {
                Console.WriteLine("✅ Database already seeded. Skipping...");
                return;
            }

            Console.WriteLine("🌱 Seeding database with test data...");

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
            Console.WriteLine("========================================");
            Console.WriteLine("");
        }
    }
}
