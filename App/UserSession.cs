using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace QLSieuThi
{
    public static class UserSession
    {
        private static int guestID = -1;

        public static int EmployeeId { get; set; } = guestID;
        public static string FullName { get; set; }
        public static string Username { get; set; }
        public static string RoleName { get; set; }
        public static string Phone { get; set; }

        public static string Email { get; set; }
        public static string Address { get; set; }

        public static DateTime LoginTime { get; set; }

        public static bool IsLoggedIn => EmployeeId != guestID;

        public static void Clear()
        {
            EmployeeId = guestID;
            FullName = null;
            Username = null;
            RoleName = null;
            Phone = null;
            Email = null;
            Address = null;
        }
    }
}
