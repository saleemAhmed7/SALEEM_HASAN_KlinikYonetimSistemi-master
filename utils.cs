using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Security.Cryptography;
using System.Data.SqlClient;

namespace Clinic_Management_System
{
    public class utils
    {
        public static string hashPassword(string password)
        {
            SHA1CryptoServiceProvider sha1 = new SHA1CryptoServiceProvider();

            byte[] password_bytes = Encoding.ASCII.GetBytes(password);
            byte[] encrypted_bytes = sha1.ComputeHash(password_bytes);
            return Convert.ToBase64String(encrypted_bytes);
        }

        public static Dictionary<int, string> getSlots()
        {
            Dictionary<int, string> slots = new Dictionary<int, string>();
            slots.Add(1, "Slot 1: 18:00 - 18:30 arası");
            slots.Add(2, "Slot 2: 18:30'dan 19:00'a kadar");
            slots.Add(3, "Slot 3: 19:00'dan 19:30'a kadar");
            slots.Add(4, "Slot 4: 19:30 - 20:00 arası");
            slots.Add(5, "Slot 5: 20:00 - 20:30 arası");
            slots.Add(6, "Slot 6: 20:30 - 21:00 arası");
            slots.Add(7, "Slot 7: 21.00'den 21.30'a kadar");
            slots.Add(8, "Slot 8: 21.30'dan 22.00'ye kadar");
            slots.Add(9, "Slot 9: 22:00 - 22:30 arası");
            slots.Add(10, "Slot 10: 22:30 - 23:00 arası");
            return slots;
        }

        public static void createAdmin(string password)
        {
            SqlConnection con = new SqlConnection(Properties.Resources.connectionString);
            SqlCommand command = con.CreateCommand();

            command.CommandText = "INSERT INTO [user] (user_username, user_password) VALUES (@username, @password)";
            command.Parameters.AddWithValue("@username", "admin");
            command.Parameters.AddWithValue("@password", hashPassword(password));

            con.Open();

            try
            {
                command.ExecuteNonQuery();
            }
            catch(Exception)
            {

            }

            con.Close();
        }
    }
}
