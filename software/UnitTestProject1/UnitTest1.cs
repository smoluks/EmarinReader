using Microsoft.VisualStudio.TestTools.UnitTesting;
using RFIDReader.Entity;
using System;

namespace UnitTestProject1
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod1()
        {
            var data = new byte[] { 0x01, 0x23, 0x45, 0x67, 0x89, 0xAB, 0xCD, 0xEF };

            var key = new Emarin(data);

            var newData = key.ToByteArray();

            Assert.IsTrue(CompareArray(data, newData));
        }

        private bool CompareArray(byte[] data, byte[] newData)
        {
            if (data.Length != newData.Length)
                return false;

            for(int i = 0; i < data.Length; i++)
            {
                if (data[i] != newData[i])
                    return false;
            }

            return true;
        }
    }
}
