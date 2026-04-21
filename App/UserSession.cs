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

        public static int EmployeeId { get; set; }
        public static string FullName { get; set; }
        public static string RoleName { get; set; }

        public static bool IsLoggedIn => EmployeeId != guestID;

        public static void Clear()
        {
            EmployeeId = guestID;
            FullName = null;
            RoleName = null;
        }
    }
}
