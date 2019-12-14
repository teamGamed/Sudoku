using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Runtime.InteropServices;

namespace Sudoku
{
    class Program
    {
        [DllImport("Project.dll")]
        private static extern int SumArr([In] int[] arr, int sz);
        static void Main(string[] args)
        {
            try
            {
                int[] x = { 1, 2, 3, 4 };
                Console.Write(SumArr(x, x.Length));
                Console.WriteLine();
            }
            catch (Exception e)
            {
                e.GetType();
            }
        }
    }
}
