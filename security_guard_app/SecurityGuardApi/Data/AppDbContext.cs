using Microsoft.EntityFrameworkCore;
using SecurityGuardApi.Models;

namespace SecurityGuardApi.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> opts) : base(opts) { }

        public DbSet<User> Users => Set<User>();
        public DbSet<Location> Locations => Set<Location>();
        public DbSet<Report> Reports => Set<Report>();
        public DbSet<Attendance> Attendances => Set<Attendance>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // Configure Identity columns for PostgreSQL
            modelBuilder.Entity<User>()
                .Property(u => u.Id)
                .ValueGeneratedOnAdd();
            
            modelBuilder.Entity<Location>()
                .Property(l => l.Id)
                .ValueGeneratedOnAdd();
            
            modelBuilder.Entity<Report>()
                .Property(r => r.Id)
                .ValueGeneratedOnAdd();
            
            modelBuilder.Entity<Attendance>()
                .Property(a => a.Id)
                .ValueGeneratedOnAdd();
        }
    }
}
