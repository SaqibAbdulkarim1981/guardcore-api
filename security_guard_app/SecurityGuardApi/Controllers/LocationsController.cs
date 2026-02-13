using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using QRCoder;
using SecurityGuardApi.Data;
using SecurityGuardApi.Models;

namespace SecurityGuardApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class LocationsController : ControllerBase
    {
        private readonly AppDbContext _db;
        public LocationsController(AppDbContext db) { _db = db; }

        [HttpPost]
        public async Task<IActionResult> Create([FromBody] Location loc)
        {
            _db.Locations.Add(loc);
            await _db.SaveChangesAsync();
            return CreatedAtAction(nameof(GetById), new { id = loc.Id }, loc);
        }

        [HttpGet]
        public async Task<IActionResult> List()
        {
            var list = await _db.Locations.OrderByDescending(l => l.CreatedAt).ToListAsync();
            return Ok(list);
        }

        [HttpGet("{id:int}")]
        public async Task<IActionResult> GetById(int id)
        {
            var loc = await _db.Locations.FindAsync(id);
            if (loc == null) return NotFound();
            return Ok(loc);
        }

        [HttpGet("{id:int}/qrcode")]
        public async Task<IActionResult> GetQr(int id)
        {
            var loc = await _db.Locations.FindAsync(id);
            if (loc == null) return NotFound();

            using var qrGen = new QRCodeGenerator();
            using var data = qrGen.CreateQrCode($"location:{loc.Id}:{loc.Name}", QRCodeGenerator.ECCLevel.Q);
            using var qr = new PngByteQRCode(data);
            var bytes = qr.GetGraphic(20);
            return File(bytes, "image/png");
        }
    }
}
