using Microsoft.AspNetCore.Mvc;
using ClubManagement.Data;
using ClubManagement.Models;
using Dapper;

namespace ClubManagement.Controllers
{
    public class ActivityLogController : Controller
    {
        private readonly DbContext _dbContext;
        private const int PageSize = 15;

        public ActivityLogController(DbContext dbContext)
        {
            _dbContext = dbContext;
        }

        public async Task<IActionResult> Index(string? actionFilter, string? tableName, string? site, string? fromDate, string? toDate, int page = 1)
        {
            using var conn = _dbContext.GetConnection();

            // Build WHERE clause
            var conditions = new List<string>();
            var parameters = new DynamicParameters();

            if (!string.IsNullOrEmpty(actionFilter))
            {
                conditions.Add("Action = @ActionFilter");
                parameters.Add("ActionFilter", actionFilter);
            }

            if (!string.IsNullOrEmpty(tableName))
            {
                conditions.Add("TableName = @TableName");
                parameters.Add("TableName", tableName);
            }

            if (!string.IsNullOrEmpty(site))
            {
                conditions.Add("Site = @Site");
                parameters.Add("Site", site);
            }

            if (!string.IsNullOrEmpty(fromDate) && DateTime.TryParse(fromDate, out var from))
            {
                conditions.Add("Timestamp >= @FromDate");
                parameters.Add("FromDate", from);
            }

            if (!string.IsNullOrEmpty(toDate) && DateTime.TryParse(toDate, out var to))
            {
                conditions.Add("Timestamp < @ToDate");
                parameters.Add("ToDate", to.AddDays(1));
            }

            var whereClause = conditions.Count > 0 ? "WHERE " + string.Join(" AND ", conditions) : "";

            // Count total
            var countSql = $"SELECT COUNT(*) FROM vw_ActivityLog {whereClause}";
            var totalRecords = await conn.ExecuteScalarAsync<int>(countSql, parameters);

            // Pagination
            var totalPages = totalRecords > 0 ? (int)Math.Ceiling(totalRecords / (double)PageSize) : 1;
            page = Math.Max(1, Math.Min(page, totalPages));
            var offset = (page - 1) * PageSize;

            // Get data - Sắp xếp theo LogId DESC để hiển thị tuần tự
            var dataSql = $@"SELECT LogId, Action, TableName, RecordId, Site, Username, Timestamp, Details 
                             FROM vw_ActivityLog {whereClause} 
                             ORDER BY LogId DESC 
                             OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY";
            parameters.Add("Offset", offset);
            parameters.Add("PageSize", PageSize);

            var logs = await conn.QueryAsync<ActivityLog>(dataSql, parameters);

            // Pass to view
            ViewBag.ActionFilter = actionFilter;
            ViewBag.TableName = tableName;
            ViewBag.Site = site;
            ViewBag.FromDate = fromDate;
            ViewBag.ToDate = toDate;
            ViewBag.CurrentPage = page;
            ViewBag.TotalPages = totalPages;
            ViewBag.TotalRecords = totalRecords;
            ViewBag.PageSize = PageSize;

            return View(logs);
        }
    }
}
